import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/focus_wrapper.dart';

void main() {
  testWidgets('FocusWrapper returns child directly when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FocusWrapper(enabled: false, child: Text('X'))),
      ),
    );

    expect(find.text('X'), findsOneWidget);
    expect(find.byType(FocusableActionDetector), findsNothing);
    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets('FocusWrapper shows focus ring via onShowFocusHighlight', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FocusWrapper(
            child: TextButton(onPressed: () {}, child: const Text('X')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final fad = tester.widget<FocusableActionDetector>(
      find.byType(FocusableActionDetector),
    );

    fad.onShowFocusHighlight?.call(true);
    await tester.pump();

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.boxShadow, isNotNull);

    fad.onShowFocusHighlight?.call(false);
    await tester.pump();

    final container2 = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration2 = container2.decoration! as BoxDecoration;
    expect(decoration2.border, isNull);
    expect(decoration2.boxShadow, isNull);
  });

  testWidgets('FocusWrapper disables animation duration when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: FocusWrapper(child: Text('X'))),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(container.duration, Duration.zero);
  });
}
