import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/contrast_alert_dialog.dart';
import 'package:writer/features/reader/widgets/contrast_monitor.dart';
import 'package:writer/features/reader/widgets/contrast_validator.dart';

void main() {
  group('ContrastAlertDialog', () {
    testWidgets('shows no issues dialog when alerts are empty', (
      WidgetTester tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ContrastAlertDialog(onDismiss: () => dismissed = true),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('All Good!'), findsOneWidget);
      expect(
        find.text('All text elements meet WCAG 2.1 AA contrast standards.'),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Contrast Issues Detected'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('shows contrast issues dialog when alerts exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Contrast Issues Detected'), findsOneWidget);
      expect(
        find.text('Found 1 contrast issue(s) that may affect readability.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('displays alert count correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Color(0xFFDDDDDD),
                    accentText: Color(0xFFEEEEEE),
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('Found 3 contrast issue(s) that may affect readability.'),
        findsOneWidget,
      );
    });

    testWidgets('shows Apply Best Fix button for critical alerts', (
      WidgetTester tester,
    ) async {
      bool applyPresetCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ContrastAlertDialog(
                onDismiss: () {},
                onApplyPreset: () => applyPresetCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Apply Best Fix'), findsOneWidget);
      expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);

      await tester.tap(find.text('Apply Best Fix'));
      await tester.pump();

      expect(applyPresetCalled, isTrue);
    });

    testWidgets('hides Apply Best Fix button when no critical alerts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Colors.black,
                    secondaryText: Colors.black87,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('All Good!'), findsOneWidget);
      expect(find.text('Apply Best Fix'), findsNothing);
    });

    testWidgets('displays alert card with severity indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays contrast badge with correct ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      final ratioText = find.textContaining(':1');
      expect(ratioText, findsAtLeastNWidgets(1));
    });

    testWidgets('displays color previews for text and background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Sample'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays suggestion items', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Suggested Fixes:'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsAtLeastNWidgets(1));
    });

    testWidgets('applies suggestion when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(InkWell), findsAtLeastNWidgets(1));

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays multiple alert cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Color(0xFFDDDDDD),
                    accentText: Color(0xFFEEEEEE),
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('calls onDismiss when Ignore button is tapped', (
      WidgetTester tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ContrastAlertDialog(onDismiss: () => dismissed = true),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Ignore'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('works without onApplyPreset callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: ContrastAlertDialog(onDismiss: () {})),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Apply Best Fix'), findsOneWidget);
    });
  });

  group('showContrastAlertDialog', () {
    testWidgets('displays dialog and dismisses on close', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showContrastAlertDialog(context),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('All Good!'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('All Good!'), findsNothing);
    });

    testWidgets('calls onApplyPreset when Apply Best Fix is tapped', (
      WidgetTester tester,
    ) async {
      bool applyPresetCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contrastMonitorProvider.overrideWith(
              (ref) => ContrastMonitorNotifier()
                ..setColors(
                  const ReaderColors(
                    background: Colors.white,
                    primaryText: Color(0xFFCCCCCC),
                    secondaryText: Colors.black,
                    accentText: Colors.black,
                    linkText: Color(0xFF0000EE),
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showContrastAlertDialog(
                    context,
                    onApplyPreset: () => applyPresetCalled = true,
                  ),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Best Fix'));
      await tester.pumpAndSettle();

      expect(applyPresetCalled, isTrue);
      expect(find.text('Contrast Issues Detected'), findsNothing);
    });
  });
}
