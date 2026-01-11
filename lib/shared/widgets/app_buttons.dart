import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'micro_interactions.dart';

/// Collection of styled button components
/// Features:
/// - Primary, secondary, text, and icon button variants
/// - Loading states
/// - Icon support
/// - Consistent styling
class AppButtons {
  /// Primary filled button with elevation
  static Widget primary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return PressScale(
      enabled: !isLoading,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          elevation: 2,
          minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: Spacing.s),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }

  /// Secondary outlined button
  static Widget secondary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return PressScale(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: Spacing.s),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }

  /// Text button for secondary actions
  static Widget text({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return PressScale(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: color),
        child: Text(label),
      ),
    );
  }

  /// Icon button for toolbar actions
  static Widget icon({
    required IconData iconData,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
    bool filled = false,
  }) {
    final button = PressScale(
      child: IconButton(
        icon: Icon(iconData),
        color: color,
        onPressed: onPressed,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(Spacing.s)),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  /// Filled icon button
  static Widget filledIcon({
    required IconData iconData,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    final button = PressScale(
      child: IconButton.filled(
        icon: Icon(iconData),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: iconColor,
          padding: const EdgeInsets.all(Spacing.s),
        ),
        onPressed: onPressed,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
