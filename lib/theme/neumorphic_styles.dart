import 'package:flutter/material.dart';
import 'design_tokens.dart';

class NeumorphicStyles {
  // Base Colors - Soft, monochromatic backgrounds (not pure white or black)
  static const Color lightBackground = Color(0xFFE0E5EC);
  static const Color darkBackground = Color(0xFF2D2F33);

  // Shadow colors derived from base background for material mimicry
  // Light mode shadows - lighter and darker versions of the base
  static const Color lightHighlightLight = Color(0xFFFFFFFF);
  static const Color darkShadowLight = Color(0xFFA3B1C6);

  // Dark mode shadows - lighter and darker versions of the base
  static const Color lightHighlightDark = Color(0xFF3E4145);
  static const Color darkShadowDark = Color(0xFF1A1C1F);

  static Color get lightShadowColorLight => lightHighlightLight;
  static Color get darkShadowColorLight => darkShadowLight;
  static Color get lightShadowColorDark => lightHighlightDark;
  static Color get darkShadowColorDark => darkShadowDark;

  // Inset shadow colors for pressed state
  static const Color insetHighlightLight = Color(0xFFA3B1C6);
  static const Color insetShadowLight = Color(0xFFFFFFFF);
  static const Color insetHighlightDark = Color(0xFF1A1C1F);
  static const Color insetShadowDark = Color(0xFF3E4145);

  // Decorations
  static BoxDecoration decoration({
    required bool isDark,
    BorderRadius? borderRadius,
    double? depth,
    bool isPressed = false, // Convex (false) vs Concave (true)
    BoxShape shape = BoxShape.rectangle,
    Color? color,
  }) {
    final bg = color ?? (isDark ? darkBackground : lightBackground);
    final radius = shape == BoxShape.circle
        ? null
        : (borderRadius ?? BorderRadius.circular(Radii.m));

    // Subtle depth for minimalist aesthetic
    final shadowDepth = depth ?? 6.0;
    final offset = Offset(shadowDepth, shadowDepth);
    // Soft blur for subtle shadows
    final blur = shadowDepth * 2.0;

    if (isPressed) {
      // Pressed state (Concave) - "Pressed in" look
      final pressedBg = isDark
          ? Color.lerp(bg, Colors.black, 0.05)!
          : Color.lerp(bg, Colors.black, 0.02)!;

      final insetHighlightColor = isDark
          ? insetHighlightDark
          : insetHighlightLight;
      final insetShadowColor = isDark ? insetShadowDark : insetShadowLight;

      return BoxDecoration(
        color: pressedBg,
        borderRadius: radius,
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: insetShadowColor.withValues(alpha: isDark ? 0.55 : 0.75),
            offset: Offset(shadowDepth * 0.4, shadowDepth * 0.4),
            blurRadius: shadowDepth,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: insetHighlightColor.withValues(alpha: isDark ? 0.35 : 0.55),
            offset: Offset(-shadowDepth * 0.4, -shadowDepth * 0.4),
            blurRadius: shadowDepth,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: isDark
                ? darkShadowDark.withValues(alpha: 0.3)
                : darkShadowLight.withValues(alpha: 0.15),
            offset: Offset(shadowDepth * 0.3, shadowDepth * 0.3),
            blurRadius: shadowDepth,
          ),
        ],
      );
    }

    // Convex state (Standard Neumorphism)
    // Material mimicry: solid color, no gradient
    // Light coming from Top-Left

    final highlightColor = isDark ? lightHighlightDark : lightHighlightLight;
    final shadowColor = isDark ? darkShadowDark : darkShadowLight;

    return BoxDecoration(
      color: bg,
      borderRadius: radius,
      shape: shape,
      // Top-Left: Light highlight (pops out)
      // Bottom-Right: Dark shadow (depth)
      boxShadow: [
        BoxShadow(color: highlightColor, offset: -offset, blurRadius: blur),
        BoxShadow(color: shadowColor, offset: offset, blurRadius: blur),
      ],
    );
  }

  // Text Shadows - Subtle for minimalist aesthetic
  static List<Shadow> textShadows({required bool isDark, double depth = 1.5}) {
    final shadowDepth = depth;
    final blur = depth * 1.2;

    final highlightColor = isDark ? lightHighlightDark : lightHighlightLight;
    final shadowColor = isDark ? darkShadowDark : darkShadowLight;

    return [
      Shadow(
        color: highlightColor.withValues(alpha: isDark ? 0.4 : 0.7),
        offset: Offset(-shadowDepth, -shadowDepth),
        blurRadius: blur,
      ),
      Shadow(
        color: shadowColor.withValues(alpha: isDark ? 0.6 : 0.25),
        offset: Offset(shadowDepth, shadowDepth),
        blurRadius: blur,
      ),
    ];
  }

  // Specific style for input fields (concave look) - Theme version
  static InputDecorationTheme inputDecorationTheme({required bool isDark}) {
    final bg = isDark ? darkBackground : lightBackground;

    // Subtle concave look for inputs - "pressed in"
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

  // Specific style for input fields (concave look)
  static InputDecoration inputDecoration({
    required bool isDark,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final bg = isDark ? darkBackground : lightBackground;

    // Subtle concave look for inputs - "pressed in"
    final pressedBg = isDark
        ? Color.lerp(bg, Colors.black, 0.03)!
        : Color.lerp(bg, Colors.black, 0.01)!;

    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: pressedBg,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
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
}
