import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/shared/utils/contrast_utils.dart';
import 'focus_wrapper.dart';

class NeumorphicRadio<T> extends StatelessWidget {
  const NeumorphicRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
    this.size = 24.0,
    this.semanticLabel,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool isEnabled;
  final Color? activeColor;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    final isDarkMode = theme.brightness == Brightness.dark;
    final resolvedBackgroundColor =
        theme.cardBackgroundColor ?? theme.colorScheme.surface;
    final baseActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveActiveColor = ContrastUtils.getAccessibleIconColor(
      iconColor: baseActiveColor,
      backgroundColor: resolvedBackgroundColor,
      isDarkMode: isDarkMode,
    );

    final resolvedBorder =
        theme.switchBorder ??
        theme.inputBorder ??
        Border.all(color: theme.colorScheme.outlineVariant, width: 1);

    final radio = Semantics(
      selected: isSelected,
      enabled: isEnabled,
      button: true,
      label: semanticLabel,
      onTap: isEnabled ? () => onChanged?.call(value) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isEnabled ? () => onChanged?.call(value) : null,
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
                onChanged?.call(value);
                return null;
              },
            ),
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected
                  ? effectiveActiveColor.withValues(alpha: 0.15)
                  : resolvedBackgroundColor,
              shape: BoxShape.circle,
              border: resolvedBorder,
              boxShadow: theme.styleCardShadows,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: size * 0.5,
                      height: size * 0.5,
                      decoration: BoxDecoration(
                        color: effectiveActiveColor,
                        shape: BoxShape.circle,
                        boxShadow: theme.buttonShadows,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );

    return FocusWrapper(
      enabled: isEnabled,
      borderRadius: BorderRadius.circular(Radii.s),
      child: radio,
    );
  }
}
