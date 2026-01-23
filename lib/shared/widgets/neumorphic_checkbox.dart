import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/neumorphic_styles.dart';
import '../utils/contrast_utils.dart';
import 'focus_wrapper.dart';

class NeumorphicCheckbox extends StatelessWidget {
  const NeumorphicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
    this.size = 24.0,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool isEnabled;
  final Color? activeColor;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDarkMode = theme.brightness == Brightness.dark;
    final baseActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveActiveColor = ContrastUtils.getAccessibleIconColor(
      iconColor: baseActiveColor,
      backgroundColor: isDarkMode
          ? NeumorphicStyles.darkBackground
          : NeumorphicStyles.lightBackground,
      isDarkMode: isDarkMode,
    );

    final resolvedBorderRadius = BorderRadius.circular(Radii.s);
    final resolvedBackgroundColor =
        theme.cardBackgroundColor ?? theme.colorScheme.surface;
    final resolvedBorder =
        theme.switchBorder ??
        theme.inputBorder ??
        Border.all(color: theme.colorScheme.outlineVariant, width: 1);

    final checkbox = Semantics(
      toggled: value,
      enabled: isEnabled,
      label: semanticLabel,
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? () => onChanged?.call(!value) : null,
        child: FocusableActionDetector(
          enabled: isEnabled,
          mouseCursor: isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) {
                onChanged?.call(!value);
                return null;
              },
            ),
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value
                  ? effectiveActiveColor.withValues(alpha: 0.1)
                  : resolvedBackgroundColor,
              borderRadius: resolvedBorderRadius,
              border: resolvedBorder,
              boxShadow: theme.styleCardShadows,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: size * 0.7,
                    color: effectiveActiveColor,
                  )
                : null,
          ),
        ),
      ),
    );

    return FocusWrapper(
      enabled: isEnabled,
      borderRadius: BorderRadius.circular(Radii.s),
      child: checkbox,
    );
  }
}
