import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Modern progress indicator with optional label
/// Features:
/// - Animated progress
/// - Optional percentage label
/// - Customizable colors
/// - Smooth transitions
class ModernProgressIndicator extends StatelessWidget {
  const ModernProgressIndicator({
    super.key,
    required this.value,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.backgroundColor,
    this.valueColor,
    this.showLabel = false,
    this.label,
  });

  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final progressColor = valueColor ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation(bgColor.withValues(alpha: 0.3)),
          ),
          // Progress circle
          TweenAnimationBuilder<double>(
            duration: Motion.medium,
            tween: Tween(begin: 0.0, end: value),
            builder: (context, animatedValue, child) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(progressColor),
              );
            },
          ),
          // Label
          if (showLabel)
            Text(
              label ?? '${(value * 100).round()}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }
}
