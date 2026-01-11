import 'package:flutter/material.dart';

// ignore_for_file: use_full_hex_values_for_flutter_colors, always_use_full_hex_values_for_flutter_colors

/// Centralized design tokens for color, spacing, radii, and motion.
class AppColors {
  /// Brand seed color: Sepia.
  /// If you prefer a different shade, provide an alternative hex.
  static const Color sepiaSeed = Color(0xFF704214);

  /// Subtle surface tints for premium feel
  static const Color surfaceTint = Color(0xFFF8F5F2);
  static const Color surfaceTintDark = Color(0xFF1A1A1A);

  /// Soft elevation colors (colored shadows/glows)
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0D704214);

  /// Semantic colors for better UX
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1976D2);

  /// Card colors for light and dark themes
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  /// Elevation colors for depth
  static const Color elevation1 = Color(0xFF0D000000);
  static const Color elevation2 = Color(0xFF140000000);
  static const Color elevation3 = Color(0xFF1F000000);

  /// Accent colors for different states
  static const Color download = Color(0xFF00BCD4);
  static const Color reading = Color(0xFF9C27B0);
  static const Color completed = Color(0xFF4CAF50);

  static const Color glassSurfaceLight = Color(0xCCFFFFFF);
  static const Color glassSurfaceDark = Color(0xB31F1F1F);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x26FFFFFF);
}

class GlassTokens {
  static const double blur = 18.0;
  static const double shadowBlurRadius = 24.0;
  static const double shadowOpacity = 0.12;
}

class Spacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double section = 64.0;
  static const double page = 96.0;

  // Component-specific spacing
  static const double cardPadding = 16.0;
  static const double listItemPadding = 12.0;
  static const double buttonPadding = 12.0;
}

class Radii {
  static const double s = 12.0;
  static const double m = 20.0;
  static const double l = 28.0;
  static const double xl = 36.0;
}

/// Mobile-specific spacing tokens
class MobileSpacing {
  // Safe area insets
  static const double safeAreaTop = 44.0; // Status bar + notch
  static const double safeAreaBottom = 34.0; // Home indicator

  // Touch targets
  static const double touchTargetMin = 48.0;
  static const double touchTargetComfortable = 56.0;

  // Bottom navigation
  static const double bottomNavHeight = 56.0;
  static const double fabMargin = 16.0;

  // Card spacing
  static const double cardPaddingMobile = 12.0;
  static const double cardGapMobile = 8.0;
}

/// Mobile-specific typography tokens
class MobileTypography {
  // Larger base sizes for readability
  static const double bodyLargeMobile = 16.0;
  static const double bodyMediumMobile = 14.0;
  static const double bodySmallMobile = 12.0;

  // Condensed headings for small screens
  static const double headingCondensed = 18.0;
  static const double titleCondensed = 16.0;
}

class TypographyScale {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;

  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;

  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;

  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
}

class LetterSpacing {
  static const double tight = -0.2;
  static const double normal = 0.0;
  static const double relaxed = 0.2;

  static const double display = -0.6;
  static const double headline = -0.3;
  static const double title = -0.1;
  static const double body = 0.0;
  static const double label = 0.1;
}

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 0; // < 600dp
  static const double tablet = 600; // 600-840dp
  static const double desktop = 840; // > 840dp

  // Mobile-specific breakpoints
  static const double mobileSmall = 360; // Small phones
  static const double mobileMedium = 390; // Medium phones
  static const double mobileLarge = 414; // Large phones
}

class Motion {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration extraSlow = Duration(milliseconds: 600);

  // Curves for different interactions
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve elasticOut = Curves.elasticOut;

  // Spring animations
  static const Curve springFast = Curves.fastOutSlowIn;
  static const Curve springMedium = Cubic(0.4, 0.0, 0.2, 1.0);
}

/// Mobile-specific motion tokens
class MobileMotion {
  // Faster transitions for mobile
  static const Duration bottomSheetEnter = Duration(milliseconds: 250);
  static const Duration bottomSheetExit = Duration(milliseconds: 200);

  // Swipe animation
  static const Duration swipeReveal = Duration(milliseconds: 200);
  static const Duration swipeSnap = Duration(milliseconds: 300);

  // FAB animation
  static const Duration fabExpand = Duration(milliseconds: 200);
  static const Duration fabCollapse = Duration(milliseconds: 150);
}

class FocusTokens {
  static const double borderWidth = 2.0;
  static const double glowOpacity = 0.28;
  static const double glowBlurRadius = 10.0;
  static const Duration duration = Motion.fast;
}
