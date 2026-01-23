import 'package:flutter/material.dart';
import 'advanced_typography.dart';
import 'design_tokens.dart';

/// Reader-friendly theme families. Each family has light and dark variants.
enum AppThemeFamily {
  oceanDepths,
  sunsetBoulevard,
  forestCanopy,
  modernMinimalist,
  goldenHour,
  arcticFrost,
  desertRose,
  techInnovation,
  botanicalGarden,
  midnightGalaxy,
}

class ThemeFactoryDef {
  final AppThemeFamily id;
  final String label;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color lightSurface;
  final Color darkSurface;

  const ThemeFactoryDef({
    required this.id,
    required this.label,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.lightSurface,
    required this.darkSurface,
  });
}

const List<ThemeFactoryDef> themeFactoryThemes = [
  ThemeFactoryDef(
    id: AppThemeFamily.oceanDepths,
    label: 'Ocean Depths',
    primary: Color(0xFF2D8B8B),
    secondary: Color(0xFFA8DADC),
    tertiary: Color(0xFF1A2332),
    lightSurface: Color(0xFFF1FAEE),
    darkSurface: Color(0xFF1A2332),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.sunsetBoulevard,
    label: 'Sunset Boulevard',
    primary: Color(0xFFE76F51),
    secondary: Color(0xFFF4A261),
    tertiary: Color(0xFFE9C46A),
    lightSurface: Color(0xFFE9C46A),
    darkSurface: Color(0xFF264653),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.forestCanopy,
    label: 'Forest Canopy',
    primary: Color(0xFF2D4A2B),
    secondary: Color(0xFF7D8471),
    tertiary: Color(0xFFA4AC86),
    lightSurface: Color(0xFFFAF9F6),
    darkSurface: Color(0xFF2D4A2B),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.modernMinimalist,
    label: 'Modern Minimalist',
    primary: Color(0xFF36454F),
    secondary: Color(0xFF708090),
    tertiary: Color(0xFFD3D3D3),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF36454F),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.goldenHour,
    label: 'Golden Hour',
    primary: Color(0xFFF4A900),
    secondary: Color(0xFFC1666B),
    tertiary: Color(0xFFD4B896),
    lightSurface: Color(0xFFD4B896),
    darkSurface: Color(0xFF4A403A),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.arcticFrost,
    label: 'Arctic Frost',
    primary: Color(0xFF4A6FA5),
    secondary: Color(0xFFD4E4F7),
    tertiary: Color(0xFFC0C0C0),
    lightSurface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF1E2D44),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.desertRose,
    label: 'Desert Rose',
    primary: Color(0xFFD4A5A5),
    secondary: Color(0xFFB87D6D),
    tertiary: Color(0xFFE8D5C4),
    lightSurface: Color(0xFFE8D5C4),
    darkSurface: Color(0xFF5D2E46),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.techInnovation,
    label: 'Tech Innovation',
    primary: Color(0xFF0066FF),
    secondary: Color(0xFF00FFFF),
    tertiary: Color(0xFF1E1E1E),
    lightSurface: Color(0xFFFFFFFF),
    darkSurface: Color(0xFF1E1E1E),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.botanicalGarden,
    label: 'Botanical Garden',
    primary: Color(0xFF4A7C59),
    secondary: Color(0xFFF9A620),
    tertiary: Color(0xFFB7472A),
    lightSurface: Color(0xFFF5F3ED),
    darkSurface: Color(0xFF2B4A35),
  ),
  ThemeFactoryDef(
    id: AppThemeFamily.midnightGalaxy,
    label: 'Midnight Galaxy',
    primary: Color(0xFF4A4E8F),
    secondary: Color(0xFFA490C2),
    tertiary: Color(0xFF2B1E3E),
    lightSurface: Color(0xFFE6E6FA),
    darkSurface: Color(0xFF2B1E3E),
  ),
];

ThemeFactoryDef? themeFactoryById(AppThemeFamily family) {
  for (final t in themeFactoryThemes) {
    if (t.id == family) return t;
  }
  return null;
}

Color _onColor(Color bg) =>
    bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

InputDecorationTheme _neumorphicInputDecorationTheme({
  required bool isDark,
  required Color surface,
}) {
  final bg = surface;
  final pressedBg = isDark
      ? Color.lerp(bg, Colors.black, 0.03)!
      : Color.lerp(bg, Colors.black, 0.01)!;

  return InputDecorationTheme(
    filled: true,
    fillColor: pressedBg,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Spacing.l,
      vertical: Spacing.m,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.m),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.m),
      borderSide: BorderSide(
        color: isDark ? Colors.black26 : Colors.white54,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.m),
      borderSide: BorderSide(
        color: isDark ? Colors.white30 : Colors.black26,
        width: 1.5,
      ),
    ),
  );
}

ThemeData _buildFromScheme(ColorScheme scheme) {
  final isLight = scheme.brightness == Brightness.light;
  final baseTheme = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    useMaterial3: true,
  );
  final cs = scheme;
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
        _neumorphicInputDecorationTheme(
          isDark: !isLight,
          surface: cs.surface,
        ).copyWith(
          // Keep some specific overrides if needed.
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),

    // Softer card elevation with colored shadows
    cardTheme: CardThemeData(
      elevation: 0, // Neumorphism uses custom shadows, not elevation
      color: cs.surface,
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
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
  );
}

/// Light variant for the given theme family.
ThemeData themeForLight(AppThemeFamily family) {
  final def = themeFactoryById(family);
  final seed = def?.primary ?? Colors.indigo;
  final surface = def?.lightSurface ?? const Color(0xFFE0E5EC);
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: surface,
  );
  final cs = base.copyWith(
    primary: seed,
    onPrimary: _onColor(seed),
    secondary: def?.secondary ?? base.secondary,
    onSecondary: _onColor(def?.secondary ?? base.secondary),
    tertiary: def?.tertiary ?? base.tertiary,
    onTertiary: _onColor(def?.tertiary ?? base.tertiary),
    surface: surface,
    onSurface: _onColor(surface),
  );
  return _buildFromScheme(cs);
}

/// Dark variant for the given theme family.
ThemeData themeForDark(AppThemeFamily family) {
  final def = themeFactoryById(family);
  final seed = def?.primary ?? Colors.indigo;
  final surface = def?.darkSurface ?? const Color(0xFF2D2F33);
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    surface: surface,
  );
  final cs = base.copyWith(
    primary: seed,
    onPrimary: _onColor(seed),
    secondary: def?.secondary ?? base.secondary,
    onSecondary: _onColor(def?.secondary ?? base.secondary),
    tertiary: def?.tertiary ?? base.tertiary,
    onTertiary: _onColor(def?.tertiary ?? base.tertiary),
    surface: surface,
    onSurface: _onColor(surface),
  );
  return _buildFromScheme(cs);
}
