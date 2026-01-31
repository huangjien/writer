import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';
import '../theme/design_tokens.dart';

/// Unified button system using design tokens
class AppButtons {
  static Widget primary(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isEnabled = true,
  }) {
    final theme = context.theme;
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon) : null,
      label: Text(label, style: theme.textTheme.labelLarge),
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static Widget secondary(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon) : null,
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }

  static Widget text(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isEnabled = true,
  }) {
    return TextButton.icon(
      icon: icon != null ? Icon(icon) : null,
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      onPressed: isEnabled ? onPressed : null,
    );
  }
}
