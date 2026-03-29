import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/writing_goal.dart';

void main() {
  group('GoalType', () {
    test('should have all expected types', () {
      expect(GoalType.values.length, 4);
      expect(GoalType.values, contains(GoalType.daily));
      expect(GoalType.values, contains(GoalType.weekly));
      expect(GoalType.values, contains(GoalType.monthly));
      expect(GoalType.values, contains(GoalType.total));
    });
  });

  group('WritingGoal', () {
    final testProgress = [
      DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        goalAchieved: true,
        writingTimeMinutes: 30,
      ),
      DailyProgress(
        date: DateTime(2026, 3, 28),
        wordsWritten: 400,
        goalAchieved: false,
        writingTimeMinutes: 25,
      ),
    ];

    test('should create instance with required fields', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      expect(goal.id, 'goal1');
      expect(goal.type, GoalType.daily);
      expect(goal.targetWordCount, 1000);
      expect(goal.dailyProgress, isEmpty);
    });

    test('should create instance with all fields', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.weekly,
        targetWordCount: 5000,
        startDate: DateTime(2026, 3, 29),
        endDate: DateTime(2026, 4, 5),
        dailyProgress: testProgress,
      );

      expect(goal.id, 'goal1');
      expect(goal.type, GoalType.weekly);
      expect(goal.targetWordCount, 5000);
      expect(goal.endDate, isNotNull);
      expect(goal.dailyProgress.length, 2);
    });

    test('should convert to map correctly', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: testProgress,
      );

      final map = goal.toMap();

      expect(map['id'], 'goal1');
      expect(map['type'], 'daily');
      expect(map['target_word_count'], 1000);
      expect(map['start_date'], '2026-03-29T00:00:00.000');
      expect(map['daily_progress'], isList);
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'goal1',
        'type': 'weekly',
        'target_word_count': 3000,
        'start_date': '2026-03-29T00:00:00.000',
        'end_date': '2026-04-05T00:00:00.000',
        'daily_progress': [
          {
            'date': '2026-03-29T00:00:00.000',
            'words_written': 500,
            'goal_achieved': true,
            'writing_time_minutes': 30,
          },
        ],
      };

      final goal = WritingGoal.fromMap(map);

      expect(goal.id, 'goal1');
      expect(goal.type, GoalType.weekly);
      expect(goal.targetWordCount, 3000);
      expect(goal.endDate, isNotNull);
      expect(goal.dailyProgress.length, 1);
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {
        'id': 'goal1',
        'type': 'daily',
        'target_word_count': 1000,
        'start_date': '2026-03-29T00:00:00.000',
      };

      final goal = WritingGoal.fromMap(map);

      expect(goal.endDate, isNull);
      expect(goal.dailyProgress, isEmpty);
    });

    test('should copy with new values', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      final copied = goal.copyWith(
        targetWordCount: 2000,
        type: GoalType.weekly,
      );

      expect(copied.id, 'goal1');
      expect(copied.targetWordCount, 2000);
      expect(copied.type, GoalType.weekly);
      expect(copied.startDate, DateTime(2026, 3, 29));
    });

    test('should calculate current progress correctly', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: testProgress,
      );

      expect(goal.currentProgress, 900);
    });

    test('should calculate progress percentage correctly', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: testProgress,
      );

      expect(goal.progressPercentage, 0.9);
    });

    test('should clamp progress percentage to 1.0', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: [
          DailyProgress(
            date: DateTime(2026, 3, 29),
            wordsWritten: 2000,
            goalAchieved: true,
          ),
        ],
      );

      expect(goal.progressPercentage, 1.0);
    });

    test('should determine if goal is achieved', () {
      final achievedGoal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: [
          DailyProgress(
            date: DateTime(2026, 3, 29),
            wordsWritten: 1000,
            goalAchieved: true,
          ),
        ],
      );

      final notAchievedGoal = WritingGoal(
        id: 'goal2',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: testProgress,
      );

      expect(achievedGoal.isGoalAchieved, true);
      expect(notAchievedGoal.isGoalAchieved, false);
    });

    test('should calculate current streak correctly', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: today,
        dailyProgress: [
          DailyProgress(date: today, wordsWritten: 1000, goalAchieved: true),
          DailyProgress(
            date: yesterday,
            wordsWritten: 1000,
            goalAchieved: true,
          ),
          DailyProgress(
            date: twoDaysAgo,
            wordsWritten: 1000,
            goalAchieved: true,
          ),
        ],
      );

      expect(goal.currentStreak, 3);
    });

    test('should handle empty daily progress for streak', () {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      expect(goal.currentStreak, 0);
    });

    test('should break streak on unachieved goal', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: today,
        dailyProgress: [
          DailyProgress(date: today, wordsWritten: 1000, goalAchieved: true),
          DailyProgress(
            date: yesterday,
            wordsWritten: 500,
            goalAchieved: false,
          ),
        ],
      );

      expect(goal.currentStreak, 1);
    });
  });

  group('DailyProgress', () {
    test('should create instance with required fields', () {
      final progress = DailyProgress(date: DateTime(2026, 3, 29));

      expect(progress.date, DateTime(2026, 3, 29));
      expect(progress.wordsWritten, 0);
      expect(progress.goalAchieved, false);
      expect(progress.writingTimeMinutes, 0);
    });

    test('should create instance with all fields', () {
      final progress = DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        goalAchieved: true,
        writingTimeMinutes: 30,
      );

      expect(progress.wordsWritten, 500);
      expect(progress.goalAchieved, true);
      expect(progress.writingTimeMinutes, 30);
    });

    test('should convert to map correctly', () {
      final progress = DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        goalAchieved: true,
        writingTimeMinutes: 30,
      );

      final map = progress.toMap();

      expect(map['date'], '2026-03-29T00:00:00.000');
      expect(map['words_written'], 500);
      expect(map['goal_achieved'], true);
      expect(map['writing_time_minutes'], 30);
    });

    test('should create from map correctly', () {
      final map = {
        'date': '2026-03-29T00:00:00.000',
        'words_written': 500,
        'goal_achieved': true,
        'writing_time_minutes': 30,
      };

      final progress = DailyProgress.fromMap(map);

      expect(progress.wordsWritten, 500);
      expect(progress.goalAchieved, true);
      expect(progress.writingTimeMinutes, 30);
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {'date': '2026-03-29T00:00:00.000'};

      final progress = DailyProgress.fromMap(map);

      expect(progress.wordsWritten, 0);
      expect(progress.goalAchieved, false);
      expect(progress.writingTimeMinutes, 0);
    });

    test('should copy with new values', () {
      final progress = DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
      );

      final copied = progress.copyWith(wordsWritten: 1000, goalAchieved: true);

      expect(copied.date, DateTime(2026, 3, 29));
      expect(copied.wordsWritten, 1000);
      expect(copied.goalAchieved, true);
    });

    test('should calculate words per minute correctly', () {
      final progress = DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      expect(progress.wordsPerMinute, 500 / 30);
    });

    test('should handle zero writing time for words per minute', () {
      final progress = DailyProgress(
        date: DateTime(2026, 3, 29),
        wordsWritten: 500,
        writingTimeMinutes: 0,
      );

      expect(progress.wordsPerMinute, 0.0);
    });
  });
}
