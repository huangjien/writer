import 'package:flutter/material.dart';
import 'ui_styles.dart';

class UiStyleThemeExtension extends ThemeExtension<UiStyleThemeExtension> {
  final UiStyleFamily styleFamily;

  const UiStyleThemeExtension({required this.styleFamily});

  @override
  UiStyleThemeExtension copyWith({UiStyleFamily? styleFamily}) {
    return UiStyleThemeExtension(styleFamily: styleFamily ?? this.styleFamily);
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
}
