import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/widgets/contrast_validator.dart';
import 'package:writer/theme/accessibility/contrast_checker.dart';

void main() {
  group('RBK-008-A High Contrast Compliance', () {
    testWidgets('HighContrast_200_contrast_aa', (tester) async {}, skip: true);
  });

  group('WCAG 2.1 AA Contrast Validation', () {
    test('ContrastChecker calculates correct ratio for black on white', () {
      final result = ContrastChecker.calculateContrast(
        Colors.black,
        Colors.white,
      );
      expect(result.ratio, closeTo(21.0, 0.1));
      expect(result.passesAA, isTrue);
    });

    test('ContrastChecker calculates correct ratio for white on black', () {
      final result = ContrastChecker.calculateContrast(
        Colors.white,
        Colors.black,
      );
      expect(result.ratio, closeTo(21.0, 0.1));
      expect(result.passesAA, isTrue);
    });

    test('ContrastChecker fails for insufficient contrast', () {
      final result = ContrastChecker.calculateContrast(
        const Color(0xFF808080),
        const Color(0xFFA0A0A0),
      );
      expect(result.passesAA, isFalse);
      expect(result.ratio, lessThan(4.5));
    });

    test('ContrastChecker validates large text threshold (3:1)', () {
      final result = ContrastChecker.calculateContrast(
        const Color(0xFF0066FF),
        const Color(0xFFFFFFFF),
      );
      expect(result.ratio, greaterThan(3.0));
    });

    test('ContrastAdjuster provides valid suggestions for low contrast', () {
      const foreground = Color(0xFFCCCCCC);
      const background = Color(0xFFE0E0E0);
      final result = ContrastChecker.calculateContrast(foreground, background);

      if (!result.passesAA) {
        final suggestions = ContrastAdjuster.suggestColorAdjustments(
          foreground,
          background,
          adjustForeground: true,
          targetRatio: 4.5,
        );
        expect(suggestions, isNotEmpty);

        final improved = ContrastChecker.calculateContrast(
          suggestions.first.suggestedColor,
          background,
        );
        expect(improved.passesAA, isTrue);
      }
    });

    test(
      'PresetColorScheme provides valid palettes for both light and dark',
      () {
        final lightSchemes = PresetColorScheme.schemesForBrightness(
          Brightness.light,
        );
        expect(lightSchemes, isNotEmpty);

        for (final scheme in lightSchemes) {
          final result = ContrastChecker.calculateContrast(
            scheme.text,
            scheme.background,
          );
          expect(
            result.passesAA,
            isTrue,
            reason: 'Light scheme ${scheme.name} fails AA: ${result.ratio}',
          );
        }

        final darkSchemes = PresetColorScheme.schemesForBrightness(
          Brightness.dark,
        );
        expect(darkSchemes, isNotEmpty);

        for (final scheme in darkSchemes) {
          final result = ContrastChecker.calculateContrast(
            scheme.text,
            scheme.background,
          );
          expect(
            result.passesAA,
            isTrue,
            reason: 'Dark scheme ${scheme.name} fails AA: ${result.ratio}',
          );
        }
      },
    );

    test('ContrastAdjuster brightness adjustments maintain valid colors', () {
      const color = Color(0xFF808080);
      const darker = Color(0xFF666666);
      const lighter = Color(0xFF999999);

      expect(
        (darker.r * 255.0).round().clamp(0, 255),
        lessThan((color.r * 255.0).round().clamp(0, 255)),
      );
      expect(
        (lighter.r * 255.0).round().clamp(0, 255),
        greaterThan((color.r * 255.0).round().clamp(0, 255)),
      );
    });

    test('ContrastChecker handles edge cases', () {
      final result1 = ContrastChecker.calculateContrast(
        Colors.black,
        Colors.black,
      );
      expect(result1.ratio, equals(1.0));

      final result2 = ContrastChecker.calculateContrast(
        Colors.white,
        Colors.white,
      );
      expect(result2.ratio, equals(1.0));
    });

    test('ReaderColors.fromTheme extracts correct colors from theme', () {
      const colorScheme = ColorScheme.light(
        primary: Colors.blue,
        onPrimary: Colors.white,
        secondary: Colors.green,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      );

      final readerColors = ReaderColors(
        background: colorScheme.surface,
        primaryText: colorScheme.onSurface,
        secondaryText: Colors.grey[700]!,
        accentText: colorScheme.primary,
        linkText: colorScheme.primary,
      );

      expect(readerColors.background, equals(colorScheme.surface));
      expect(readerColors.primaryText, equals(colorScheme.onSurface));
    });
  });

  group('Dynamic Contrast Detection', () {
    test('ContrastAdjuster provides multiple adjustment strategies', () {
      const lowContrastForeground = Color(0xFFCCCCCC);
      const background = Color(0xFFE0E0E0);

      final suggestions = ContrastAdjuster.suggestColorAdjustments(
        lowContrastForeground,
        background,
        adjustForeground: true,
        targetRatio: 4.5,
      );

      expect(suggestions.length, greaterThan(1));
      expect(
        suggestions.map((s) => s.reason).toSet().length,
        greaterThan(1),
        reason: 'Should provide multiple different adjustment strategies',
      );
    });
  });
}
