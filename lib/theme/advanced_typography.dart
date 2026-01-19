import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AdvancedTypography {
  static TextTheme apply(TextTheme base) {
    TextStyle? s(TextStyle? style) => style;
    // We intentionally do not override fontSize with fixed scales here,
    // because that would destroy the dynamic scaling applied by ReaderTypography.
    // Instead, we only apply letter spacing and font weights to refine the look.

    return base.copyWith(
      displayLarge: s(base.displayLarge)?.copyWith(
        // fontSize: TypographyScale.displayLarge, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: s(base.displayMedium)?.copyWith(
        // fontSize: TypographyScale.displayMedium, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: s(base.displaySmall)?.copyWith(
        // fontSize: TypographyScale.displaySmall, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: s(base.headlineLarge)?.copyWith(
        // fontSize: TypographyScale.headlineLarge, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: s(base.headlineMedium)?.copyWith(
        // fontSize: TypographyScale.headlineMedium, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: s(base.headlineSmall)?.copyWith(
        // fontSize: TypographyScale.headlineSmall, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: s(base.titleLarge)?.copyWith(
        // fontSize: TypographyScale.titleLarge, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: s(base.titleMedium)?.copyWith(
        // fontSize: TypographyScale.titleMedium, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: s(base.titleSmall)?.copyWith(
        // fontSize: TypographyScale.titleSmall, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: s(base.bodyLarge)?.copyWith(
        // fontSize: TypographyScale.bodyLarge, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: s(base.bodyMedium)?.copyWith(
        // fontSize: TypographyScale.bodyMedium, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: s(base.bodySmall)?.copyWith(
        // fontSize: TypographyScale.bodySmall, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: s(base.labelLarge)?.copyWith(
        // fontSize: TypographyScale.labelLarge, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: s(base.labelMedium)?.copyWith(
        // fontSize: TypographyScale.labelMedium, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: s(base.labelSmall)?.copyWith(
        // fontSize: TypographyScale.labelSmall, // REMOVED: Breaks scaling
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
