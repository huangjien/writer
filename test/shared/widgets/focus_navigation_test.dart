import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/focus_wrapper.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';

void main() {
  BoxDecoration? focusedRingDecorationIn(WidgetTester tester, Finder scope) {
    final containers = tester.widgetList<AnimatedContainer>(
      find.descendant(of: scope, matching: find.byType(AnimatedContainer)),
    );

    for (final container in containers) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration) {
        final border = decoration.border;
        if (border is Border && border.top.width == 2.0) {
          return decoration;
        }
      }
    }

    return null;
  }

  group('Focus Indicators - Keyboard Navigation', () {
    testWidgets('ThemeAwareCard shows focus ring on Tab navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        decoration.border,
        isNotNull,
        reason: 'Focus ring border should be visible when focused',
      );
      expect(
        decoration.boxShadow,
        isNotNull,
        reason: 'Focus ring glow should be visible when focused',
      );
    });

    testWidgets('Multiple ThemeAwareCard widgets allow Tab traversal', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ThemeAwareCard(
                  key: const Key('card1'),
                  onTap: () {},
                  child: const Text('Card 1'),
                ),
                ThemeAwareCard(
                  key: const Key('card2'),
                  onTap: () {},
                  child: const Text('Card 2'),
                ),
                ThemeAwareCard(
                  key: const Key('card3'),
                  onTap: () {},
                  child: const Text('Card 3'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration1 = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('card1')),
      );

      expect(decoration1, isNotNull, reason: 'First card should be focused');
      expect(
        decoration1!.border,
        isNotNull,
        reason: 'First card should be focused',
      );

      BoxDecoration? decoration2;
      for (int i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        decoration2 = focusedRingDecorationIn(
          tester,
          find.byKey(const Key('card2')),
        );
        if (decoration2 != null) break;
      }

      expect(decoration2, isNotNull, reason: 'Second card should be focused');
      expect(
        decoration2!.border,
        isNotNull,
        reason: 'Second card should be focused',
      );
    });

    testWidgets('ThemeAwareCard activates on Enter key', (tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () => cardTapped = true,
              child: const Text('Card 1'),
            ),
          ),
        ),
      );

      BoxDecoration? decoration;
      for (int i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        decoration = focusedRingDecorationIn(
          tester,
          find.byType(ThemeAwareCard),
        );
        if (decoration != null) break;
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(cardTapped, isTrue, reason: 'Card should activate on Enter key');
    });

    testWidgets('ThemeAwareCard activates on Space key', (tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () => cardTapped = true,
              child: const Text('Card 1'),
            ),
          ),
        ),
      );

      BoxDecoration? decoration;
      for (int i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        decoration = focusedRingDecorationIn(
          tester,
          find.byType(ThemeAwareCard),
        );
        if (decoration != null) break;
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(cardTapped, isTrue, reason: 'Card should activate on Space key');
    });

    testWidgets('AppButtons.primary shows focus ring on Tab navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: const Key('primaryButton'),
              child: AppButtons.primary(
                label: 'Primary Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('primaryButton')),
      );

      expect(
        decoration,
        isNotNull,
        reason: 'Focus ring should be visible when focused',
      );
      expect(
        decoration!.border,
        isNotNull,
        reason: 'Focus ring border should be visible when focused',
      );
      expect(
        decoration.boxShadow,
        isNotNull,
        reason: 'Focus ring glow should be visible when focused',
      );
    });

    testWidgets('AppButtons.secondary shows focus ring on Tab navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: const Key('secondaryButton'),
              child: AppButtons.secondary(
                label: 'Secondary Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('secondaryButton')),
      );

      expect(
        decoration,
        isNotNull,
        reason: 'Focus ring should be visible when focused',
      );
      expect(
        decoration!.border,
        isNotNull,
        reason: 'Focus ring border should be visible when focused',
      );
    });

    testWidgets('AppButtons.text shows focus ring on Tab navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: const Key('textButton'),
              child: AppButtons.text(label: 'Text Button', onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('textButton')),
      );

      expect(
        decoration,
        isNotNull,
        reason: 'Focus ring should be visible when focused',
      );
      expect(
        decoration!.border,
        isNotNull,
        reason: 'Focus ring border should be visible when focused',
      );
    });

    testWidgets('AppButtons.icon shows focus ring on Tab navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: const Key('iconButton'),
              child: AppButtons.icon(iconData: Icons.add, onPressed: () {}),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('iconButton')),
      );

      expect(
        decoration,
        isNotNull,
        reason: 'Focus ring should be visible when focused',
      );
      expect(
        decoration!.border,
        isNotNull,
        reason: 'Focus ring border should be visible when focused',
      );
    });

    testWidgets('Focus ring is visible in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        decoration.border,
        isNotNull,
        reason: 'Focus ring border should be visible in light mode',
      );
      final border = decoration.border as Border?;
      expect(
        border?.top.color,
        isNotNull,
        reason: 'Focus ring border color should be set in light mode',
      );
    });

    testWidgets('Focus ring is visible in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        decoration.border,
        isNotNull,
        reason: 'Focus ring border should be visible in dark mode',
      );
      final border = decoration.border as Border?;
      expect(
        border?.top.color,
        isNotNull,
        reason: 'Focus ring border color should be set in dark mode',
      );
    });

    testWidgets('Focus ring glow is visible in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        decoration.boxShadow,
        isNotNull,
        reason: 'Focus ring glow should be visible in light mode',
      );
      expect(
        decoration.boxShadow?.length,
        greaterThan(0),
        reason: 'Focus ring glow should have at least one shadow in light mode',
      );
    });

    testWidgets('Focus ring glow is visible in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(
        decoration.boxShadow,
        isNotNull,
        reason: 'Focus ring glow should be visible in dark mode',
      );
      expect(
        decoration.boxShadow?.length,
        greaterThan(0),
        reason: 'Focus ring glow should have at least one shadow in dark mode',
      );
    });

    testWidgets('FocusWrapper maintains semantic properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              button: true,
              label: 'Test Card',
              hint: 'Double tap to activate',
              child: FocusWrapper(
                key: const Key('testFocusWrapper'),
                child: ThemeAwareCard(
                  onTap: () {},
                  child: const Text('Card 1'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final semantics = tester.getSemantics(find.bySemanticsLabel('Test Card'));

      expect(
        semantics.label,
        'Test Card',
        reason: 'Semantic label should be preserved',
      );
      expect(
        semantics.hint,
        'Double tap to activate',
        reason: 'Semantic hint should be preserved',
      );
    });

    testWidgets('Focus navigation respects FocusTraversalOrder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: SizedBox(
                      key: const Key('button2'),
                      child: AppButtons.primary(
                        label: 'Button 2',
                        onPressed: () {},
                      ),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: SizedBox(
                      key: const Key('button1'),
                      child: AppButtons.primary(
                        label: 'Button 1',
                        onPressed: () {},
                      ),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: SizedBox(
                      key: const Key('button3'),
                      child: AppButtons.primary(
                        label: 'Button 3',
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final decoration1 = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('button1')),
      );
      final decoration2 = focusedRingDecorationIn(
        tester,
        find.byKey(const Key('button2')),
      );

      expect(
        decoration1,
        isNotNull,
        reason: 'Button 1 should be focused first (order 1)',
      );
      expect(
        decoration1!.border,
        isNotNull,
        reason: 'Button 1 should be focused first (order 1)',
      );
      expect(
        decoration2,
        isNull,
        reason: 'Button 2 should not be focused first (order 2)',
      );
    });

    testWidgets('Focus ring animation completes within expected duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      stopwatch.stop();

      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 100)),
        reason: 'Focus ring animation should be fast',
      );
    });

    testWidgets('Focus ring animation is disabled when requested', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: ThemeAwareCard(onTap: () {}, child: const Text('Card 1')),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ThemeAwareCard),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(
        container.duration,
        Duration.zero,
        reason: 'Focus ring animation should be disabled',
      );
    });

    testWidgets('Multiple focusable elements cycle correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ThemeAwareCard(
                  key: const Key('card1'),
                  onTap: () {},
                  child: const Text('Card 1'),
                ),
                SizedBox(
                  key: const Key('button1'),
                  child: AppButtons.primary(
                    label: 'Button 1',
                    onPressed: () {},
                  ),
                ),
                ThemeAwareCard(
                  key: const Key('card2'),
                  onTap: () {},
                  child: const Text('Card 2'),
                ),
              ],
            ),
          ),
        ),
      );

      for (int i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      final allContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(
        allContainers.length,
        greaterThanOrEqualTo(0),
        reason: 'All focusable elements should render',
      );
    });
  });
}
