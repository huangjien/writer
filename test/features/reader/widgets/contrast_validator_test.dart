import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/contrast_validator.dart';
import 'package:writer/theme/accessibility/contrast_checker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContrastValidator', () {
    test('validates high contrast colors', () {
      final result = ContrastValidator.validateColors(
        Colors.black,
        Colors.white,
      );

      expect(result.foreground, Colors.black);
      expect(result.background, Colors.white);
      expect(result.isValid, isTrue);
      expect(result.contrastResult.passesAA, isTrue);
    });

    test('validates low contrast colors', () {
      final result = ContrastValidator.validateColors(
        const Color(0xFFCCCCCC),
        const Color(0xFFDDDDDD),
      );

      expect(result.isValid, isFalse);
      expect(result.contrastResult.passesAA, isFalse);
    });

    test('validates mid-contrast colors at AA threshold', () {
      final result = ContrastValidator.validateColors(
        const Color(0xFF000000),
        const Color(0xFF7D7D7D),
      );

      expect(result.contrastResult.ratio, greaterThanOrEqualTo(4.5));
    });

    test('validates text style with explicit color', () {
      const style = TextStyle(color: Colors.black);
      final result = ContrastValidator.validateTextStyle(style, Colors.white);

      expect(result.foreground, Colors.black);
      expect(result.background, Colors.white);
    });

    test('validates text style without color defaults to black', () {
      const style = TextStyle();
      final result = ContrastValidator.validateTextStyle(style, Colors.white);

      expect(result.foreground, Colors.black);
    });

    test('validates multiple text elements', () {
      final pairs = {
        Colors.black: Colors.white,
        Colors.white: Colors.black,
        const Color(0xFFCCCCCC): const Color(0xFFDDDDDD),
      };

      final results = ContrastValidator.validateMultipleTextElements(pairs);

      expect(results.length, 3);
      expect(results[0].isValid, isTrue);
      expect(results[1].isValid, isTrue);
      expect(results[2].isValid, isFalse);
    });

    test('generates report for all passing results', () {
      final results = [
        ContrastValidator.validateColors(Colors.black, Colors.white),
        ContrastValidator.validateColors(Colors.white, Colors.black),
      ];

      final report = ContrastValidator.generateReport(results);

      expect(report.totalChecks, 2);
      expect(report.passed, 2);
      expect(report.failed, 0);
      expect(report.allPassed, isTrue);
      expect(report.passPercentage, 100);
    });

    test('generates report for mixed results', () {
      final results = [
        ContrastValidator.validateColors(Colors.black, Colors.white),
        ContrastValidator.validateColors(
          const Color(0xFFCCCCCC),
          const Color(0xFFDDDDDD),
        ),
      ];

      final report = ContrastValidator.generateReport(results);

      expect(report.totalChecks, 2);
      expect(report.passed, 1);
      expect(report.failed, 1);
      expect(report.allPassed, isFalse);
      expect(report.passPercentage, 50);
    });

    test('generates report for all failing results', () {
      final results = [
        ContrastValidator.validateColors(
          const Color(0xFFCCCCCC),
          const Color(0xFFDDDDDD),
        ),
      ];

      final report = ContrastValidator.generateReport(results);

      expect(report.totalChecks, 1);
      expect(report.passed, 0);
      expect(report.failed, 1);
      expect(report.allPassed, isFalse);
      expect(report.passPercentage, 0);
    });

    test('generates empty report', () {
      final results = <ContrastValidationResult>[];

      final report = ContrastValidator.generateReport(results);

      expect(report.totalChecks, 0);
      expect(report.passed, 0);
      expect(report.failed, 0);
      expect(report.allPassed, isTrue);
      expect(report.passPercentage, 0);
    });
  });

  group('ContrastReport', () {
    test('calculates pass percentage correctly', () {
      const report = ContrastReport(
        totalChecks: 10,
        passed: 8,
        failed: 2,
        failedResults: [],
        allPassed: false,
      );

      expect(report.passPercentage, 80);
    });

    test('handles zero total checks', () {
      const report = ContrastReport(
        totalChecks: 0,
        passed: 0,
        failed: 0,
        failedResults: [],
        allPassed: true,
      );

      expect(report.passPercentage, 0);
    });

    test('generates success summary', () {
      const report = ContrastReport(
        totalChecks: 5,
        passed: 5,
        failed: 0,
        failedResults: [],
        allPassed: true,
      );

      expect(report.summary, 'All 5 contrast checks passed!');
    });

    test('generates failure summary', () {
      const report = ContrastReport(
        totalChecks: 10,
        passed: 7,
        failed: 3,
        failedResults: [],
        allPassed: false,
      );

      expect(report.summary, '3 of 10 contrast checks failed');
    });
  });

  group('ContrastValidationNotifier', () {
    test('validates colors and updates state', () {
      final notifier = ContrastValidationNotifier();

      notifier.validate(Colors.black, Colors.white);

      expect(notifier.state, isNotNull);
      expect(notifier.state!.isValid, isTrue);
      expect(notifier.state!.foreground, Colors.black);
      expect(notifier.state!.background, Colors.white);
    });

    test('validates low contrast colors', () {
      final notifier = ContrastValidationNotifier();

      notifier.validate(const Color(0xFFCCCCCC), const Color(0xFFDDDDDD));

      expect(notifier.state!.isValid, isFalse);
    });

    test('resets state to null', () {
      final notifier = ContrastValidationNotifier();

      notifier.validate(Colors.black, Colors.white);
      expect(notifier.state, isNotNull);

      notifier.reset();
      expect(notifier.state, isNull);
    });

    test('updates state on new validation', () {
      final notifier = ContrastValidationNotifier();

      notifier.validate(Colors.black, Colors.white);
      expect(notifier.state!.foreground, Colors.black);

      notifier.validate(Colors.white, Colors.black);
      expect(notifier.state!.foreground, Colors.white);
    });
  });

  group('ReaderColors', () {
    testWidgets('creates reader colors from light theme', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final readerColors = ReaderColors.fromTheme(context);

              expect(
                readerColors.background,
                equals(theme.colorScheme.surface),
              );
              expect(readerColors.primaryText, isNotNull);
              expect(readerColors.secondaryText, isNotNull);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('creates reader colors from dark theme', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData.dark();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              final readerColors = ReaderColors.fromTheme(context);

              expect(
                readerColors.background,
                equals(theme.colorScheme.surface),
              );
              expect(readerColors.primaryText, isNotNull);
              return Container();
            },
          ),
        ),
      );
    });

    test('validates all reader colors with high contrast', () {
      const readerColors = ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFF424242),
        accentText: Colors.black,
        linkText: Colors.black,
      );

      final results = readerColors.validateAll();

      expect(results.length, 4);
      expect(results.every((r) => r.isValid), isTrue);
    });

    test('validates all reader colors with mixed contrast', () {
      const readerColors = ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFFCCCCCC),
        accentText: Colors.black,
        linkText: Colors.black,
      );

      final results = readerColors.validateAll();

      expect(results.length, 4);
      expect(results.where((r) => r.isValid).length, 3);
    });

    test('generates report for all valid colors', () {
      const readerColors = ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFF424242),
        accentText: Colors.black,
        linkText: Colors.black,
      );

      final report = readerColors.generateReport();

      expect(report.allPassed, isTrue);
      expect(report.passed, 4);
      expect(report.failed, 0);
    });

    test('generates report with failed colors', () {
      const readerColors = ReaderColors(
        background: Colors.white,
        primaryText: Colors.black,
        secondaryText: Color(0xFFCCCCCC),
        accentText: Colors.black,
        linkText: Colors.black,
      );

      final report = readerColors.generateReport();

      expect(report.allPassed, isFalse);
      expect(report.failed, greaterThan(0));
    });
  });

  group('ReaderColorsNotifier', () {
    testWidgets('updates individual color - background', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                notifier!.updateColor(background: Colors.red);
                expect(notifier!.state.background, Colors.red);
                expect(notifier!.state.primaryText, isNotNull);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('updates individual color - primary text', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                notifier!.updateColor(primaryText: Colors.blue);
                expect(notifier!.state.primaryText, Colors.blue);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('updates multiple colors at once', (WidgetTester tester) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                notifier!.updateColor(
                  background: Colors.white,
                  primaryText: Colors.black,
                );
                expect(notifier!.state.background, Colors.white);
                expect(notifier!.state.primaryText, Colors.black);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('applies preset color scheme', (WidgetTester tester) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                const preset = PresetColorScheme(
                  name: 'Test',
                  background: Colors.white,
                  text: Colors.black,
                  secondaryText: Color(0xFF424242),
                );
                notifier!.applyPresetScheme(preset);
                expect(notifier!.state.background, Colors.white);
                expect(notifier!.state.primaryText, Colors.black);
                expect(notifier!.state.secondaryText, const Color(0xFF424242));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('applies dark preset scheme', (WidgetTester tester) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                const preset = PresetColorScheme(
                  name: 'Dark',
                  background: Color(0xFF121212),
                  text: Color(0xFFE0E0E0),
                  secondaryText: Color(0xFFB0B0B0),
                );
                notifier!.applyPresetScheme(preset);
                expect(notifier!.state.background, const Color(0xFF121212));
                expect(notifier!.state.primaryText, const Color(0xFFE0E0E0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('preserves unchanged colors when updating single color', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData.light();
      ReaderColorsNotifier? notifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                notifier = ReaderColorsNotifier(context);
                final originalPrimaryText = notifier!.state.primaryText;
                notifier!.updateColor(background: Colors.red);
                expect(notifier!.state.background, Colors.red);
                expect(notifier!.state.primaryText, originalPrimaryText);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('Edge Cases', () {
    test('handles white on white (zero contrast)', () {
      final result = ContrastValidator.validateColors(
        Colors.white,
        Colors.white,
      );

      expect(result.isValid, isFalse);
      expect(result.contrastResult.ratio, lessThan(1.01));
    });

    test('handles black on black (zero contrast)', () {
      final result = ContrastValidator.validateColors(
        Colors.black,
        Colors.black,
      );

      expect(result.isValid, isFalse);
      expect(result.contrastResult.ratio, lessThan(1.01));
    });

    test('handles maximum contrast (black on white)', () {
      final result = ContrastValidator.validateColors(
        Colors.black,
        Colors.white,
      );

      expect(result.contrastResult.ratio, greaterThan(20));
      expect(result.isValid, isTrue);
    });

    test('handles grayscale color combinations', () {
      final results = [
        ContrastValidator.validateColors(
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
        ),
        ContrastValidator.validateColors(
          const Color(0xFF333333),
          const Color(0xFFCCCCCC),
        ),
        ContrastValidator.validateColors(
          const Color(0xFF666666),
          const Color(0xFF999999),
        ),
      ];

      expect(results[0].isValid, isTrue);
      expect(
        results[0].contrastResult.ratio,
        greaterThan(results[1].contrastResult.ratio),
      );
      expect(results[2].isValid, isFalse);
    });

    test('handles text style with inherited color', () {
      const style = TextStyle(inherit: true);
      final result = ContrastValidator.validateTextStyle(style, Colors.white);

      expect(result.foreground, Colors.black);
    });

    test('generates report with failed results list', () {
      final results = [
        ContrastValidator.validateColors(
          const Color(0xFFCCCCCC),
          const Color(0xFFDDDDDD),
        ),
        ContrastValidator.validateColors(
          const Color(0xFFEEEEEE),
          const Color(0xFFFFFFFF),
        ),
      ];

      final report = ContrastValidator.generateReport(results);

      expect(report.failedResults.length, 2);
      expect(report.failedResults.every((r) => !r.isValid), isTrue);
    });

    test('validates empty text element map', () {
      final pairs = <Color, Color>{};
      final results = ContrastValidator.validateMultipleTextElements(pairs);

      expect(results, isEmpty);
    });
  });
}
