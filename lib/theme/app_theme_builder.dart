import 'package:flutter/material.dart';

import '../theme/themes.dart';
import '../theme/reader_typography.dart';
import '../theme/font_packs.dart' show ReaderFontPack;
import '../theme/font_packs.dart' as font_packs;
import '../theme/design_tokens.dart';

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
    // Preserve the font family from the base theme if the preset doesn't override it
    final presetTheme = _getTextThemeForPreset(preset);
    final baseTheme = base.textTheme;

    // Helper to merge text styles while preserving base font if preset doesn't specify one
    TextStyle? merge(TextStyle? baseStyle, TextStyle? presetStyle) {
      if (presetStyle == null) return baseStyle;
      if (baseStyle == null) return presetStyle;

      // If preset has a font family (e.g. serifLike), use it.
      // Otherwise, keep the base font family (from font pack or custom font).
      return baseStyle
          .merge(presetStyle)
          .copyWith(
            fontFamily: presetStyle.fontFamily ?? baseStyle.fontFamily,
            fontFamilyFallback:
                presetStyle.fontFamilyFallback ?? baseStyle.fontFamilyFallback,
          );
    }

    return base.copyWith(
      textTheme: baseTheme.copyWith(
        displayLarge: merge(baseTheme.displayLarge, presetTheme.displayLarge),
        bodyLarge: merge(baseTheme.bodyLarge, presetTheme.bodyLarge),
        bodyMedium: merge(baseTheme.bodyMedium, presetTheme.bodyMedium),
        bodySmall: merge(baseTheme.bodySmall, presetTheme.bodySmall),
      ),
    );
  }

  /// Get text theme for a preset
  static TextTheme _getTextThemeForPreset(ReaderTypographyPreset preset) {
    switch (preset) {
      case ReaderTypographyPreset.system:
        return const TextTheme();
      case ReaderTypographyPreset.comfortable:
        return const TextTheme(
          displayLarge: TextStyle(
            fontSize: ReaderTypographyScale.displayComfortable,
          ),
          bodyLarge: TextStyle(
            fontSize: ReaderTypographyScale.bodyLargeComfortable,
          ),
          bodyMedium: TextStyle(
            fontSize: ReaderTypographyScale.bodyMediumComfortable,
          ),
          bodySmall: TextStyle(
            fontSize: ReaderTypographyScale.bodySmallComfortable,
          ),
        );
      case ReaderTypographyPreset.compact:
        return const TextTheme(
          displayLarge: TextStyle(
            fontSize: ReaderTypographyScale.displayCompact,
          ),
          bodyLarge: TextStyle(
            fontSize: ReaderTypographyScale.bodyLargeCompact,
          ),
          bodyMedium: TextStyle(
            fontSize: ReaderTypographyScale.bodyMediumCompact,
          ),
          bodySmall: TextStyle(
            fontSize: ReaderTypographyScale.bodySmallCompact,
          ),
        );
      case ReaderTypographyPreset.serifLike:
        return const TextTheme(
          displayLarge: TextStyle(
            fontSize: ReaderTypographyScale.displayComfortable,
            fontFamily: 'serif',
          ),
          bodyLarge: TextStyle(
            fontSize: ReaderTypographyScale.bodyLargeComfortable,
            fontFamily: 'serif',
          ),
          bodyMedium: TextStyle(
            fontSize: ReaderTypographyScale.bodyMediumComfortable,
            fontFamily: 'serif',
          ),
          bodySmall: TextStyle(
            fontSize: ReaderTypographyScale.bodySmallComfortable,
            fontFamily: 'serif',
          ),
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
