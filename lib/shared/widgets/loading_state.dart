import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'loading/loading_story.dart';
import 'loading/shimmer_skeleton.dart';
import 'loading/step_progress.dart';

/// Loading state component with skeleton loading support
/// Features:
/// - Skeleton loading for content placeholders
/// - Standard circular progress indicator
/// - Optional message
/// - Dark mode support
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.size = 48.0,
    this.useSkeleton = false,
    this.skeletonChild,
    this.stories,
    this.steps,
    this.currentStep,
  });

  final String? message;
  final double size;
  final bool useSkeleton;
  final Widget? skeletonChild;
  final List<String>? stories;
  final List<String>? steps;
  final int? currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasSteps = steps != null && steps!.isNotEmpty && currentStep != null;
    final showStories =
        (message == null || message!.isEmpty) && (stories?.isNotEmpty ?? false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : 320.0;

        if (useSkeleton) {
          return ShimmerSkeleton(
            child: SizedBox(
              width: maxWidth,
              child: skeletonChild ?? const _DefaultSkeleton(),
            ),
          );
        }

        return SizedBox(
          width: maxWidth,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasSteps)
                  SizedBox(
                    width: maxWidth - 32.0,
                    child: StepProgress(
                      steps: steps!,
                      currentStep: currentStep!,
                    ),
                  )
                else
                  _PulsingProgressIndicator(size: size),
                if (showStories) ...[
                  const SizedBox(height: Spacing.m),
                  SizedBox(
                    width: maxWidth - 32.0,
                    child: LoadingStory(stories: stories!),
                  ),
                ] else if (message != null) ...[
                  const SizedBox(height: Spacing.m),
                  SizedBox(
                    width: maxWidth - 32.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.m,
                      ),
                      child: Text(
                        message!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingProgressIndicator extends StatefulWidget {
  const _PulsingProgressIndicator({required this.size});

  final double size;

  @override
  State<_PulsingProgressIndicator> createState() =>
      _PulsingProgressIndicatorState();
}

class _PulsingProgressIndicatorState extends State<_PulsingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Motion.pulse)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final ringAlpha = 0.14 + (0.18 * t);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.5 + (0.5 * t),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(
                      alpha: ringAlpha,
                    ),
                  ),
                ),
              ),
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DefaultSkeleton extends StatelessWidget {
  const _DefaultSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.s),
              color: surface,
            ),
          ),
          const SizedBox(height: Spacing.m),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.s),
              color: surface,
            ),
          ),
          const SizedBox(height: Spacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.s),
                color: surface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.l),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.m),
                    color: surface,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.m),
                    color: surface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
