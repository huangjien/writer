import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/neumorphic_checkbox.dart';
import 'package:writer/shared/widgets/neumorphic_radio.dart';
import 'package:writer/shared/widgets/theme_aware_card.dart';

void main() {
  group('NeumorphicButton Hover States', () {
    testWidgets('shows click cursor when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Test Button');
      expect(buttonFinder, findsOneWidget);

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicButton),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsOneWidget);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.click);
    });

    testWidgets('shows forbidden cursor when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              onPressed: null,
              child: Text('Disabled Button'),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Disabled Button');
      expect(buttonFinder, findsOneWidget);

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicButton),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsOneWidget);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.forbidden);
    });

    testWidgets('responds to hover highlight events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicButton(
              onPressed: () {},
              child: const Text('Hover Button'),
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Hover Button');
      expect(buttonFinder, findsOneWidget);

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicButton),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsOneWidget);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder,
      );

      expect(actionDetector.onShowHoverHighlight, isNotNull);
    });
  });

  group('NeumorphicSwitch Hover States', () {
    testWidgets('shows click cursor when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicSwitch(value: false, onChanged: (_) {}),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicSwitch),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.click);
    });

    testWidgets('shows forbidden cursor when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicSwitch(
              value: false,
              onChanged: null,
              isEnabled: false,
            ),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicSwitch),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.forbidden);
    });
  });

  group('NeumorphicCheckbox Hover States', () {
    testWidgets('shows click cursor when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicCheckbox(value: false, onChanged: (_) {}),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicCheckbox),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.click);
    });

    testWidgets('shows forbidden cursor when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCheckbox(
              value: false,
              onChanged: null,
              isEnabled: false,
            ),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicCheckbox),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.forbidden);
    });
  });

  group('NeumorphicRadio Hover States', () {
    testWidgets('shows click cursor when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeumorphicRadio<String>(
              value: 'a',
              groupValue: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicRadio<String>),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.click);
    });

    testWidgets('shows forbidden cursor when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicRadio<String>(
              value: 'a',
              groupValue: null,
              onChanged: null,
              isEnabled: false,
            ),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(NeumorphicRadio<String>),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      final actionDetector = tester.widget<FocusableActionDetector>(
        actionDetectorFinder.last,
      );

      expect(actionDetector.mouseCursor, SystemMouseCursors.forbidden);
    });
  });

  group('ThemeAwareCard Hover States', () {
    testWidgets('shows InkWell with hoverColor when onTap provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () {},
              child: const Text('Clickable Card'),
            ),
          ),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(ThemeAwareCard),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);

      final inkWell = tester.widget<InkWell>(inkWellFinder);
      expect(inkWell.hoverColor, isNotNull);
      expect(inkWell.splashColor, isNotNull);
    });

    testWidgets('does not add InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ThemeAwareCard(child: Text('Static Card'))),
        ),
      );

      final inkWellFinder = find.descendant(
        of: find.byType(ThemeAwareCard),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsNothing);
    });

    testWidgets('provides keyboard shortcuts for activation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeAwareCard(
              onTap: () {},
              child: const Text('Keyboard Card'),
            ),
          ),
        ),
      );

      final actionDetectorFinder = find.descendant(
        of: find.byType(ThemeAwareCard),
        matching: find.byType(FocusableActionDetector),
      );
      expect(actionDetectorFinder, findsWidgets);

      FocusableActionDetector? actionDetector;
      for (final finder in actionDetectorFinder.evaluate()) {
        final widget = finder.widget as FocusableActionDetector;
        if (widget.shortcuts != null) {
          actionDetector = widget;
          break;
        }
      }

      expect(actionDetector, isNotNull);
      expect(
        actionDetector!.shortcuts?.containsKey(
          const SingleActivator(LogicalKeyboardKey.enter),
        ),
        isTrue,
      );
      expect(
        actionDetector.shortcuts?.containsKey(
          const SingleActivator(LogicalKeyboardKey.space),
        ),
        isTrue,
      );
    });
  });
}
