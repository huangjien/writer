import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AdvancedTypography {
  static TextTheme apply(TextTheme base) {
    TextStyle? s(TextStyle? style) => style;
    return base.copyWith(
      displayLarge: s(base.displayLarge)?.copyWith(
        fontSize: TypographyScale.displayLarge,
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: s(base.displayMedium)?.copyWith(
        fontSize: TypographyScale.displayMedium,
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: s(base.displaySmall)?.copyWith(
        fontSize: TypographyScale.displaySmall,
        letterSpacing: LetterSpacing.display,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: s(base.headlineLarge)?.copyWith(
        fontSize: TypographyScale.headlineLarge,
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: s(base.headlineMedium)?.copyWith(
        fontSize: TypographyScale.headlineMedium,
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: s(base.headlineSmall)?.copyWith(
        fontSize: TypographyScale.headlineSmall,
        letterSpacing: LetterSpacing.headline,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: s(base.titleLarge)?.copyWith(
        fontSize: TypographyScale.titleLarge,
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: s(base.titleMedium)?.copyWith(
        fontSize: TypographyScale.titleMedium,
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: s(base.titleSmall)?.copyWith(
        fontSize: TypographyScale.titleSmall,
        letterSpacing: LetterSpacing.title,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: s(base.bodyLarge)?.copyWith(
        fontSize: TypographyScale.bodyLarge,
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: s(base.bodyMedium)?.copyWith(
        fontSize: TypographyScale.bodyMedium,
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: s(base.bodySmall)?.copyWith(
        fontSize: TypographyScale.bodySmall,
        letterSpacing: LetterSpacing.body,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: s(base.labelLarge)?.copyWith(
        fontSize: TypographyScale.labelLarge,
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: s(base.labelMedium)?.copyWith(
        fontSize: TypographyScale.labelMedium,
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: s(base.labelSmall)?.copyWith(
        fontSize: TypographyScale.labelSmall,
        letterSpacing: LetterSpacing.label,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
