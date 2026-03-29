import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/writing_progress.dart';

void main() {
  group('WritingProgress', () {
    test('should create instance with required fields', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1000,
      );

      expect(progress.id, 'prog1');
      expect(progress.wordsWritten, 1000);
      expect(progress.writingTimeMinutes, 0);
      expect(progress.sessionCount, 1);
      expect(progress.goalIdsContributed, isEmpty);
    });

    test('should create instance with all fields', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 2000,
        writingTimeMinutes: 60,
        sessionCount: 3,
        goalIdsContributed: ['goal1', 'goal2'],
        notes: 'Great writing session',
      );

      expect(progress.wordsWritten, 2000);
      expect(progress.writingTimeMinutes, 60);
      expect(progress.sessionCount, 3);
      expect(progress.goalIdsContributed.length, 2);
      expect(progress.notes, 'Great writing session');
    });

    test('should calculate words per minute correctly', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      expect(progress.wordsPerMinute, 500 / 30);
    });

    test('should handle zero writing time for words per minute', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        writingTimeMinutes: 0,
      );

      expect(progress.wordsPerMinute, 0.0);
    });

    test('should calculate words per session correctly', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1500,
        sessionCount: 3,
      );

      expect(progress.wordsPerSession, 500);
    });

    test('should handle zero sessions for words per session', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1500,
        sessionCount: 0,
      );

      expect(progress.wordsPerSession, 0.0);
    });

    test('should identify productive days correctly', () {
      final productiveProgress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1000,
      );

      final unproductiveProgress = WritingProgress(
        id: 'prog2',
        date: DateTime(2026, 3, 30),
        wordsWritten: 0,
      );

      expect(productiveProgress.isProductive, true);
      expect(unproductiveProgress.isProductive, false);
    });

    test('should convert to map correctly', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1000,
        writingTimeMinutes: 45,
      );

      final map = progress.toMap();

      expect(map['id'], 'prog1');
      expect(map['words_written'], 1000);
      expect(map['writing_time_minutes'], 45);
      expect(map['date'], '2026-03-29T00:00:00.000');
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'prog1',
        'date': '2026-03-29T00:00:00.000',
        'words_written': 1500,
        'writing_time_minutes': 60,
        'session_count': 2,
        'goal_ids_contributed': ['goal1'],
        'notes': 'Test note',
      };

      final progress = WritingProgress.fromMap(map);

      expect(progress.id, 'prog1');
      expect(progress.wordsWritten, 1500);
      expect(progress.writingTimeMinutes, 60);
      expect(progress.sessionCount, 2);
      expect(progress.goalIdsContributed, ['goal1']);
      expect(progress.notes, 'Test note');
    });

    test('should copy with new values', () {
      final progress = WritingProgress(
        id: 'prog1',
        date: DateTime(2026, 3, 29),
        wordsWritten: 1000,
      );

      final copied = progress.copyWith(
        wordsWritten: 2000,
        writingTimeMinutes: 90,
      );

      expect(copied.id, 'prog1');
      expect(copied.wordsWritten, 2000);
      expect(copied.writingTimeMinutes, 90);
      expect(copied.date, DateTime(2026, 3, 29));
    });
  });

  group('Achievement', () {
    test('should create instance with required fields', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'First Words',
        description: 'Write your first 100 words',
        type: AchievementType.wordCount,
      );

      expect(achievement.id, 'ach1');
      expect(achievement.title, 'First Words');
      expect(achievement.type, AchievementType.wordCount);
      expect(achievement.isUnlocked, false);
    });

    test('should create instance with all fields', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Week Warrior',
        description: 'Write every day for a week',
        type: AchievementType.streak,
        unlockedAt: DateTime(2026, 3, 29),
        progress: 7,
        target: 7,
        iconPath: '/icons/week_warrior.png',
      );

      expect(achievement.isUnlocked, true);
      expect(achievement.progress, 7);
      expect(achievement.target, 7);
      expect(achievement.iconPath, '/icons/week_warrior.png');
    });

    test('should identify unlocked achievements', () {
      final unlocked = Achievement(
        id: 'ach1',
        title: 'Unlocked',
        description: 'Test',
        type: AchievementType.milestone,
        unlockedAt: DateTime(2026, 3, 29),
      );

      final locked = Achievement(
        id: 'ach2',
        title: 'Locked',
        description: 'Test',
        type: AchievementType.milestone,
      );

      expect(unlocked.isUnlocked, true);
      expect(locked.isUnlocked, false);
    });

    test('should calculate progress percentage correctly', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Test',
        description: 'Test',
        type: AchievementType.wordCount,
        progress: 500,
        target: 1000,
      );

      expect(achievement.progressPercentage, 0.5);
    });

    test('should handle zero target for progress percentage', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Test',
        description: 'Test',
        type: AchievementType.wordCount,
        progress: 500,
        target: 0,
      );

      expect(achievement.progressPercentage, 0.0);
    });

    test('should identify progress-based achievements', () {
      final progressBased = Achievement(
        id: 'ach1',
        title: 'Test',
        description: 'Test',
        type: AchievementType.wordCount,
        progress: 500,
        target: 1000,
      );

      final notProgressBased = Achievement(
        id: 'ach2',
        title: 'Test',
        description: 'Test',
        type: AchievementType.special,
      );

      expect(progressBased.isProgressBased, true);
      expect(notProgressBased.isProgressBased, false);
    });

    test('should clamp progress percentage to 1.0', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Test',
        description: 'Test',
        type: AchievementType.wordCount,
        progress: 1500,
        target: 1000,
      );

      expect(achievement.progressPercentage, 1.0);
    });

    test('should convert to map and from map correctly', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Test Achievement',
        description: 'Test description',
        type: AchievementType.milestone,
        unlockedAt: DateTime(2026, 3, 29),
        progress: 50,
        target: 100,
        metadata: {'category': 'writing'},
      );

      final map = achievement.toMap();
      final restored = Achievement.fromMap(map);

      expect(restored.id, 'ach1');
      expect(restored.title, 'Test Achievement');
      expect(restored.type, AchievementType.milestone);
      expect(restored.isUnlocked, true);
      expect(restored.progress, 50);
      expect(restored.target, 100);
      expect(restored.metadata, {'category': 'writing'});
    });

    test('should copy with new values', () {
      final achievement = Achievement(
        id: 'ach1',
        title: 'Original Title',
        description: 'Test',
        type: AchievementType.wordCount,
      );

      final copied = achievement.copyWith(
        title: 'Updated Title',
        progress: 500,
      );

      expect(copied.id, 'ach1');
      expect(copied.title, 'Updated Title');
      expect(copied.progress, 500);
      expect(copied.description, 'Test');
    });
  });

  group('WritingStats', () {
    test('should create instance with all fields', () {
      final stats = WritingStats(
        totalWords: 10000,
        totalTimeMinutes: 600,
        totalSessions: 20,
        averageWordsPerDay: 500,
        averageWordsPerSession: 500,
        currentStreak: 5,
        longestStreak: 14,
        totalDays: 30,
        productiveDays: 20,
        mostProductiveDay: DateTime(2026, 3, 29),
        mostProductiveDayWordCount: 2000,
        periodStart: DateTime(2026, 3, 1),
        periodEnd: DateTime(2026, 3, 30),
      );

      expect(stats.totalWords, 10000);
      expect(stats.totalTimeMinutes, 600);
      expect(stats.currentStreak, 5);
      expect(stats.longestStreak, 14);
      expect(stats.mostProductiveDay, DateTime(2026, 3, 29));
    });

    test('should calculate average words per minute correctly', () {
      final stats = WritingStats(
        totalWords: 3000,
        totalTimeMinutes: 60,
        totalSessions: 2,
        averageWordsPerDay: 500,
        averageWordsPerSession: 1500,
        currentStreak: 1,
        longestStreak: 1,
        totalDays: 1,
        productiveDays: 1,
        periodStart: DateTime(2026, 3, 29),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.averageWordsPerMinute, 50);
    });

    test('should handle zero time for average words per minute', () {
      final stats = WritingStats(
        totalWords: 1000,
        totalTimeMinutes: 0,
        totalSessions: 1,
        averageWordsPerDay: 1000,
        averageWordsPerSession: 1000,
        currentStreak: 1,
        longestStreak: 1,
        totalDays: 1,
        productiveDays: 1,
        periodStart: DateTime(2026, 3, 29),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.averageWordsPerMinute, 0.0);
    });

    test('should calculate productivity rate correctly', () {
      final stats = WritingStats(
        totalWords: 5000,
        totalTimeMinutes: 300,
        totalSessions: 10,
        averageWordsPerDay: 500,
        averageWordsPerSession: 500,
        currentStreak: 5,
        longestStreak: 5,
        totalDays: 10,
        productiveDays: 7,
        periodStart: DateTime(2026, 3, 20),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.productivityRate, 0.7);
    });

    test('should handle zero days for productivity rate', () {
      final stats = WritingStats(
        totalWords: 0,
        totalTimeMinutes: 0,
        totalSessions: 0,
        averageWordsPerDay: 0,
        averageWordsPerSession: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalDays: 0,
        productiveDays: 0,
        periodStart: DateTime(2026, 3, 29),
        periodEnd: DateTime(2026, 3, 29),
      );

      expect(stats.productivityRate, 0.0);
    });

    test('should convert to map and from map correctly', () {
      final stats = WritingStats(
        totalWords: 5000,
        totalTimeMinutes: 250,
        totalSessions: 10,
        averageWordsPerDay: 500,
        averageWordsPerSession: 500,
        currentStreak: 7,
        longestStreak: 14,
        totalDays: 20,
        productiveDays: 15,
        mostProductiveDay: DateTime(2026, 3, 29),
        mostProductiveDayWordCount: 1500,
        periodStart: DateTime(2026, 3, 10),
        periodEnd: DateTime(2026, 3, 29),
      );

      final map = stats.toMap();
      final restored = WritingStats.fromMap(map);

      expect(restored.totalWords, 5000);
      expect(restored.currentStreak, 7);
      expect(restored.longestStreak, 14);
      expect(restored.mostProductiveDay, DateTime(2026, 3, 29));
      expect(restored.mostProductiveDayWordCount, 1500);
    });
  });
}
