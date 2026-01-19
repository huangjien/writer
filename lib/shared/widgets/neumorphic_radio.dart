import 'package:flutter/material.dart';
import '../../theme/neumorphic_styles.dart';

class NeumorphicRadio<T> extends StatelessWidget {
  const NeumorphicRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
    this.size = 24.0,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool isEnabled;
  final Color? activeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = value == groupValue;

    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? () => onChanged?.call(value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration:
            NeumorphicStyles.decoration(
              isDark: isDark,
              isPressed: true, // Concave
              shape: BoxShape.circle,
              depth: 2,
              color: isSelected
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
        child: isSelected
            ? Center(
                child: Container(
                  width: size * 0.5,
                  height: size * 0.5,
                  decoration: BoxDecoration(
                    color: effectiveActiveColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: effectiveActiveColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
