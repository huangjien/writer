import 'package:flutter/material.dart';
import 'neumorphic_styles.dart';

Color deriveDarkerColor(Color color, {double factor = 0.05}) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0)).toColor();
}

Color deriveLighterColor(Color color, {double factor = 0.05}) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + factor).clamp(0.0, 1.0)).toColor();
}

Color neumorphicBackground(bool isDark) {
  return isDark
      ? NeumorphicStyles.darkBackground
      : NeumorphicStyles.lightBackground;
}

List<BoxShadow> neumorphicConvexShadows({
  required bool isDark,
  required double depth,
}) {
  final offset = Offset(depth, depth);
  final blur = depth * 2.0;
  final highlightColor = isDark
      ? NeumorphicStyles.lightHighlightDark
      : NeumorphicStyles.lightHighlightLight;
  final shadowColor = isDark
      ? NeumorphicStyles.darkShadowDark
      : NeumorphicStyles.darkShadowLight;
  return [
    BoxShadow(color: highlightColor, offset: -offset, blurRadius: blur),
    BoxShadow(color: shadowColor, offset: offset, blurRadius: blur),
  ];
}

List<BoxShadow> neumorphicPressedShadows({
  required bool isDark,
  required double depth,
}) {
  final blur = depth * 2.0;
  final insetHighlightColor = isDark
      ? NeumorphicStyles.insetHighlightDark
      : NeumorphicStyles.insetHighlightLight;
  final insetShadowColor = isDark
      ? NeumorphicStyles.insetShadowDark
      : NeumorphicStyles.insetShadowLight;
  final outerShadowColor = isDark
      ? NeumorphicStyles.darkShadowDark.withValues(alpha: 0.3)
      : NeumorphicStyles.darkShadowLight.withValues(alpha: 0.15);
  return [
    BoxShadow(
      color: insetShadowColor.withValues(alpha: isDark ? 0.55 : 0.75),
      offset: Offset(depth * 0.4, depth * 0.4),
      blurRadius: blur,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: insetHighlightColor.withValues(alpha: isDark ? 0.35 : 0.55),
      offset: Offset(-depth * 0.4, -depth * 0.4),
      blurRadius: blur,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: outerShadowColor,
      offset: Offset(depth * 0.3, depth * 0.3),
      blurRadius: blur,
    ),
  ];
}
