import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'focus_wrapper.dart';
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
    bool enabled = true,
    bool fullWidth = false,
  }) {
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: PressScale(
        enabled: enabled && !isLoading,
        child: FilledButton(
          onPressed: (enabled && !isLoading) ? onPressed : null,
          style: FilledButton.styleFrom(
            minimumSize: fullWidth
                ? const Size(double.infinity, MobileSpacing.touchTargetMin)
                : null,
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
      ),
    );
  }

  /// Secondary outlined button
  static Widget secondary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool enabled = true,
    bool fullWidth = false,
  }) {
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: PressScale(
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: fullWidth
                ? const Size(double.infinity, MobileSpacing.touchTargetMin)
                : null,
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
      ),
    );
  }

  /// Text button for secondary actions
  static Widget text({
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
    Color? color,
  }) {
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: PressScale(
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(foregroundColor: color),
          child: Text(label),
        ),
      ),
    );
  }

  /// Icon button for toolbar actions
  static Widget icon({
    required IconData iconData,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
    bool enabled = true,
    bool filled = false,
  }) {
    final button = PressScale(
      child: IconButton(
        icon: Icon(iconData),
        color: color,
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(Spacing.s)),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          child: button,
        ),
      );
    }
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: button,
    );
  }

  /// Filled icon button
  static Widget filledIcon({
    required IconData iconData,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
    Color? iconColor,
    bool enabled = true,
  }) {
    final button = PressScale(
      child: IconButton.filled(
        icon: Icon(iconData),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: iconColor,
          padding: const EdgeInsets.all(Spacing.s),
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          child: button,
        ),
      );
    }
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: button,
    );
  }
}
