class WritingProgress {
  final String id;
  final DateTime date;
  final int wordsWritten;
  final int writingTimeMinutes;
  final int sessionCount;
  final List<String> goalIdsContributed;
  final String? notes;

  WritingProgress({
    required this.id,
    required this.date,
    required this.wordsWritten,
    this.writingTimeMinutes = 0,
    this.sessionCount = 1,
    this.goalIdsContributed = const [],
    this.notes,
  });

  double get wordsPerMinute {
    if (writingTimeMinutes == 0) return 0.0;
    return wordsWritten / writingTimeMinutes;
  }

  double get wordsPerSession {
    if (sessionCount == 0) return 0.0;
    return wordsWritten / sessionCount;
  }

  bool get isProductive => wordsWritten > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'words_written': wordsWritten,
      'writing_time_minutes': writingTimeMinutes,
      'session_count': sessionCount,
      'goal_ids_contributed': goalIdsContributed,
      'notes': notes,
    };
  }

  factory WritingProgress.fromMap(Map<String, dynamic> map) {
    return WritingProgress(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      wordsWritten: map['words_written'] as int,
      writingTimeMinutes: map['writing_time_minutes'] as int? ?? 0,
      sessionCount: map['session_count'] as int? ?? 1,
      goalIdsContributed: List<String>.from(map['goal_ids_contributed'] ?? []),
      notes: map['notes'] as String?,
    );
  }

  WritingProgress copyWith({
    String? id,
    DateTime? date,
    int? wordsWritten,
    int? writingTimeMinutes,
    int? sessionCount,
    List<String>? goalIdsContributed,
    String? notes,
  }) {
    return WritingProgress(
      id: id ?? this.id,
      date: date ?? this.date,
      wordsWritten: wordsWritten ?? this.wordsWritten,
      writingTimeMinutes: writingTimeMinutes ?? this.writingTimeMinutes,
      sessionCount: sessionCount ?? this.sessionCount,
      goalIdsContributed: goalIdsContributed ?? this.goalIdsContributed,
      notes: notes ?? this.notes,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;
  final String? iconPath;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.unlockedAt,
    this.progress,
    this.target,
    this.iconPath,
    this.metadata,
  });

  bool get isUnlocked => unlockedAt != null;

  double get progressPercentage {
    if (target == null || target == 0) return 0.0;
    if (progress == null) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  bool get isProgressBased => progress != null && target != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
      'icon_path': iconPath,
      'metadata': metadata,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.milestone,
      ),
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      progress: map['progress'] as int?,
      target: map['target'] as int?,
      iconPath: map['icon_path'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    DateTime? unlockedAt,
    int? progress,
    int? target,
    String? iconPath,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      iconPath: iconPath ?? this.iconPath,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum AchievementType { milestone, streak, wordCount, consistency, special }

class WritingStats {
  final int totalWords;
  final int totalTimeMinutes;
  final int totalSessions;
  final double averageWordsPerDay;
  final double averageWordsPerSession;
  final int currentStreak;
  final int longestStreak;
  final int totalDays;
  final int productiveDays;
  final DateTime? mostProductiveDay;
  final int? mostProductiveDayWordCount;
  final DateTime periodStart;
  final DateTime periodEnd;

  WritingStats({
    required this.totalWords,
    required this.totalTimeMinutes,
    required this.totalSessions,
    required this.averageWordsPerDay,
    required this.averageWordsPerSession,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
    required this.productiveDays,
    this.mostProductiveDay,
    this.mostProductiveDayWordCount,
    required this.periodStart,
    required this.periodEnd,
  });

  double get averageWordsPerMinute {
    if (totalTimeMinutes == 0) return 0.0;
    return totalWords / totalTimeMinutes;
  }

  double get productivityRate {
    if (totalDays == 0) return 0.0;
    return productiveDays / totalDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'total_words': totalWords,
      'total_time_minutes': totalTimeMinutes,
      'total_sessions': totalSessions,
      'average_words_per_day': averageWordsPerDay,
      'average_words_per_session': averageWordsPerSession,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_days': totalDays,
      'productive_days': productiveDays,
      'most_productive_day': mostProductiveDay?.toIso8601String(),
      'most_productive_day_word_count': mostProductiveDayWordCount,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  factory WritingStats.fromMap(Map<String, dynamic> map) {
    return WritingStats(
      totalWords: map['total_words'] as int,
      totalTimeMinutes: map['total_time_minutes'] as int,
      totalSessions: map['total_sessions'] as int,
      averageWordsPerDay: map['average_words_per_day'] as double,
      averageWordsPerSession: map['average_words_per_session'] as double,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      totalDays: map['total_days'] as int,
      productiveDays: map['productive_days'] as int,
      mostProductiveDay: map['most_productive_day'] != null
          ? DateTime.parse(map['most_productive_day'] as String)
          : null,
      mostProductiveDayWordCount: map['most_productive_day_word_count'] as int?,
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: DateTime.parse(map['period_end'] as String),
    );
  }
}
