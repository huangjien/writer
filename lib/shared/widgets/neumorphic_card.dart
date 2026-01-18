import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final content = Container(
      padding: padding ?? const EdgeInsets.all(Spacing.l),
      decoration: NeumorphicStyles.decoration(
        isDark: isDark,
        borderRadius: borderRadius ?? BorderRadius.circular(Radii.l),
        depth: depth ?? 6.0,
        color: color,
        shape: shape,
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
