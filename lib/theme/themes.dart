import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'advanced_typography.dart';
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

  final cs = baseTheme.colorScheme;
  final outline = cs.outlineVariant;
  final fill = brightness == Brightness.light
      ? cs.surfaceContainerHighest
      : cs.surfaceContainerHigh;

  return baseTheme.copyWith(
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: baseTheme.colorScheme.primary,
      selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.25),
      selectionHandleColor: baseTheme.colorScheme.primary,
    ),
    // Enhanced Typography with Merriweather for headings, Inter for body
    textTheme: AdvancedTypography.apply(
      GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
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
    ),

    // Modern outline input decorations
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: outline, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: outline, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: cs.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: cs.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide(color: cs.error, width: 2.0),
      ),
      filled: true,
      fillColor: fill,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.m,
      ),
    ),

    // Softer card elevation with colored shadows
    cardTheme: CardThemeData(
      elevation: 2.0,
      shadowColor: AppColors.shadowColorLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.s,
      ),
    ),

    // Enhanced list tile for better readability
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.xs,
      ),
      minLeadingWidth: 24.0,
    ),

    // Improved scrollbar styling
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(cs.outline),
      trackColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
      thickness: WidgetStateProperty.all(6.0),
      radius: const Radius.circular(3.0),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Spacing.l, vertical: Spacing.m),
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(0, MobileSpacing.touchTargetMin),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.m)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Spacing.l, vertical: Spacing.m),
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(0, MobileSpacing.touchTargetMin),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.m)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: cs.onSurface.withValues(alpha: 0.12),
              width: 1.5,
            );
          }
          return BorderSide(color: cs.outlineVariant, width: 1.5);
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Spacing.m, vertical: Spacing.s),
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(0, MobileSpacing.touchTargetMin),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.m)),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(MobileSpacing.touchTargetMin, MobileSpacing.touchTargetMin),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(Spacing.s)),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.s),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.24);
        }
        if (states.contains(WidgetState.selected)) {
          return cs.onPrimary;
        }
        return cs.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return cs.primary;
        }
        return cs.surfaceContainerHighest;
      }),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cs.inverseSurface,
      contentTextStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: cs.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.m),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.l)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: MobileSpacing.bottomNavHeight,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      labelTextStyle: WidgetStatePropertyAll(baseTheme.textTheme.labelMedium),
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
      focusColor: baseTheme.colorScheme.primary.withValues(alpha: 0.18),
      hoverColor: baseTheme.colorScheme.primary.withValues(alpha: 0.10),
      highlightColor: baseTheme.colorScheme.primary.withValues(alpha: 0.14),
      dividerColor: baseTheme.colorScheme.onSurface.withValues(alpha: 0.20),
      iconTheme: IconThemeData(color: baseTheme.colorScheme.onSurface),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: baseTheme.colorScheme.primary,
        selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: baseTheme.colorScheme.primary,
      ),
      textTheme: AdvancedTypography.apply(
        GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
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
      focusColor: baseTheme.colorScheme.primary.withValues(alpha: 0.18),
      hoverColor: baseTheme.colorScheme.primary.withValues(alpha: 0.10),
      highlightColor: baseTheme.colorScheme.primary.withValues(alpha: 0.14),
      dividerColor: baseTheme.colorScheme.onSurface.withValues(alpha: 0.20),
      iconTheme: IconThemeData(color: baseTheme.colorScheme.onSurface),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: baseTheme.colorScheme.primary,
        selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.35),
        selectionHandleColor: baseTheme.colorScheme.primary,
      ),
      textTheme: AdvancedTypography.apply(
        GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
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
