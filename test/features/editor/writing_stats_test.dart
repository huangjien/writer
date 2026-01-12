import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/writing_stats.dart';

void main() {
  testWidgets('WritingStats shows words/chars/read by default', (tester) async {
    final controller = TextEditingController(text: 'one two three');
    addTearDown(controller.dispose);

    final charCount = controller.text.characters.length;
    final expectedSemantics =
        '3 words, $charCount characters, estimated reading time <1m';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: WritingStats(controller: controller)),
      ),
    );

    expect(find.text('Words'), findsOneWidget);
    expect(find.text('Chars'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
  });

  testWidgets('WritingStats updates when controller text changes', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'one two three');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: WritingStats(controller: controller)),
      ),
    );

    controller.text = 'one two';
    await tester.pump();

    final charCount = controller.text.characters.length;
    final expectedSemantics =
        '2 words, $charCount characters, estimated reading time <1m';
    expect(find.bySemanticsLabel(expectedSemantics), findsOneWidget);
  });

  testWidgets('WritingStats can hide counts and show streak', (tester) async {
    final controller = TextEditingController(text: 'one two three');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingStats(
            controller: controller,
            streakDays: 5,
            showCounts: false,
          ),
        ),
      ),
    );

    expect(find.text('Words'), findsNothing);
    expect(find.text('Chars'), findsNothing);
    expect(find.text('Read'), findsNothing);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('5d'), findsOneWidget);
  });

  testWidgets('WritingStats can hide streak even if streakDays provided', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'one two three');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingStats(
            controller: controller,
            streakDays: 5,
            showStreak: false,
          ),
        ),
      ),
    );

    expect(find.text('Words'), findsOneWidget);
    expect(find.text('Chars'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Streak'), findsNothing);
    expect(find.text('5d'), findsNothing);
  });

  testWidgets(
    'WritingStats renders nothing when counts and streak are hidden',
    (tester) async {
      final controller = TextEditingController(text: 'one two three');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WritingStats(
              controller: controller,
              streakDays: 5,
              showCounts: false,
              showStreak: false,
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsNothing);
      expect(find.text('Words'), findsNothing);
      expect(find.text('Chars'), findsNothing);
      expect(find.text('Read'), findsNothing);
      expect(find.text('Streak'), findsNothing);
    },
  );
}
