import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/theme/ui_styles.dart';
import 'package:writer/shared/utils/contrast_utils.dart';
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final buttonBackgroundColor =
            theme.buttonBackgroundColor ?? primaryColor;
        final isDark = theme.brightness == Brightness.dark;
        final accessibleTextColor = ContrastUtils.getButtonTextColor(
          buttonBackgroundColor: buttonBackgroundColor,
          isDarkMode: isDark,
        );

        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          onActivate: (enabled && !isLoading) ? onPressed : null,
          child: PressScale(
            enabled: enabled && !isLoading,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: MobileSpacing.touchTargetMin,
              ),
              child: SizedBox(
                width: fullWidth ? double.infinity : null,
                child: NeumorphicButton(
                  onPressed: (enabled && !isLoading) ? onPressed : null,
                  borderRadius: BorderRadius.circular(Radii.m),
                  color: buttonBackgroundColor,
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accessibleTextColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: 18, color: accessibleTextColor),
                              const SizedBox(width: Spacing.s),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: accessibleTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final buttonBackgroundColor =
            theme.buttonBackgroundColor ?? theme.colorScheme.surface;
        final isDark = theme.brightness == Brightness.dark;
        final accessibleTextColor = ContrastUtils.getButtonTextColor(
          buttonBackgroundColor: buttonBackgroundColor,
          isDarkMode: isDark,
        );

        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          onActivate: (enabled && !isLoading) ? onPressed : null,
          child: PressScale(
            enabled: enabled && !isLoading,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: MobileSpacing.touchTargetMin,
              ),
              child: SizedBox(
                width: fullWidth ? double.infinity : null,
                child: NeumorphicButton(
                  onPressed: (enabled && !isLoading) ? onPressed : null,
                  borderRadius: BorderRadius.circular(Radii.m),
                  depth: 6,
                  color: buttonBackgroundColor,
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accessibleTextColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: 18, color: accessibleTextColor),
                              const SizedBox(width: Spacing.s),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: accessibleTextColor),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Text button for secondary actions
  static Widget text({
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final buttonBackground =
            theme.buttonBackgroundColor ?? theme.colorScheme.surface;
        final textColor = color ?? theme.colorScheme.primary;
        final accessibleColor = ContrastUtils.forceContrastColor(
          foreground: textColor,
          background: buttonBackground,
        );

        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          onActivate: enabled ? onPressed : null,
          child: PressScale(
            enabled: enabled,
            child: NeumorphicButton(
              onPressed: enabled ? onPressed : null,
              depth: 3,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.s,
              ),
              child: Text(
                label,
                style: TextStyle(color: color ?? accessibleColor),
              ),
            ),
          ),
        );
      },
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final buttonBackground =
            theme.buttonBackgroundColor ?? theme.colorScheme.surface;
        final effectiveColor =
            color ??
            ContrastUtils.forceContrastColor(
              foreground: primaryColor,
              background: buttonBackground,
            );

        // For Flat Design style with primary background, use onPrimary for better contrast
        final finalIconColor =
            (theme.uiStyleFamily == UiStyleFamily.flatDesign && color == null)
            ? ContrastUtils.forceContrastColor(
                foreground: theme.colorScheme.onPrimary,
                background: buttonBackground,
              )
            : effectiveColor;

        // If filled, use Neumorphic style
        if (filled) {
          return filledIcon(
            iconData: iconData,
            onPressed: onPressed,
            tooltip: tooltip,
            iconColor: finalIconColor,
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
              child: Icon(iconData, color: finalIconColor, size: 20),
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
                onActivate: enabled ? onPressed : null,
                child: ExcludeSemantics(child: button),
              ),
            ),
          );
        }
        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          padding: focusPadding,
          onActivate: enabled ? onPressed : null,
          child: button,
        );
      },
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final buttonBackground =
            backgroundColor ??
            theme.buttonBackgroundColor ??
            theme.colorScheme.surface;
        final effectiveIconColor =
            iconColor ??
            ContrastUtils.forceContrastColor(
              foreground: primaryColor,
              background: buttonBackground,
            );

        final button = PressScale(
          enabled: enabled,
          child: SizedBox(
            width: MobileSpacing.touchTargetMin,
            height: MobileSpacing.touchTargetMin,
            child: NeumorphicButton(
              onPressed: enabled ? onPressed : null,
              padding: EdgeInsets.zero,
              color: backgroundColor,
              child: Icon(iconData, color: effectiveIconColor, size: 20),
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
                onActivate: enabled ? onPressed : null,
                child: ExcludeSemantics(child: button),
              ),
            ),
          );
        }
        return FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.m),
          padding: focusPadding,
          onActivate: enabled ? onPressed : null,
          child: button,
        );
      },
    );
  }
}
