import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
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
    final dropdownBackgroundColor =
        theme.dropdownBackgroundColor ?? theme.colorScheme.surface;
    final dropdownMenuBackgroundColor =
        theme.dropdownMenuBackgroundColor ??
        theme.cardBackgroundColor ??
        theme.colorScheme.surface;

    final resolvedTextColor = ContrastUtils.getAccessibleTextColor(
      textColor:
          theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface,
      backgroundColor: dropdownMenuBackgroundColor,
      isDarkMode: isDarkMode,
    );
    final resolvedIconColor = ContrastUtils.getAccessibleIconColor(
      iconColor: theme.colorScheme.onSurface,
      backgroundColor: dropdownBackgroundColor,
      isDarkMode: isDarkMode,
    );

    final dropdownTheme = ThemeData(
      useMaterial3: true,
      cardColor: dropdownMenuBackgroundColor,
      highlightColor: theme.dropdownMenuSelectedColor,
      hoverColor: theme.dropdownMenuHoverColor,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
      decoration: BoxDecoration(
        color: dropdownBackgroundColor,
        borderRadius:
            theme.dropdownBorderRadius ?? BorderRadius.circular(Radii.m),
        border: theme.dropdownBorder,
        boxShadow: theme.styleCardShadows,
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          data: dropdownTheme,
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            hint: hint,
            isExpanded: isExpanded,
            icon: Icon(Icons.arrow_drop_down, color: resolvedIconColor),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: resolvedTextColor,
            ),
            dropdownColor: dropdownMenuBackgroundColor,
            borderRadius:
                theme.dropdownBorderRadius ?? BorderRadius.circular(Radii.m),
          ),
        ),
      ),
    );
  }
}
