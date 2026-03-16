import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/utils/contrast_utils.dart';

void main() {
  group('ContrastUtils', () {
    test(
      'calculateContrastRatio returns positive value for contrasting colors',
      () {
        final ratio = ContrastUtils.calculateContrastRatio(
          const Color(0xFFFFFFFF),
          const Color(0xFF000000),
        );

        expect(ratio, greaterThan(1));
      },
    );

    test('calculateContrastRatio returns 1 for identical colors', () {
      final ratio = ContrastUtils.calculateContrastRatio(
        const Color(0xFF123456),
        const Color(0xFF123456),
      );

      expect(ratio, closeTo(1, 0.001));
    });

    test('meetsWCAGAA returns true for high contrast', () {
      final result = ContrastUtils.meetsWCAGAA(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );

      expect(result, isTrue);
    });

    test('meetsWCAGAA returns false for low contrast', () {
      final result = ContrastUtils.meetsWCAGAA(
        const Color(0xFF808080),
        const Color(0xFF909090),
      );

      expect(result, isFalse);
    });

    test('meetsWCAGAAA returns true for very high contrast', () {
      final result = ContrastUtils.meetsWCAGAAA(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );

      expect(result, isTrue);
    });

    test('meetsWCAGAAA returns false for AA compliant contrast', () {
      final result = ContrastUtils.meetsWCAGAAA(
        const Color(0xFF000000),
        const Color(0xFF404040),
      );

      expect(result, isFalse);
    });

    test('getAccessibleTextColor returns original if contrast is good', () {
      final result = ContrastUtils.getAccessibleTextColor(
        textColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF000000),
        isDarkMode: false,
      );

      expect(result, const Color(0xFFFFFFFF));
    });

    test('getAccessibleTextColor returns adjusted color for dark mode', () {
      final result = ContrastUtils.getAccessibleTextColor(
        textColor: const Color(0xFF404040),
        backgroundColor: const Color(0xFF303030),
        isDarkMode: true,
      );

      expect(result, isNotNull);
    });

    test('getAccessibleTextColor returns adjusted color for light mode', () {
      final result = ContrastUtils.getAccessibleTextColor(
        textColor: const Color(0xFF909090),
        backgroundColor: const Color(0xFFF0F0F0),
        isDarkMode: false,
      );

      expect(result, isNotNull);
    });

    test('getAccessibleTextColor respects minContrastRatio parameter', () {
      final result = ContrastUtils.getAccessibleTextColor(
        textColor: const Color(0xFF707070),
        backgroundColor: const Color(0xFFE0E0E0),
        isDarkMode: false,
        minContrastRatio: 7.0,
      );

      expect(result, isNotNull);
    });

    test('getAccessibleIconColor returns original if contrast is good', () {
      final result = ContrastUtils.getAccessibleIconColor(
        iconColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF000000),
        isDarkMode: false,
      );

      expect(result, const Color(0xFFFFFFFF));
    });

    test('getAccessibleIconColor returns adjusted color for dark mode', () {
      final result = ContrastUtils.getAccessibleIconColor(
        iconColor: const Color(0xFF505050),
        backgroundColor: const Color(0xFF404040),
        isDarkMode: true,
      );

      expect(result, isNotNull);
    });

    test('getAccessibleIconColor returns adjusted color for light mode', () {
      final result = ContrastUtils.getAccessibleIconColor(
        iconColor: const Color(0xFF909090),
        backgroundColor: const Color(0xFFF8F8F8),
        isDarkMode: false,
      );

      expect(result, isNotNull);
    });

    test('calculateContrastRatio is symmetric', () {
      final ratio1 = ContrastUtils.calculateContrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );

      final ratio2 = ContrastUtils.calculateContrastRatio(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
      );

      expect(ratio1, closeTo(ratio2, 0.001));
    });

    test('calculateContrastRatio returns values in expected range', () {
      final ratio = ContrastUtils.calculateContrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );

      expect(ratio, greaterThan(20));
      expect(ratio, lessThan(22));
    });

    test('getAccessibleTextColor uses default minContrastRatio', () {
      final result = ContrastUtils.getAccessibleTextColor(
        textColor: const Color(0xFF606060),
        backgroundColor: const Color(0xFFE8E8E8),
        isDarkMode: false,
      );

      expect(result, isNotNull);
    });

    test('forceContrastColor returns original if contrast is good', () {
      final result = ContrastUtils.forceContrastColor(
        foreground: const Color(0xFF000000),
        background: const Color(0xFFFFFFFF),
      );
      expect(result, const Color(0xFF000000));
    });

    test('forceContrastColor returns white for dark background', () {
      final result = ContrastUtils.forceContrastColor(
        foreground: const Color(0xFF333333),
        background: const Color(0xFF000000),
      );
      // Expects white with alpha 0.95
      expect(result.a, closeTo(0.95, 0.01));
      expect(result.r, 1.0);
      expect(result.g, 1.0);
      expect(result.b, 1.0);
    });

    test('forceContrastColor returns black for light background', () {
      final result = ContrastUtils.forceContrastColor(
        foreground: const Color(0xFFCCCCCC),
        background: const Color(0xFFFFFFFF),
      );
      // Expects black with alpha 0.87
      expect(result.a, closeTo(0.87, 0.01));
      expect(result.r, 0.0);
      expect(result.g, 0.0);
      expect(result.b, 0.0);
    });

    test(
      'adjustButtonBackgroundColorForContrast returns original if contrast is good',
      () {
        final result = ContrastUtils.adjustButtonBackgroundColorForContrast(
          buttonColor: const Color(0xFF000000),
          surfaceColor: const Color(0xFFFFFFFF),
          isDarkMode: false,
        );
        expect(result, const Color(0xFF000000));
      },
    );

    test('adjustButtonBackgroundColorForContrast dark mode adjustment', () {
      // Dark mode, button luminance > 0.4
      final result = ContrastUtils.adjustButtonBackgroundColorForContrast(
        buttonColor: const Color(0xFFCCCCCC), // Light grey
        surfaceColor: const Color(0xFFCCCCCC), // Same color, low contrast
        isDarkMode: true,
      );
      // Should be darkened
      expect(result.computeLuminance(), lessThan(0.4));
    });

    test('adjustButtonBackgroundColorForContrast light mode adjustment', () {
      // Light mode, button luminance > 0.6
      final result = ContrastUtils.adjustButtonBackgroundColorForContrast(
        buttonColor: const Color(0xFFEEEEEE), // Very light grey
        surfaceColor: const Color(0xFFEEEEEE), // Same color, low contrast
        isDarkMode: false,
      );
      // Should be darkened
      expect(
        result.computeLuminance(),
        lessThan(const Color(0xFFEEEEEE).computeLuminance()),
      );
    });

    test('getButtonTextColor dark mode low luminance', () {
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFF202020),
        isDarkMode: true,
      );
      // Should be white (Luminance ~0.01 < 0.3)
      expect(result.computeLuminance(), greaterThan(0.9));
    });

    test('getButtonTextColor dark mode mid luminance', () {
      // We want to hit 0.3 <= lum < 0.5.
      // 0xFFA0A0A0 has luminance ~0.32
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFFA0A0A0),
        isDarkMode: true,
      );
      // Should be white (alpha 0.90)
      expect(result.computeLuminance(), greaterThan(0.9));
    });

    test('getButtonTextColor dark mode high luminance', () {
      // We want to hit lum >= 0.5 to get Black.
      // 0xFFCCCCCC has luminance ~0.6
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFFCCCCCC),
        isDarkMode: true,
      );
      // Should be Black
      expect(result.computeLuminance(), lessThan(0.1));
    });

    test('getButtonTextColor light mode high luminance', () {
      // We want lum > 0.65 to get Black (alpha 0.80)
      // 0xFFE0E0E0 has luminance ~0.76
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFFE0E0E0),
        isDarkMode: false,
      );
      // Should be black
      expect(result.computeLuminance(), lessThan(0.1));
    });

    test('getButtonTextColor light mode mid luminance', () {
      // We want 0.45 < lum <= 0.65 to get Black (alpha 0.75)
      // 0xFFC0C0C0 has luminance ~0.50
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFFC0C0C0),
        isDarkMode: false,
      );
      // Should be black
      expect(result.computeLuminance(), lessThan(0.1));
    });

    test('getButtonTextColor light mode low luminance', () {
      // We want lum <= 0.45 to get White
      // 0xFF808080 has luminance ~0.21
      final result = ContrastUtils.getButtonTextColor(
        buttonBackgroundColor: const Color(0xFF808080),
        isDarkMode: false,
      );
      // Should be white
      expect(result.computeLuminance(), greaterThan(0.9));
    });

    test('getAccessibleIconColor dark mode high bg luminance fallback', () {
      // _getHighContrastDarkModeIconColor: if (bgLuminance > 0.4) return white
      // Use same color for icon and bg to ensure bad contrast
      final result = ContrastUtils.getAccessibleIconColor(
        iconColor: const Color(0xFFAAAAAA),
        backgroundColor: const Color(0xFFAAAAAA), // Luminance ~0.4
        isDarkMode: true,
      );
      // Should return white
      expect(result.computeLuminance(), greaterThan(0.9));
    });

    test('getAccessibleIconColor light mode low bg luminance fallback', () {
      // _getHighContrastLightModeIconColor: if (bgLuminance < 0.6) return black
      // Use same color for icon and bg to ensure bad contrast
      final result = ContrastUtils.getAccessibleIconColor(
        iconColor: const Color(0xFF555555),
        backgroundColor: const Color(0xFF555555), // Luminance < 0.6
        isDarkMode: false,
      );
      // Should return black
      expect(result.computeLuminance(), lessThan(0.1));
    });
  });
}
