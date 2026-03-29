import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/progress_dashboard/widgets/achievement_badge.dart';
import 'package:writer/models/writing_progress.dart';

void main() {
  group('AchievementBadge', () {
    late Achievement unlockedAchievement;
    late Achievement lockedAchievement;
    late Achievement progressAchievement;

    setUp(() {
      unlockedAchievement = Achievement(
        id: '1',
        title: 'First Words',
        description: 'Write your first 100 words',
        type: AchievementType.wordCount,
        unlockedAt: DateTime(2026, 3, 15),
      );

      lockedAchievement = Achievement(
        id: '2',
        title: 'Novel Writer',
        description: 'Write 50,000 words in one month',
        type: AchievementType.wordCount,
      );

      progressAchievement = Achievement(
        id: '3',
        title: 'Consistency King',
        description: 'Write for 30 days in a row',
        type: AchievementType.consistency,
        progress: 15,
        target: 30,
      );
    });

    testWidgets('displays unlocked achievement correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: unlockedAchievement),
          ),
        ),
      );

      expect(find.text('First Words'), findsOneWidget);
      expect(find.text('Write your first 100 words'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays locked achievement correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: lockedAchievement),
          ),
        ),
      );

      expect(find.text('Novel Writer'), findsOneWidget);
      expect(find.text('Write 50,000 words in one month'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays achievement with progress', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: progressAchievement),
          ),
        ),
      );

      expect(find.text('Consistency King'), findsOneWidget);
      expect(find.text('Write for 30 days in a row'), findsOneWidget);
      expect(find.text('15/30'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('unlocked achievement has full opacity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: unlockedAchievement),
          ),
        ),
      );

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 1.0);
    });

    testWidgets('locked achievement has reduced opacity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: lockedAchievement),
          ),
        ),
      );

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.6);
    });

    testWidgets('displays correct icon for word count achievement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: unlockedAchievement),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays correct icon for streak achievement', (
      WidgetTester tester,
    ) async {
      final streakAchievement = Achievement(
        id: '4',
        title: 'Week Warrior',
        description: 'Write for 7 days in a row',
        type: AchievementType.streak,
        unlockedAt: DateTime(2026, 3, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: streakAchievement),
          ),
        ),
      );

      expect(find.byIcon(Icons.whatshot), findsOneWidget);
    });

    testWidgets('displays correct icon for consistency achievement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: progressAchievement),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays correct icon for milestone achievement', (
      WidgetTester tester,
    ) async {
      final milestoneAchievement = Achievement(
        id: '5',
        title: 'Marathon Writer',
        description: 'Write for 1000 hours',
        type: AchievementType.milestone,
        progress: 500,
        target: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: milestoneAchievement),
          ),
        ),
      );

      expect(find.byIcon(Icons.military_tech), findsOneWidget);
    });

    testWidgets('displays correct icon for special achievement', (
      WidgetTester tester,
    ) async {
      final specialAchievement = Achievement(
        id: '6',
        title: 'Night Owl',
        description: 'Write more than 1000 words between midnight and 6 AM',
        type: AchievementType.special,
        unlockedAt: DateTime(2026, 3, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(achievement: specialAchievement),
          ),
        ),
      );

      expect(find.byIcon(Icons.stars), findsOneWidget);
    });

    testWidgets(
      'does not display progress for non-progress based achievements',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementBadge(achievement: unlockedAchievement),
            ),
          ),
        );

        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('/'), findsNothing);
      },
    );
  });
}
