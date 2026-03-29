import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/writing_goals/widgets/statistics_card.dart';

void main() {
  group('StatisticsCard', () {
    testWidgets('should display all statistics', (tester) async {
      final statistics = {
        'total_words_written': 5000,
        'total_writing_time_minutes': 120,
        'average_words_per_minute': 41.67,
        'current_streak': 7,
        'longest_streak': 14,
        'achieved_goals': 3,
        'total_goals': 5,
        'active_goals': 2,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatisticsCard(statistics: statistics)),
        ),
      );

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);
      expect(find.text('Writing Time'), findsOneWidget);
      expect(find.text('120 min'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('Longest Streak'), findsOneWidget);
      expect(find.text('14 days'), findsOneWidget);
      expect(find.text('Achieved Goals'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('should handle zero values', (tester) async {
      final statistics = {
        'total_words_written': 0,
        'total_writing_time_minutes': 0,
        'average_words_per_minute': 0.0,
        'current_streak': 0,
        'longest_streak': 0,
        'achieved_goals': 0,
        'total_goals': 0,
        'active_goals': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatisticsCard(statistics: statistics)),
        ),
      );

      expect(find.text('0'), findsWidgets);
      expect(find.text('0.0 wpm'), findsOneWidget);
    });

    testWidgets('should display statistics in grid layout', (tester) async {
      final statistics = {
        'total_words_written': 1000,
        'total_writing_time_minutes': 30,
        'average_words_per_minute': 33.33,
        'current_streak': 3,
        'longest_streak': 5,
        'achieved_goals': 1,
        'total_goals': 2,
        'active_goals': 1,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatisticsCard(statistics: statistics)),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
