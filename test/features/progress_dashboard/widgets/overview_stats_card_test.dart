import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/progress_dashboard/widgets/overview_stats_card.dart';
import 'package:writer/models/writing_progress.dart';

void main() {
  group('OverviewStatsCard', () {
    late WritingStats mockStats;

    setUp(() {
      mockStats = WritingStats(
        totalWords: 50000,
        totalTimeMinutes: 1200,
        totalSessions: 50,
        averageWordsPerDay: 500.0,
        averageWordsPerSession: 1000.0,
        currentStreak: 7,
        longestStreak: 14,
        totalDays: 30,
        productiveDays: 25,
        mostProductiveDay: DateTime(2026, 3, 15),
        mostProductiveDayWordCount: 2500,
        periodStart: DateTime(2026, 3, 1),
        periodEnd: DateTime(2026, 3, 30),
      );
    });

    testWidgets('displays all statistics correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('words written'), findsOneWidget);
    });

    testWidgets('displays time statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.text('20.0'), findsOneWidget);
      expect(find.text('Total Time'), findsOneWidget);
      expect(find.text('hours writing'), findsOneWidget);
    });

    testWidgets('displays streak information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.text('7'), findsAtLeastNWidgets(1));
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Longest Streak'), findsOneWidget);
    });

    testWidgets('displays productive days', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);
      expect(find.text('Productive Days'), findsOneWidget);
    });

    testWidgets('displays additional insights', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.text('Additional Insights'), findsOneWidget);
      expect(find.text('Best Day: 2500 words'), findsOneWidget);
      expect(find.text('Avg/Session: 1000 words'), findsOneWidget);
      expect(find.text('Avg Speed: 41.7 words/min'), findsOneWidget);
      expect(find.text('Productivity Rate: 83%'), findsOneWidget);
    });

    testWidgets('handles zero values correctly', (WidgetTester tester) async {
      final zeroStats = WritingStats(
        totalWords: 0,
        totalTimeMinutes: 0,
        totalSessions: 0,
        averageWordsPerDay: 0.0,
        averageWordsPerSession: 0.0,
        currentStreak: 0,
        longestStreak: 0,
        totalDays: 0,
        productiveDays: 0,
        periodStart: DateTime(2026, 3, 1),
        periodEnd: DateTime(2026, 3, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: zeroStats),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsAtLeastNWidgets(2));
    });

    testWidgets('displays all stat cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OverviewStatsCard(stats: mockStats),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.whatshot), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
    });
  });
}
