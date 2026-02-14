import 'package:flutter/material.dart';
import 'ui_styles.dart';
import 'theme_extensions.dart';
import 'style_theme_patch_resolvers.dart';

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
    final resolvedCardRadius = cardBorderRadius ?? BorderRadius.zero;
    final resolvedButtonRadius = buttonBorderRadius ?? BorderRadius.circular(8);
    final resolvedElevation = elevation ?? base.cardTheme.elevation;
    final resolvedSurfaceColor = resolveSurfaceColor(base, isDark);
    final resolvedTileColor = resolveTileColor(base, isDark);
    final resolvedDividerThickness = resolveDividerThickness();
    final resolvedDividerColor = resolveDividerColor(base, isDark);
    final resolvedCardShadows = resolveCardShadows(base, isDark);
    final resolvedDropdownBackgroundColor = resolveDropdownBackgroundColor(
      base,
      isDark,
    );
    final resolvedInputBackgroundColor = resolveInputBackgroundColor(
      base,
      isDark,
    );
    final resolvedButtonBackgroundColor = resolveButtonBackgroundColor(
      base,
      isDark,
    );
    final resolvedButtonShadows = resolveButtonShadows(base, isDark);
    final resolvedButtonPressedColor = resolveButtonPressedColor(base, isDark);
    final resolvedButtonPressedShadows = resolveButtonPressedShadows(
      base,
      isDark,
    );
    final resolvedCardBackgroundColor = resolveCardBackgroundColor(
      base,
      isDark,
    );
    final resolvedCardBorder = resolveCardBorder(base, isDark);
    final resolvedCardPressedColor = resolveCardPressedColor(base, isDark);
    final resolvedCardPressedShadows = resolveCardPressedShadows(base, isDark);
    final resolvedSwitchBackgroundColor = resolveSwitchBackgroundColor(
      base,
      isDark,
    );
    final resolvedSwitchThumbColor = resolveSwitchThumbColor(base, isDark);
    final resolvedSwitchBorder = resolveSwitchBorder(base, isDark);
    final resolvedDropdownMenuBackgroundColor =
        resolveDropdownMenuBackgroundColor(base, isDark);
    final resolvedDropdownMenuSelectedColor = resolveDropdownMenuSelectedColor(
      base,
      isDark,
    );
    final resolvedDropdownMenuHoverColor = resolveDropdownMenuHoverColor(
      base,
      isDark,
    );
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
          borderRadius: cardBorderRadius ?? BorderRadius.zero,
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
          cardBorder: resolvedCardBorder,
          cardShadows: resolvedCardShadows,
          cardGradient: cardGradient,
          buttonBackgroundColor: resolvedButtonBackgroundColor,
          buttonShadows: resolvedButtonShadows,
          buttonBorder: buttonBorder,
          buttonBorderRadius: buttonBorderRadius,
          buttonPressedColor: resolvedButtonPressedColor,
          buttonPressedShadows: resolvedButtonPressedShadows,
          cardBackgroundColor: resolvedCardBackgroundColor,
          cardBorderRadius: cardBorderRadius,
          cardPressedColor: resolvedCardPressedColor,
          cardPressedShadows: resolvedCardPressedShadows,
          inputBackgroundColor: resolvedInputBackgroundColor,
          inputBorder: inputBorder,
          inputBorderRadius: inputBorderRadius,
          inputFocusedBorderColor: inputFocusedBorderColor,
          switchBackgroundColor: resolvedSwitchBackgroundColor,
          switchActiveColor: switchActiveColor,
          switchThumbColor: resolvedSwitchThumbColor,
          switchBorder: resolvedSwitchBorder,
          dropdownBackgroundColor: resolvedDropdownBackgroundColor,
          dropdownBorder: dropdownBorder,
          dropdownBorderRadius: dropdownBorderRadius,
          dropdownMenuBackgroundColor: resolvedDropdownMenuBackgroundColor,
          dropdownMenuSelectedColor: resolvedDropdownMenuSelectedColor,
          dropdownMenuHoverColor: resolvedDropdownMenuHoverColor,
        ),
      ],
    );
  }
}
