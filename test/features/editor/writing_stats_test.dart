import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/writing_stats.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: child,
  );
}

void main() {
  group('WritingStats', () {
    testWidgets('shows word and char count', (tester) async {
      final controller = TextEditingController(text: 'Hello world');
      await tester.pumpWidget(
        buildTestWidget(Center(child: WritingStats(controller: controller))),
      );

      expect(find.text('Words'), findsOneWidget);
      expect(find.text('Chars'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('updates count as user types', (tester) async {
      final controller = TextEditingController(text: 'Hello');
      await tester.pumpWidget(
        buildTestWidget(Center(child: WritingStats(controller: controller))),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      controller.text = 'Hello world';
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('hides counts when showCounts is false', (tester) async {
      final controller = TextEditingController(text: 'Hello world');
      await tester.pumpWidget(
        buildTestWidget(
          Center(
            child: WritingStats(controller: controller, showCounts: false),
          ),
        ),
      );

      expect(find.text('Words'), findsNothing);
      expect(find.text('Chars'), findsNothing);
    });

    testWidgets('shows streak when provided', (tester) async {
      final controller = TextEditingController(text: 'Hello world');
      await tester.pumpWidget(
        buildTestWidget(
          Center(
            child: WritingStats(
              controller: controller,
              showStreak: true,
              streakDays: 5,
            ),
          ),
        ),
      );

      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('5d'), findsOneWidget);
    });

    testWidgets('hides streak when showStreak is false', (tester) async {
      final controller = TextEditingController(text: 'Hello world');
      await tester.pumpWidget(
        buildTestWidget(
          Center(
            child: WritingStats(
              controller: controller,
              showStreak: false,
              streakDays: 5,
            ),
          ),
        ),
      );

      expect(find.text('Streak'), findsNothing);
      expect(find.text('5d'), findsNothing);
    });

    testWidgets('handles empty text', (tester) async {
      final controller = TextEditingController(text: '');
      await tester.pumpWidget(
        buildTestWidget(Center(child: WritingStats(controller: controller))),
      );

      expect(find.text('0'), findsNWidgets(2));
    });
  });
}
