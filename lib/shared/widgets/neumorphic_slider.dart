import 'package:flutter/material.dart';
import '../../theme/neumorphic_styles.dart';

class NeumorphicSlider extends StatelessWidget {
  const NeumorphicSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.thumbColor,
    this.activeTrackColor,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final Color? thumbColor;
  final Color? activeTrackColor;

  void _updateValue(Offset localPosition, double width, double thumbSize) {
    if (onChanged == null) return;

    final double workableWidth = width - thumbSize;
    // Adjust touch to center of thumb
    double dx = localPosition.dx - (thumbSize / 2);
    dx = dx.clamp(0.0, workableWidth);

    final double percent = dx / workableWidth;
    final double newValue = min + (max - min) * percent;

    if (newValue != value) {
      onChanged!(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Ensure we have a finite width
        if (width.isInfinite) {
          return const SizedBox(height: 32);
        }

        const height = 32.0;
        const thumbSize = 24.0;
        const trackHeight = 8.0;

        final double safeValue = value.clamp(min, max);
        final double percent = (max == min)
            ? 0.0
            : (safeValue - min) / (max - min);
        final double workableWidth = width - thumbSize;
        final double thumbLeft = workableWidth * percent;

        return GestureDetector(
          onPanUpdate: (details) =>
              _updateValue(details.localPosition, width, thumbSize),
          onPanDown: (details) =>
              _updateValue(details.localPosition, width, thumbSize),
          child: Container(
            width: width,
            height: height,
            color: Colors.transparent, // Hit test target
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track Background (Concave)
                Container(
                  width: width,
                  height: trackHeight,
                  decoration: NeumorphicStyles.decoration(
                    isDark: isDark,
                    isPressed: true,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                    depth: 2,
                  ),
                ),
                // Active Track (Optional)
                if (activeTrackColor != null)
                  Container(
                    width: thumbLeft + (thumbSize / 2),
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: activeTrackColor,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),
                // Thumb
                Positioned(
                  left: thumbLeft,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: NeumorphicStyles.decoration(
                      isDark: isDark,
                      shape: BoxShape.circle,
                      depth: 4,
                      color: thumbColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
