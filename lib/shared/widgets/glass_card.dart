import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

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
    final resolvedRadius = borderRadius ?? BorderRadius.circular(Radii.l);
    final resolvedBlur = blur ?? GlassTokens.blur;
    final resolvedColor =
        color ??
        (theme.brightness == Brightness.dark
            ? AppColors.glassSurfaceDark
            : AppColors.glassSurfaceLight);
    final resolvedBorderColor =
        borderColor ??
        (theme.brightness == Brightness.dark
            ? AppColors.glassBorderDark
            : AppColors.glassBorderLight);

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: resolvedBlur, sigmaY: resolvedBlur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: resolvedRadius,
            border: Border.all(color: resolvedBorderColor),
            boxShadow: shadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
