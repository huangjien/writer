import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';

class NeumorphicDropdown<T> extends StatelessWidget {
  const NeumorphicDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.isExpanded = false,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Widget? hint;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      decoration: NeumorphicStyles.decoration(
        isDark: isDark,
        borderRadius: BorderRadius.circular(Radii.m),
        isPressed: false, // Convex
        depth: 4,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint,
          isExpanded: isExpanded,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
          style: theme.textTheme.bodyMedium,
          dropdownColor: isDark
              ? NeumorphicStyles.darkBackground
              : NeumorphicStyles.lightBackground,
          borderRadius: BorderRadius.circular(Radii.m),
        ),
      ),
    );
  }
}
