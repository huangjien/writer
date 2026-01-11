import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/editor/focus_timer.dart';

void main() {
  testWidgets('FocusTimerSheet starts, pauses, and resets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FocusTimerSheet())),
    );

    expect(find.text('25:00'), findsOneWidget);

    LinearProgressIndicator progress() => tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

    expect(progress().value, 0);

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:59'), findsOneWidget);
    expect(progress().value, closeTo(1 / 1500, 0.0002));

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Start'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('24:59'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(progress().value, 0);
  });
}
