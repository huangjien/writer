import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/writing_goal.dart';

class WritingGoalsService {
  static const String _goalsKey = 'writing_goals';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';

  SharedPreferences? _prefs;
  List<WritingGoal> _cachedGoals = [];

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<WritingGoal>> getGoals() async {
    if (_cachedGoals.isNotEmpty) {
      return List.from(_cachedGoals);
    }

    final prefs = await _preferences;
    final goalsJson = prefs.getString(_goalsKey);

    if (goalsJson == null) {
      return [];
    }

    try {
      final goalsList = _decodeGoalsList(goalsJson);
      _cachedGoals = goalsList;
      return List.from(goalsList);
    } catch (e) {
      return [];
    }
  }

  Future<WritingGoal?> getGoalById(String id) async {
    final goals = await getGoals();
    try {
      return goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<WritingGoal> createGoal({
    required GoalType type,
    required int targetWordCount,
    DateTime? endDate,
  }) async {
    final goal = WritingGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      targetWordCount: targetWordCount,
      startDate: DateTime.now(),
      endDate: endDate,
    );

    final goals = await getGoals();
    _cachedGoals = [...goals, goal];
    await _saveGoals(_cachedGoals);

    return goal;
  }

  Future<WritingGoal> updateGoal(
    String id, {
    GoalType? type,
    int? targetWordCount,
    DateTime? endDate,
  }) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == id);

    if (index == -1) {
      throw Exception('Goal not found');
    }

    final updatedGoal = goals[index].copyWith(
      type: type,
      targetWordCount: targetWordCount,
      endDate: endDate,
    );

    _cachedGoals = [...goals];
    _cachedGoals[index] = updatedGoal;
    await _saveGoals(_cachedGoals);

    return updatedGoal;
  }

  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    _cachedGoals = goals.where((goal) => goal.id != id).toList();
    await _saveGoals(_cachedGoals);
  }

  Future<DailyProgress> addDailyProgress({
    required String goalId,
    required int wordsWritten,
    int writingTimeMinutes = 0,
  }) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);

    if (index == -1) {
      throw Exception('Goal not found');
    }

    final goal = goals[index];
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final existingProgressIndex = goal.dailyProgress.indexWhere(
      (p) => DateTime(p.date.year, p.date.month, p.date.day) == normalizedToday,
    );

    DailyProgress newProgress;
    List<DailyProgress> updatedProgress;

    if (existingProgressIndex != -1) {
      newProgress = goal.dailyProgress[existingProgressIndex].copyWith(
        wordsWritten:
            goal.dailyProgress[existingProgressIndex].wordsWritten +
            wordsWritten,
        writingTimeMinutes:
            goal.dailyProgress[existingProgressIndex].writingTimeMinutes +
            writingTimeMinutes,
        goalAchieved:
            (goal.dailyProgress[existingProgressIndex].wordsWritten +
                wordsWritten) >=
            goal.targetWordCount,
      );
      updatedProgress = [...goal.dailyProgress];
      updatedProgress[existingProgressIndex] = newProgress;
    } else {
      final goalAchieved = wordsWritten >= goal.targetWordCount;
      newProgress = DailyProgress(
        date: normalizedToday,
        wordsWritten: wordsWritten,
        writingTimeMinutes: writingTimeMinutes,
        goalAchieved: goalAchieved,
      );
      updatedProgress = [...goal.dailyProgress, newProgress];
    }

    final updatedGoal = goal.copyWith(dailyProgress: updatedProgress);
    _cachedGoals = [...goals];
    _cachedGoals[index] = updatedGoal;
    await _saveGoals(_cachedGoals);

    await _updateStreakIfNeeded(updatedGoal, newProgress);

    return newProgress;
  }

  Future<int> getCurrentStreak() async {
    final prefs = await _preferences;
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  Future<int> getLongestStreak() async {
    final prefs = await _preferences;
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  Future<void> _updateStreakIfNeeded(
    WritingGoal goal,
    DailyProgress progress,
  ) async {
    if (!progress.goalAchieved) {
      return;
    }

    final goals = await getGoals();
    final allGoalsAchievedToday = goals.every((g) {
      if (g.dailyProgress.isEmpty) return true;
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final todayProgress = g.dailyProgress.firstWhere(
        (p) =>
            DateTime(p.date.year, p.date.month, p.date.day) == normalizedToday,
        orElse: () => DailyProgress(date: normalizedToday),
      );
      return todayProgress.goalAchieved;
    });

    if (allGoalsAchievedToday) {
      final currentStreak = await getCurrentStreak();
      final newStreak = currentStreak + 1;
      final longestStreak = await getLongestStreak();

      final prefs = await _preferences;
      await prefs.setInt(_currentStreakKey, newStreak);

      if (newStreak > longestStreak) {
        await prefs.setInt(_longestStreakKey, newStreak);
      }
    }
  }

  Future<void> resetStreak() async {
    final prefs = await _preferences;
    await prefs.setInt(_currentStreakKey, 0);
  }

  Future<List<DailyProgress>> getRecentProgress({int days = 7}) async {
    final goals = await getGoals();
    final allProgress = <DailyProgress>[];

    for (final goal in goals) {
      allProgress.addAll(goal.dailyProgress);
    }

    allProgress.sort((a, b) => b.date.compareTo(a.date));

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return allProgress.where((p) => p.isAfter(cutoffDate)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final goals = await getGoals();
    final currentStreak = await getCurrentStreak();
    final longestStreak = await getLongestStreak();

    int totalWordsWritten = 0;
    int totalWritingTimeMinutes = 0;
    int activeGoals = 0;
    int achievedGoals = 0;

    for (final goal in goals) {
      totalWordsWritten += goal.currentProgress;

      for (final progress in goal.dailyProgress) {
        totalWritingTimeMinutes += progress.writingTimeMinutes;
      }

      if (goal.endDate == null || goal.endDate!.isAfter(DateTime.now())) {
        activeGoals++;
      }

      if (goal.isGoalAchieved) {
        achievedGoals++;
      }
    }

    final averageWordsPerMinute = totalWritingTimeMinutes > 0
        ? totalWordsWritten / totalWritingTimeMinutes
        : 0.0;

    return {
      'total_words_written': totalWordsWritten,
      'total_writing_time_minutes': totalWritingTimeMinutes,
      'average_words_per_minute': averageWordsPerMinute,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'active_goals': activeGoals,
      'achieved_goals': achievedGoals,
      'total_goals': goals.length,
    };
  }

  Future<void> _saveGoals(List<WritingGoal> goals) async {
    final prefs = await _preferences;
    final goalsJson = _encodeGoalsList(goals);
    await prefs.setString(_goalsKey, goalsJson);
  }

  String _encodeGoalsList(List<WritingGoal> goals) {
    final goalsMap = goals.map((goal) => goal.toMap()).toList();
    return jsonEncode(goalsMap);
  }

  List<WritingGoal> _decodeGoalsList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => WritingGoal.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  void clearCache() {
    _cachedGoals = [];
  }
}

extension on DailyProgress {
  bool isAfter(DateTime date) {
    return this.date.isAfter(date);
  }
}
