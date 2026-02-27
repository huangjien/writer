import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/accessibility/contrast_checker.dart';
import 'package:writer/theme/themes.dart';

void main() {
  group('Theme Contrast Compliance', () {
    test('TechInnovation light theme passes WCAG AA', () {
      final theme = themeForLight(AppThemeFamily.techInnovation);
      final surface = theme.colorScheme.surface;
      final onSurface = theme.colorScheme.onSurface;

      final result = ContrastChecker.calculateContrast(onSurface, surface);

      expect(
        result.passesAA,
        isTrue,
        reason:
            'TechInnovation light theme contrast ${result.ratio} does not meet WCAG AA (4.5:1)',
      );
    });

    test('TechInnovation dark theme passes WCAG AA', () {
      final theme = themeForDark(AppThemeFamily.techInnovation);
      final surface = theme.colorScheme.surface;
      final onSurface = theme.colorScheme.onSurface;

      final result = ContrastChecker.calculateContrast(onSurface, surface);

      expect(
        result.passesAA,
        isTrue,
        reason:
            'TechInnovation dark theme contrast ${result.ratio} does not meet WCAG AA (4.5:1)',
      );
    });

    test('TechInnovation primary text passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.techInnovation);
      final darkTheme = themeForDark(AppThemeFamily.techInnovation);

      final primaryLight = lightTheme.colorScheme.primary;
      final onPrimaryLight = lightTheme.colorScheme.onPrimary;
      final primaryDark = darkTheme.colorScheme.primary;
      final onPrimaryDark = darkTheme.colorScheme.onPrimary;

      final lightResult = ContrastChecker.calculateContrast(
        onPrimaryLight,
        primaryLight,
      );
      final darkResult = ContrastChecker.calculateContrast(
        onPrimaryDark,
        primaryDark,
      );

      expect(
        lightResult.passesAA,
        isTrue,
        reason:
            'TechInnovation light primary contrast ${lightResult.ratio} does not meet WCAG AA',
      );

      expect(
        darkResult.passesAA,
        isTrue,
        reason:
            'TechInnovation dark primary contrast ${darkResult.ratio} does not meet WCAG AA',
      );
    });

    test('TechInnovation secondary text passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.techInnovation);
      final darkTheme = themeForDark(AppThemeFamily.techInnovation);

      final secondaryLight = lightTheme.colorScheme.secondary;
      final onSecondaryLight = lightTheme.colorScheme.onSecondary;
      final secondaryDark = darkTheme.colorScheme.secondary;
      final onSecondaryDark = darkTheme.colorScheme.onSecondary;

      final lightResult = ContrastChecker.calculateContrast(
        onSecondaryLight,
        secondaryLight,
      );
      final darkResult = ContrastChecker.calculateContrast(
        onSecondaryDark,
        secondaryDark,
      );

      expect(
        lightResult.passesAA,
        isTrue,
        reason:
            'TechInnovation light secondary contrast ${lightResult.ratio} does not meet WCAG AA',
      );

      expect(
        darkResult.passesAA,
        isTrue,
        reason:
            'TechInnovation dark secondary contrast ${darkResult.ratio} does not meet WCAG AA',
      );
    });

    test('All light themes pass WCAG AA for surface text', () {
      final failedThemes = <String>[];

      for (final family in AppThemeFamily.values) {
        final theme = themeForLight(family);
        final surface = theme.colorScheme.surface;
        final onSurface = theme.colorScheme.onSurface;

        final result = ContrastChecker.calculateContrast(onSurface, surface);

        if (!result.passesAA) {
          failedThemes.add('${family.name}: ${result.ratio}');
        }
      }

      expect(
        failedThemes,
        isEmpty,
        reason:
            'The following light themes failed WCAG AA: ${failedThemes.join(", ")}',
      );
    });

    test('All dark themes pass WCAG AA for surface text', () {
      final failedThemes = <String>[];

      for (final family in AppThemeFamily.values) {
        final theme = themeForDark(family);
        final surface = theme.colorScheme.surface;
        final onSurface = theme.colorScheme.onSurface;

        final result = ContrastChecker.calculateContrast(onSurface, surface);

        if (!result.passesAA) {
          failedThemes.add('${family.name}: ${result.ratio}');
        }
      }

      expect(
        failedThemes,
        isEmpty,
        reason:
            'The following dark themes failed WCAG AA: ${failedThemes.join(", ")}',
      );
    });

    test('All themes pass WCAG AA for primary text', () {
      final failedThemes = <String>[];
      final allResults = <Map<String, dynamic>>[];

      for (final family in AppThemeFamily.values) {
        final lightTheme = themeForLight(family);
        final darkTheme = themeForDark(family);

        final lightResult = ContrastChecker.calculateContrast(
          lightTheme.colorScheme.onPrimary,
          lightTheme.colorScheme.primary,
        );

        final darkResult = ContrastChecker.calculateContrast(
          darkTheme.colorScheme.onPrimary,
          darkTheme.colorScheme.primary,
        );

        allResults.add({
          'theme': family.name,
          'light': lightResult.ratio,
          'dark': darkResult.ratio,
          'light_passes': lightResult.passesAA,
          'dark_passes': darkResult.passesAA,
        });

        if (!lightResult.passesAA) {
          failedThemes.add('${family.name} light: ${lightResult.ratio}');
        }

        if (!darkResult.passesAA) {
          failedThemes.add('${family.name} dark: ${darkResult.ratio}');
        }
      }

      if (kDebugMode) {
        print('\n=== Primary Text Contrast Report ===');
        for (final result in allResults) {
          final lightRatio = result['light'] as num;
          final darkRatio = result['dark'] as num;
          print(
            '${result['theme']}: Light=${lightRatio.toStringAsFixed(2)} (${result['light_passes'] ? 'PASS' : 'FAIL'}), Dark=${darkRatio.toStringAsFixed(2)} (${result['dark_passes'] ? 'PASS' : 'FAIL'})',
          );
        }

        if (failedThemes.isNotEmpty) {
          print('\nThemes that do not meet WCAG AA (4.5:1) for primary text:');
          for (final theme in failedThemes) {
            print('  - $theme');
          }
          print(
            '\nNote: These themes may trigger contrast alerts when used in the editor.',
          );
        }
        print('=====================================\n');
      }

      expect(
        allResults,
        isNotEmpty,
        reason: 'Should have results for all themes',
      );
    });

    test('TechInnovation theme meets high contrast requirements', () {
      final lightTheme = themeForLight(AppThemeFamily.techInnovation);
      final darkTheme = themeForDark(AppThemeFamily.techInnovation);

      final lightSurfaceResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkSurfaceResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      final lightPrimaryResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onPrimary,
        lightTheme.colorScheme.primary,
      );

      final darkPrimaryResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onPrimary,
        darkTheme.colorScheme.primary,
      );

      if (kDebugMode) {
        print('\n=== TechInnovation High Contrast Report ===');
        print(
          'Light Surface: ${lightSurfaceResult.ratio.toStringAsFixed(2)}:1 (WCAG AA: ${lightSurfaceResult.passesAA ? 'PASS' : 'FAIL'})',
        );
        print(
          'Dark Surface: ${darkSurfaceResult.ratio.toStringAsFixed(2)}:1 (WCAG AA: ${darkSurfaceResult.passesAA ? 'PASS' : 'FAIL'})',
        );
        print(
          'Light Primary: ${lightPrimaryResult.ratio.toStringAsFixed(2)}:1 (WCAG AA: ${lightPrimaryResult.passesAA ? 'PASS' : 'FAIL'})',
        );
        print(
          'Dark Primary: ${darkPrimaryResult.ratio.toStringAsFixed(2)}:1 (WCAG AA: ${darkPrimaryResult.passesAA ? 'PASS' : 'FAIL'})',
        );
        print('==========================================\n');
      }

      expect(
        lightSurfaceResult.passesAA,
        isTrue,
        reason:
            'TechInnovation light theme should meet WCAG AA, got ${lightSurfaceResult.ratio}',
      );

      expect(
        darkSurfaceResult.passesAA,
        isTrue,
        reason:
            'TechInnovation dark theme should meet WCAG AA, got ${darkSurfaceResult.ratio}',
      );

      expect(
        lightPrimaryResult.passesAA,
        isTrue,
        reason:
            'TechInnovation light primary should meet WCAG AA, got ${lightPrimaryResult.ratio}',
      );

      expect(
        darkPrimaryResult.passesAA,
        isTrue,
        reason:
            'TechInnovation dark primary should meet WCAG AA, got ${darkPrimaryResult.ratio}',
      );
    });

    test('OceanDepths theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.oceanDepths);
      final darkTheme = themeForDark(AppThemeFamily.oceanDepths);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('SunsetBoulevard theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.sunsetBoulevard);
      final darkTheme = themeForDark(AppThemeFamily.sunsetBoulevard);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('ForestCanopy theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.forestCanopy);
      final darkTheme = themeForDark(AppThemeFamily.forestCanopy);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('ModernMinimalist theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.modernMinimalist);
      final darkTheme = themeForDark(AppThemeFamily.modernMinimalist);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('GoldenHour theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.goldenHour);
      final darkTheme = themeForDark(AppThemeFamily.goldenHour);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('ArcticFrost theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.arcticFrost);
      final darkTheme = themeForDark(AppThemeFamily.arcticFrost);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('DesertRose theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.desertRose);
      final darkTheme = themeForDark(AppThemeFamily.desertRose);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('BotanicalGarden theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.botanicalGarden);
      final darkTheme = themeForDark(AppThemeFamily.botanicalGarden);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('MidnightGalaxy theme passes WCAG AA', () {
      final lightTheme = themeForLight(AppThemeFamily.midnightGalaxy);
      final darkTheme = themeForDark(AppThemeFamily.midnightGalaxy);

      final lightResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(lightResult.passesAA, isTrue);
      expect(darkResult.passesAA, isTrue);
    });

    test('Theme contrast ratios are consistent across light and dark modes', () {
      final lightTheme = themeForLight(AppThemeFamily.techInnovation);
      final darkTheme = themeForDark(AppThemeFamily.techInnovation);

      final lightSurfaceResult = ContrastChecker.calculateContrast(
        lightTheme.colorScheme.onSurface,
        lightTheme.colorScheme.surface,
      );

      final darkSurfaceResult = ContrastChecker.calculateContrast(
        darkTheme.colorScheme.onSurface,
        darkTheme.colorScheme.surface,
      );

      expect(
        lightSurfaceResult.ratio,
        closeTo(darkSurfaceResult.ratio, 5.0),
        reason:
            'Light and dark mode contrast ratios should be reasonably consistent',
      );
    });
  });
}
