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

  const UiStyleThemeExtension({
    required this.styleFamily,
    this.useBackdropBlur = false,
    this.cardBlur = 0,
    this.cardColor,
    this.cardBorder,
    this.cardShadows,
  });

  @override
  UiStyleThemeExtension copyWith({
    UiStyleFamily? styleFamily,
    bool? useBackdropBlur,
    double? cardBlur,
    Color? cardColor,
    Border? cardBorder,
    List<BoxShadow>? cardShadows,
  }) {
    return UiStyleThemeExtension(
      styleFamily: styleFamily ?? this.styleFamily,
      useBackdropBlur: useBackdropBlur ?? this.useBackdropBlur,
      cardBlur: cardBlur ?? this.cardBlur,
      cardColor: cardColor ?? this.cardColor,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadows: cardShadows ?? this.cardShadows,
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
    );
  }

  static const defaultStyle = UiStyleThemeExtension(
    styleFamily: UiStyleFamily.glassmorphism,
  );
}

extension ThemeDataExtensions on ThemeData {
  UiStyleFamily get uiStyleFamily =>
      extension<UiStyleThemeExtension>()?.styleFamily ??
      UiStyleFamily.glassmorphism;

  bool get useBackdropBlur =>
      extension<UiStyleThemeExtension>()?.useBackdropBlur ?? false;

  double get cardBlur => extension<UiStyleThemeExtension>()?.cardBlur ?? 0;

  Color? get styleCardColor => extension<UiStyleThemeExtension>()?.cardColor;

  Border? get styleCardBorder => extension<UiStyleThemeExtension>()?.cardBorder;

  List<BoxShadow>? get styleCardShadows =>
      extension<UiStyleThemeExtension>()?.cardShadows;
}
