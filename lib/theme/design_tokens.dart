import 'package:flutter/material.dart';

/// Centralized design tokens for color, spacing, radii, and motion.
class AppColors {
  /// Brand seed color: Sepia.
  /// If you prefer a different shade, provide an alternative hex.
  static const Color sepiaSeed = Color(0xFF704214);
}

class Spacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
}

class Radii {
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
}

class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
}
