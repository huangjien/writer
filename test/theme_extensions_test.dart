import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/theme/ui_styles.dart';

void main() {
  group('UiStyleThemeExtension', () {
    test('copyWith overrides selected fields', () {
      const base = UiStyleThemeExtension(
        styleFamily: UiStyleFamily.glassmorphism,
        useBackdropBlur: false,
        cardBlur: 2,
      );

      final updated = base.copyWith(
        styleFamily: UiStyleFamily.brutalism,
        useBackdropBlur: true,
        cardBlur: 10,
        cardColor: Colors.red,
      );

      expect(updated.styleFamily, UiStyleFamily.brutalism);
      expect(updated.useBackdropBlur, isTrue);
      expect(updated.cardBlur, 10);
      expect(updated.cardColor, Colors.red);
    });

    test('lerp returns this when other is wrong type', () {
      const base = UiStyleThemeExtension(
        styleFamily: UiStyleFamily.neumorphism,
      );
      final result = base.lerp(const _WrongGenericExtension(), 0.5);
      expect(result, same(base));
    });

    test('lerp switches discrete fields at t >= 0.5', () {
      const a = UiStyleThemeExtension(
        styleFamily: UiStyleFamily.flatDesign,
        useBackdropBlur: false,
        cardBlur: 0,
        cardColor: Colors.black,
      );
      const b = UiStyleThemeExtension(
        styleFamily: UiStyleFamily.glassmorphism,
        useBackdropBlur: true,
        cardBlur: 20,
        cardColor: Colors.white,
      );

      final midA = a.lerp(b, 0.49);
      expect(midA.styleFamily, UiStyleFamily.flatDesign);
      expect(midA.useBackdropBlur, isFalse);

      final midB = a.lerp(b, 0.51);
      expect(midB.styleFamily, UiStyleFamily.glassmorphism);
      expect(midB.useBackdropBlur, isTrue);
      expect(midB.cardBlur, closeTo(10.2, 0.001));
      expect(midB.cardColor, isNotNull);
    });
  });

  group('ThemeDataExtensions', () {
    test('defaults when extension is missing', () {
      final theme = ThemeData.light();
      expect(theme.uiStyleFamily, UiStyleFamily.glassmorphism);
      expect(theme.useBackdropBlur, isFalse);
      expect(theme.cardBlur, 0);
      expect(theme.styleCardColor, isNull);
      expect(theme.styleCardBorder, isNull);
      expect(theme.styleCardShadows, isNull);
      expect(theme.styleCardGradient, isNull);
    });

    test('reads values from UiStyleThemeExtension', () {
      final theme = ThemeData.light().copyWith(
        extensions: const <ThemeExtension<dynamic>>[
          UiStyleThemeExtension(
            styleFamily: UiStyleFamily.brutalism,
            useBackdropBlur: true,
            cardBlur: 12,
            cardColor: Colors.green,
          ),
        ],
      );

      expect(theme.uiStyleFamily, UiStyleFamily.brutalism);
      expect(theme.useBackdropBlur, isTrue);
      expect(theme.cardBlur, 12);
      expect(theme.styleCardColor, Colors.green);
    });
  });
}

class _WrongGenericExtension extends ThemeExtension<UiStyleThemeExtension> {
  const _WrongGenericExtension();

  @override
  ThemeExtension<UiStyleThemeExtension> copyWith() => this;

  @override
  ThemeExtension<UiStyleThemeExtension> lerp(
    ThemeExtension<UiStyleThemeExtension>? other,
    double t,
  ) => this;
}
