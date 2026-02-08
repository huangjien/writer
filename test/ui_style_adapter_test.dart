import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/ui_style_adapter.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/theme/ui_styles.dart';

void main() {
  group('UiStyleAdapter', () {
    late UiStyleAdapter adapter;

    setUp(() {
      adapter = const UiStyleAdapter();
    });

    group('resolveStylePatch', () {
      test('returns glassmorphism patch for glassmorphism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.glassmorphism);
        expect(patch.cardBorderRadius, BorderRadius.circular(16));
        expect(patch.buttonBorderRadius, BorderRadius.circular(12));
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, true);
      });

      test('returns liquidGlass patch for liquidGlass style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.liquidGlass);
        expect(patch.styleFamily, UiStyleFamily.liquidGlass);
        expect(patch.useBackdropBlur, true);
        expect(patch.cardBlur, 24);
      });

      test('returns neumorphism patch for neumorphism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.neumorphism);
        expect(patch.cardBorderRadius, BorderRadius.circular(20));
        expect(patch.buttonBorderRadius, BorderRadius.circular(16));
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, false);
      });

      test('returns minimalism patch for minimalism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.minimalism);
        expect(patch.cardBorderRadius, BorderRadius.circular(12));
        expect(patch.buttonBorderRadius, BorderRadius.circular(8));
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, false);
      });

      test('returns flatDesign patch for flatDesign style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.flatDesign);
        expect(patch.cardBorderRadius, BorderRadius.circular(4));
        expect(patch.buttonBorderRadius, BorderRadius.circular(4));
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, false);
      });
    });

    group('StyleThemePatch.applyToTheme', () {
      test('resolves divider thickness and color for styleFamily branches', () {
        final baseTheme = ThemeData.light();

        final flat = const StyleThemePatch(
          styleFamily: UiStyleFamily.flatDesign,
        ).applyToTheme(baseTheme, false);
        expect(flat.dividerTheme.thickness, 1);
        expect(flat.dividerTheme.color, baseTheme.colorScheme.outline);

        final minimal = const StyleThemePatch(
          styleFamily: UiStyleFamily.minimalism,
        ).applyToTheme(baseTheme, false);
        expect(minimal.dividerTheme.thickness, 0.5);
        expect(
          minimal.dividerTheme.color,
          baseTheme.colorScheme.outlineVariant,
        );
      });

      test('cardColor override takes precedence for surface color', () {
        final baseTheme = ThemeData.light();
        final themed = const StyleThemePatch(
          styleFamily: UiStyleFamily.glassmorphism,
          cardColor: Colors.purple,
        ).applyToTheme(baseTheme, false);

        expect(themed.cardTheme.color, Colors.purple);
      });

      test('resolves card shadows when not provided', () {
        final baseTheme = ThemeData.light();

        final glass = const StyleThemePatch(
          styleFamily: UiStyleFamily.glassmorphism,
        ).applyToTheme(baseTheme, false);
        final ext1 = glass.extension<UiStyleThemeExtension>();
        expect(ext1, isNotNull);
        expect(ext1!.cardShadows, isNotNull);
        expect(ext1.cardShadows, isNotEmpty);

        final liquid = const StyleThemePatch(
          styleFamily: UiStyleFamily.liquidGlass,
        ).applyToTheme(baseTheme, false);
        final extLiquid = liquid.extension<UiStyleThemeExtension>();
        expect(extLiquid, isNotNull);
        expect(extLiquid!.cardShadows, isNotNull);
        expect(extLiquid.cardShadows, isNotEmpty);

        final neu = const StyleThemePatch(
          styleFamily: UiStyleFamily.neumorphism,
        ).applyToTheme(baseTheme, false);
        final ext2 = neu.extension<UiStyleThemeExtension>();
        expect(ext2, isNotNull);
        expect(ext2!.cardShadows, isNotNull);
        expect(ext2.cardShadows, isNotEmpty);
      });

      test('applies custom card border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(20)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.shape, isA<RoundedRectangleBorder>());
        final shape = modified.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      });

      test('applies custom button border radius', () {
        final patch = const StyleThemePatch(
          buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        final buttonStyle = modified.elevatedButtonTheme.style;
        expect(buttonStyle, isNotNull);
        final shape = buttonStyle?.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
        final roundedShape = shape as RoundedRectangleBorder;
        expect(roundedShape.borderRadius, BorderRadius.circular(16));
      });

      test('applies custom elevation', () {
        final patch = const StyleThemePatch(
          elevation: 8,
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.elevation, 8);
        expect(modified.dialogTheme.elevation, 8);
        expect(modified.floatingActionButtonTheme.elevation, 8);
      });

      test('uses base elevation when patch elevation is null', () {
        final patch = const StyleThemePatch(
          elevation: null,
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.elevation, baseTheme.cardTheme.elevation);
      });

      test('applies card margin', () {
        final patch = const StyleThemePatch(
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.margin, const EdgeInsets.all(8));
      });

      test('applies dialog border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(24)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.dialogTheme.shape, isA<RoundedRectangleBorder>());
        final shape = modified.dialogTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(24));
      });

      test('applies floating action button border radius', () {
        final patch = const StyleThemePatch(
          buttonBorderRadius: BorderRadius.all(Radius.circular(20)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(
          modified.floatingActionButtonTheme.shape,
          isA<RoundedRectangleBorder>(),
        );
        final shape =
            modified.floatingActionButtonTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      });

      test('applies bottom sheet border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(20)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());
        final shape = modified.bottomSheetTheme.shape as RoundedRectangleBorder;
        final borderRadius = shape.borderRadius as BorderRadius;
        expect(borderRadius.topLeft, const Radius.circular(20));
      });

      test('applies input decoration theme', () {
        final patch = const StyleThemePatch(
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.inputDecorationTheme.filled, true);
        expect(modified.inputDecorationTheme.border, isA<OutlineInputBorder>());
        final border =
            modified.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(8));
        expect(border.borderSide, BorderSide.none);
      });

      test('preserves existing theme extensions', () {
        const patch = StyleThemePatch(styleFamily: UiStyleFamily.glassmorphism);

        const baseExtension = _TestThemeExtension(value: 1);
        final baseTheme = ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[baseExtension],
        );

        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.extension<_TestThemeExtension>(), isNotNull);
        expect(modified.extension<_TestThemeExtension>()?.value, 1);
      });

      test('applies list tile shape from card border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(20)),
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.listTileTheme.shape, isA<RoundedRectangleBorder>());
        final shape = modified.listTileTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      });

      test('applies minimalism divider thickness', () {
        final patch = const StyleThemePatch(
          styleFamily: UiStyleFamily.minimalism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.dividerTheme.thickness, 0.5);
      });

      test('applies to light theme', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(16)),
          elevation: 4,
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.brightness, Brightness.light);
        expect(modified.cardTheme.elevation, 4);
      });

      test('applies to dark theme', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(16)),
          elevation: 4,
          styleFamily: UiStyleFamily.glassmorphism,
        );
        final baseTheme = ThemeData.dark();
        final modified = patch.applyToTheme(baseTheme, true);

        expect(modified.brightness, Brightness.dark);
        expect(modified.cardTheme.elevation, 4);
      });
    });

    group('StyleThemePatch const constructor', () {
      test('creates patch with all optional fields null', () {
        const patch = StyleThemePatch(styleFamily: UiStyleFamily.glassmorphism);

        expect(patch.cardDecoration, isNull);
        expect(patch.inputDecoration, isNull);
        expect(patch.buttonDecoration, isNull);
        expect(patch.cardShadow, isNull);
        expect(patch.buttonShadow, isNull);
        expect(patch.cardBorderRadius, isNull);
        expect(patch.buttonBorderRadius, isNull);
        expect(patch.elevation, isNull);
        expect(patch.useBackdropBlur, isNull);
      });

      test('creates patch with custom fields', () {
        const patch = StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(12)),
          buttonBorderRadius: BorderRadius.all(Radius.circular(8)),
          elevation: 6,
          useBackdropBlur: true,
          styleFamily: UiStyleFamily.glassmorphism,
        );

        expect(patch.cardBorderRadius, BorderRadius.circular(12));
        expect(patch.buttonBorderRadius, BorderRadius.circular(8));
        expect(patch.elevation, 6);
        expect(patch.useBackdropBlur, true);
      });
    });
  });
}

class _TestThemeExtension extends ThemeExtension<_TestThemeExtension> {
  const _TestThemeExtension({required this.value});

  final int value;

  @override
  _TestThemeExtension copyWith({int? value}) =>
      _TestThemeExtension(value: value ?? this.value);

  @override
  _TestThemeExtension lerp(
    ThemeExtension<_TestThemeExtension>? other,
    double t,
  ) {
    if (other is! _TestThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}
