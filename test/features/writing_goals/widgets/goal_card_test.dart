import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/writing_goals/widgets/goal_card.dart';
import 'package:writer/models/writing_goal.dart';

void main() {
  group('GoalCard', () {
    testWidgets('should display goal information', (tester) async {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(goal: goal, onAddProgress: () {}, onDelete: () {}),
          ),
        ),
      );

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('0 / 1000 words'), findsOneWidget);
      expect(find.text('0.0% complete'), findsOneWidget);
      expect(find.text('0 day streak'), findsOneWidget);
      expect(find.text('0 days tracked'), findsOneWidget);
    });

    testWidgets('should display progress correctly', (tester) async {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.weekly,
        targetWordCount: 5000,
        startDate: DateTime(2026, 3, 29),
        dailyProgress: [
          DailyProgress(
            date: DateTime(2026, 3, 29),
            wordsWritten: 2500,
            writingTimeMinutes: 60,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(goal: goal, onAddProgress: () {}, onDelete: () {}),
          ),
        ),
      );

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('2500 / 5000 words'), findsOneWidget);
      expect(find.text('50.0% complete'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should show achievement badge when goal achieved', (
      tester,
    ) async {
      final goal = WritingGoal(
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(goal: goal, onAddProgress: () {}, onDelete: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call onAddProgress when button pressed', (
      tester,
    ) async {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      bool addProgressCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(
              goal: goal,
              onAddProgress: () => addProgressCalled = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add Progress'));
      await tester.pump();

      expect(addProgressCalled, true);
    });

    testWidgets('should call onDelete when delete button pressed', (
      tester,
    ) async {
      final goal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(
              goal: goal,
              onAddProgress: () {},
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(deleteCalled, true);
    });

    testWidgets('should display correct color for each goal type', (
      tester,
    ) async {
      final dailyGoal = WritingGoal(
        id: 'goal1',
        type: GoalType.daily,
        targetWordCount: 1000,
        startDate: DateTime(2026, 3, 29),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoalCard(
              goal: dailyGoal,
              onAddProgress: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Daily'), findsOneWidget);
    });
  });
}
