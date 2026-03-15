import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/theme/neumorphic_styles.dart';

void main() {
  group('NeumorphicStyles.decoration', () {
    test('light convex uses default depth and two shadows', () {
      final decoration = NeumorphicStyles.decoration(isDark: false);

      expect(decoration.color, NeumorphicStyles.lightBackground);
      expect(decoration.borderRadius, BorderRadius.circular(Radii.m));

      expect(decoration.gradient, isNull);

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(2));

      final highlight = decoration.boxShadow![0];
      final shadow = decoration.boxShadow![1];

      expect(highlight.offset, const Offset(-6.0, -6.0));
      expect(highlight.blurRadius, 6.0 * 2.0);
      expect(highlight.color, NeumorphicStyles.lightHighlightLight);

      expect(shadow.offset, const Offset(6.0, 6.0));
      expect(shadow.blurRadius, 6.0 * 2.0);
      expect(shadow.color, NeumorphicStyles.darkShadowLight);
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

      expect(decoration.gradient, isNull);

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(2));

      final highlight = decoration.boxShadow![0];
      final shadow = decoration.boxShadow![1];

      expect(highlight.offset, const Offset(-10.0, -10.0));
      expect(highlight.blurRadius, 10.0 * 2.0);
      expect(highlight.color, NeumorphicStyles.lightHighlightDark);

      expect(shadow.offset, const Offset(10.0, 10.0));
      expect(shadow.blurRadius, 10.0 * 2.0);
      expect(shadow.color, NeumorphicStyles.darkShadowDark);
    });

    test('pressed state uses inset-like inner shadows', () {
      final decoration = NeumorphicStyles.decoration(
        isDark: false,
        isPressed: true,
      );

      expect(decoration.gradient, isNull);
      expect(decoration.borderRadius, BorderRadius.circular(Radii.m));

      final pressedBg = Color.lerp(
        NeumorphicStyles.lightBackground,
        Colors.black,
        0.02,
      )!;
      expect(decoration.color, pressedBg);

      final border = decoration.border;
      expect(border, isNotNull);
      expect((border!.top.color.a * 255.0).round().clamp(0, 255), equals(20));
      expect(border.top.color, Colors.black.withValues(alpha: 0.08));

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!, hasLength(3));

      final innerShadow = decoration.boxShadow![0];
      final innerHighlight = decoration.boxShadow![1];
      final outerShadow = decoration.boxShadow![2];

      expect(innerShadow.blurStyle, BlurStyle.inner);
      expect(innerHighlight.blurStyle, BlurStyle.inner);
      expect(innerShadow.offset.dx, closeTo(2.4, 1e-9));
      expect(innerShadow.offset.dy, closeTo(2.4, 1e-9));
      expect(innerHighlight.offset.dx, closeTo(-2.4, 1e-9));
      expect(innerHighlight.offset.dy, closeTo(-2.4, 1e-9));
      expect(outerShadow.offset.dx, closeTo(1.8, 1e-9));
      expect(outerShadow.offset.dy, closeTo(1.8, 1e-9));
    });
  });

  group('NeumorphicStyles.inputDecorationTheme', () {
    test('light theme uses concave fill and correct borders', () {
      final theme = NeumorphicStyles.inputDecorationTheme(isDark: false);

      expect(theme.filled, true);
      expect(
        theme.fillColor,
        Color.lerp(NeumorphicStyles.lightBackground, Colors.black, 0.01),
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
        Color.lerp(NeumorphicStyles.darkBackground, Colors.black, 0.03),
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
      const prefix = Icon(Icons.search);
      const suffix = Icon(Icons.clear);
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
        Color.lerp(NeumorphicStyles.lightBackground, Colors.black, 0.01),
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

  group('NeumorphicStyles.textShadows', () {
    test('light mode returns two shadows with correct properties', () {
      final shadows = NeumorphicStyles.textShadows(isDark: false);

      expect(shadows, hasLength(2));

      final highlight = shadows[0];
      final shadow = shadows[1];

      expect(
        highlight.color,
        NeumorphicStyles.lightHighlightLight.withValues(alpha: 0.7),
      );
      expect(highlight.offset, const Offset(-1.5, -1.5));
      expect(highlight.blurRadius, closeTo(1.8, 1e-9));

      expect(
        shadow.color,
        NeumorphicStyles.darkShadowLight.withValues(alpha: 0.25),
      );
      expect(shadow.offset, const Offset(1.5, 1.5));
      expect(shadow.blurRadius, closeTo(1.8, 1e-9));
    });

    test('dark mode returns two shadows with correct properties', () {
      final shadows = NeumorphicStyles.textShadows(isDark: false);

      expect(shadows, hasLength(2));

      final highlight = shadows[0];
      final shadow = shadows[1];

      expect(
        highlight.color,
        NeumorphicStyles.lightHighlightLight.withValues(alpha: 0.7),
      );
      expect(highlight.offset, const Offset(-1.5, -1.5));
      expect(highlight.blurRadius, closeTo(1.8, 1e-9));

      expect(
        shadow.color,
        NeumorphicStyles.darkShadowLight.withValues(alpha: 0.25),
      );
      expect(shadow.offset, const Offset(1.5, 1.5));
      expect(shadow.blurRadius, closeTo(1.8, 1e-9));
    });

    test('respects custom depth parameter', () {
      final shadows = NeumorphicStyles.textShadows(isDark: false, depth: 3.0);

      expect(shadows, hasLength(2));

      final highlight = shadows[0];
      final shadow = shadows[1];

      expect(highlight.offset, const Offset(-3.0, -3.0));
      expect(highlight.blurRadius, closeTo(3.6, 1e-9));

      expect(shadow.offset, const Offset(3.0, 3.0));
      expect(shadow.blurRadius, closeTo(3.6, 1e-9));
    });

    test('dark mode shadows have different alpha values', () {
      final shadows = NeumorphicStyles.textShadows(isDark: true);

      expect(shadows, hasLength(2));

      final highlight = shadows[0];
      final shadow = shadows[1];

      expect(
        highlight.color,
        NeumorphicStyles.lightHighlightDark.withValues(alpha: 0.4),
      );
      expect(
        shadow.color,
        NeumorphicStyles.darkShadowDark.withValues(alpha: 0.6),
      );
    });
  });

  group('NeumorphicStyles.decoration edge cases', () {
    test('circle shape ignores border radius', () {
      final decoration = NeumorphicStyles.decoration(
        isDark: false,
        shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(12),
      );

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
    });

    test('convex decoration in dark mode includes no border', () {
      final decoration = NeumorphicStyles.decoration(isDark: true);

      expect(decoration.border, isNull);
    });

    test('pressed decoration in dark mode includes border', () {
      final decoration = NeumorphicStyles.decoration(
        isDark: true,
        isPressed: true,
      );

      final border = decoration.border;
      expect(border, isNull);
    });
  });
}
