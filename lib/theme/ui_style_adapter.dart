import 'package:flutter/material.dart';
import 'ui_styles.dart';
import 'theme_extensions.dart';

class StyleThemePatch {
  final BoxDecoration? cardDecoration;
  final InputDecoration? inputDecoration;
  final BoxDecoration? buttonDecoration;
  final BoxShadow? cardShadow;
  final BoxShadow? buttonShadow;
  final BorderRadius? cardBorderRadius;
  final BorderRadius? buttonBorderRadius;
  final double? elevation;
  final bool? useBackdropBlur;
  final Color? cardColor;
  final Border? cardBorder;
  final double? cardBlur;
  final List<BoxShadow>? cardShadows;
  final LinearGradient? cardGradient;
  final UiStyleFamily styleFamily;

  const StyleThemePatch({
    this.cardDecoration,
    this.inputDecoration,
    this.buttonDecoration,
    this.cardShadow,
    this.buttonShadow,
    this.cardBorderRadius,
    this.buttonBorderRadius,
    this.elevation,
    this.useBackdropBlur,
    this.cardColor,
    this.cardBorder,
    this.cardBlur,
    this.cardShadows,
    this.cardGradient,
    required this.styleFamily,
  });

  ThemeData applyToTheme(ThemeData base, bool isDark) {
    final resolvedCardRadius = cardBorderRadius ?? BorderRadius.circular(12);
    final resolvedButtonRadius = buttonBorderRadius ?? BorderRadius.circular(8);
    final resolvedElevation = elevation ?? base.cardTheme.elevation;
    final resolvedSurfaceColor = _resolveSurfaceColor(base, isDark);
    final resolvedTileColor = _resolveTileColor(base, isDark);
    final resolvedDividerThickness = _resolveDividerThickness();
    final resolvedDividerColor = _resolveDividerColor(base, isDark);
    final resolvedCardShadows = _resolveCardShadows(isDark);
    final preservedExtensions = base.extensions.values
        .where((e) => e is! UiStyleThemeExtension)
        .toList(growable: false);

    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        color: resolvedSurfaceColor,
        elevation: resolvedElevation,
        shape: RoundedRectangleBorder(borderRadius: resolvedCardRadius),
        margin: const EdgeInsets.all(8),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: resolvedCardRadius),
        tileColor: resolvedTileColor,
        selectedTileColor: resolvedTileColor,
      ),
      dividerTheme: base.dividerTheme.copyWith(
        thickness: resolvedDividerThickness,
        color: resolvedDividerColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation ?? 4,
          shape: RoundedRectangleBorder(borderRadius: resolvedButtonRadius),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius ?? BorderRadius.circular(16),
        ),
        elevation: elevation ?? 8,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        elevation: elevation ?? 6,
        shape: RoundedRectangleBorder(
          borderRadius: buttonBorderRadius ?? BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(resolvedCardRadius.topLeft.x),
          ),
        ),
        elevation: elevation ?? 16,
      ),
      extensions: [
        ...preservedExtensions,
        UiStyleThemeExtension(
          styleFamily: styleFamily,
          useBackdropBlur: useBackdropBlur ?? false,
          cardBlur: cardBlur ?? 0,
          cardColor: cardColor,
          cardBorder: cardBorder,
          cardShadows: resolvedCardShadows,
          cardGradient: cardGradient,
        ),
      ],
    );
  }

  List<BoxShadow>? _resolveCardShadows(bool isDark) {
    if (cardShadows != null) {
      return cardShadows;
    }

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return [
          BoxShadow(
            color: isDark ? const Color(0x66000000) : const Color(0x1A1F2387),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ];
      case UiStyleFamily.neumorphism:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  double? _resolveDividerThickness() {
    switch (styleFamily) {
      case UiStyleFamily.flatDesign:
        return 1;
      case UiStyleFamily.minimalism:
        return 0.5;
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.neumorphism:
        return null;
    }
  }

  Color? _resolveDividerColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    switch (styleFamily) {
      case UiStyleFamily.flatDesign:
        return cs.outline;
      case UiStyleFamily.minimalism:
        return cs.outlineVariant;
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.neumorphism:
        return null;
    }
  }

  Color? _resolveSurfaceColor(ThemeData base, bool isDark) {
    if (cardColor != null) return cardColor;
    final cs = base.colorScheme;
    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return cs.surface.withValues(alpha: isDark ? 0.55 : 0.75);
      case UiStyleFamily.neumorphism:
        return cs.surface;
      case UiStyleFamily.minimalism:
        return cs.surface;
      case UiStyleFamily.flatDesign:
        return cs.surface;
    }
  }

  Color? _resolveTileColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return cs.surface.withValues(alpha: isDark ? 0.35 : 0.55);
      case UiStyleFamily.neumorphism:
        return cs.surface;
      case UiStyleFamily.minimalism:
        return cs.surface;
      case UiStyleFamily.flatDesign:
        return cs.surface;
    }
  }
}

class UiStyleAdapter {
  const UiStyleAdapter();

  StyleThemePatch resolveStylePatch(UiStyleFamily style) {
    switch (style) {
      case UiStyleFamily.glassmorphism:
        return _glassmorphismPatch();
      case UiStyleFamily.neumorphism:
        return _neumorphismPatch();
      case UiStyleFamily.minimalism:
        return _minimalismPatch();
      case UiStyleFamily.flatDesign:
        return _flatDesignPatch();
    }
  }

  StyleThemePatch _glassmorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(16)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(12)),
      elevation: 0,
      useBackdropBlur: true,
      cardBlur: 16,
      cardShadows: [
        BoxShadow(
          color: Color(0x1A1F2387),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ],
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x19FFFFFF), Color(0x0DFFFFFF)],
      ),
      styleFamily: UiStyleFamily.glassmorphism,
    );
  }

  StyleThemePatch _neumorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(20)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
      elevation: 0,
      useBackdropBlur: false,
      cardShadows: [
        BoxShadow(
          color: Color(0x1E000000),
          blurRadius: 28,
          offset: Offset(14, 14),
        ),
        BoxShadow(
          color: Color(0xBFFFFFFF),
          blurRadius: 28,
          offset: Offset(-14, -14),
        ),
      ],
      styleFamily: UiStyleFamily.neumorphism,
    );
  }

  StyleThemePatch _minimalismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(12)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(8)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.minimalism,
    );
  }

  StyleThemePatch _flatDesignPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(4)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(4)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.flatDesign,
    );
  }
}
