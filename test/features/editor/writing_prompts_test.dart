import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/writing_prompts.dart';

void main() {
  testWidgets('WritingPromptsSheet shows prompts and inserts on tap', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? inserted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WritingPromptsSheet(onInsert: (p) => inserted = p),
        ),
      ),
    );

    expect(find.text('Pick a prompt to insert'), findsOneWidget);

    const firstPrompt =
        'Write a scene where a small mistake changes everything.';
    const secondPrompt = 'Describe a room using only sounds and textures.';

    expect(find.text(firstPrompt), findsOneWidget);
    expect(find.text(secondPrompt), findsOneWidget);

    await tester.tap(find.text(secondPrompt));
    await tester.pump();

    expect(inserted, secondPrompt);
  });
}
