import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

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
    final cardColor =
        color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final radius = borderRadius ?? BorderRadius.circular(Radii.l);

    final card = Container(
      padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border:
            border ??
            Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 1,
            ),
      ),
      child: child,
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: _getBoxShadow(elevation, isDark),
        ),
        child: card,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _getBoxShadow(elevation, isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: card,
        ),
      ),
    );
  }

  List<BoxShadow> _getBoxShadow(int elevation, bool isDark) {
    switch (elevation) {
      case 1:
        return [
          BoxShadow(
            color: AppColors.elevation1,
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: AppColors.elevation1,
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.elevation2,
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: AppColors.elevation1,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.elevation2,
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
      default:
        return [];
    }
  }
}
