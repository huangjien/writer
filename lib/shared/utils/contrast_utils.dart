import 'dart:math' as math;
import 'package:flutter/material.dart';

class ContrastUtils {
  ContrastUtils._();

  static double _getLuminance(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final rLum = r <= 0.03928
        ? r / 12.92
        : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
    final gLum = g <= 0.03928
        ? g / 12.92
        : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
    final bLum = b <= 0.03928
        ? b / 12.92
        : math.pow((b + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * rLum + 0.7152 * gLum + 0.0722 * bLum;
  }

  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  static Color getAccessibleTextColor({
    required Color textColor,
    required Color backgroundColor,
    required bool isDarkMode,
    double minContrastRatio = 4.5,
  }) {
    final currentContrast = calculateContrastRatio(textColor, backgroundColor);

    if (currentContrast >= minContrastRatio) {
      return textColor;
    }

    if (isDarkMode) {
      return _getHighContrastDarkModeColor(textColor);
    } else {
      return _getHighContrastLightModeColor(textColor);
    }
  }

  static Color _getHighContrastDarkModeColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final adjustedLuminance = hslColor.lightness.clamp(0.75, 0.98);
    final adjustedSaturation = (hslColor.saturation * 0.9).clamp(0.1, 1.0);

    return hslColor
        .withLightness(adjustedLuminance)
        .withSaturation(adjustedSaturation)
        .toColor();
  }

  static Color _getHighContrastLightModeColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final adjustedLuminance = hslColor.lightness.clamp(0.15, 0.30);

    return hslColor.withLightness(adjustedLuminance).toColor();
  }

  static Color getAccessibleIconColor({
    required Color iconColor,
    required Color backgroundColor,
    required bool isDarkMode,
    double minContrastRatio = 4.5,
  }) {
    final currentContrast = calculateContrastRatio(iconColor, backgroundColor);

    if (currentContrast >= minContrastRatio) {
      return iconColor;
    }

    if (isDarkMode) {
      return _getHighContrastDarkModeIconColor(iconColor, backgroundColor);
    } else {
      return _getHighContrastLightModeIconColor(iconColor, backgroundColor);
    }
  }

  static Color _getHighContrastDarkModeIconColor(
    Color iconColor,
    Color backgroundColor,
  ) {
    final bgLuminance = backgroundColor.computeLuminance();
    final contrastRatio = calculateContrastRatio(iconColor, backgroundColor);

    if (contrastRatio >= 4.5) {
      return iconColor;
    }

    if (bgLuminance > 0.4) {
      return Colors.white.withValues(alpha: 0.95);
    }

    final hslColor = HSLColor.fromColor(iconColor);
    final adjustedLuminance = hslColor.lightness.clamp(0.80, 0.98);
    final adjustedSaturation = (hslColor.saturation * 0.8).clamp(0.2, 1.0);

    return hslColor
        .withLightness(adjustedLuminance)
        .withSaturation(adjustedSaturation)
        .toColor();
  }

  static Color _getHighContrastLightModeIconColor(
    Color iconColor,
    Color backgroundColor,
  ) {
    final bgLuminance = backgroundColor.computeLuminance();
    final contrastRatio = calculateContrastRatio(iconColor, backgroundColor);

    if (contrastRatio >= 4.5) {
      return iconColor;
    }

    if (bgLuminance < 0.6) {
      return Colors.black.withValues(alpha: 0.9);
    }

    final hslColor = HSLColor.fromColor(iconColor);
    final adjustedLuminance = hslColor.lightness.clamp(0.05, 0.20);

    return hslColor.withLightness(adjustedLuminance).toColor();
  }

  static Color forceContrastColor({
    required Color foreground,
    required Color background,
    double minContrastRatio = 4.5,
  }) {
    final currentContrast = calculateContrastRatio(foreground, background);
    if (currentContrast >= minContrastRatio) {
      return foreground;
    }

    final bgLuminance = _getLuminance(background);

    if (bgLuminance > 0.5) {
      return Colors.black.withValues(alpha: 0.87);
    } else {
      return Colors.white.withValues(alpha: 0.95);
    }
  }

  static Color adjustButtonBackgroundColorForContrast({
    required Color buttonColor,
    required Color surfaceColor,
    required bool isDarkMode,
  }) {
    final buttonLuminance = buttonColor.computeLuminance();
    final contrastWithSurface = calculateContrastRatio(
      buttonColor,
      surfaceColor,
    );

    if (contrastWithSurface >= 1.5) {
      return buttonColor;
    }

    final hsl = HSLColor.fromColor(buttonColor);

    if (isDarkMode) {
      if (buttonLuminance > 0.4) {
        return hsl
            .withLightness((buttonLuminance - 0.15).clamp(0.15, 0.40))
            .toColor();
      }
      return buttonColor;
    } else {
      if (buttonLuminance > 0.6) {
        return hsl
            .withLightness((buttonLuminance - 0.2).clamp(0.35, 0.60))
            .toColor();
      }
      return buttonColor;
    }
  }

  static Color getButtonTextColor({
    required Color buttonBackgroundColor,
    required bool isDarkMode,
  }) {
    final bgLuminance = buttonBackgroundColor.computeLuminance();

    if (isDarkMode) {
      if (bgLuminance < 0.3) {
        return Colors.white.withValues(alpha: 0.95);
      } else if (bgLuminance < 0.5) {
        return Colors.white.withValues(alpha: 0.90);
      } else {
        return Colors.black.withValues(alpha: 0.85);
      }
    } else {
      if (bgLuminance > 0.65) {
        return Colors.black.withValues(alpha: 0.80);
      } else if (bgLuminance > 0.45) {
        return Colors.black.withValues(alpha: 0.75);
      } else {
        return Colors.white.withValues(alpha: 0.95);
      }
    }
  }
}
