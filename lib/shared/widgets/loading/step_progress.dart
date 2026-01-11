import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.steps,
    required this.currentStep,
    this.showLabels = true,
  });

  final List<String> steps;
  final int currentStep;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = steps.isEmpty ? 1 : steps.length;
    final idx = currentStep.clamp(0, total - 1);
    final activeLabel = steps.isEmpty ? '' : steps[idx];

    final trackColor = theme.colorScheme.surfaceContainerHighest;
    final doneColor = theme.colorScheme.primary;
    final activeColor = theme.colorScheme.primaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          Text(
            'Step ${idx + 1} / $total',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (activeLabel.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              activeLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: Spacing.m),
        ],
        Row(
          children: List.generate(total, (i) {
            final isDone = i < idx;
            final isActive = i == idx;
            final color = isDone
                ? doneColor
                : isActive
                ? activeColor
                : trackColor;
            final height = isActive ? 8.0 : 6.0;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == total - 1 ? 0 : Spacing.xs,
                ),
                child: AnimatedContainer(
                  duration: Motion.medium,
                  curve: Motion.easeInOut,
                  height: height,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
