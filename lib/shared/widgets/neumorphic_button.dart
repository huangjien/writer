import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class NeumorphicButton extends StatelessWidget {
  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(Radii.m);
    final background = theme.colorScheme.surfaceContainerLowest;

    final lightShadow = BoxShadow(
      color: (isDark ? Colors.white : Colors.white).withValues(
        alpha: isDark ? 0.05 : 0.70,
      ),
      blurRadius: 16,
      offset: const Offset(-6, -6),
    );
    final darkShadow = BoxShadow(
      color: (isDark ? Colors.black : Colors.black).withValues(
        alpha: isDark ? 0.45 : 0.12,
      ),
      blurRadius: 16,
      offset: const Offset(6, 6),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: Spacing.l,
                vertical: Spacing.m,
              ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            boxShadow: [lightShadow, darkShadow],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
