import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/writing_progress.dart';
import 'package:writer/features/writing_goals/services/writing_goals_service.dart';

class ProgressAnalyticsService {
  static const String _achievementsKey = 'achievements';

  SharedPreferences? _prefs;
  List<Achievement> _cachedAchievements = [];
  final WritingGoalsService _goalsService;

  ProgressAnalyticsService({WritingGoalsService? goalsService})
    : _goalsService = goalsService ?? WritingGoalsService();

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<WritingStats> calculateStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final periodStart =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final periodEnd = endDate ?? DateTime.now();

    final progressData = await _getProgressDataForPeriod(
      periodStart,
      periodEnd,
    );

    if (progressData.isEmpty) {
      return WritingStats(
        totalWords: 0,
        totalTimeMinutes: 0,
        totalSessions: 0,
        averageWordsPerDay: 0,
        averageWordsPerSession: 0,
        currentStreak: await _goalsService.getCurrentStreak(),
        longestStreak: await _goalsService.getLongestStreak(),
        totalDays: 0,
        productiveDays: 0,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    }

    final totalWords = progressData.fold(0, (sum, p) => sum + p.wordsWritten);
    final totalTimeMinutes = progressData.fold(
      0,
      (sum, p) => sum + p.writingTimeMinutes,
    );
    final totalSessions = progressData.fold(
      0,
      (sum, p) => sum + p.sessionCount,
    );
    final productiveDays = progressData.where((p) => p.isProductive).length;

    final totalDays = periodEnd.difference(periodStart).inDays + 1;
    final averageWordsPerDay = totalWords / totalDays;
    final averageWordsPerSession = totalSessions > 0
        ? totalWords / totalSessions
        : 0.0;

    final mostProductiveEntry = progressData.reduce(
      (a, b) => a.wordsWritten > b.wordsWritten ? a : b,
    );

    final currentStreak = await _goalsService.getCurrentStreak();
    final longestStreak = await _goalsService.getLongestStreak();

    return WritingStats(
      totalWords: totalWords,
      totalTimeMinutes: totalTimeMinutes,
      totalSessions: totalSessions,
      averageWordsPerDay: averageWordsPerDay,
      averageWordsPerSession: averageWordsPerSession,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalDays: totalDays,
      productiveDays: productiveDays,
      mostProductiveDay: mostProductiveEntry.date,
      mostProductiveDayWordCount: mostProductiveEntry.wordsWritten,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Future<List<WritingProgress>> _getProgressDataForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final goals = await _goalsService.getGoals();
    final progressMap = <DateTime, WritingProgress>{};

    for (final goal in goals) {
      for (final dailyProgress in goal.dailyProgress) {
        final normalizedDate = DateTime(
          dailyProgress.date.year,
          dailyProgress.date.month,
          dailyProgress.date.day,
        );

        if (normalizedDate.isAfter(start.subtract(const Duration(days: 1))) &&
            normalizedDate.isBefore(end.add(const Duration(days: 1)))) {
          if (progressMap.containsKey(normalizedDate)) {
            final existing = progressMap[normalizedDate]!;
            progressMap[normalizedDate] = existing.copyWith(
              wordsWritten: existing.wordsWritten + dailyProgress.wordsWritten,
              writingTimeMinutes:
                  existing.writingTimeMinutes +
                  dailyProgress.writingTimeMinutes,
              sessionCount: existing.sessionCount + 1,
              goalIdsContributed: [...existing.goalIdsContributed, goal.id],
            );
          } else {
            progressMap[normalizedDate] = WritingProgress(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              date: normalizedDate,
              wordsWritten: dailyProgress.wordsWritten,
              writingTimeMinutes: dailyProgress.writingTimeMinutes,
              sessionCount: 1,
              goalIdsContributed: [goal.id],
            );
          }
        }
      }
    }

    final sortedList = progressMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedList;
  }

  Future<List<WritingProgress>> getWritingTrend({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    return _getProgressDataForPeriod(startDate, endDate);
  }

  Future<Map<DateTime, int>> getWeeklyWordCounts({int weeks = 4}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: weeks * 7));

    final progressData = await _getProgressDataForPeriod(startDate, endDate);
    final weeklyMap = <DateTime, int>{};

    for (final progress in progressData) {
      final weekStart = _getWeekStart(progress.date);
      weeklyMap[weekStart] =
          (weeklyMap[weekStart] ?? 0) + progress.wordsWritten;
    }

    return weeklyMap;
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final mondayOffset = dayOfWeek - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: mondayOffset));
  }

  Future<Map<String, dynamic>> getProductivityPatterns() async {
    final progressData = await getWritingTrend(days: 30);

    final hourlyMap = <int, int>{};
    final dayOfWeekMap = <int, int>{};

    for (final progress in progressData) {
      final hour = progress.date.hour;
      final dayOfWeek = progress.date.weekday;

      hourlyMap[hour] = (hourlyMap[hour] ?? 0) + progress.wordsWritten;
      dayOfWeekMap[dayOfWeek] =
          (dayOfWeekMap[dayOfWeek] ?? 0) + progress.wordsWritten;
    }

    String? bestHour;
    int maxHourWords = 0;
    hourlyMap.forEach((hour, words) {
      if (words > maxHourWords) {
        maxHourWords = words;
        bestHour = _formatHour(hour);
      }
    });

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    String? bestDay;
    int maxDayWords = 0;
    dayOfWeekMap.forEach((day, words) {
      if (words > maxDayWords) {
        maxDayWords = words;
        bestDay = dayNames[day - 1];
      }
    });

    return {
      'best_hour': bestHour ?? 'Not enough data',
      'best_hour_words': maxHourWords,
      'best_day': bestDay ?? 'Not enough data',
      'best_day_words': maxDayWords,
      'total_days_analyzed': progressData.length,
    };
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }

  Future<List<Achievement>> getAchievements() async {
    if (_cachedAchievements.isNotEmpty) {
      return List.from(_cachedAchievements);
    }

    final prefs = await _preferences;
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson == null) {
      return _initializeDefaultAchievements();
    }

    try {
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      final achievements = decoded
          .map((item) => Achievement.fromMap(item as Map<String, dynamic>))
          .toList();
      _cachedAchievements = achievements;
      return List.from(achievements);
    } catch (e) {
      return _initializeDefaultAchievements();
    }
  }

  Future<List<Achievement>> _initializeDefaultAchievements() async {
    final defaultAchievements = [
      Achievement(
        id: 'first_words',
        title: 'First Words',
        description: 'Write your first 100 words',
        type: AchievementType.wordCount,
        progress: 0,
        target: 100,
      ),
      Achievement(
        id: 'thousand_words',
        title: 'Word Warrior',
        description: 'Write 1,000 words in a single day',
        type: AchievementType.wordCount,
        progress: 0,
        target: 1000,
      ),
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Write every day for a week',
        type: AchievementType.streak,
        progress: 0,
        target: 7,
      ),
      Achievement(
        id: 'month_streak',
        title: 'Monthly Master',
        description: 'Write every day for a month',
        type: AchievementType.streak,
        progress: 0,
        target: 30,
      ),
      Achievement(
        id: 'ten_k_words',
        title: '10K Club',
        description: 'Write 10,000 total words',
        type: AchievementType.wordCount,
        progress: 0,
        target: 10000,
      ),
      Achievement(
        id: 'consistent_writer',
        title: 'Consistent Writer',
        description: 'Write for 7 days in a row',
        type: AchievementType.consistency,
        progress: 0,
        target: 7,
      ),
    ];

    await _saveAchievements(defaultAchievements);
    _cachedAchievements = defaultAchievements;
    return List.from(defaultAchievements);
  }

  Future<void> updateAchievementProgress() async {
    final stats = await calculateStats();
    final achievements = await getAchievements();

    for (final achievement in achievements) {
      if (achievement.isUnlocked) continue;

      Achievement? updated;
      switch (achievement.id) {
        case 'first_words':
          updated = achievement.copyWith(
            progress: stats.totalWords,
            unlockedAt: stats.totalWords >= 100 ? DateTime.now() : null,
          );
        case 'thousand_words':
          updated = achievement.copyWith(
            progress: stats.mostProductiveDayWordCount ?? 0,
            unlockedAt: (stats.mostProductiveDayWordCount ?? 0) >= 1000
                ? DateTime.now()
                : null,
          );
        case 'week_streak':
        case 'month_streak':
        case 'consistent_writer':
          updated = achievement.copyWith(
            progress: stats.currentStreak,
            unlockedAt: stats.currentStreak >= (achievement.target ?? 0)
                ? DateTime.now()
                : null,
          );
      }

      if (updated != null) {
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        achievements[index] = updated;
      }
    }

    await _saveAchievements(achievements);
  }

  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await _preferences;
    final achievementsJson = jsonEncode(
      achievements.map((a) => a.toMap()).toList(),
    );
    await prefs.setString(_achievementsKey, achievementsJson);
    _cachedAchievements = achievements;
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index != -1 && !achievements[index].isUnlocked) {
      achievements[index] = achievements[index].copyWith(
        unlockedAt: DateTime.now(),
      );
      await _saveAchievements(achievements);
    }
  }

  Future<String> exportToCSV({DateTime? startDate, DateTime? endDate}) async {
    final progressData = await _getProgressDataForPeriod(
      startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate ?? DateTime.now(),
    );

    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Words Written,Writing Time (min),Sessions,Words per Minute',
    );
    for (final progress in progressData) {
      buffer.writeln(
        '${progress.date.toIso8601String().split('T')[0]},'
        '${progress.wordsWritten},'
        '${progress.writingTimeMinutes},'
        '${progress.sessionCount},'
        '${progress.wordsPerMinute.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }

  Future<String> generateSummaryReport() async {
    final stats30Days = await calculateStats();
    final stats7Days = await calculateStats(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
    );
    final patterns = await getProductivityPatterns();
    final achievements = await getAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    final buffer = StringBuffer();
    buffer.writeln('# Writing Progress Report');
    buffer.writeln('');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## 30-Day Overview');
    buffer.writeln('- Total Words: ${stats30Days.totalWords}');
    buffer.writeln(
      '- Total Writing Time: ${stats30Days.totalTimeMinutes} minutes',
    );
    buffer.writeln(
      '- Average per Day: ${stats30Days.averageWordsPerDay.toStringAsFixed(0)} words',
    );
    buffer.writeln('- Current Streak: ${stats30Days.currentStreak} days');
    buffer.writeln('- Longest Streak: ${stats30Days.longestStreak} days');
    buffer.writeln(
      '- Productivity Rate: ${(stats30Days.productivityRate * 100).toStringAsFixed(0)}%',
    );
    buffer.writeln('');
    buffer.writeln('## Last 7 Days');
    buffer.writeln('- Total Words: ${stats7Days.totalWords}');
    buffer.writeln('- Productive Days: ${stats7Days.productiveDays}/7');
    buffer.writeln(
      '- Average per Day: ${stats7Days.averageWordsPerDay.toStringAsFixed(0)} words',
    );
    buffer.writeln('');
    buffer.writeln('## Productivity Patterns');
    buffer.writeln(
      '- Best Time to Write: ${patterns['best_hour']} (${patterns['best_hour_words']} words)',
    );
    buffer.writeln(
      '- Best Day to Write: ${patterns['best_day']} (${patterns['best_day_words']} words)',
    );
    buffer.writeln('');
    buffer.writeln('## Achievements');
    buffer.writeln('- Unlocked: $unlockedCount/${achievements.length}');
    buffer.writeln('');
    for (final achievement in achievements) {
      final status = achievement.isUnlocked ? '✅' : '🔒';
      final progress = achievement.isProgressBased
          ? ' (${achievement.progress}/${achievement.target})'
          : '';
      buffer.writeln('$status ${achievement.title}$progress');
    }

    return buffer.toString();
  }

  void clearCache() {
    _cachedAchievements = [];
  }

  Future<List<Achievement>> searchAchievements(String query) async {
    final achievements = await getAchievements();
    final lowerQuery = query.toLowerCase();

    return achievements
        .where(
          (achievement) =>
              achievement.title.toLowerCase().contains(lowerQuery) ||
              achievement.description.toLowerCase().contains(lowerQuery) ||
              achievement.type.name.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
