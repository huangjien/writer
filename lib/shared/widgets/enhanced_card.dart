import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';
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

    // For Neumorphism, the card color should usually match the background
    // unless explicitly overridden.
    final cardColor =
        color ??
        (isDark
            ? NeumorphicStyles.darkBackground
            : NeumorphicStyles.lightBackground);

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

    // If elevation is 0, we might want a flat card or just border.
    // If elevation > 0, use Neumorphic decoration.
    final decoration = elevation > 0
        ? NeumorphicStyles.decoration(
            isDark: isDark,
            borderRadius: radius,
            color: cardColor,
            depth:
                elevation * 3.0, // Subtle multiplier for minimalist aesthetic
          )
        : BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            border:
                border ??
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

  // _getBoxShadow is no longer needed as NeumorphicStyles handles it
}
