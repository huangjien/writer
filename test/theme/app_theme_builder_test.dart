import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/app_theme_builder.dart';
import 'package:writer/theme/themes.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/no_animation_transitions.dart';
import 'package:writer/theme/fade_through_page_transitions.dart';

void main() {
  group('AppThemeBuilder', () {
    group('buildLight', () {
      testWidgets('builds light theme with default family', (tester) async {
        final theme = AppThemeBuilder.buildLight(
          family: AppThemeFamily.defaultFamily,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.light);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds light theme with sepia family', (tester) async {
        final theme = AppThemeBuilder.buildLight(
          family: AppThemeFamily.sepia,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.light);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds light theme with high contrast family', (
        tester,
      ) async {
        final theme = AppThemeBuilder.buildLight(
          family: AppThemeFamily.highContrast,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.light);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds light theme with all font packs', (tester) async {
        for (final fontPack in ReaderFontPack.values) {
          final theme = AppThemeBuilder.buildLight(
            family: AppThemeFamily.defaultFamily,
            fontPack: fontPack,
            customFontFamily: null,
            preset: ReaderTypographyPreset.system,
          );

          expect(theme.brightness, Brightness.light);
          expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
        }
      });

      testWidgets('builds light theme with custom font family', (tester) async {
        final theme = AppThemeBuilder.buildLight(
          family: AppThemeFamily.defaultFamily,
          fontPack: ReaderFontPack.system,
          customFontFamily: 'Custom Font',
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.light);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });
    });

    group('buildDark', () {
      testWidgets('builds dark theme with default family', (tester) async {
        final theme = AppThemeBuilder.buildDark(
          family: AppThemeFamily.defaultFamily,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds dark theme with sepia family', (tester) async {
        final theme = AppThemeBuilder.buildDark(
          family: AppThemeFamily.sepia,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds dark theme with high contrast family', (
        tester,
      ) async {
        final theme = AppThemeBuilder.buildDark(
          family: AppThemeFamily.highContrast,
          fontPack: ReaderFontPack.system,
          customFontFamily: null,
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('builds dark theme with all font packs', (tester) async {
        for (final fontPack in ReaderFontPack.values) {
          final theme = AppThemeBuilder.buildDark(
            family: AppThemeFamily.defaultFamily,
            fontPack: fontPack,
            customFontFamily: null,
            preset: ReaderTypographyPreset.system,
          );

          expect(theme.brightness, Brightness.dark);
          expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
        }
      });

      testWidgets('builds dark theme with custom font family', (tester) async {
        final theme = AppThemeBuilder.buildDark(
          family: AppThemeFamily.defaultFamily,
          fontPack: ReaderFontPack.system,
          customFontFamily: 'Custom Font',
          preset: ReaderTypographyPreset.system,
        );

        expect(theme.brightness, Brightness.dark);
        expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });
    });

    group('applyFontPackOrCustom', () {
      testWidgets('applies font pack correctly', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyFontPackOrCustom(
          baseTheme,
          ReaderFontPack.inter,
          null,
        );

        expect(result.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('applies custom font family', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyFontPackOrCustom(
          baseTheme,
          ReaderFontPack.system,
          'Custom Font',
        );

        expect(result.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });

      testWidgets('handles null custom font family', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyFontPackOrCustom(
          baseTheme,
          ReaderFontPack.system,
          null,
        );

        expect(result.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
      });
    });

    group('applyReaderTypography', () {
      testWidgets('applies system preset', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.system,
          separatePreset: null,
          hasSeparate: false,
        );

        expect(result, isNotNull);
      });

      testWidgets('applies comfortable preset', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.comfortable,
          separatePreset: null,
          hasSeparate: false,
        );

        expect(result, isNotNull);
      });

      testWidgets('applies compact preset', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.compact,
          separatePreset: null,
          hasSeparate: false,
        );

        expect(result, isNotNull);
      });

      testWidgets('applies serifLike preset', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.serifLike,
          separatePreset: null,
          hasSeparate: false,
        );

        expect(result, isNotNull);
      });

      testWidgets('uses separate preset when hasSeparate is true', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.system,
          separatePreset: ReaderTypographyPreset.comfortable,
          hasSeparate: true,
        );

        expect(result, isNotNull);
      });

      testWidgets('falls back to main preset when separate is null', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypography(
          baseTheme,
          preset: ReaderTypographyPreset.comfortable,
          separatePreset: null,
          hasSeparate: true,
        );

        expect(result, isNotNull);
      });
    });

    group('applyReaderTypographyToTheme', () {
      testWidgets('applies system preset to theme', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.system,
        );

        expect(result.textTheme, isNotNull);
      });

      testWidgets('applies comfortable preset to theme', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.comfortable,
        );

        expect(result.textTheme, isNotNull);
      });

      testWidgets('applies compact preset to theme', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.compact,
        );

        expect(result.textTheme, isNotNull);
      });

      testWidgets('applies serifLike preset to theme', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.serifLike,
        );

        expect(result.textTheme, isNotNull);
      });
    });

    group('applyReaderTypographyToTheme with presets', () {
      testWidgets('applies correct text theme for system preset', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.system,
        );

        expect(result.textTheme, isNotNull);
      });

      testWidgets('applies correct text theme for comfortable preset', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.comfortable,
        );

        expect(result.textTheme.displayLarge?.fontSize, 18);
        expect(result.textTheme.bodyLarge?.fontSize, 16);
        expect(result.textTheme.bodyMedium?.fontSize, 15);
        expect(result.textTheme.bodySmall?.fontSize, 14);
      });

      testWidgets('applies correct text theme for compact preset', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.compact,
        );

        expect(result.textTheme.displayLarge?.fontSize, 16);
        expect(result.textTheme.bodyLarge?.fontSize, 15);
        expect(result.textTheme.bodyMedium?.fontSize, 14);
        expect(result.textTheme.bodySmall?.fontSize, 13);
      });

      testWidgets('applies correct text theme for serifLike preset', (
        tester,
      ) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyReaderTypographyToTheme(
          baseTheme,
          ReaderTypographyPreset.serifLike,
        );

        expect(result.textTheme.displayLarge?.fontSize, 18);
        expect(result.textTheme.bodyLarge?.fontSize, 16);
        expect(result.textTheme.bodyMedium?.fontSize, 15);
        expect(result.textTheme.bodySmall?.fontSize, 14);
        expect(result.textTheme.displayLarge?.fontFamily, 'Roboto');
        expect(result.textTheme.bodyLarge?.fontFamily, 'Roboto');
      });
    });

    group('applyMotion', () {
      testWidgets('applies reduced motion settings', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyMotion(
          base: baseTheme,
          reduceMotion: true,
        );

        expect(result.splashFactory, NoSplash.splashFactory);
        expect(
          result.pageTransitionsTheme.builders.values.any(
            (builder) => builder is NoAnimationPageTransitionsBuilder,
          ),
          isTrue,
        );
      });

      testWidgets('applies normal motion settings', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyMotion(
          base: baseTheme,
          reduceMotion: false,
        );

        expect(
          result.pageTransitionsTheme.builders.values.any(
            (builder) => builder is FadeThroughPageTransitionsBuilder,
          ),
          isTrue,
        );
      });

      testWidgets('covers all platforms for reduced motion', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyMotion(
          base: baseTheme,
          reduceMotion: true,
        );

        final builders = result.pageTransitionsTheme.builders;
        expect(
          builders[TargetPlatform.android] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.iOS] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.macOS] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.linux] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.windows] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.fuchsia] is NoAnimationPageTransitionsBuilder,
          isTrue,
        );
      });

      testWidgets('covers all platforms for normal motion', (tester) async {
        final baseTheme = ThemeData.light();
        final result = AppThemeBuilder.applyMotion(
          base: baseTheme,
          reduceMotion: false,
        );

        final builders = result.pageTransitionsTheme.builders;
        expect(
          builders[TargetPlatform.android] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.iOS] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.macOS] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.linux] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.windows] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
        expect(
          builders[TargetPlatform.fuchsia] is FadeThroughPageTransitionsBuilder,
          isTrue,
        );
      });
    });

    group('Integration tests', () {
      testWidgets('builds complete light theme with all options', (
        tester,
      ) async {
        final theme = AppThemeBuilder.buildLight(
          family: AppThemeFamily.nord,
          fontPack: ReaderFontPack.merriweather,
          customFontFamily: 'Custom Font',
          preset: ReaderTypographyPreset.comfortable,
        );

        final motionTheme = AppThemeBuilder.applyMotion(
          base: theme,
          reduceMotion: false,
        );

        expect(motionTheme.brightness, Brightness.light);
        expect(
          motionTheme.textTheme.apply(fontFamily: 'Noto Sans SC'),
          isNotNull,
        );
        expect(
          motionTheme.pageTransitionsTheme.builders.values.any(
            (builder) => builder is FadeThroughPageTransitionsBuilder,
          ),
          isTrue,
        );
      });

      testWidgets('builds complete dark theme with all options', (
        tester,
      ) async {
        final theme = AppThemeBuilder.buildDark(
          family: AppThemeFamily.solarized,
          fontPack: ReaderFontPack.inter,
          customFontFamily: null,
          preset: ReaderTypographyPreset.compact,
        );

        final motionTheme = AppThemeBuilder.applyMotion(
          base: theme,
          reduceMotion: true,
        );

        expect(motionTheme.brightness, Brightness.dark);
        expect(
          motionTheme.textTheme.apply(fontFamily: 'Noto Sans SC'),
          isNotNull,
        );
        expect(motionTheme.splashFactory, NoSplash.splashFactory);
      });

      testWidgets('handles all theme families', (tester) async {
        for (final family in AppThemeFamily.values) {
          final lightTheme = AppThemeBuilder.buildLight(
            family: family,
            fontPack: ReaderFontPack.system,
            customFontFamily: null,
            preset: ReaderTypographyPreset.system,
          );

          final darkTheme = AppThemeBuilder.buildDark(
            family: family,
            fontPack: ReaderFontPack.system,
            customFontFamily: null,
            preset: ReaderTypographyPreset.system,
          );

          expect(lightTheme.brightness, Brightness.light);
          expect(darkTheme.brightness, Brightness.dark);
          expect(
            lightTheme.textTheme.apply(fontFamily: 'Noto Sans SC'),
            isNotNull,
          );
          expect(
            darkTheme.textTheme.apply(fontFamily: 'Noto Sans SC'),
            isNotNull,
          );
        }
      });

      testWidgets('handles all typography presets', (tester) async {
        for (final preset in ReaderTypographyPreset.values) {
          final theme = AppThemeBuilder.buildLight(
            family: AppThemeFamily.defaultFamily,
            fontPack: ReaderFontPack.system,
            customFontFamily: null,
            preset: preset,
          );

          final typographyTheme = AppThemeBuilder.applyReaderTypography(
            theme,
            preset: preset,
            separatePreset: null,
            hasSeparate: false,
          );

          expect(typographyTheme, isNotNull);
          expect(typographyTheme.textTheme, isNotNull);
        }
      });

      testWidgets('handles all font packs', (tester) async {
        for (final fontPack in ReaderFontPack.values) {
          final theme = AppThemeBuilder.buildLight(
            family: AppThemeFamily.defaultFamily,
            fontPack: fontPack,
            customFontFamily: null,
            preset: ReaderTypographyPreset.system,
          );

          expect(theme.brightness, Brightness.light);
          expect(theme.textTheme.apply(fontFamily: 'Noto Sans SC'), isNotNull);
        }
      });
    });
  });
}
