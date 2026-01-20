import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import '../../theme/neumorphic_styles.dart';
import '../../theme/ui_styles.dart';
import '../../theme/theme_extensions.dart';
import 'focus_wrapper.dart';

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
    final useBackdropBlur = theme.useBackdropBlur;
    final cardBlur = theme.cardBlur;
    final styleCardColor = theme.styleCardColor;
    final styleCardBorder = theme.styleCardBorder;
    final styleCardShadows = theme.styleCardShadows;
    final styleCardGradient = theme.styleCardGradient;

    Widget cardContent;

    switch (currentStyle) {
      case UiStyleFamily.glassmorphism:
        cardContent = _buildGlassCard(
          context: context,
          child: child,
          padding: resolvedPadding,
          borderRadius: resolvedRadius,
          isDark: isDark,
          cardBlur: cardBlur,
          useBackdropBlur: useBackdropBlur,
          styleCardColor: styleCardColor,
          styleCardBorder: styleCardBorder,
          styleCardShadows: styleCardShadows,
          styleCardGradient: styleCardGradient,
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
          styleCardShadows: styleCardShadows,
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
      final theme = Theme.of(context);
      final clickableCard = Semantics(
        button: true,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: FocusableActionDetector(
              mouseCursor: SystemMouseCursors.click,
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              },
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (intent) {
                    onTap?.call();
                    return null;
                  },
                ),
              },
              child: InkWell(
                onTap: onTap,
                borderRadius: resolvedRadius,
                splashColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                hoverColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: margin ?? EdgeInsets.zero,
                  child: cardContent,
                ),
              ),
            ),
          ),
        ),
      );

      return FocusWrapper(
        enabled: true,
        borderRadius: resolvedRadius,
        child: clickableCard,
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
    required double cardBlur,
    required bool useBackdropBlur,
    Color? styleCardColor,
    Border? styleCardBorder,
    List<BoxShadow>? styleCardShadows,
    LinearGradient? styleCardGradient,
  }) {
    final surfaceColor =
        styleCardColor ??
        (isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight);
    final borderColor =
        styleCardBorder ??
        Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
        );

    final decoration = BoxDecoration(
      color: styleCardGradient != null ? null : surfaceColor,
      gradient: styleCardGradient,
      borderRadius: borderRadius,
      border: borderColor,
      boxShadow: styleCardShadows,
    );

    final card = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (useBackdropBlur) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: cardBlur, sigmaY: cardBlur),
          child: card,
        ),
      );
    }

    return ClipRRect(borderRadius: borderRadius, child: card);
  }

  Widget _buildNeumorphicCard({
    required BuildContext context,
    required Widget child,
    required EdgeInsetsGeometry padding,
    required BorderRadius borderRadius,
    required bool isDark,
    required double elevation,
    List<BoxShadow>? styleCardShadows,
  }) {
    final decoration = NeumorphicStyles.decoration(
      isDark: isDark,
      borderRadius: borderRadius,
      depth: elevation * 4,
    );

    final boxDecoration = styleCardShadows != null
        ? BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: borderRadius,
            boxShadow: styleCardShadows,
          )
        : decoration;

    return Container(padding: padding, decoration: boxDecoration, child: child);
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
