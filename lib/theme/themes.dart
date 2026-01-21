import 'package:flutter/material.dart';
import 'advanced_typography.dart';
import 'design_tokens.dart';
import 'neumorphic_styles.dart';

/// Reader-friendly theme families. Each family has light and dark variants.
enum AppThemeFamily {
  defaultFamily,
  sepia,
  emeraldGreen,
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
    case AppThemeFamily.emeraldGreen:
      return const Color(0xFF50C878);
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
  final isLight = brightness == Brightness.light;
  final baseTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: isLight
          ? NeumorphicStyles.lightBackground
          : NeumorphicStyles.darkBackground,
    ),
    scaffoldBackgroundColor: isLight
        ? NeumorphicStyles.lightBackground
        : NeumorphicStyles.darkBackground,
    useMaterial3: true,
  );
  final cs = baseTheme.colorScheme;
  // outline and fill were unused

  return baseTheme.copyWith(
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: cs.primary,
      circularTrackColor: cs.surfaceContainerHighest,
      linearTrackColor: cs.surfaceContainerHighest,
      refreshBackgroundColor: cs.surface,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: baseTheme.colorScheme.primary,
      selectionColor: baseTheme.colorScheme.primary.withValues(alpha: 0.25),
      selectionHandleColor: baseTheme.colorScheme.primary,
    ),
    textTheme: AdvancedTypography.apply(
      baseTheme.textTheme.copyWith(
        displayLarge: baseTheme.textTheme.displayLarge?.copyWith(height: 1.6),
        displayMedium: baseTheme.textTheme.displayMedium?.copyWith(height: 1.6),
        displaySmall: baseTheme.textTheme.displaySmall?.copyWith(height: 1.6),
        headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(height: 1.6),
        headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
          height: 1.6,
        ),
        headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(height: 1.6),
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(height: 1.6),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(height: 1.6),
        titleSmall: baseTheme.textTheme.titleSmall?.copyWith(height: 1.6),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
      ),
    ),

    // Modern outline input decorations
    inputDecorationTheme:
        NeumorphicStyles.inputDecorationTheme(isDark: !isLight).copyWith(
          // Keep some specific overrides if needed, but NeumorphicStyles handles most
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),

    // Softer card elevation with colored shadows
    cardTheme: CardThemeData(
      elevation: 0, // Neumorphism uses custom shadows, not elevation
      color: isLight
          ? NeumorphicStyles.lightBackground
          : NeumorphicStyles.darkBackground,
      shadowColor: Colors.transparent,
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
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(MobileSpacing.touchTargetMin, MobileSpacing.touchTargetMin),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.all(Spacing.s)),
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
      shape: const RoundedRectangleBorder(
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
    appBarTheme: AppBarTheme(
      backgroundColor: isLight
          ? NeumorphicStyles.lightBackground
          : NeumorphicStyles.darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: baseTheme.colorScheme.primary,
        circularTrackColor: baseTheme.colorScheme.surface,
        linearTrackColor: baseTheme.colorScheme.surface,
        refreshBackgroundColor: baseTheme.colorScheme.surface,
      ),
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
        baseTheme.textTheme.copyWith(
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: baseTheme.colorScheme.primary,
        circularTrackColor: baseTheme.colorScheme.surface,
        linearTrackColor: baseTheme.colorScheme.surface,
        refreshBackgroundColor: baseTheme.colorScheme.surface,
      ),
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
        baseTheme.textTheme.copyWith(
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.8),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.8),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(height: 1.8),
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
