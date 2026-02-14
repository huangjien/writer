import 'package:flutter/material.dart';
import 'package:writer/theme/style_theme_patch.dart';
import 'package:writer/theme/style_theme_patch_helpers.dart';
import 'ui_styles.dart';

extension StyleThemePatchResolvers on StyleThemePatch {
  List<BoxShadow>? resolveCardShadows(ThemeData base, bool isDark) {
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
        return neumorphicConvexShadows(isDark: isDark, depth: 14);
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  Border? resolveCardBorder(ThemeData base, bool isDark) {
    if (cardBorder != null) return cardBorder;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        return isDark
            ? null
            : Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  List<BoxShadow>? resolveButtonShadows(ThemeData base, bool isDark) {
    if (buttonShadows != null) return buttonShadows;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        return neumorphicConvexShadows(isDark: isDark, depth: 6);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  Color? resolveButtonPressedColor(ThemeData base, bool isDark) {
    if (buttonPressedColor != null) return buttonPressedColor;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        final bg = neumorphicBackground(isDark);
        return Color.lerp(bg, Colors.black, isDark ? 0.05 : 0.02);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  List<BoxShadow>? resolveButtonPressedShadows(ThemeData base, bool isDark) {
    if (buttonPressedShadows != null) return buttonPressedShadows;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        return neumorphicPressedShadows(isDark: isDark, depth: 6);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  Color? resolveCardPressedColor(ThemeData base, bool isDark) {
    if (cardPressedColor != null) return cardPressedColor;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        final bg = neumorphicBackground(isDark);
        return Color.lerp(bg, Colors.black, isDark ? 0.05 : 0.02);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  List<BoxShadow>? resolveCardPressedShadows(ThemeData base, bool isDark) {
    if (cardPressedShadows != null) return cardPressedShadows;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        return neumorphicPressedShadows(isDark: isDark, depth: 14);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  Border? resolveSwitchBorder(ThemeData base, bool isDark) {
    if (switchBorder != null) return switchBorder;
    switch (styleFamily) {
      case UiStyleFamily.neumorphism:
        return isDark
            ? null
            : Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1);
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.minimalism:
      case UiStyleFamily.flatDesign:
        return null;
    }
  }

  double? resolveDividerThickness() {
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

  Color? resolveDividerColor(ThemeData base, bool isDark) {
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

  Color? resolveSurfaceColor(ThemeData base, bool isDark) {
    if (cardColor != null) return cardColor;
    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(
          surface,
          factor: 0.04,
        ).withValues(alpha: isDark ? 0.85 : 0.90);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(
          surface,
          factor: 0.06,
        ).withValues(alpha: isDark ? 0.80 : 0.85);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.01);
      case UiStyleFamily.flatDesign:
        return surface;
    }
  }

  Color? resolveTileColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(
          surface,
          factor: 0.06,
        ).withValues(alpha: isDark ? 0.75 : 0.80);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(
          surface,
          factor: 0.08,
        ).withValues(alpha: isDark ? 0.70 : 0.75);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.02);
      case UiStyleFamily.flatDesign:
        return deriveLighterColor(surface, factor: 0.02);
    }
  }

  Color? resolveDropdownBackgroundColor(ThemeData base, bool isDark) {
    if (dropdownBackgroundColor != null) {
      return dropdownBackgroundColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveDarkerColor(surface, factor: 0.08);
      case UiStyleFamily.liquidGlass:
        return deriveDarkerColor(surface, factor: 0.06);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.04);
      case UiStyleFamily.flatDesign:
        return deriveDarkerColor(surface, factor: 0.05);
    }
  }

  Color? resolveInputBackgroundColor(ThemeData base, bool isDark) {
    if (inputBackgroundColor != null) {
      return inputBackgroundColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(surface, factor: 0.08).withValues(alpha: 0.7);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(surface, factor: 0.10).withValues(alpha: 0.6);
      case UiStyleFamily.neumorphism:
        final bg = neumorphicBackground(isDark);
        return Color.lerp(bg, Colors.black, isDark ? 0.03 : 0.01);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.04);
      case UiStyleFamily.flatDesign:
        return deriveLighterColor(surface, factor: 0.06);
    }
  }

  Color? resolveButtonBackgroundColor(ThemeData base, bool isDark) {
    if (buttonBackgroundColor != null) {
      return buttonBackgroundColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        if (isDark) {
          final bgLuminance = cs.primary.computeLuminance();
          if (bgLuminance > 0.4) {
            return deriveDarkerColor(cs.primary, factor: 0.15);
          }
        }
        return cs.primary;
      case UiStyleFamily.liquidGlass:
        if (isDark) {
          final bgLuminance = cs.primary.computeLuminance();
          if (bgLuminance > 0.4) {
            return deriveDarkerColor(
              cs.primary,
              factor: 0.2,
            ).withValues(alpha: 0.95);
          }
        }
        return cs.primary.withValues(alpha: 0.9);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        if (isDark) {
          return deriveDarkerColor(cs.primary, factor: 0.25);
        }
        return deriveLighterColor(surface, factor: 0.06);
      case UiStyleFamily.flatDesign:
        if (isDark) {
          return deriveDarkerColor(cs.primary, factor: 0.1);
        }
        return cs.primary;
    }
  }

  Color? resolveCardBackgroundColor(ThemeData base, bool isDark) {
    if (cardBackgroundColor != null) {
      return cardBackgroundColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(surface, factor: 0.06).withValues(alpha: 0.8);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(surface, factor: 0.08).withValues(alpha: 0.7);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.03);
      case UiStyleFamily.flatDesign:
        return surface;
    }
  }

  Color? resolveSwitchBackgroundColor(ThemeData base, bool isDark) {
    if (switchBackgroundColor != null) {
      return switchBackgroundColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(surface, factor: 0.10);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(surface, factor: 0.12);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.08);
      case UiStyleFamily.flatDesign:
        return deriveLighterColor(surface, factor: 0.12);
    }
  }

  Color? resolveSwitchThumbColor(ThemeData base, bool isDark) {
    if (switchThumbColor != null) {
      return switchThumbColor;
    }

    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
      case UiStyleFamily.liquidGlass:
      case UiStyleFamily.flatDesign:
        return cs.onPrimary;
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.08);
    }
  }

  Color? resolveDropdownMenuBackgroundColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(surface, factor: 0.10);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(surface, factor: 0.12);
      case UiStyleFamily.neumorphism:
        return neumorphicBackground(isDark);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.06);
      case UiStyleFamily.flatDesign:
        return deriveLighterColor(surface, factor: 0.08);
    }
  }

  Color? resolveDropdownMenuSelectedColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return cs.primary.withValues(alpha: 0.15);
      case UiStyleFamily.liquidGlass:
        return cs.primary.withValues(alpha: 0.12);
      case UiStyleFamily.neumorphism:
        return deriveLighterColor(neumorphicBackground(isDark), factor: 0.04);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.10);
      case UiStyleFamily.flatDesign:
        return cs.primary.withValues(alpha: 0.12);
    }
  }

  Color? resolveDropdownMenuHoverColor(ThemeData base, bool isDark) {
    final cs = base.colorScheme;
    final surface = cs.surface;

    switch (styleFamily) {
      case UiStyleFamily.glassmorphism:
        return deriveLighterColor(surface, factor: 0.08);
      case UiStyleFamily.liquidGlass:
        return deriveLighterColor(surface, factor: 0.10);
      case UiStyleFamily.neumorphism:
        return deriveLighterColor(neumorphicBackground(isDark), factor: 0.02);
      case UiStyleFamily.minimalism:
        return deriveLighterColor(surface, factor: 0.04);
      case UiStyleFamily.flatDesign:
        return deriveLighterColor(surface, factor: 0.06);
    }
  }
}
