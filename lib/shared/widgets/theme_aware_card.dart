import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';
import '../../theme/ui_styles.dart';
import '../../theme/theme_extensions.dart';

class ThemeAwareCard extends StatelessWidget {
  const ThemeAwareCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.semanticType,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final CardSemanticType? semanticType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedElevation = elevation ?? cardTheme.elevation ?? 0;
    final resolvedRadius =
        borderRadius ??
        _getBorderRadiusFromShape(cardTheme.shape) ??
        BorderRadius.circular(12);
    final resolvedPadding =
        padding ?? const EdgeInsets.all(Spacing.cardPadding);

    final currentStyle = theme.uiStyleFamily;

    Widget cardContent;

    switch (currentStyle) {
      case UiStyleFamily.glassmorphism:
        cardContent = _buildGlassCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          isDark: isDark,
        );
        break;

      case UiStyleFamily.neumorphism:
        cardContent = _buildNeumorphicCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          isDark: isDark,
          elevation: resolvedElevation,
        );
        break;

      case UiStyleFamily.minimalism:
        cardContent = _buildMinimalCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
        );
        break;

      case UiStyleFamily.brutalism:
        cardContent = _buildBrutalistCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          isDark: isDark,
        );
        break;

      case UiStyleFamily.claymorphism:
        cardContent = _buildClaymorphicCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          isDark: isDark,
          elevation: resolvedElevation,
        );
        break;

      case UiStyleFamily.skeuomorphism:
        cardContent = _buildStandardCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          elevation: resolvedElevation,
          isDark: isDark,
        );
        break;

      case UiStyleFamily.bentoGrid:
        cardContent = _buildBentoGridCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          isDark: isDark,
          elevation: resolvedElevation,
        );
        break;

      case UiStyleFamily.responsive:
        cardContent = _buildStandardCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          elevation: resolvedElevation,
          isDark: isDark,
        );
        break;

      case UiStyleFamily.flatDesign:
        cardContent = _buildFlatCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
        );
        break;
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius,
          child: Padding(
            padding: margin ?? EdgeInsets.zero,
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? cardTheme.margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }

  BorderRadius? _getBorderRadiusFromShape(ShapeBorder? shape) {
    if (shape == null) return null;

    if (shape is RoundedRectangleBorder) {
      final geometry = shape.borderRadius;
      if (geometry is BorderRadius) {
        return geometry;
      }
      return BorderRadius.zero;
    }

    return null;
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassTokens.blur,
          sigmaY: GlassTokens.blur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassSurfaceDark
                : AppColors.glassSurfaceLight,
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeumorphicCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required bool isDark,
    required double elevation,
  }) {
    final decoration = NeumorphicStyles.decoration(
      isDark: isDark,
      borderRadius: borderRadius,
      depth: elevation * 4,
    );

    return Container(padding: padding, decoration: decoration, child: child);
  }

  Widget _buildMinimalCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildBrutalistCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black87,
          width: 2,
        ),
      ),
      child: child,
    );
  }

  Widget _buildStandardCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required double elevation,
    required bool isDark,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.shadowColor.withValues(alpha: 0.3)
                : AppColors.shadowColor,
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildClaymorphicCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required bool isDark,
    required double elevation,
  }) {
    final theme = Theme.of(context);
    final neumorphicDecoration = NeumorphicStyles.decoration(
      isDark: isDark,
      borderRadius: borderRadius,
      depth: elevation * 5,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? theme.cardColor.withValues(alpha: 0.9) : theme.cardColor,
            isDark
                ? theme.cardColor.withValues(alpha: 0.7)
                : theme.cardColor.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: borderRadius,
        boxShadow: neumorphicDecoration.boxShadow,
      ),
      child: child,
    );
  }

  Widget _buildBentoGridCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required bool isDark,
    required double elevation,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassSurfaceDark
                : AppColors.glassSurfaceLight,
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: elevation * 3,
                offset: Offset(0, elevation),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFlatCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

enum CardSemanticType { default_, primary, success, warning, error, info }
