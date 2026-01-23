import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

class NeumorphicText extends StatelessWidget {
  const NeumorphicText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.depth = 1.5,
    this.useNeumorphicColor = false,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double depth;

  /// If true, uses the background color for the text, making it look extruded.
  /// If false (default), uses the style's color or theme's text color.
  final bool useNeumorphicColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor = useNeumorphicColor
        ? (theme.cardBackgroundColor ??
              theme.buttonBackgroundColor ??
              theme.colorScheme.surface)
        : null; // Use default from style

    final effectiveDepth = depth <= 0 ? 0 : depth;
    final textShadows =
        theme.styleCardShadows
            ?.map(
              (s) => Shadow(
                color: s.color,
                blurRadius: s.blurRadius * effectiveDepth,
                offset: s.offset,
              ),
            )
            .toList(growable: false) ??
        const <Shadow>[];

    final effectiveStyle = (style ?? theme.textTheme.bodyMedium!).copyWith(
      color: effectiveColor,
      shadows: textShadows,
    );

    return Text(
      data,
      style: effectiveStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
