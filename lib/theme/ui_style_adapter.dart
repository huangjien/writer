import 'package:flutter/material.dart';
import 'ui_styles.dart';

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
  });

  ThemeData applyToTheme(ThemeData base, bool isDark) {
    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: elevation ?? base.cardTheme.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: cardBorderRadius ?? BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation ?? 4,
          shape: RoundedRectangleBorder(
            borderRadius: buttonBorderRadius ?? BorderRadius.circular(8),
          ),
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
            top: Radius.circular(
              (cardBorderRadius ?? BorderRadius.circular(12)).topLeft.x,
            ),
          ),
        ),
        elevation: elevation ?? 16,
      ),
    );
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
      case UiStyleFamily.claymorphism:
        return _claymorphismPatch();
      case UiStyleFamily.minimalism:
        return _minimalismPatch();
      case UiStyleFamily.brutalism:
        return _brutalismPatch();
      case UiStyleFamily.skeuomorphism:
        return _skeuomorphismPatch();
      case UiStyleFamily.bentoGrid:
        return _bentoGridPatch();
      case UiStyleFamily.responsive:
        return _responsivePatch();
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
    );
  }

  StyleThemePatch _neumorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(20)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
      elevation: 2,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _claymorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(24)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(20)),
      elevation: 8,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _minimalismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(8)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(6)),
      elevation: 0,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _brutalismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.zero,
      buttonBorderRadius: BorderRadius.zero,
      elevation: 0,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _skeuomorphismPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(12)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(10)),
      elevation: 4,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _bentoGridPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(20)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
      elevation: 2,
      useBackdropBlur: true,
    );
  }

  StyleThemePatch _responsivePatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(12)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(8)),
      elevation: 1,
      useBackdropBlur: false,
    );
  }

  StyleThemePatch _flatDesignPatch() {
    return const StyleThemePatch(
      cardBorderRadius: BorderRadius.all(Radius.circular(4)),
      buttonBorderRadius: BorderRadius.all(Radius.circular(4)),
      elevation: 0,
      useBackdropBlur: false,
    );
  }
}
