import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../theme/neumorphic_styles.dart';
import '../utils/contrast_utils.dart';

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

    final isDarkMode = theme.brightness == Brightness.dark;
    final resolvedTextColor = ContrastUtils.getAccessibleTextColor(
      textColor:
          theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
      backgroundColor: isDarkMode
          ? NeumorphicStyles.darkBackground
          : NeumorphicStyles.lightBackground,
      isDarkMode: isDarkMode,
    );
    final resolvedIconColor = ContrastUtils.getAccessibleIconColor(
      iconColor: theme.colorScheme.onSurface,
      backgroundColor: isDarkMode
          ? NeumorphicStyles.darkBackground
          : NeumorphicStyles.lightBackground,
      isDarkMode: isDarkMode,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      decoration: BoxDecoration(
        color: theme.dropdownBackgroundColor ?? theme.colorScheme.surface,
        borderRadius:
            theme.dropdownBorderRadius ?? BorderRadius.circular(Radii.m),
        border: theme.dropdownBorder,
        boxShadow: theme.styleCardShadows,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint,
          isExpanded: isExpanded,
          icon: Icon(Icons.arrow_drop_down, color: resolvedIconColor),
          style: theme.textTheme.bodyMedium?.copyWith(color: resolvedTextColor),
          dropdownColor: theme.cardBackgroundColor ?? theme.colorScheme.surface,
          borderRadius:
              theme.dropdownBorderRadius ?? BorderRadius.circular(Radii.m),
        ),
      ),
    );
  }
}
