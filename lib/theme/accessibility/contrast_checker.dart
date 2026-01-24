import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ContrastLevel { fail, aa, aaa, largeTextAa, largeTextAaa }

class ContrastResult {
  final double ratio;
  final ContrastLevel level;
  final bool passesAA;

  const ContrastResult({
    required this.ratio,
    required this.level,
    required this.passesAA,
  });

  @override
  String toString() =>
      'ContrastResult(ratio: $ratio, level: $level, passesAA: $passesAA)';
}

class ContrastChecker {
  static const double _aaThreshold = 4.5;
  static const double _aaaThreshold = 7.0;
  static const double _largeTextAaThreshold = 3.0;
  static const double _largeTextAaaThreshold = 4.5;

  static ContrastResult calculateContrast(Color foreground, Color background) {
    final fgLuminance = _getRelativeLuminance(foreground);
    final bgLuminance = _getRelativeLuminance(background);

    final ratio = _getContrastRatio(fgLuminance, bgLuminance);
    final level = _determineLevel(ratio);
    final passesAA = ratio >= _aaThreshold;

    return ContrastResult(ratio: ratio, level: level, passesAA: passesAA);
  }

  static double _getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent((color.r * 255.0).round().clamp(0, 255));
    final g = _linearizeColorComponent((color.g * 255.0).round().clamp(0, 255));
    final b = _linearizeColorComponent((color.b * 255.0).round().clamp(0, 255));

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearizeColorComponent(int value) {
    final normalized = value / 255.0;

    if (normalized <= 0.03928) {
      return normalized / 12.92;
    } else {
      return math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  static double _getContrastRatio(double l1, double l2) {
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  static ContrastLevel _determineLevel(double ratio) {
    if (ratio >= _aaaThreshold) return ContrastLevel.aaa;
    if (ratio >= _largeTextAaaThreshold) return ContrastLevel.largeTextAaa;
    if (ratio >= _aaThreshold) return ContrastLevel.aa;
    if (ratio >= _largeTextAaThreshold) return ContrastLevel.largeTextAa;
    return ContrastLevel.fail;
  }

  static String getContrastLevelDescription(ContrastLevel level) {
    switch (level) {
      case ContrastLevel.fail:
        return 'Fail (below WCAG AA)';
      case ContrastLevel.aa:
        return 'AA (Normal Text)';
      case ContrastLevel.aaa:
        return 'AAA (Normal Text)';
      case ContrastLevel.largeTextAa:
        return 'AA (Large Text Only)';
      case ContrastLevel.largeTextAaa:
        return 'AAA (Large Text Only)';
    }
  }

  static bool isValidForText(
    ContrastResult result, {
    bool isLargeText = false,
  }) {
    if (isLargeText) {
      return result.ratio >= _largeTextAaThreshold;
    }
    return result.ratio >= _aaThreshold;
  }
}

class ContrastSuggestion {
  final Color suggestedColor;
  final String reason;
  final double newRatio;

  const ContrastSuggestion({
    required this.suggestedColor,
    required this.reason,
    required this.newRatio,
  });
}

class ContrastAdjuster {
  static List<ContrastSuggestion> suggestColorAdjustments(
    Color foreground,
    Color background, {
    bool adjustForeground = true,
    double targetRatio = 4.5,
  }) {
    final suggestions = <ContrastSuggestion>[];
    final currentResult = ContrastChecker.calculateContrast(
      foreground,
      background,
    );

    if (currentResult.passesAA) {
      return suggestions;
    }

    final bgLuminance = ContrastChecker._getRelativeLuminance(background);

    if (adjustForeground) {
      suggestions.addAll(
        _generateForegroundAdjustments(foreground, bgLuminance, targetRatio),
      );
    } else {
      suggestions.addAll(
        _generateBackgroundAdjustments(
          background,
          ContrastChecker._getRelativeLuminance(foreground),
          targetRatio,
        ),
      );
    }

    return suggestions;
  }

  static List<ContrastSuggestion> _generateForegroundAdjustments(
    Color original,
    double bgLuminance,
    double targetRatio,
  ) {
    final suggestions = <ContrastSuggestion>[];

    final adjustments = [
      _makeDarker(original, 0.2),
      _makeDarker(original, 0.4),
      _makeLighter(original, 0.2),
      _makeLighter(original, 0.4),
      _invertColor(original),
      Colors.black,
      Colors.white,
    ];

    for (final color in adjustments) {
      final ratio = ContrastChecker.calculateContrast(
        color,
        Color.fromRGBO(
          (bgLuminance * 255).round(),
          (bgLuminance * 255).round(),
          (bgLuminance * 255).round(),
          1.0,
        ),
      ).ratio;

      if (ratio >= targetRatio) {
        String reason;
        if (color == Colors.black) {
          reason = 'Use pure black';
        } else if (color == Colors.white) {
          reason = 'Use pure white';
        } else if (_isInverted(original, color)) {
          reason = 'Invert the color';
        } else if (_isDarker(original, color)) {
          reason = 'Make the text darker';
        } else {
          reason = 'Make the text lighter';
        }

        suggestions.add(
          ContrastSuggestion(
            suggestedColor: color,
            reason: reason,
            newRatio: ratio,
          ),
        );
      }
    }

    return suggestions;
  }

  static List<ContrastSuggestion> _generateBackgroundAdjustments(
    Color original,
    double fgLuminance,
    double targetRatio,
  ) {
    final suggestions = <ContrastSuggestion>[];

    final adjustments = [
      _makeDarker(original, 0.2),
      _makeDarker(original, 0.4),
      _makeLighter(original, 0.2),
      _makeLighter(original, 0.4),
      _invertColor(original),
      Colors.black,
      Colors.white,
    ];

    for (final color in adjustments) {
      final ratio = ContrastChecker.calculateContrast(
        Color.fromRGBO(
          (fgLuminance * 255).round(),
          (fgLuminance * 255).round(),
          (fgLuminance * 255).round(),
          1.0,
        ),
        color,
      ).ratio;

      if (ratio >= targetRatio) {
        String reason;
        if (color == Colors.black) {
          reason = 'Use pure black background';
        } else if (color == Colors.white) {
          reason = 'Use pure white background';
        } else if (_isInverted(original, color)) {
          reason = 'Invert the background';
        } else if (_isDarker(original, color)) {
          reason = 'Make the background darker';
        } else {
          reason = 'Make the background lighter';
        }

        suggestions.add(
          ContrastSuggestion(
            suggestedColor: color,
            reason: reason,
            newRatio: ratio,
          ),
        );
      }
    }

    return suggestions;
  }

  static Color _makeDarker(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _makeLighter(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * (1 + amount)).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _invertColor(Color color) {
    return Color.fromARGB(
      (color.a * 255.0).round().clamp(0, 255),
      255 - (color.r * 255.0).round().clamp(0, 255),
      255 - (color.g * 255.0).round().clamp(0, 255),
      255 - (color.b * 255.0).round().clamp(0, 255),
    );
  }

  static bool _isDarker(Color original, Color modified) {
    final hslOriginal = HSLColor.fromColor(original);
    final hslModified = HSLColor.fromColor(modified);
    return hslModified.lightness < hslOriginal.lightness;
  }

  static bool _isInverted(Color original, Color modified) {
    final threshold = 20;
    return ((original.r - modified.r).abs() * 255).round().clamp(0, 255) >
            threshold &&
        ((original.g - modified.g).abs() * 255).round().clamp(0, 255) >
            threshold &&
        ((original.b - modified.b).abs() * 255).round().clamp(0, 255) >
            threshold;
  }
}

class PresetColorScheme {
  final String name;
  final Color background;
  final Color text;
  final Color secondaryText;

  const PresetColorScheme({
    required this.name,
    required this.background,
    required this.text,
    required this.secondaryText,
  });

  static const List<PresetColorScheme> lightSchemes = [
    PresetColorScheme(
      name: 'Standard Light',
      background: Color(0xFFFFFFFF),
      text: Color(0xFF000000),
      secondaryText: Color(0xFF424242),
    ),
    PresetColorScheme(
      name: 'Warm Paper',
      background: Color(0xFFFAF3E0),
      text: Color(0xFF2C1810),
      secondaryText: Color(0xFF5D4037),
    ),
    PresetColorScheme(
      name: 'Cool Grey',
      background: Color(0xFFF5F5F5),
      text: Color(0xFF212121),
      secondaryText: Color(0xFF424242),
    ),
    PresetColorScheme(
      name: 'Sepia',
      background: Color(0xFFF4ECD8),
      text: Color(0xFF5B4636),
      secondaryText: Color(0xFF8B7355),
    ),
  ];

  static const List<PresetColorScheme> darkSchemes = [
    PresetColorScheme(
      name: 'Standard Dark',
      background: Color(0xFF121212),
      text: Color(0xFFE0E0E0),
      secondaryText: Color(0xFFB0B0B0),
    ),
    PresetColorScheme(
      name: 'Midnight',
      background: Color(0xFF1A1A2E),
      text: Color(0xFFE8E8E8),
      secondaryText: Color(0xFFB0B0B0),
    ),
    PresetColorScheme(
      name: 'Dark Sepia',
      background: Color(0xFF2B2118),
      text: Color(0xFFE6D5C3),
      secondaryText: Color(0xFFC4B5A4),
    ),
    PresetColorScheme(
      name: 'Deep Ocean',
      background: Color(0xFF0D1B2A),
      text: Color(0xFFE0F7FA),
      secondaryText: Color(0xFF80DEEA),
    ),
  ];

  static List<PresetColorScheme> schemesForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkSchemes : lightSchemes;
  }

  ContrastResult checkTextContrast() {
    return ContrastChecker.calculateContrast(text, background);
  }

  ContrastResult checkSecondaryTextContrast() {
    return ContrastChecker.calculateContrast(secondaryText, background);
  }
}
