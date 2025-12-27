import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../theme/design_tokens.dart';

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
  });

  final String? message;
  final double size;
  final bool useSkeleton;
  final Widget? skeletonChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (useSkeleton && skeletonChild != null) {
      return _SkeletonLoader(child: skeletonChild!);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: Spacing.m),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        duration: const Duration(milliseconds: 1500),
      ),
      child: child,
    );
  }
}
