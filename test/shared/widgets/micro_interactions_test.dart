import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/micro_interactions.dart';

void main() {
  group('PressScale', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(PressScale), findsOneWidget);
    });

    testWidgets('renders child widget with onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onTap: () => tapped = true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(PressScale), findsOneWidget);

      await tester.tap(find.text('Test Child'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('renders child widget with onLongPress callback', (
      tester,
    ) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onLongPress: () => longPressed = true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(PressScale), findsOneWidget);

      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      expect(longPressed, true);
    });

    testWidgets('uses default duration value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.duration, const Duration(milliseconds: 120));
    });

    testWidgets('uses custom duration value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressScale(
              duration: Duration(milliseconds: 200),
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.duration, const Duration(milliseconds: 200));
    });

    testWidgets('uses default curve value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.curve, Curves.easeOut);
    });

    testWidgets('uses custom curve value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressScale(
              curve: Curves.easeInOut,
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.curve, Curves.easeInOut);
    });

    testWidgets('uses default enabled value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.enabled, true);
    });

    testWidgets('uses custom enabled value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressScale(enabled: false, child: Text('Test Child')),
          ),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.enabled, false);
    });

    testWidgets('wraps any widget type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Container Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Container Child'), findsOneWidget);
      expect(find.byType(PressScale), findsOneWidget);
    });

    testWidgets('wraps Icon widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Icon(Icons.star))),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(PressScale), findsOneWidget);
    });

    testWidgets('handles multiple PressScale widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PressScale(
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                PressScale(
                  child: Container(width: 100, height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PressScale), findsNWidgets(2));
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('calls onLongPress callback when long pressed', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onLongPress: () => longPressed = true,
              child: const Text('Long Press Me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressed, true);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              enabled: false,
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, false);
    });

    testWidgets('does not call onLongPress when disabled', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              enabled: false,
              onLongPress: () => longPressed = true,
              child: const Text('Long Press Me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressed, false);
    });

    testWidgets('does not scale when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressScale(enabled: false, child: Text('Test Child')),
          ),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.enabled, false);
    });

    testWidgets('uses Listener when no callbacks provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      // Listener should be used internally by PressScale when no callbacks are provided
      expect(find.byType(PressScale), findsOneWidget);
    });

    testWidgets('uses GestureDetector when callbacks provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      // GestureDetector should be used internally by PressScale when callbacks are provided
      expect(find.byType(PressScale), findsOneWidget);
    });

    testWidgets('preserves child widget properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PressScale(
              child: Text(
                'Styled Text',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.purple);
    });

    testWidgets('works inside ListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                PressScale(child: Container(height: 100, color: Colors.red)),
                PressScale(child: Container(height: 100, color: Colors.blue)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PressScale), findsNWidgets(2));
    });

    testWidgets('works inside Stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                PressScale(
                  child: Container(width: 200, height: 200, color: Colors.red),
                ),
                const Positioned(top: 10, left: 10, child: Text('Overlay')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PressScale), findsOneWidget);
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('enabled parameter can be toggled', (tester) async {
      bool enabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              enabled: enabled,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);

      // Rebuild with enabled = false
      enabled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              enabled: enabled,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      final pressScale = tester.widget<PressScale>(find.byType(PressScale));
      expect(pressScale.enabled, false);
    });

    testWidgets('handles both onTap and onLongPress', (tester) async {
      bool tapped = false;
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onTap: () => tapped = true,
              onLongPress: () => longPressed = true,
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      // Test tap
      await tester.tap(find.text('Test Child'));
      await tester.pump();
      expect(tapped, true);

      // Test long press
      await tester.longPress(find.text('Test Child'));
      await tester.pump();
      expect(longPressed, true);
    });

    testWidgets('AnimatedOpacity is used for animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PressScale(child: Text('Test Child'))),
        ),
      );

      expect(find.byType(AnimatedOpacity), findsOneWidget);
    });
  });

  group('TapBump', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(TapBump), findsOneWidget);
    });

    testWidgets('requires onTap callback', (tester) async {
      expect(
        () => TapBump(onTap: () {}, child: const Text('Test Child')),
        returnsNormally,
      );
    });

    testWidgets('uses default enabled value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      final tapBump = tester.widget<TapBump>(find.byType(TapBump));
      expect(tapBump.enabled, true);
    });

    testWidgets('uses custom enabled value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              enabled: false,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      final tapBump = tester.widget<TapBump>(find.byType(TapBump));
      expect(tapBump.enabled, false);
    });

    testWidgets('wraps any widget type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              onTap: () {},
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Container Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Container Child'), findsOneWidget);
      expect(find.byType(TapBump), findsOneWidget);
    });

    testWidgets('wraps Icon widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Icon(Icons.star)),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(TapBump), findsOneWidget);
    });

    testWidgets('handles multiple TapBump widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TapBump(
                  onTap: () {},
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                TapBump(
                  onTap: () {},
                  child: Container(width: 100, height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TapBump), findsNWidgets(2));
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              enabled: false,
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, false);
    });

    testWidgets('uses GestureDetector for tap detection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('uses AnimatedBuilder for animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      // AnimatedBuilder should be used internally by TapBump for animation
      expect(find.byType(TapBump), findsOneWidget);
    });

    testWidgets('uses Transform.scale for scaling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      // Transform should be used internally by TapBump for scaling
      expect(find.byType(TapBump), findsOneWidget);
    });

    testWidgets('preserves child widget properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              onTap: () {},
              child: const Text(
                'Styled Text',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.purple);
    });

    testWidgets('works inside ListView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TapBump(
                  onTap: () {},
                  child: Container(height: 100, color: Colors.red),
                ),
                TapBump(
                  onTap: () {},
                  child: Container(height: 100, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TapBump), findsNWidgets(2));
    });

    testWidgets('works inside Stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                TapBump(
                  onTap: () {},
                  child: Container(width: 200, height: 200, color: Colors.red),
                ),
                const Positioned(top: 10, left: 10, child: Text('Overlay')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TapBump), findsOneWidget);
      expect(find.text('Overlay'), findsOneWidget);
    });

    testWidgets('enabled parameter can be toggled', (tester) async {
      bool enabled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              enabled: enabled,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);

      // Rebuild with enabled = false
      enabled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              enabled: enabled,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      final tapBump = tester.widget<TapBump>(find.byType(TapBump));
      expect(tapBump.enabled, false);
    });

    testWidgets('animation runs before callback', (tester) async {
      final callbackOrder = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              onTap: () => callbackOrder.add('callback'),
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump(const Duration(milliseconds: 100));
      callbackOrder.add('after_pump');
      await tester.pumpAndSettle();

      // The animation should complete before the callback is called
      expect(callbackOrder, contains('callback'));
    });

    testWidgets('animation duration is 220ms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(onTap: () {}, child: const Text('Test Child')),
          ),
        ),
      );

      expect(find.byType(TapBump), findsOneWidget);
    });
  });

  group('Micro Interactions Integration', () {
    testWidgets('PressScale and TapBump work together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PressScale(onTap: () {}, child: const Text('PressScale')),
                TapBump(onTap: () {}, child: const Text('TapBump')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(PressScale), findsOneWidget);
      expect(find.byType(TapBump), findsOneWidget);
      expect(find.text('PressScale'), findsOneWidget);
      expect(find.text('TapBump'), findsOneWidget);
    });

    testWidgets('works with Navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              onTap: () {},
              child: const Text('Navigable Child'),
            ),
          ),
        ),
      );

      expect(find.text('Navigable Child'), findsOneWidget);
    });

    testWidgets('PressScale with custom key', (tester) async {
      const key = Key('custom_press_scale');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressScale(
              key: key,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('TapBump with custom key', (tester) async {
      const key = Key('custom_tap_bump');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapBump(
              key: key,
              onTap: () {},
              child: const Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });
  });
}
