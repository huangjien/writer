import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/ui_styles.dart';
import '../utils/contrast_utils.dart';
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
  /// Returns a high-contrast text color for neumorphic buttons in dark mode
  /// that meets WCAG AA standards (4.5:1 ratio) while maintaining the primary hue
  static Color _getAccessiblePrimaryTextColor(
    BuildContext context,
    Color primaryColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;

    if (!isDark) {
      return primaryColor;
    }

    final primaryLuminance = primaryColor.computeLuminance();
    final surfaceLuminance = surface.computeLuminance();

    final contrastRatio = (primaryLuminance + 0.05) / (surfaceLuminance + 0.05);

    if (contrastRatio >= 4.5) {
      return primaryColor;
    }

    final hsl = HSLColor.fromColor(primaryColor);
    final highContrastColor = hsl
        .withLightness(isDark ? 0.85 : 0.15)
        .withSaturation(hsl.saturation * 0.8)
        .toColor();

    return highContrastColor;
  }

  /// Returns a high-contrast icon color based on the actual button background color
  static Color _getAccessibleIconColor(
    BuildContext context,
    Color iconColor,
    Color? backgroundColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actualButtonBackground =
        backgroundColor ??
        theme.buttonBackgroundColor ??
        theme.colorScheme.surface;

    return ContrastUtils.getAccessibleIconColor(
      iconColor: iconColor,
      backgroundColor: actualButtonBackground,
      isDarkMode: isDark,
    );
  }

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
        final accessibleTextColor = _getAccessiblePrimaryTextColor(
          context,
          primaryColor,
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
        final accessibleTextColor = _getAccessiblePrimaryTextColor(
          context,
          theme.colorScheme.primary,
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
        final defaultTextColor = _getAccessiblePrimaryTextColor(
          context,
          theme.colorScheme.primary,
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
                style: TextStyle(color: color ?? defaultTextColor),
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
        final buttonBackground = theme.buttonBackgroundColor;
        final effectiveColor =
            color ??
            _getAccessibleIconColor(context, primaryColor, buttonBackground);

        // For Flat Design style with primary background, use onPrimary for better contrast
        final finalIconColor =
            (theme.uiStyleFamily == UiStyleFamily.flatDesign && color == null)
            ? theme.colorScheme.onPrimary
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
        final buttonBackground = backgroundColor ?? theme.buttonBackgroundColor;
        final effectiveIconColor =
            iconColor ??
            _getAccessibleIconColor(context, primaryColor, buttonBackground);

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
