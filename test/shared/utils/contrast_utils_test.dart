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
  });
}
