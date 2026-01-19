import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';

class NeumorphicCheckbox extends StatelessWidget {
  const NeumorphicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.activeColor,
    this.size = 24.0,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool isEnabled;
  final Color? activeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration:
            NeumorphicStyles.decoration(
              isDark: isDark,
              isPressed: true, // Concave look like the switch track
              borderRadius: BorderRadius.circular(Radii.s),
              depth: 2,
              color: value ? effectiveActiveColor.withValues(alpha: 0.1) : null,
            ).copyWith(
              border: Border.all(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
        child: value
            ? Icon(Icons.check, size: size * 0.7, color: effectiveActiveColor)
            : null,
      ),
    );
  }
}
