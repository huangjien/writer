import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Provides theme extensions throughout the app using unified design tokens
extension AppThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  // Primary brand colors
  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;
  Color get error => AppColors.error;
  Color get success => AppColors.success;

  // Semantic colors
  Color get surface => AppColors.surface;
  Color get surfaceContainerLow => AppColors.surfaceContainerLow;
  Color get surfaceContainerHighest => AppColors.surfaceContainerHighest;

  // Card colors
  Color get cardBackground => theme.brightness == Brightness.dark
      ? AppColors.cardBackgroundDark
      : AppColors.cardBackground;

  // Input colors
  Color get inputBackground => theme.brightness == Brightness.dark
      ? AppColors.inputBackgroundDark
      : AppColors.inputBackground;

  // Text colors
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textDisabled => AppColors.textDisabled;

  // Overlay colors
  Color get progressOverlay => AppColors.progressOverlay;

  // Alpha values
  double get radiusSmall => Radii.s;
  double get radiusMedium => Radii.m;
  double get radiusLarge => Radii.l;
}
