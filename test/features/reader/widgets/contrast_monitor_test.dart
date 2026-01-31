import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/contrast_monitor.dart';
import 'package:writer/features/reader/widgets/contrast_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContrastSeverity', () {
    test('has three severity levels', () {
      expect(ContrastSeverity.values.length, 3);
      expect(ContrastSeverity.values, contains(ContrastSeverity.ok));
      expect(ContrastSeverity.values, contains(ContrastSeverity.warning));
      expect(ContrastSeverity.values, contains(ContrastSeverity.error));
    });
  });

  group('AdjustmentSuggestion', () {
    test('creates suggestion with all properties', () {
      const suggestion = AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Colors.black,
        suggestedBackground: Colors.white,
        improvedRatio: 21.0,
      );

      expect(suggestion.description, 'Darken foreground');
      expect(suggestion.suggestedForeground, Colors.black);
      expect(suggestion.suggestedBackground, Colors.white);
      expect(suggestion.improvedRatio, 21.0);
    });
  });

  group('ContrastAlert', () {
    test('creates alert with all properties', () {
      const alert = ContrastAlert(
        elementName: 'Primary Text',
        foreground: Colors.black,
        background: Colors.white,
        contrastRatio: 21.0,
        severity: ContrastSeverity.ok,
        message: 'Excellent contrast',
        suggestions: [],
      );

      expect(alert.elementName, 'Primary Text');
      expect(alert.foreground, Colors.black);
      expect(alert.background, Colors.white);
      expect(alert.contrastRatio, 21.0);
      expect(alert.severity, ContrastSeverity.ok);
      expect(alert.message, 'Excellent contrast');
      expect(alert.suggestions, isEmpty);
    });

    test('identifies critical alerts', () {
      const criticalAlert = ContrastAlert(
        elementName: 'Primary Text',
        foreground: Colors.grey,
        background: Colors.white,
        contrastRatio: 3.0,
        severity: ContrastSeverity.error,
        message: 'Low contrast',
        suggestions: [],
      );

      expect(criticalAlert.isCritical, isTrue);
    });

    test('non-critical alerts are not critical', () {
      const warningAlert = ContrastAlert(
        elementName: 'Primary Text',
        foreground: Colors.black,
        background: Colors.white,
        contrastRatio: 5.0,
        severity: ContrastSeverity.warning,
        message: 'Acceptable contrast',
        suggestions: [],
      );

      expect(warningAlert.isCritical, isFalse);
    });
  });

  group('ContrastMonitor', () {
    test('determines error severity for ratios below 4.5', () {
      expect(ContrastMonitor.determineSeverity(3.0), ContrastSeverity.error);
      expect(ContrastMonitor.determineSeverity(4.4), ContrastSeverity.error);
    });

    test('determines warning severity for ratios between 4.5 and 7.0', () {
      expect(ContrastMonitor.determineSeverity(4.5), ContrastSeverity.warning);
      expect(ContrastMonitor.determineSeverity(5.0), ContrastSeverity.warning);
      expect(ContrastMonitor.determineSeverity(6.9), ContrastSeverity.warning);
    });

    test('determines ok severity for ratios 7.0 and above', () {
      expect(ContrastMonitor.determineSeverity(7.0), ContrastSeverity.ok);
      expect(ContrastMonitor.determineSeverity(10.0), ContrastSeverity.ok);
      expect(ContrastMonitor.determineSeverity(21.0), ContrastSeverity.ok);
    });

    test('monitors reader colors with all valid combinations', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts, isEmpty);
    });

    test('detects invalid primary text contrast', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].elementName, 'Primary Text');
      expect(alerts[0].severity, ContrastSeverity.error);
      expect(alerts[0].contrastRatio, lessThan(4.5));
    });

    test('detects invalid secondary text contrast', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFFDDDDDD),
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].elementName, 'Secondary Text');
      expect(alerts[0].severity, ContrastSeverity.error);
    });

    test('detects invalid accent text contrast', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Color(0xFFEEEEEE),
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].elementName, 'Accent Text');
      expect(alerts[0].severity, ContrastSeverity.error);
    });

    test('detects invalid link text contrast', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFF888888),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].elementName, 'Link Text');
      expect(alerts[0].severity, ContrastSeverity.error);
    });

    test('detects multiple invalid color combinations', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Color(0xFFDDDDDD),
        accentText: Color(0xFFEEEEEE),
        linkText: Color(0xFFBBBBBB),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 4);
      expect(alerts.map((a) => a.elementName), contains('Primary Text'));
      expect(alerts.map((a) => a.elementName), contains('Secondary Text'));
      expect(alerts.map((a) => a.elementName), contains('Accent Text'));
      expect(alerts.map((a) => a.elementName), contains('Link Text'));
    });

    test('alerts contain adjustment suggestions', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].suggestions, isNotEmpty);
      expect(
        alerts[0].suggestions.first.improvedRatio,
        greaterThan(alerts[0].contrastRatio),
      );
    });

    test('alerts contain descriptive messages', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].message, contains('Primary Text'));
      expect(alerts[0].message, contains('contrast'));
    });

    test('alerts store correct color information', () {
      final foreground = const Color(0xFFCCCCCC);
      final background = Colors.white;

      final colors = ReaderColors(
        background: background,
        primaryText: foreground,
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: const Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);

      expect(alerts.length, 1);
      expect(alerts[0].foreground, foreground);
      expect(alerts[0].background, background);
    });
  });

  group('ContrastMonitorNotifier', () {
    test('initializes with empty state', () {
      final notifier = ContrastMonitorNotifier();

      expect(notifier.state, isEmpty);
      expect(notifier.hasAlerts, isFalse);
      expect(notifier.criticalAlerts, isEmpty);
    });

    test('sets colors and validates them', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);

      expect(notifier.state, isEmpty);
      expect(notifier.hasAlerts, isFalse);
    });

    test('sets colors with invalid combinations produces alerts', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);

      expect(notifier.state.length, 1);
      expect(notifier.hasAlerts, isTrue);
      expect(notifier.criticalAlerts.length, 1);
    });

    test('updates individual color field', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      notifier.updateColor(primaryText: Colors.black);
      expect(notifier.state, isEmpty);
      expect(notifier.hasAlerts, isFalse);
    });

    test('updates background color', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state, isEmpty);

      notifier.updateColor(background: const Color(0xFF999999));
      expect(notifier.hasAlerts, isTrue);
    });

    test('updates secondary text color', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFFDDDDDD),
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      notifier.updateColor(secondaryText: Colors.black87);
      expect(notifier.state, isEmpty);
    });

    test('updates accent text color', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Color(0xFFEEEEEE),
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      notifier.updateColor(accentText: Colors.black);
      expect(notifier.state, isEmpty);
    });

    test('updates link text color', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFFBBBBBB),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      notifier.updateColor(linkText: const Color(0xFF0000EE));
      expect(notifier.state, isEmpty);
    });

    test('does nothing when updating colors before setting them', () {
      final notifier = ContrastMonitorNotifier();

      notifier.updateColor(primaryText: Colors.black);
      expect(notifier.state, isEmpty);
      expect(notifier.hasAlerts, isFalse);
    });

    test('applies suggestion to primary text', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      final suggestion = const AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Colors.black,
        suggestedBackground: Colors.white,
        improvedRatio: 21.0,
      );

      notifier.applySuggestion(suggestion, 'Primary Text');
      expect(notifier.state, isEmpty);
    });

    test('applies suggestion to secondary text', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFFDDDDDD),
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      final suggestion = const AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Colors.black87,
        suggestedBackground: Colors.white,
        improvedRatio: 18.0,
      );

      notifier.applySuggestion(suggestion, 'Secondary Text');
      expect(notifier.state, isEmpty);
    });

    test('applies suggestion to accent text', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Color(0xFFEEEEEE),
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      final suggestion = const AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Colors.black,
        suggestedBackground: Colors.white,
        improvedRatio: 21.0,
      );

      notifier.applySuggestion(suggestion, 'Accent Text');
      expect(notifier.state, isEmpty);
    });

    test('applies suggestion to link text', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Colors.black87,
        accentText: Colors.black,
        linkText: Color(0xFFBBBBBB),
      );

      notifier.setColors(colors);
      expect(notifier.state.length, 1);

      final suggestion = const AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Color(0xFF0000EE),
        suggestedBackground: Colors.white,
        improvedRatio: 8.5,
      );

      notifier.applySuggestion(suggestion, 'Link Text');
      expect(notifier.state, isEmpty);
    });

    test('does not apply suggestion when colors are not set', () {
      final notifier = ContrastMonitorNotifier();

      final suggestion = const AdjustmentSuggestion(
        description: 'Darken foreground',
        suggestedForeground: Colors.black,
        suggestedBackground: Colors.white,
        improvedRatio: 21.0,
      );

      notifier.applySuggestion(suggestion, 'Primary Text');
      expect(notifier.state, isEmpty);
    });

    test('correctly identifies critical alerts', () {
      final notifier = ContrastMonitorNotifier();

      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Color(0xFFDDDDDD),
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(colors);

      expect(notifier.hasAlerts, isTrue);
      expect(notifier.criticalAlerts.length, 2);
      expect(
        notifier.criticalAlerts.every((alert) => alert.isCritical),
        isTrue,
      );
    });
  });

  group('ContrastWidget', () {
    testWidgets('displays child widget without alert badge when no alerts', (
      WidgetTester tester,
    ) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContrastWidget(
                child: const Text('Content'),
                onContrastIssue: () => callbackCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsNothing);
      expect(callbackCalled, isFalse);
    });

    testWidgets('displays alert badge when critical alerts exist', (
      WidgetTester tester,
    ) async {
      bool callbackCalled = false;

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
              body: ContrastWidget(
                child: const Text('Content'),
                onContrastIssue: () => callbackCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Content'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(callbackCalled, isTrue);
    });

    testWidgets('displays correct alert count', (WidgetTester tester) async {
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
          child: const MaterialApp(
            home: Scaffold(body: ContrastWidget(child: Text('Content'))),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('alert badge is positioned at top right', (
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
          child: const MaterialApp(
            home: Scaffold(body: ContrastWidget(child: Text('Content'))),
          ),
        ),
      );

      await tester.pump();

      final badge = find.byIcon(Icons.warning);
      final badgeWidget = tester.widget(badge) as Icon;

      expect(badge, findsOneWidget);
      expect(badgeWidget.color, Colors.white);
      expect(badgeWidget.size, 16);
    });

    testWidgets('does not call callback when no alerts', (
      WidgetTester tester,
    ) async {
      int callbackCount = 0;

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
            home: Scaffold(
              body: ContrastWidget(
                child: const Text('Content'),
                onContrastIssue: () => callbackCount++,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(callbackCount, 0);
    });

    testWidgets('calls callback when alerts are detected', (
      WidgetTester tester,
    ) async {
      int callbackCount = 0;

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
                    linkText: Colors.blue,
                  ),
                ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ContrastWidget(
                child: const Text('Content'),
                onContrastIssue: () => callbackCount++,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(callbackCount, 1);
    });

    testWidgets('works without callback', (WidgetTester tester) async {
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
          child: const MaterialApp(
            home: Scaffold(body: ContrastWidget(child: Text('Content'))),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    test('full workflow: set colors, detect alerts, apply suggestion', () {
      final notifier = ContrastMonitorNotifier();

      final initialColors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      notifier.setColors(initialColors);
      expect(notifier.state.length, 1);
      expect(notifier.hasAlerts, isTrue);

      final suggestion = notifier.state.first.suggestions.first;
      notifier.applySuggestion(suggestion, 'Primary Text');

      expect(notifier.state, isEmpty);
      expect(notifier.hasAlerts, isFalse);
    });

    test('full workflow: update colors incrementally', () {
      final notifier = ContrastMonitorNotifier();

      final initialColors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Color(0xFFDDDDDD),
        accentText: Color(0xFFEEEEEE),
        linkText: Color(0xFF999999),
      );

      notifier.setColors(initialColors);
      expect(notifier.state.length, 4);

      notifier.updateColor(primaryText: Colors.black);
      expect(notifier.state.length, 3);

      notifier.updateColor(secondaryText: Colors.black87);
      expect(notifier.state.length, 2);

      notifier.updateColor(accentText: Colors.black);
      expect(notifier.state.length, 1);

      notifier.updateColor(linkText: const Color(0xFF0000EE));
      expect(notifier.state, isEmpty);
    });

    test('monitor returns suggestions sorted by improved ratio', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Colors.blue,
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);
      final suggestions = alerts.first.suggestions;

      expect(suggestions, isNotEmpty);

      for (int i = 0; i < suggestions.length - 1; i++) {
        expect(
          suggestions[i].improvedRatio,
          greaterThanOrEqualTo(suggestions[i + 1].improvedRatio),
        );
      }
    });

    test('monitor limits suggestions to top 5', () {
      final colors = const ReaderColors(
        background: Colors.white,
        primaryText: Color(0xFFCCCCCC),
        secondaryText: Colors.black,
        accentText: Colors.black,
        linkText: Color(0xFF0000EE),
      );

      final alerts = ContrastMonitor.monitorReaderColors(colors);
      final suggestions = alerts.first.suggestions;

      expect(suggestions.length, lessThanOrEqualTo(5));
    });
  });
}
