import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'focus_wrapper.dart';
import 'micro_interactions.dart';
import 'neumorphic_button.dart';

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
    // Neumorphic Primary Button
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          child: PressScale(
            enabled: enabled && !isLoading,
            child: SizedBox(
              width: fullWidth ? double.infinity : null,
              height: MobileSpacing.touchTargetMin,
              child: NeumorphicButton(
                onPressed: (enabled && !isLoading) ? onPressed : null,
                borderRadius: BorderRadius.circular(Radii.m),
                // Primary buttons in Neumorphism often use the accent color
                // but subtle. If we want standard Neumorphism, we keep it background-colored.
                // But for "Primary" action, let's use a slightly tinted version or just standard.
                // Let's stick to standard background for true Neumorphism,
                // maybe with colored text/icon to indicate primary.
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 18,
                              color: primaryColor,
                            ), // Use brand color for content
                            const SizedBox(width: Spacing.s),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Secondary outlined button
  static Widget secondary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool enabled = true,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      child: PressScale(
        enabled: enabled && !isLoading,
        child: SizedBox(
          width: fullWidth ? double.infinity : null,
          height: MobileSpacing.touchTargetMin,
          child: NeumorphicButton(
            onPressed: (enabled && !isLoading) ? onPressed : null,
            borderRadius: BorderRadius.circular(Radii.m),
            depth: 6,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
        enabled: enabled,
        child: NeumorphicButton(
          onPressed: enabled ? onPressed : null,
          depth: 3,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          child: Text(label, style: TextStyle(color: color)),
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
    EdgeInsets focusPadding = const EdgeInsets.all(2),
  }) {
    // If filled, use Neumorphic style
    if (filled) {
      return filledIcon(
        iconData: iconData,
        onPressed: onPressed,
        tooltip: tooltip,
        iconColor: color,
        enabled: enabled,
        focusPadding: focusPadding,
      );
    }

    final button = PressScale(
      enabled: enabled,
      child: SizedBox(
        width: MobileSpacing.touchTargetMin,
        height: MobileSpacing.touchTargetMin,
        child: NeumorphicButton(
          onPressed: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(Radii.m),
          depth: 4,
          padding: EdgeInsets.zero,
          child: Icon(iconData, color: color),
        ),
      ),
    );

    if (tooltip != null) {
      return Semantics(
        label: tooltip,
        button: true,
        enabled: enabled,
        onTap: enabled ? onPressed : null,
        child: Tooltip(
          message: tooltip,
          excludeFromSemantics: true,
          child: FocusWrapper(
            borderRadius: BorderRadius.circular(Radii.m),
            padding: focusPadding,
            child: ExcludeSemantics(child: button),
          ),
        ),
      );
    }
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      padding: focusPadding,
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
    EdgeInsets focusPadding = const EdgeInsets.all(2),
  }) {
    final button = PressScale(
      enabled: enabled,
      child: SizedBox(
        width: MobileSpacing.touchTargetMin,
        height: MobileSpacing.touchTargetMin,
        child: NeumorphicButton(
          onPressed: enabled ? onPressed : null,
          padding: EdgeInsets.zero,
          color: backgroundColor, // Use provided color or default
          child: Icon(iconData, color: iconColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Semantics(
        label: tooltip,
        button: true,
        enabled: enabled,
        onTap: enabled ? onPressed : null,
        child: Tooltip(
          message: tooltip,
          excludeFromSemantics: true,
          child: FocusWrapper(
            borderRadius: BorderRadius.circular(Radii.m),
            padding: focusPadding,
            child: ExcludeSemantics(child: button),
          ),
        ),
      );
    }
    return FocusWrapper(
      borderRadius: BorderRadius.circular(Radii.m),
      padding: focusPadding,
      child: button,
    );
  }
}
