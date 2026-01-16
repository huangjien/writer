import 'package:flutter/material.dart';
import 'design_tokens.dart';

class NeumorphicStyles {
  // Common Colors
  static const Color lightBackground = Color(
    0xFFE0E5EC,
  ); // Classic Neumorphism gray-ish blue
  static const Color darkBackground = Color(0xFF2D2F33);

  static const Color lightShadowColorLight = Colors.white;
  static const Color darkShadowColorLight = Color(0xFFA3B1C6);

  static const Color lightShadowColorDark = Color(0xFF3E4145);
  static const Color darkShadowColorDark = Colors.black;

  // Decorations
  static BoxDecoration decoration({
    required bool isDark,
    BorderRadius? borderRadius,
    double? depth,
    bool isPressed =
        false, // This effectively toggles between Convex (false) and Concave (true)
    BoxShape shape = BoxShape.rectangle,
    Color? color,
  }) {
    final bg = color ?? (isDark ? darkBackground : lightBackground);
    final radius = shape == BoxShape.circle
        ? null
        : (borderRadius ?? BorderRadius.circular(Radii.m));
    // Increased base depth for more "3D" feel
    final shadowDepth = depth ?? 8.0;

    // Shadows
    final offset = Offset(shadowDepth, shadowDepth);
    // Increased blur multiplier for softer, deeper shadows
    final blur = shadowDepth * 2.5;

    // Increased opacity/contrast for more pop
    final topShadowColor = isDark
        ? lightShadowColorDark.withValues(alpha: 0.15)
        : lightShadowColorLight;

    final bottomShadowColor = isDark
        ? darkShadowColorDark.withValues(
            alpha: 0.8,
          ) // Darker shadow in dark mode
        : darkShadowColorDark.withValues(
            alpha: 0.5,
          ); // Darker shadow in light mode

    if (isPressed) {
      // Pressed state (Concave)
      // To simulate "pressed", we can use a gradient or inner shadow simulation
      // Since standard Flutter BoxShadow is outer only, we simulate "pressed"
      // by using a border that suggests depth (inset look) or changing the background color slightly
      // to look like it's in shadow.

      // A trick for pressed state without custom painter:
      // Darker background + no shadow (or very small shadow) + inner-like border

      final pressedBg = isDark
          ? Color.lerp(bg, Colors.black, 0.2)!
          : Color.lerp(bg, Colors.black, 0.05)!;

      return BoxDecoration(
        color: pressedBg,
        borderRadius: radius,
        shape: shape,
        // Inset-like border simulation
        border: Border.all(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          // Tiny shadow to keep it from looking floating
          BoxShadow(
            color: bottomShadowColor.withValues(alpha: 0.1),
            offset: const Offset(1, 1),
            blurRadius: 1,
          ),
        ],
      );
    }

    // Convex state (Standard Neumorphism)
    // Adding a subtle gradient to the surface makes it look more 3D (curved)
    // Light coming from Top-Left -> Top-Left is lighter, Bottom-Right is darker.

    // However, if 'color' is provided (e.g. primary button), we should be careful with gradients.
    // Let's only apply strong gradients if it's the default background color.
    // If it's a custom color, just use it or a subtle version.

    // Calculate gradient colors based on the provided 'bg'
    final gradientColors = isDark
        ? [
            Color.lerp(bg, Colors.white, 0.05)!,
            Color.lerp(bg, Colors.black, 0.1)!,
          ]
        : [
            Color.lerp(bg, Colors.white, 0.2)!,
            Color.lerp(bg, Colors.black, 0.05)!,
          ];

    return BoxDecoration(
      color: bg,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: radius,
      shape: shape,
      boxShadow: [
        // Top Left Shadow (Light/Highlight)
        BoxShadow(color: topShadowColor, offset: -offset, blurRadius: blur),
        // Bottom Right Shadow (Dark)
        BoxShadow(color: bottomShadowColor, offset: offset, blurRadius: blur),
      ],
    );
  }

  // Text Shadows
  static List<Shadow> textShadows({required bool isDark, double depth = 2.0}) {
    final shadowDepth = depth;
    final blur = depth * 1.5;

    final topShadowColor = isDark
        ? lightShadowColorDark.withValues(alpha: 0.3)
        : lightShadowColorLight.withValues(alpha: 0.8);

    final bottomShadowColor = isDark
        ? darkShadowColorDark.withValues(alpha: 0.8)
        : darkShadowColorDark.withValues(alpha: 0.3);

    return [
      Shadow(
        color: topShadowColor,
        offset: Offset(-shadowDepth, -shadowDepth),
        blurRadius: blur,
      ),
      Shadow(
        color: bottomShadowColor,
        offset: Offset(shadowDepth, shadowDepth),
        blurRadius: blur,
      ),
    ];
  }

  // Specific style for input fields (concave look) - Theme version
  static InputDecorationTheme inputDecorationTheme({required bool isDark}) {
    final bg = isDark ? darkBackground : lightBackground;
    // borderColor was unused

    // Deep concave look for inputs:
    // Darker background than surface, inner shadow simulated by border or gradient?
    // Inputs usually look "pressed".
    final pressedBg = isDark
        ? Color.lerp(bg, Colors.black, 0.2)!
        : Color.lerp(bg, Colors.black, 0.05)!;

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
          color: isDark
              ? Colors.black26
              : Colors.white54, // Inset highlight/shadow
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

    final pressedBg = isDark
        ? Color.lerp(bg, Colors.black, 0.2)!
        : Color.lerp(bg, Colors.black, 0.05)!;

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
