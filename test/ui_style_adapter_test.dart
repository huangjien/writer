import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/ui_style_adapter.dart';
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

      test('returns neumorphism patch for neumorphism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.neumorphism);
        expect(patch.cardBorderRadius, BorderRadius.circular(20));
        expect(patch.buttonBorderRadius, BorderRadius.circular(16));
        expect(patch.elevation, 2);
        expect(patch.useBackdropBlur, false);
      });

      test('returns claymorphism patch for claymorphism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.claymorphism);
        expect(patch.cardBorderRadius, BorderRadius.circular(24));
        expect(patch.buttonBorderRadius, BorderRadius.circular(20));
        expect(patch.elevation, 8);
        expect(patch.useBackdropBlur, false);
      });

      test('returns minimalism patch for minimalism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.minimalism);
        expect(patch.cardBorderRadius, BorderRadius.circular(8));
        expect(patch.buttonBorderRadius, BorderRadius.circular(6));
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, false);
      });

      test('returns brutalism patch for brutalism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.brutalism);
        expect(patch.cardBorderRadius, BorderRadius.zero);
        expect(patch.buttonBorderRadius, BorderRadius.zero);
        expect(patch.elevation, 0);
        expect(patch.useBackdropBlur, false);
      });

      test('returns skeuomorphism patch for skeuomorphism style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.skeuomorphism);
        expect(patch.cardBorderRadius, BorderRadius.circular(12));
        expect(patch.buttonBorderRadius, BorderRadius.circular(10));
        expect(patch.elevation, 4);
        expect(patch.useBackdropBlur, false);
      });

      test('returns bentoGrid patch for bentoGrid style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.bentoGrid);
        expect(patch.cardBorderRadius, BorderRadius.circular(20));
        expect(patch.buttonBorderRadius, BorderRadius.circular(16));
        expect(patch.elevation, 2);
        expect(patch.useBackdropBlur, true);
      });

      test('returns responsive patch for responsive style', () {
        final patch = adapter.resolveStylePatch(UiStyleFamily.responsive);
        expect(patch.cardBorderRadius, BorderRadius.circular(12));
        expect(patch.buttonBorderRadius, BorderRadius.circular(8));
        expect(patch.elevation, 1);
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
      test('applies custom card border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(20)),
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
        final patch = const StyleThemePatch(elevation: 8);
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.elevation, 8);
        expect(modified.dialogTheme.elevation, 8);
        expect(modified.floatingActionButtonTheme.elevation, 8);
      });

      test('uses base elevation when patch elevation is null', () {
        final patch = const StyleThemePatch(elevation: null);
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.elevation, baseTheme.cardTheme.elevation);
      });

      test('applies card margin', () {
        final patch = const StyleThemePatch();
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.cardTheme.margin, const EdgeInsets.all(8));
      });

      test('applies dialog border radius', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(24)),
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
        );
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());
        final shape = modified.bottomSheetTheme.shape as RoundedRectangleBorder;
        final borderRadius = shape.borderRadius as BorderRadius;
        expect(borderRadius.topLeft, const Radius.circular(20));
      });

      test('applies input decoration theme', () {
        final patch = const StyleThemePatch();
        final baseTheme = ThemeData.light();
        final modified = patch.applyToTheme(baseTheme, false);

        expect(modified.inputDecorationTheme.filled, true);
        expect(modified.inputDecorationTheme.border, isA<OutlineInputBorder>());
        final border =
            modified.inputDecorationTheme.border as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(8));
        expect(border.borderSide, BorderSide.none);
      });

      test('applies to light theme', () {
        final patch = const StyleThemePatch(
          cardBorderRadius: BorderRadius.all(Radius.circular(16)),
          elevation: 4,
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
        );
        final baseTheme = ThemeData.dark();
        final modified = patch.applyToTheme(baseTheme, true);

        expect(modified.brightness, Brightness.dark);
        expect(modified.cardTheme.elevation, 4);
      });
    });

    group('StyleThemePatch const constructor', () {
      test('creates patch with all optional fields null', () {
        const patch = StyleThemePatch();

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
        );

        expect(patch.cardBorderRadius, BorderRadius.circular(12));
        expect(patch.buttonBorderRadius, BorderRadius.circular(8));
        expect(patch.elevation, 6);
        expect(patch.useBackdropBlur, true);
      });
    });
  });
}
