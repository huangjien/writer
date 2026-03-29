import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/progress_dashboard/widgets/productivity_patterns_card.dart';

void main() {
  group('ProductivityPatternsCard', () {
    late Map<String, dynamic> mockPatterns;

    setUp(() {
      mockPatterns = {
        'best_day_of_week': 'monday',
        'best_hour': 9,
        'day_distribution': {
          'monday': 1500,
          'tuesday': 1200,
          'wednesday': 1800,
          'thursday': 1400,
          'friday': 1000,
          'saturday': 800,
          'sunday': 900,
        },
        'hour_distribution': {8: 500, 9: 1200, 10: 800, 11: 600},
      };
    });

    testWidgets('displays productivity patterns card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Productivity Patterns'), findsOneWidget);
    });

    testWidgets('displays best day of week', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Best Day of the Week'), findsOneWidget);
      expect(find.text('Monday'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays most productive hour', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Most Productive Hour'), findsOneWidget);
      expect(find.text('9 AM'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays day distribution chart', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Day Distribution'), findsOneWidget);
      expect(find.text('Mon'), findsAtLeastNWidgets(1));
      expect(find.text('Tue'), findsAtLeastNWidgets(1));
      expect(find.text('Wed'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays hour distribution chart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Hour Distribution'), findsOneWidget);
    });

    testWidgets('displays empty state when no patterns', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductivityPatternsCard(patterns: {})),
        ),
      );

      expect(find.text('No productivity patterns yet'), findsOneWidget);
      expect(
        find.text('Keep writing to discover your patterns'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('formats day names correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Monday'), findsAtLeastNWidgets(1));
    });

    testWidgets('formats hours correctly - morning', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('8 AM'), findsAtLeastNWidgets(1));
      expect(find.text('9 AM'), findsAtLeastNWidgets(1));
      expect(find.text('10 AM'), findsAtLeastNWidgets(1));
    });

    testWidgets('formats hours correctly - afternoon', (
      WidgetTester tester,
    ) async {
      final afternoonPatterns = {
        'best_hour': 14,
        'hour_distribution': {13: 500, 14: 1200, 15: 800},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: afternoonPatterns),
            ),
          ),
        ),
      );

      expect(find.text('1 PM'), findsAtLeastNWidgets(1));
      expect(find.text('2 PM'), findsAtLeastNWidgets(1));
      expect(find.text('3 PM'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles missing best day', (WidgetTester tester) async {
      final patternsWithoutBestDay = {
        'best_hour': 9,
        'day_distribution': {'monday': 1500, 'tuesday': 1200},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: patternsWithoutBestDay),
            ),
          ),
        ),
      );

      expect(find.text('Best Day of the Week'), findsNothing);
    });

    testWidgets('handles missing best hour', (WidgetTester tester) async {
      final patternsWithoutBestHour = {
        'best_day_of_week': 'monday',
        'day_distribution': {'monday': 1500, 'tuesday': 1200},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(
                patterns: patternsWithoutBestHour,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Most Productive Hour'), findsNothing);
    });

    testWidgets('handles missing day distribution', (
      WidgetTester tester,
    ) async {
      final patternsWithoutDayDist = {
        'best_day_of_week': 'monday',
        'best_hour': 9,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: patternsWithoutDayDist),
            ),
          ),
        ),
      );

      expect(find.text('Day Distribution'), findsNothing);
    });

    testWidgets('handles missing hour distribution', (
      WidgetTester tester,
    ) async {
      final patternsWithoutHourDist = {
        'best_day_of_week': 'monday',
        'best_hour': 9,
        'day_distribution': {'monday': 1500},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(
                patterns: patternsWithoutHourDist,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hour Distribution'), findsNothing);
    });

    testWidgets('highlights best day in distribution chart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: mockPatterns),
            ),
          ),
        ),
      );

      expect(find.text('Day Distribution'), findsOneWidget);
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('handles midnight hour', (WidgetTester tester) async {
      final midnightPatterns = {
        'best_hour': 0,
        'hour_distribution': {0: 100},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: midnightPatterns),
            ),
          ),
        ),
      );

      expect(find.text('12 AM'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles noon hour', (WidgetTester tester) async {
      final noonPatterns = {
        'best_hour': 12,
        'hour_distribution': {12: 100},
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductivityPatternsCard(patterns: noonPatterns),
            ),
          ),
        ),
      );

      expect(find.text('12 PM'), findsAtLeastNWidgets(1));
    });
  });
}
