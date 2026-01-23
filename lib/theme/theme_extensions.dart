import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'ui_styles.dart';

class UiStyleThemeExtension extends ThemeExtension<UiStyleThemeExtension> {
  final UiStyleFamily styleFamily;
  final bool useBackdropBlur;
  final double cardBlur;
  final Color? cardColor;
  final Border? cardBorder;
  final List<BoxShadow>? cardShadows;
  final LinearGradient? cardGradient;

  final Color? buttonBackgroundColor;
  final List<BoxShadow>? buttonShadows;
  final Border? buttonBorder;
  final BorderRadius? buttonBorderRadius;
  final Color? buttonPressedColor;
  final List<BoxShadow>? buttonPressedShadows;

  final Color? cardBackgroundColor;
  final BorderRadius? cardBorderRadius;
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

  const UiStyleThemeExtension({
    required this.styleFamily,
    this.useBackdropBlur = false,
    this.cardBlur = 0,
    this.cardColor,
    this.cardBorder,
    this.cardShadows,
    this.cardGradient,
    this.buttonBackgroundColor,
    this.buttonShadows,
    this.buttonBorder,
    this.buttonBorderRadius,
    this.buttonPressedColor,
    this.buttonPressedShadows,
    this.cardBackgroundColor,
    this.cardBorderRadius,
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

  @override
  UiStyleThemeExtension copyWith({
    UiStyleFamily? styleFamily,
    bool? useBackdropBlur,
    double? cardBlur,
    Color? cardColor,
    Border? cardBorder,
    List<BoxShadow>? cardShadows,
    LinearGradient? cardGradient,
    Color? buttonBackgroundColor,
    List<BoxShadow>? buttonShadows,
    Border? buttonBorder,
    BorderRadius? buttonBorderRadius,
    Color? buttonPressedColor,
    List<BoxShadow>? buttonPressedShadows,
    Color? cardBackgroundColor,
    BorderRadius? cardBorderRadius,
    Color? cardPressedColor,
    List<BoxShadow>? cardPressedShadows,
    Color? inputBackgroundColor,
    Border? inputBorder,
    BorderRadius? inputBorderRadius,
    Color? inputFocusedBorderColor,
    Color? switchBackgroundColor,
    Color? switchActiveColor,
    Color? switchThumbColor,
    Border? switchBorder,
    Color? dropdownBackgroundColor,
    Border? dropdownBorder,
    BorderRadius? dropdownBorderRadius,
  }) {
    return UiStyleThemeExtension(
      styleFamily: styleFamily ?? this.styleFamily,
      useBackdropBlur: useBackdropBlur ?? this.useBackdropBlur,
      cardBlur: cardBlur ?? this.cardBlur,
      cardColor: cardColor ?? this.cardColor,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadows: cardShadows ?? this.cardShadows,
      cardGradient: cardGradient ?? this.cardGradient,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonShadows: buttonShadows ?? this.buttonShadows,
      buttonBorder: buttonBorder ?? this.buttonBorder,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonPressedColor: buttonPressedColor ?? this.buttonPressedColor,
      buttonPressedShadows: buttonPressedShadows ?? this.buttonPressedShadows,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardPressedColor: cardPressedColor ?? this.cardPressedColor,
      cardPressedShadows: cardPressedShadows ?? this.cardPressedShadows,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      inputFocusedBorderColor:
          inputFocusedBorderColor ?? this.inputFocusedBorderColor,
      switchBackgroundColor:
          switchBackgroundColor ?? this.switchBackgroundColor,
      switchActiveColor: switchActiveColor ?? this.switchActiveColor,
      switchThumbColor: switchThumbColor ?? this.switchThumbColor,
      switchBorder: switchBorder ?? this.switchBorder,
      dropdownBackgroundColor:
          dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      dropdownBorder: dropdownBorder ?? this.dropdownBorder,
      dropdownBorderRadius: dropdownBorderRadius ?? this.dropdownBorderRadius,
    );
  }

  @override
  UiStyleThemeExtension lerp(
    ThemeExtension<UiStyleThemeExtension>? other,
    double t,
  ) {
    if (other is! UiStyleThemeExtension) {
      return this;
    }

    return UiStyleThemeExtension(
      styleFamily: t < 0.5 ? styleFamily : other.styleFamily,
      useBackdropBlur: t < 0.5 ? useBackdropBlur : other.useBackdropBlur,
      cardBlur: lerpDouble(cardBlur, other.cardBlur, t) ?? cardBlur,
      cardColor: Color.lerp(cardColor, other.cardColor, t),
      cardBorder: t < 0.5 ? cardBorder : other.cardBorder,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      cardGradient: t < 0.5 ? cardGradient : other.cardGradient,
      buttonBackgroundColor: Color.lerp(
        buttonBackgroundColor,
        other.buttonBackgroundColor,
        t,
      ),
      buttonShadows: t < 0.5 ? buttonShadows : other.buttonShadows,
      buttonBorder: t < 0.5 ? buttonBorder : other.buttonBorder,
      buttonBorderRadius: t < 0.5
          ? buttonBorderRadius
          : other.buttonBorderRadius,
      buttonPressedColor: Color.lerp(
        buttonPressedColor,
        other.buttonPressedColor,
        t,
      ),
      buttonPressedShadows: t < 0.5
          ? buttonPressedShadows
          : other.buttonPressedShadows,
      cardBackgroundColor: Color.lerp(
        cardBackgroundColor,
        other.cardBackgroundColor,
        t,
      ),
      cardBorderRadius: t < 0.5 ? cardBorderRadius : other.cardBorderRadius,
      cardPressedColor: Color.lerp(cardPressedColor, other.cardPressedColor, t),
      cardPressedShadows: t < 0.5
          ? cardPressedShadows
          : other.cardPressedShadows,
      inputBackgroundColor: Color.lerp(
        inputBackgroundColor,
        other.inputBackgroundColor,
        t,
      ),
      inputBorder: t < 0.5 ? inputBorder : other.inputBorder,
      inputBorderRadius: t < 0.5 ? inputBorderRadius : other.inputBorderRadius,
      inputFocusedBorderColor: Color.lerp(
        inputFocusedBorderColor,
        other.inputFocusedBorderColor,
        t,
      ),
      switchBackgroundColor: Color.lerp(
        switchBackgroundColor,
        other.switchBackgroundColor,
        t,
      ),
      switchActiveColor: Color.lerp(
        switchActiveColor,
        other.switchActiveColor,
        t,
      ),
      switchThumbColor: Color.lerp(switchThumbColor, other.switchThumbColor, t),
      switchBorder: t < 0.5 ? switchBorder : other.switchBorder,
      dropdownBackgroundColor: Color.lerp(
        dropdownBackgroundColor,
        other.dropdownBackgroundColor,
        t,
      ),
      dropdownBorder: t < 0.5 ? dropdownBorder : other.dropdownBorder,
      dropdownBorderRadius: t < 0.5
          ? dropdownBorderRadius
          : other.dropdownBorderRadius,
    );
  }

  static const defaultStyle = UiStyleThemeExtension(
    styleFamily: UiStyleFamily.minimalism,
  );
}

extension ThemeDataExtensions on ThemeData {
  UiStyleFamily get uiStyleFamily =>
      extension<UiStyleThemeExtension>()?.styleFamily ??
      UiStyleFamily.minimalism;

  bool get useBackdropBlur =>
      extension<UiStyleThemeExtension>()?.useBackdropBlur ?? false;

  double get cardBlur => extension<UiStyleThemeExtension>()?.cardBlur ?? 0;

  Color? get styleCardColor => extension<UiStyleThemeExtension>()?.cardColor;

  Border? get styleCardBorder => extension<UiStyleThemeExtension>()?.cardBorder;

  List<BoxShadow>? get styleCardShadows =>
      extension<UiStyleThemeExtension>()?.cardShadows;

  LinearGradient? get styleCardGradient =>
      extension<UiStyleThemeExtension>()?.cardGradient;

  Color? get buttonBackgroundColor =>
      extension<UiStyleThemeExtension>()?.buttonBackgroundColor;
  List<BoxShadow>? get buttonShadows =>
      extension<UiStyleThemeExtension>()?.buttonShadows;
  Border? get buttonBorder => extension<UiStyleThemeExtension>()?.buttonBorder;
  BorderRadius? get buttonBorderRadius =>
      extension<UiStyleThemeExtension>()?.buttonBorderRadius;
  Color? get buttonPressedColor =>
      extension<UiStyleThemeExtension>()?.buttonPressedColor;
  List<BoxShadow>? get buttonPressedShadows =>
      extension<UiStyleThemeExtension>()?.buttonPressedShadows;

  Color? get cardBackgroundColor =>
      extension<UiStyleThemeExtension>()?.cardBackgroundColor;
  BorderRadius? get cardBorderRadius =>
      extension<UiStyleThemeExtension>()?.cardBorderRadius;
  Color? get cardPressedColor =>
      extension<UiStyleThemeExtension>()?.cardPressedColor;
  List<BoxShadow>? get cardPressedShadows =>
      extension<UiStyleThemeExtension>()?.cardPressedShadows;

  Color? get inputBackgroundColor =>
      extension<UiStyleThemeExtension>()?.inputBackgroundColor;
  Border? get inputBorder => extension<UiStyleThemeExtension>()?.inputBorder;
  BorderRadius? get inputBorderRadius =>
      extension<UiStyleThemeExtension>()?.inputBorderRadius;
  Color? get inputFocusedBorderColor =>
      extension<UiStyleThemeExtension>()?.inputFocusedBorderColor;

  Color? get switchBackgroundColor =>
      extension<UiStyleThemeExtension>()?.switchBackgroundColor;
  Color? get switchActiveColor =>
      extension<UiStyleThemeExtension>()?.switchActiveColor;
  Color? get switchThumbColor =>
      extension<UiStyleThemeExtension>()?.switchThumbColor;
  Border? get switchBorder => extension<UiStyleThemeExtension>()?.switchBorder;

  Color? get dropdownBackgroundColor =>
      extension<UiStyleThemeExtension>()?.dropdownBackgroundColor;
  Border? get dropdownBorder =>
      extension<UiStyleThemeExtension>()?.dropdownBorder;
  BorderRadius? get dropdownBorderRadius =>
      extension<UiStyleThemeExtension>()?.dropdownBorderRadius;
}
