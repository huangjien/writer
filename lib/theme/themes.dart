import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Reader-friendly theme families. Each family has light and dark variants.
enum AppThemeFamily {
  defaultFamily,
  sepia,
  highContrast,
  solarized,
  solarizedTan,
  nord,
  nordFrost,
  nordSnowstorm,
}

/// Returns the seed color for the given family.
Color _seedFor(AppThemeFamily family) {
  switch (family) {
    case AppThemeFamily.defaultFamily:
      return Colors.indigo;
    case AppThemeFamily.sepia:
      return AppColors.sepiaSeed;
    case AppThemeFamily.solarized:
      // Solarized Blue
      return const Color(0xFF268BD2);
    case AppThemeFamily.solarizedTan:
      // Solarized Tan (base yellow)
      return const Color(0xFFB58900);
    case AppThemeFamily.nord:
      // Nord Blue
      return const Color(0xFF5E81AC);
    case AppThemeFamily.nordFrost:
      // Nord Frost palette accent
      return const Color(0xFF8FBCBB);
    case AppThemeFamily.nordSnowstorm:
      // Nord Snowstorm (light neutrals as seed may not be ideal)
      return const Color(0xFFE5E9F0);
    case AppThemeFamily.highContrast:
      // Seed not used for highContrast families
      return Colors.black;
  }
}

bool _isHighContrast(AppThemeFamily family) =>
    family == AppThemeFamily.highContrast;

ThemeData _buildFromSeed(Color seed, Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );
}

/// Light variant for the given theme family.
ThemeData themeForLight(AppThemeFamily family) {
  if (_isHighContrast(family)) {
    return ThemeData(
      colorScheme: const ColorScheme.highContrastLight(),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
  return _buildFromSeed(_seedFor(family), Brightness.light);
}

/// Dark variant for the given theme family.
ThemeData themeForDark(AppThemeFamily family) {
  if (_isHighContrast(family)) {
    return ThemeData(
      colorScheme: const ColorScheme.highContrastDark(),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
  return _buildFromSeed(_seedFor(family), Brightness.dark);
}
