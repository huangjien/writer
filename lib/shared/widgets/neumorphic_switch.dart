import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';

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

    // Track dimensions
    const width = 56.0;
    const height = 32.0;
    const padding = 4.0;
    const thumbSize = height - (padding * 2);

    final effectiveActiveColor = activeColor ?? AppColors.success;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged?.call(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: const EdgeInsets.all(padding),
        decoration:
            NeumorphicStyles.decoration(
              isDark: isDark,
              isPressed: true, // Concave track
              borderRadius: BorderRadius.circular(height / 2),
              depth: 2, // Shallower depth for switch track
              color: value ? effectiveActiveColor.withValues(alpha: 0.1) : null,
            ).copyWith(
              // Ensure we have a border for definition
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
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: NeumorphicStyles.decoration(
                  isDark: isDark,
                  isPressed: false, // Convex thumb
                  shape: BoxShape.circle,
                  depth: 3,
                  color: value ? effectiveActiveColor : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
