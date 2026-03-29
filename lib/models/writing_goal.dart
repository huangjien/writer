enum GoalType { daily, weekly, monthly, total }

class WritingGoal {
  final String id;
  final GoalType type;
  final int targetWordCount;
  final DateTime startDate;
  final DateTime? endDate;
  final List<DailyProgress> dailyProgress;

  const WritingGoal({
    required this.id,
    required this.type,
    required this.targetWordCount,
    required this.startDate,
    this.endDate,
    this.dailyProgress = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'target_word_count': targetWordCount,
    'start_date': startDate.toIso8601String(),
    if (endDate != null) 'end_date': endDate!.toIso8601String(),
    'daily_progress': dailyProgress.map((p) => p.toMap()).toList(),
  };

  factory WritingGoal.fromMap(Map<String, dynamic> map) {
    return WritingGoal(
      id: map['id'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GoalType.daily,
      ),
      targetWordCount: map['target_word_count'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      dailyProgress:
          (map['daily_progress'] as List<dynamic>?)
              ?.map((e) => DailyProgress.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  WritingGoal copyWith({
    String? id,
    GoalType? type,
    int? targetWordCount,
    DateTime? startDate,
    DateTime? endDate,
    List<DailyProgress>? dailyProgress,
  }) => WritingGoal(
    id: id ?? this.id,
    type: type ?? this.type,
    targetWordCount: targetWordCount ?? this.targetWordCount,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    dailyProgress: dailyProgress ?? this.dailyProgress,
  );

  int get currentProgress {
    return dailyProgress.fold(0, (sum, p) => sum + p.wordsWritten);
  }

  double get progressPercentage {
    if (targetWordCount == 0) return 0.0;
    return (currentProgress / targetWordCount).clamp(0.0, 1.0);
  }

  bool get isGoalAchieved => currentProgress >= targetWordCount;

  int get currentStreak {
    if (dailyProgress.isEmpty) return 0;

    var streak = 0;
    final today = DateTime.now();
    final sortedProgress = List<DailyProgress>.from(dailyProgress)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final progress in sortedProgress) {
      final difference = today.difference(progress.date).inDays;
      if (difference == streak && progress.goalAchieved) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

class DailyProgress {
  final DateTime date;
  final int wordsWritten;
  final bool goalAchieved;
  final int writingTimeMinutes;

  const DailyProgress({
    required this.date,
    this.wordsWritten = 0,
    this.goalAchieved = false,
    this.writingTimeMinutes = 0,
  });

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'words_written': wordsWritten,
    'goal_achieved': goalAchieved,
    'writing_time_minutes': writingTimeMinutes,
  };

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      date: DateTime.parse(map['date'] as String),
      wordsWritten: map['words_written'] as int? ?? 0,
      goalAchieved: map['goal_achieved'] as bool? ?? false,
      writingTimeMinutes: map['writing_time_minutes'] as int? ?? 0,
    );
  }

  DailyProgress copyWith({
    DateTime? date,
    int? wordsWritten,
    bool? goalAchieved,
    int? writingTimeMinutes,
  }) => DailyProgress(
    date: date ?? this.date,
    wordsWritten: wordsWritten ?? this.wordsWritten,
    goalAchieved: goalAchieved ?? this.goalAchieved,
    writingTimeMinutes: writingTimeMinutes ?? this.writingTimeMinutes,
  );

  double get wordsPerMinute {
    if (writingTimeMinutes == 0) return 0.0;
    return wordsWritten / writingTimeMinutes;
  }
}
