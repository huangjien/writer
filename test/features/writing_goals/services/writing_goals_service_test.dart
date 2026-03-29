import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/writing_goals/services/writing_goals_service.dart';
import 'package:writer/models/writing_goal.dart';

void main() {
  late WritingGoalsService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = WritingGoalsService();
  });

  tearDown(() {
    service.clearCache();
  });

  group('WritingGoalsService - Goal Management', () {
    test('should create a new goal', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      expect(goal.id, isNotEmpty);
      expect(goal.type, GoalType.daily);
      expect(goal.targetWordCount, 1000);
      expect(goal.dailyProgress, isEmpty);
    });

    test('should create a goal with end date', () async {
      final endDate = DateTime(2026, 4, 30);
      final goal = await service.createGoal(
        type: GoalType.weekly,
        targetWordCount: 5000,
        endDate: endDate,
      );

      expect(goal.endDate, endDate);
    });

    test('should retrieve all goals', () async {
      await service.createGoal(type: GoalType.daily, targetWordCount: 1000);
      await service.createGoal(type: GoalType.weekly, targetWordCount: 5000);

      final goals = await service.getGoals();

      expect(goals.length, 2);
    });

    test('should retrieve goal by id', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final retrievedGoal = await service.getGoalById(goal.id);

      expect(retrievedGoal, isNotNull);
      expect(retrievedGoal?.id, goal.id);
    });

    test('should return null when goal id not found', () async {
      final retrievedGoal = await service.getGoalById('non_existent');

      expect(retrievedGoal, isNull);
    });

    test('should update goal', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final updatedGoal = await service.updateGoal(
        goal.id,
        targetWordCount: 2000,
        type: GoalType.weekly,
      );

      expect(updatedGoal.targetWordCount, 2000);
      expect(updatedGoal.type, GoalType.weekly);
    });

    test('should throw error when updating non-existent goal', () async {
      expect(
        () => service.updateGoal('non_existent', targetWordCount: 2000),
        throwsException,
      );
    });

    test('should delete goal', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.deleteGoal(goal.id);

      final goals = await service.getGoals();
      expect(goals, isEmpty);
    });

    test('should cache goals in memory', () async {
      await service.createGoal(type: GoalType.daily, targetWordCount: 1000);

      final goals1 = await service.getGoals();
      final goals2 = await service.getGoals();

      expect(identical(goals1, goals2), false);
      expect(goals1.length, goals2.length);
    });
  });

  group('WritingGoalsService - Daily Progress', () {
    test('should add daily progress to goal', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final progress = await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      expect(progress.wordsWritten, 500);
      expect(progress.writingTimeMinutes, 30);
      expect(progress.goalAchieved, false);
    });

    test('should mark goal as achieved when target reached', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final progress = await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 1000,
      );

      expect(progress.goalAchieved, true);
    });

    test('should update existing progress for same day', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      final progress = await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 300,
        writingTimeMinutes: 20,
      );

      expect(progress.wordsWritten, 800);
      expect(progress.writingTimeMinutes, 50);
    });

    test(
      'should update goal achievement status on subsequent writes',
      () async {
        final goal = await service.createGoal(
          type: GoalType.daily,
          targetWordCount: 1000,
        );

        await service.addDailyProgress(goalId: goal.id, wordsWritten: 500);

        final progress = await service.addDailyProgress(
          goalId: goal.id,
          wordsWritten: 600,
        );

        expect(progress.wordsWritten, 1100);
        expect(progress.goalAchieved, true);
      },
    );

    test(
      'should throw error when adding progress to non-existent goal',
      () async {
        expect(
          () => service.addDailyProgress(
            goalId: 'non_existent',
            wordsWritten: 500,
          ),
          throwsException,
        );
      },
    );

    test('should get recent progress', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      final recentProgress = await service.getRecentProgress(days: 7);

      expect(recentProgress.length, 1);
      expect(recentProgress.first.wordsWritten, 500);
    });

    test('should filter recent progress by date', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      DailyProgress(date: oldDate, writingTimeMinutes: 10, wordsWritten: 100);

      await service.updateGoal(goal.id, targetWordCount: 1000);

      final recentProgress = await service.getRecentProgress(days: 7);

      expect(recentProgress, isEmpty);
    });
  });

  group('WritingGoalsService - Streak Calculation', () {
    test('should initialize with zero streak', () async {
      final streak = await service.getCurrentStreak();

      expect(streak, 0);
    });

    test('should update current streak when goals achieved', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);

      final streak = await service.getCurrentStreak();

      expect(streak, 1);
    });

    test('should not update streak when goal not achieved', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 500);

      final streak = await service.getCurrentStreak();

      expect(streak, 0);
    });

    test('should track longest streak', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      for (int i = 0; i < 5; i++) {
        await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);
      }

      final longestStreak = await service.getLongestStreak();

      expect(longestStreak, 5);
    });

    test('should reset streak', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);

      await service.resetStreak();

      final streak = await service.getCurrentStreak();
      expect(streak, 0);
    });
  });

  group('WritingGoalsService - Statistics', () {
    test('should calculate total words written', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 500);
      await service.addDailyProgress(goalId: goal.id, wordsWritten: 300);

      final stats = await service.getStatistics();

      expect(stats['total_words_written'], 800);
    });

    test('should calculate total writing time', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      final stats = await service.getStatistics();

      expect(stats['total_writing_time_minutes'], 30);
    });

    test('should calculate average words per minute', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(
        goalId: goal.id,
        wordsWritten: 500,
        writingTimeMinutes: 30,
      );

      final stats = await service.getStatistics();

      expect(stats['average_words_per_minute'], 500 / 30);
    });

    test('should count active goals', () async {
      await service.createGoal(type: GoalType.daily, targetWordCount: 1000);

      await service.createGoal(
        type: GoalType.weekly,
        targetWordCount: 5000,
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      final stats = await service.getStatistics();

      expect(stats['active_goals'], 2);
    });

    test('should count achieved goals', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);

      final stats = await service.getStatistics();

      expect(stats['achieved_goals'], 1);
    });

    test('should count total goals', () async {
      await service.createGoal(type: GoalType.daily, targetWordCount: 1000);
      await service.createGoal(type: GoalType.weekly, targetWordCount: 5000);

      final stats = await service.getStatistics();

      expect(stats['total_goals'], 2);
    });

    test('should include streak data in statistics', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);

      final stats = await service.getStatistics();

      expect(stats['current_streak'], 1);
      expect(stats['longest_streak'], 1);
    });
  });

  group('WritingGoalsService - Persistence', () {
    test('should persist goals across service instances', () async {
      final goal1 = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      final newService = WritingGoalsService();
      final goals = await newService.getGoals();

      expect(goals.length, 1);
      expect(goals.first.id, goal1.id);
    });

    test('should persist streak across service instances', () async {
      final goal = await service.createGoal(
        type: GoalType.daily,
        targetWordCount: 1000,
      );

      await service.addDailyProgress(goalId: goal.id, wordsWritten: 1000);

      final newService = WritingGoalsService();
      final streak = await newService.getCurrentStreak();

      expect(streak, 1);
    });

    test('should handle corrupted data gracefully', () async {
      await prefs.setString('writing_goals', 'invalid_json');

      final goals = await service.getGoals();

      expect(goals, isEmpty);
    });
  });
}
