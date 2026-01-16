import 'package:flutter/material.dart';
import '../../theme/neumorphic_styles.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor = useNeumorphicColor
        ? (isDark
              ? NeumorphicStyles.darkBackground
              : NeumorphicStyles.lightBackground)
        : null; // Use default from style

    final effectiveStyle = (style ?? theme.textTheme.bodyMedium!).copyWith(
      color: effectiveColor,
      shadows: NeumorphicStyles.textShadows(isDark: isDark, depth: depth),
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
