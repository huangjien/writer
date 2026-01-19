import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';

class NeumorphicTextField extends StatelessWidget {
  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration:
          NeumorphicStyles.decoration(
            isDark: isDark,
            isPressed: true, // Concave
            borderRadius: BorderRadius.circular(Radii.m),
            depth:
                4, // Positive depth for inner shadow effect simulation if handled by style, or just rely on isPressed
          ).copyWith(
            border: Border.all(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        enabled: enabled,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.m,
          ),
        ),
      ),
    );
  }
}
