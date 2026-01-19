import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/neumorphic_slider.dart';

/// Enhanced reading progress bar with time display
/// Features:
/// - Interactive seek slider
/// - Time display (current/total)
/// - Smooth animations
/// - Dark mode support
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    super.key,
    required this.progress,
    required this.onSeek,
    this.showTime = false,
    this.currentTime,
    this.totalTime,
  });

  final double progress; // 0.0 to 1.0
  final ValueChanged<double> onSeek;
  final bool showTime;
  final Duration? currentTime;
  final Duration? totalTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: NeumorphicSlider(value: progress, onChanged: onSeek),
        ),
        // Time display
        if (showTime && currentTime != null && totalTime != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentTime!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDuration(totalTime!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
