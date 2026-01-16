import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/theme/neumorphic_styles.dart';

void main() {
  group('NeumorphicStyles.decoration', () {
    test('light convex uses default depth, gradient, and two shadows', () {
      final decoration = NeumorphicStyles.decoration(isDark: false);

      expect(decoration.color, NeumorphicStyles.lightBackground);
      expect(decoration.borderRadius, BorderRadius.circular(Radii.m));

      final gradient = decoration.gradient as LinearGradient?;
      expect(gradient, isNotNull);
      expect(gradient!.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
      expect(gradient.colors, [
        Color.lerp(NeumorphicStyles.lightBackground, Colors.white, 0.2)!,
        Color.lerp(NeumorphicStyles.lightBackground, Colors.black, 0.05)!,
      ]);

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(2));

      final highlight = decoration.boxShadow![0];
      final shadow = decoration.boxShadow![1];

      expect(highlight.offset, const Offset(-8.0, -8.0));
      expect(highlight.blurRadius, 8.0 * 2.5);
      expect(highlight.color, Colors.white);

      expect(shadow.offset, const Offset(8.0, 8.0));
      expect(shadow.blurRadius, 8.0 * 2.5);
      expect(shadow.color, Colors.black.withValues(alpha: 0.5));
    });

    test('dark convex respects custom depth, radius, and color', () {
      const bg = Colors.red;
      final decoration = NeumorphicStyles.decoration(
        isDark: true,
        depth: 10.0,
        borderRadius: BorderRadius.circular(12),
        color: bg,
      );

      expect(decoration.color, bg);
      expect(decoration.borderRadius, BorderRadius.circular(12));

      final gradient = decoration.gradient as LinearGradient?;
      expect(gradient, isNotNull);
      expect(gradient!.colors, [
        Color.lerp(bg, Colors.white, 0.05)!,
        Color.lerp(bg, Colors.black, 0.1)!,
      ]);

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(2));

      final highlight = decoration.boxShadow![0];
      final shadow = decoration.boxShadow![1];

      expect(highlight.offset, const Offset(-10.0, -10.0));
      expect(highlight.blurRadius, 10.0 * 2.5);
      expect(
        highlight.color,
        NeumorphicStyles.lightShadowColorDark.withValues(alpha: 0.15),
      );

      expect(shadow.offset, const Offset(10.0, 10.0));
      expect(shadow.blurRadius, 10.0 * 2.5);
      expect(shadow.color, Colors.black.withValues(alpha: 0.8));
    });

    test('pressed state uses inset-like border and tiny shadow', () {
      final decoration = NeumorphicStyles.decoration(
        isDark: false,
        isPressed: true,
      );

      expect(decoration.gradient, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(Radii.m));

      final pressedBg = Color.lerp(
        NeumorphicStyles.lightBackground,
        Colors.black,
        0.05,
      )!;
      expect(decoration.color, pressedBg);

      expect(decoration.border, isNotNull);
      final border = decoration.border! as Border;
      expect(border.top.width, 1);
      expect(border.top.color, Colors.white.withValues(alpha: 0.7));

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(1));
      expect(decoration.boxShadow!.first.offset, const Offset(1, 1));
      expect(decoration.boxShadow!.first.blurRadius, 1);
    });
  });

  group('NeumorphicStyles.inputDecorationTheme', () {
    test('light theme uses concave fill and correct borders', () {
      final theme = NeumorphicStyles.inputDecorationTheme(isDark: false);

      expect(theme.filled, true);
      expect(
        theme.fillColor,
        Color.lerp(NeumorphicStyles.lightBackground, Colors.black, 0.05),
      );
      expect(
        theme.contentPadding,
        const EdgeInsets.symmetric(horizontal: Spacing.l, vertical: Spacing.m),
      );

      final base = theme.border as OutlineInputBorder?;
      expect(base, isNotNull);
      expect(base!.borderSide, BorderSide.none);
      expect(base.borderRadius, BorderRadius.circular(Radii.m));

      final enabled = theme.enabledBorder as OutlineInputBorder?;
      expect(enabled, isNotNull);
      expect(enabled!.borderRadius, BorderRadius.circular(Radii.m));
      expect(enabled.borderSide.color, Colors.white54);
      expect(enabled.borderSide.width, 1);

      final focused = theme.focusedBorder as OutlineInputBorder?;
      expect(focused, isNotNull);
      expect(focused!.borderRadius, BorderRadius.circular(Radii.m));
      expect(focused.borderSide.color, Colors.black26);
      expect(focused.borderSide.width, 1.5);
    });

    test('dark theme uses concave fill and dark-specific borders', () {
      final theme = NeumorphicStyles.inputDecorationTheme(isDark: true);

      expect(theme.filled, true);
      expect(
        theme.fillColor,
        Color.lerp(NeumorphicStyles.darkBackground, Colors.black, 0.2),
      );

      final enabled = theme.enabledBorder as OutlineInputBorder?;
      expect(enabled, isNotNull);
      expect(enabled!.borderSide.color, Colors.black26);
      expect(enabled.borderSide.width, 1);

      final focused = theme.focusedBorder as OutlineInputBorder?;
      expect(focused, isNotNull);
      expect(focused!.borderSide.color, Colors.white30);
      expect(focused.borderSide.width, 1.5);
    });
  });

  group('NeumorphicStyles.inputDecoration', () {
    test('returns a concave InputDecoration with expected properties', () {
      final prefix = Icon(Icons.search);
      final suffix = Icon(Icons.clear);
      final decoration = NeumorphicStyles.inputDecoration(
        isDark: false,
        hintText: 'Search',
        prefixIcon: prefix,
        suffixIcon: suffix,
      );

      expect(decoration.hintText, 'Search');
      expect(decoration.filled, true);
      expect(
        decoration.fillColor,
        Color.lerp(NeumorphicStyles.lightBackground, Colors.black, 0.05),
      );
      expect(decoration.prefixIcon, prefix);
      expect(decoration.suffixIcon, suffix);
      expect(
        decoration.contentPadding,
        const EdgeInsets.symmetric(horizontal: Spacing.l, vertical: Spacing.m),
      );

      final enabled = decoration.enabledBorder as OutlineInputBorder?;
      expect(enabled, isNotNull);
      expect(enabled!.borderRadius, BorderRadius.circular(Radii.m));
      expect(enabled.borderSide.color, Colors.white54);
      expect(enabled.borderSide.width, 1);

      final focused = decoration.focusedBorder as OutlineInputBorder?;
      expect(focused, isNotNull);
      expect(focused!.borderRadius, BorderRadius.circular(Radii.m));
      expect(focused.borderSide.color, Colors.black26);
      expect(focused.borderSide.width, 1.5);
    });
  });
}
