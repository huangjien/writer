import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/neumorphic_styles.dart';
import 'focus_wrapper.dart';

class NeumorphicSwitch extends StatelessWidget {
  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const width = 56.0;
    const height = 32.0;
    const padding = 4.0;
    const thumbSize = height - (padding * 2);

    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;

    final switchWidget = Semantics(
      toggled: value,
      enabled: isEnabled,
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
            decoration:
                NeumorphicStyles.decoration(
                  isDark: isDark,
                  isPressed: true,
                  borderRadius: BorderRadius.circular(height / 2),
                  depth: 2,
                  color: value
                      ? effectiveActiveColor.withValues(alpha: 0.1)
                      : null,
                ).copyWith(
                  border: Border.all(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.7),
                    width: 1,
                  ),
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
                    decoration: NeumorphicStyles.decoration(
                      isDark: isDark,
                      isPressed: false,
                      shape: BoxShape.circle,
                      depth: 3,
                      color: value ? effectiveActiveColor : null,
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
