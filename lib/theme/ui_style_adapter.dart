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

  final Color? buttonBackgroundColor;
  final List<BoxShadow>? buttonShadows;
  final Border? buttonBorder;
  final Color? buttonPressedColor;
  final List<BoxShadow>? buttonPressedShadows;

  final Color? cardBackgroundColor;
  final Color? cardPressedColor;
  final List<BoxShadow>? cardPressedShadows;

  final Color? inputBackgroundColor;
  final Border? inputBorder;
  final BorderRadius? inputBorderRadius;
  final Color? inputFocusedBorderColor;

  final Color? switchBackgroundColor;
  final Color? switchActiveColor;
  final Color? switchThumbColor;
  final Border? switchBorder;

  final Color? dropdownBackgroundColor;
  final Border? dropdownBorder;
  final BorderRadius? dropdownBorderRadius;

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
    this.buttonBackgroundColor,
    this.buttonShadows,
    this.buttonBorder,
    this.buttonPressedColor,
    this.buttonPressedShadows,
    this.cardBackgroundColor,
    this.cardPressedColor,
    this.cardPressedShadows,
    this.inputBackgroundColor,
    this.inputBorder,
    this.inputBorderRadius,
    this.inputFocusedBorderColor,
    this.switchBackgroundColor,
    this.switchActiveColor,
    this.switchThumbColor,
    this.switchBorder,
    this.dropdownBackgroundColor,
    this.dropdownBorder,
    this.dropdownBorderRadius,
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
          buttonBackgroundColor: buttonBackgroundColor,
          buttonShadows: buttonShadows,
          buttonBorder: buttonBorder,
          buttonBorderRadius: buttonBorderRadius,
          buttonPressedColor: buttonPressedColor,
          buttonPressedShadows: buttonPressedShadows,
          cardBackgroundColor: cardBackgroundColor,
          cardBorderRadius: cardBorderRadius,
          cardPressedColor: cardPressedColor,
          cardPressedShadows: cardPressedShadows,
          inputBackgroundColor: inputBackgroundColor,
          inputBorder: inputBorder,
          inputBorderRadius: inputBorderRadius,
          inputFocusedBorderColor: inputFocusedBorderColor,
          switchBackgroundColor: switchBackgroundColor,
          switchActiveColor: switchActiveColor,
          switchThumbColor: switchThumbColor,
          switchBorder: switchBorder,
          dropdownBackgroundColor: dropdownBackgroundColor,
          dropdownBorder: dropdownBorder,
          dropdownBorderRadius: dropdownBorderRadius,
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
      case UiStyleFamily.liquidGlass:
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
      case UiStyleFamily.liquidGlass:
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
      case UiStyleFamily.liquidGlass:
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
      case UiStyleFamily.liquidGlass:
        return cs.surface.withValues(alpha: isDark ? 0.45 : 0.65);
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
      case UiStyleFamily.liquidGlass:
        return cs.surface.withValues(alpha: isDark ? 0.3 : 0.5);
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
      case UiStyleFamily.liquidGlass:
        return _liquidGlassPatch();
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

  StyleThemePatch _liquidGlassPatch() {
    return StyleThemePatch(
      cardBorderRadius: const BorderRadius.all(Radius.circular(20)),
      buttonBorderRadius: const BorderRadius.all(Radius.circular(14)),
      elevation: 0,
      useBackdropBlur: true,
      cardBlur: 24,
      cardShadows: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 36,
          offset: Offset(0, 12),
        ),
        BoxShadow(
          color: Color(0x1A1F2387),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
      cardBorder: Border.all(color: const Color(0x33FFFFFF), width: 1),
      cardGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
      ),
      styleFamily: UiStyleFamily.liquidGlass,
      dropdownBackgroundColor: const Color(0x1AFFFFFF),
      dropdownBorder: Border.all(color: const Color(0x26FFFFFF), width: 1),
      dropdownBorderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  StyleThemePatch _neumorphismPatch() {
    return StyleThemePatch(
      cardBorderRadius: const BorderRadius.all(Radius.circular(20)),
      buttonBorderRadius: const BorderRadius.all(Radius.circular(16)),
      elevation: 0,
      useBackdropBlur: false,
      cardShadows: const [
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
      buttonBackgroundColor: const Color(0xFFE0E5EC),
      buttonShadows: const [
        BoxShadow(
          color: Color(0xFFFFFFFF),
          blurRadius: 12,
          offset: Offset(-6, -6),
        ),
        BoxShadow(
          color: Color(0xFFA3B1C6),
          blurRadius: 12,
          offset: Offset(6, 6),
        ),
      ],
      buttonPressedColor: const Color(0xFFD6DBE3),
      buttonPressedShadows: const [
        BoxShadow(
          color: Color(0xFFA3B1C6),
          blurRadius: 12,
          offset: Offset(4, 4),
        ),
      ],
      cardBackgroundColor: const Color(0xFFE0E5EC),
      cardPressedColor: const Color(0xFFD6DBE3),
      cardPressedShadows: const [
        BoxShadow(
          color: Color(0xFFA3B1C6),
          blurRadius: 12,
          offset: Offset(4, 4),
        ),
      ],
      inputBackgroundColor: const Color(0xFFD6DBE3),
      inputBorderRadius: const BorderRadius.all(Radius.circular(12)),
      inputFocusedBorderColor: const Color(0xFF6366F1),
      switchBackgroundColor: const Color(0xFFE0E5EC),
      switchBorder: Border.all(color: const Color(0xFFA3B1C6), width: 0.5),
      switchThumbColor: const Color(0xFFE0E5EC),
      dropdownBackgroundColor: const Color(0xFFE0E5EC),
      dropdownBorder: Border.all(color: const Color(0xFFA3B1C6), width: 0.5),
      dropdownBorderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  StyleThemePatch _minimalismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(12)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(8)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.minimalism,
      buttonBackgroundColor: Color(0xFFFAFAFA),
      buttonShadows: [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
      buttonPressedColor: Color(0xFFF0F0F0),
      cardBackgroundColor: Color(0xFFFAFAFA),
      cardPressedColor: Color(0xFFF0F0F0),
      inputBackgroundColor: Color(0xFFF5F5F5),
      inputBorderRadius: BorderRadius.all(Radius.circular(8)),
      inputFocusedBorderColor: Color(0xFF6366F1),
      switchBackgroundColor: Color(0xFFE0E0E0),
      switchThumbColor: Color(0xFFFFFFFF),
      dropdownBackgroundColor: Color(0xFFFAFAFA),
      dropdownBorderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  StyleThemePatch _flatDesignPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(4)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(4)),
      elevation: 0,
      useBackdropBlur: false,
      styleFamily: UiStyleFamily.flatDesign,
      buttonBackgroundColor: Color(0xFF6366F1),
      buttonPressedColor: Color(0xFF4F46E5),
      cardBackgroundColor: Color(0xFFFFFFFF),
      inputBackgroundColor: Color(0xFFF3F4F6),
      inputBorderRadius: BorderRadius.all(Radius.circular(4)),
      inputFocusedBorderColor: Color(0xFF6366F1),
      switchBackgroundColor: Color(0xFFE5E7EB),
      switchThumbColor: Color(0xFFFFFFFF),
      dropdownBackgroundColor: Color(0xFFFFFFFF),
      dropdownBorderRadius: BorderRadius.all(Radius.circular(4)),
    );
  }
}
