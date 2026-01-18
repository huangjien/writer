import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur,
    this.color,
    this.borderColor,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? blur;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedRadius = borderRadius ?? BorderRadius.circular(Radii.l);

    // Use theme extension values when available, otherwise fall back to defaults
    final resolvedBlur =
        blur ?? (theme.cardBlur > 0 ? theme.cardBlur : GlassTokens.blur);

    final resolvedColor =
        color ??
        (theme.styleCardColor ??
            (isDark
                ? AppColors.glassSurfaceDark
                : AppColors.glassSurfaceLight));

    Border? resolvedBorder;
    if (borderColor != null) {
      resolvedBorder = Border.all(color: borderColor!);
    } else {
      resolvedBorder =
          theme.styleCardBorder ??
          Border.all(
            color: isDark
                ? AppColors.glassBorderDark
                : AppColors.glassBorderLight,
          );
    }

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: resolvedBlur, sigmaY: resolvedBlur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: resolvedRadius,
            border: resolvedBorder,
            boxShadow: shadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
