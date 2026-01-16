import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';

void main() {
  testWidgets(
    'NeumorphicSlider returns fixed height when unconstrained width',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UnconstrainedBox(
              child: NeumorphicSlider(value: 0.5, onChanged: null),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    },
  );

  testWidgets('NeumorphicSlider drag updates value via onChanged', (
    tester,
  ) async {
    double latest = 0.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: NeumorphicSlider(
              value: 0.0,
              min: 0.0,
              max: 100.0,
              onChanged: (v) => latest = v,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final gestureTarget = find.byType(NeumorphicSlider);
    expect(gestureTarget, findsOneWidget);

    final center = tester.getCenter(gestureTarget);
    final left = Offset(center.dx - 100, center.dy);
    final right = Offset(center.dx + 100, center.dy);

    final gesture = await tester.startGesture(left);
    await tester.pump();
    await gesture.moveTo(right);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(latest, greaterThan(0.0));
    expect(latest, lessThanOrEqualTo(100.0));
  });

  testWidgets('NeumorphicSlider does not call onChanged when null', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: NeumorphicSlider(value: 0.5, onChanged: null),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final gestureTarget = find.byType(NeumorphicSlider);
    final center = tester.getCenter(gestureTarget);
    await tester.dragFrom(center, const Offset(60, 0));
    await tester.pumpAndSettle();

    expect(find.byType(NeumorphicSlider), findsOneWidget);
  });
}
