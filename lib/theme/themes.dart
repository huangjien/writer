import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final baseTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: brightness == Brightness.light
          ? AppColors.surfaceTint
          : AppColors.surfaceTintDark,
    ),
    useMaterial3: true,
  );

  return baseTheme.copyWith(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: baseTheme.colorScheme.primary,
      selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.25),
      selectionHandleColor: baseTheme.colorScheme.primary,
    ),
    // Enhanced Typography with Merriweather for headings, Inter for body
    textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.displayLarge,
        height: 1.6,
      ),
      displayMedium: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.displayMedium,
        height: 1.6,
      ),
      displaySmall: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.displaySmall,
        height: 1.6,
      ),
      headlineLarge: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.headlineLarge,
        height: 1.6,
      ),
      headlineMedium: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.headlineMedium,
        height: 1.6,
      ),
      headlineSmall: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.headlineSmall,
        height: 1.6,
      ),
      titleLarge: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.titleLarge,
        height: 1.6,
      ),
      titleMedium: GoogleFonts.merriweather(
        textStyle: baseTheme.textTheme.titleMedium,
        height: 1.6,
      ),
      titleSmall: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.titleSmall,
        height: 1.6,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
      ),
    ),

    // Modern outline input decorations
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.grey.shade600,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.grey.shade600,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: seed, width: 2.0),
      ),
      filled: true,
      fillColor: brightness == Brightness.light
          ? Colors.grey.shade50
          : Colors.grey.shade800,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
    ),

    // Softer card elevation with colored shadows
    cardTheme: CardThemeData(
      elevation: 2.0,
      shadowColor: AppColors.shadowColorLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    ),

    // Enhanced list tile for better readability
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      minLeadingWidth: 24.0,
    ),

    // Improved scrollbar styling
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        brightness == Brightness.light
            ? Colors.grey.shade400
            : Colors.grey.shade600,
      ),
      trackColor: WidgetStateProperty.all(
        brightness == Brightness.light
            ? Colors.grey.shade200
            : Colors.grey.shade800,
      ),
      thickness: WidgetStateProperty.all(6.0),
      radius: const Radius.circular(3.0),
    ),
  );
}

/// Light variant for the given theme family.
ThemeData themeForLight(AppThemeFamily family) {
  if (_isHighContrast(family)) {
    final baseTheme = ThemeData(
      colorScheme: const ColorScheme.highContrastLight(),
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: baseTheme.colorScheme.primary,
        selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: baseTheme.colorScheme.primary,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.m),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.m),
          borderSide: const BorderSide(width: 2.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.l),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
  return _buildFromSeed(_seedFor(family), Brightness.light);
}

/// Dark variant for the given theme family.
ThemeData themeForDark(AppThemeFamily family) {
  if (_isHighContrast(family)) {
    final baseTheme = ThemeData(
      colorScheme: const ColorScheme.highContrastDark(),
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: baseTheme.colorScheme.primary,
        selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: baseTheme.colorScheme.primary,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.m),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.m),
          borderSide: const BorderSide(width: 2.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.l),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
  return _buildFromSeed(_seedFor(family), Brightness.dark);
}
