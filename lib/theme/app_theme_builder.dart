import 'package:flutter/material.dart';

import '../theme/themes.dart';
import '../theme/reader_typography.dart';
import '../theme/font_packs.dart' show ReaderFontPack;
import '../theme/font_packs.dart' as font_packs;

import '../theme/no_animation_transitions.dart';
import '../theme/fade_through_page_transitions.dart';

/// Builder for app themes
///
/// This class handles the theme building logic, separating it from
/// the UI layer for better testability.
class AppThemeBuilder {
  /// Build light theme palette
  static ThemeData buildLight({
    required AppThemeFamily family,
    required ReaderFontPack fontPack,
    required String? customFontFamily,
    required ReaderTypographyPreset preset,
  }) {
    final palette = themeForLight(family);
    return applyFontPackOrCustom(palette, fontPack, customFontFamily);
  }

  /// Build dark theme palette
  static ThemeData buildDark({
    required AppThemeFamily family,
    required ReaderFontPack fontPack,
    required String? customFontFamily,
    required ReaderTypographyPreset preset,
  }) {
    final palette = themeForDark(family);
    return applyFontPackOrCustom(palette, fontPack, customFontFamily);
  }

  /// Apply font pack or custom font family
  static ThemeData applyFontPackOrCustom(
    ThemeData base,
    ReaderFontPack fontPack,
    String? customFontFamily,
  ) {
    return font_packs.applyFontPackOrCustom(base, fontPack, customFontFamily);
  }

  /// Apply reader typography preset
  static ThemeData applyReaderTypography(
    ThemeData base, {
    required ReaderTypographyPreset preset,
    required ReaderTypographyPreset? separatePreset,
    required bool hasSeparate,
  }) {
    final targetPreset = hasSeparate && separatePreset != null
        ? separatePreset
        : preset;
    return applyReaderTypographyToTheme(base, targetPreset);
  }

  /// Apply reader typography to theme data
  static ThemeData applyReaderTypographyToTheme(
    ThemeData base,
    ReaderTypographyPreset preset,
  ) {
    return base.copyWith(textTheme: _getTextThemeForPreset(preset));
  }

  /// Get text theme for a preset
  static TextTheme _getTextThemeForPreset(ReaderTypographyPreset preset) {
    switch (preset) {
      case ReaderTypographyPreset.system:
        return const TextTheme();
      case ReaderTypographyPreset.comfortable:
        return const TextTheme(
          displayLarge: TextStyle(fontSize: 18),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 15),
          bodySmall: TextStyle(fontSize: 14),
        );
      case ReaderTypographyPreset.compact:
        return const TextTheme(
          displayLarge: TextStyle(fontSize: 16),
          bodyLarge: TextStyle(fontSize: 15),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 13),
        );
      case ReaderTypographyPreset.serifLike:
        return const TextTheme(
          displayLarge: TextStyle(fontSize: 18, fontFamily: 'serif'),
          bodyLarge: TextStyle(fontSize: 16, fontFamily: 'serif'),
          bodyMedium: TextStyle(fontSize: 15, fontFamily: 'serif'),
          bodySmall: TextStyle(fontSize: 14, fontFamily: 'serif'),
        );
    }
  }

  /// Apply motion settings to theme
  static ThemeData applyMotion({
    required ThemeData base,
    required bool reduceMotion,
  }) {
    if (reduceMotion) {
      return base.copyWith(
        splashFactory: NoSplash.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.fuchsia: NoAnimationPageTransitionsBuilder(),
          },
        ),
      );
    }

    // Apply Material FadeThrough transitions when motion is allowed.
    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeThroughPageTransitionsBuilder(),
        },
      ),
    );
  }
}
