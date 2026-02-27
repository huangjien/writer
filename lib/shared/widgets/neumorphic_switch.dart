import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:writer/theme/theme_extensions.dart';
import 'package:writer/shared/utils/contrast_utils.dart';
import 'focus_wrapper.dart';

class NeumorphicSwitch extends StatelessWidget {
  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final Color? activeColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const width = 56.0;
    const height = 32.0;
    const padding = 4.0;
    const thumbSize = height - (padding * 2);

    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        theme.switchBackgroundColor ?? theme.colorScheme.surface;
    final baseActiveColor =
        activeColor ?? theme.switchActiveColor ?? theme.colorScheme.primary;
    final effectiveActiveColor = ContrastUtils.getAccessibleTextColor(
      textColor: baseActiveColor,
      backgroundColor: backgroundColor,
      isDarkMode: isDarkMode,
    );
    final thumbColor = theme.switchThumbColor ?? theme.colorScheme.surface;

    final switchWidget = Semantics(
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
            width: width,
            height: height,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: value
                  ? effectiveActiveColor.withValues(alpha: 0.15)
                  : backgroundColor,
              borderRadius: BorderRadius.circular(height / 2),
              border: theme.switchBorder,
              boxShadow: theme.styleCardShadows,
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: value ? effectiveActiveColor : thumbColor,
                      shape: BoxShape.circle,
                      boxShadow: value
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : theme.buttonShadows,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return FocusWrapper(
      enabled: isEnabled,
      borderRadius: BorderRadius.circular(height / 2),
      child: switchWidget,
    );
  }
}
