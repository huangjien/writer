import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';

class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.depth,
    this.color,
    this.onTap,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? depth;
  final Color? color;
  final VoidCallback? onTap;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedBorderRadius =
        borderRadius ??
        theme.cardBorderRadius ??
        BorderRadius.circular(Radii.l);
    final resolvedBackgroundColor =
        color ?? theme.cardBackgroundColor ?? theme.colorScheme.surface;
    final resolvedShadows = (depth ?? 6.0) <= 0 ? null : theme.styleCardShadows;
    final resolvedBorder = theme.styleCardBorder;

    final content = Container(
      padding: padding ?? const EdgeInsets.all(Spacing.l),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: shape == BoxShape.rectangle ? resolvedBorderRadius : null,
        shape: shape,
        border: resolvedBorder,
        boxShadow: resolvedShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: content);
  }
}
