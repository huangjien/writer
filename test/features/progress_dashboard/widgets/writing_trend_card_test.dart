import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/progress_dashboard/widgets/writing_trend_card.dart';
import 'package:writer/models/writing_progress.dart';

void main() {
  group('WritingTrendCard', () {
    late List<WritingProgress> mockTrendData;

    setUp(() {
      mockTrendData = List.generate(30, (index) {
        return WritingProgress(
          id: 'progress_$index',
          date: DateTime(2026, 3, 1).add(Duration(days: index)),
          wordsWritten: 500 + (index * 50),
          writingTimeMinutes: 30 + index,
          sessionCount: 1,
        );
      });
    });

    testWidgets('displays trend card with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: mockTrendData)),
        ),
      );

      expect(find.text('Writing Trend'), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('displays average chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: mockTrendData)),
        ),
      );

      expect(find.byType(Chip), findsOneWidget);
      expect(find.textContaining('Avg:'), findsOneWidget);
    });

    testWidgets('displays empty state when no data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: [])),
        ),
      );

      expect(find.text('No trend data available yet'), findsOneWidget);
      expect(find.text('Start writing to see your trends'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('displays trend insights', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: mockTrendData)),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsAtLeastNWidgets(1));
      expect(find.textContaining('Last week:'), findsOneWidget);
      expect(find.textContaining('Last 7 days:'), findsOneWidget);
    });

    testWidgets('trends up when recent week is better', (
      WidgetTester tester,
    ) async {
      final increasingData = List.generate(14, (index) {
        return WritingProgress(
          id: 'progress_$index',
          date: DateTime(2026, 3, 1).add(Duration(days: index)),
          wordsWritten: index < 7 ? 500 : 1000,
          writingTimeMinutes: 30,
          sessionCount: 1,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: increasingData)),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsAtLeastNWidgets(1));
      expect(find.textContaining('Increased'), findsOneWidget);
    });

    testWidgets('trends down when recent week is worse', (
      WidgetTester tester,
    ) async {
      final decreasingData = List.generate(14, (index) {
        return WritingProgress(
          id: 'progress_$index',
          date: DateTime(2026, 3, 1).add(Duration(days: index)),
          wordsWritten: index < 7 ? 1000 : 500,
          writingTimeMinutes: 30,
          sessionCount: 1,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: decreasingData)),
        ),
      );

      expect(find.byIcon(Icons.trending_down), findsAtLeastNWidgets(1));
      expect(find.textContaining('Decreased'), findsOneWidget);
    });

    testWidgets('shows stable trend when weeks are similar', (
      WidgetTester tester,
    ) async {
      final stableData = List.generate(14, (index) {
        return WritingProgress(
          id: 'progress_$index',
          date: DateTime(2026, 3, 1).add(Duration(days: index)),
          wordsWritten: 500,
          writingTimeMinutes: 30,
          sessionCount: 1,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: stableData)),
        ),
      );

      expect(find.byIcon(Icons.trending_flat), findsAtLeastNWidgets(1));
      expect(find.textContaining('Stable'), findsOneWidget);
    });

    testWidgets('handles single data point', (WidgetTester tester) async {
      final singleData = [
        WritingProgress(
          id: 'progress_0',
          date: DateTime(2026, 3, 1),
          wordsWritten: 500,
          writingTimeMinutes: 30,
          sessionCount: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: singleData)),
        ),
      );

      expect(find.text('Writing Trend'), findsOneWidget);
    });

    testWidgets('displays chart with correct height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: mockTrendData)),
        ),
      );

      expect(find.text('Writing Trend'), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('handles zero word days correctly', (
      WidgetTester tester,
    ) async {
      final mixedData = List.generate(10, (index) {
        return WritingProgress(
          id: 'progress_$index',
          date: DateTime(2026, 3, 1).add(Duration(days: index)),
          wordsWritten: index % 2 == 0 ? 0 : 500,
          writingTimeMinutes: 30,
          sessionCount: 1,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WritingTrendCard(trendData: mixedData)),
        ),
      );

      expect(find.text('Writing Trend'), findsOneWidget);
    });
  });
}
