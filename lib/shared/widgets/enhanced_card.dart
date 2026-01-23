import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import 'theme_aware_card.dart';

/// Enhanced card component with modern Material 3 design
/// Features:
/// - Tap feedback with ripple effect
/// - Customizable elevation and border radius
/// - Dark mode support
/// - Smooth hover states
class EnhancedCard extends StatelessWidget {
  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevation = 2,
    this.borderRadius,
    this.margin,
    this.color,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final int elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = color ?? theme.cardBackgroundColor ?? theme.cardColor;

    final radius = borderRadius ?? BorderRadius.circular(Radii.l);

    if (elevation > 0 && border == null) {
      return ThemeAwareCard(
        margin: margin,
        borderRadius: radius,
        padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
        semanticType: CardSemanticType.default_,
        onTap: onTap,
        child: child,
      );
    }

    final decoration = elevation > 0
        ? BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            boxShadow: theme.styleCardShadows,
            border: border ?? theme.styleCardBorder,
          )
        : BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            border:
                border ??
                theme.styleCardBorder ??
                Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                  width: 1,
                ),
          );

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
      child: child,
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: cardContent,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: cardContent,
        ),
      ),
    );
  }
}
