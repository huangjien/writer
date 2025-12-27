import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/novel.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/enhanced_card.dart';

/// Enhanced novel card for grid view
/// Features:
/// - Cover image with loading states
/// - Progress indicator overlay
/// - Action buttons (download, continue, remove)
/// - Hover effects
class EnhancedNovelCard extends ConsumerWidget {
  const EnhancedNovelCard({
    super.key,
    required this.novel,
    this.onTap = _defaultTap,
    this.onDownload = _defaultDownload,
    this.onContinue = _defaultContinue,
    this.onRemove = _defaultRemove,
    this.progress,
    this.isDownloading = false,
  });

  static VoidCallback _defaultTap() => () {};
  static VoidCallback _defaultDownload() => () {};
  static VoidCallback _defaultContinue() => () {};
  static VoidCallback _defaultRemove() => () {};

  final Novel novel;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onContinue;
  final VoidCallback onRemove;
  final double? progress;
  final bool isDownloading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return EnhancedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          AspectRatio(
            aspectRatio: 0.7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCover(context),
                if (progress != null && progress! > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildProgressBar(context),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(Spacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  novel.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                // Author
                if (novel.author != null)
                  Text(
                    novel.author!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: Spacing.s),
                // Action buttons
                Row(
                  children: [
                    _ActionButton(
                      icon: isDownloading ? null : Icons.download,
                      isLoading: isDownloading,
                      onPressed: onDownload,
                      tooltip: 'Download chapters',
                    ),
                    if (progress != null && progress! > 0)
                      _ActionButton(
                        icon: Icons.play_arrow,
                        label: 'Continue',
                        onPressed: onContinue,
                        tooltip: 'Continue reading',
                      ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      color: theme.colorScheme.error,
                      onPressed: onRemove,
                      tooltip: 'Remove from library',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (novel.coverUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.l),
        ),
        child: Image.network(
          novel.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder(context, isLoading: true);
          },
        ),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context, {bool isLoading = false}) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.l),
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Icon(
                Icons.menu_book,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.s),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          minHeight: 4,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.icon,
    this.label,
    this.isLoading = false,
    this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData? icon;
  final String? label;
  final bool isLoading;
  final Color? color;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon != null
            ? Icon(icon, color: buttonColor)
            : Text(label ?? '', style: TextStyle(color: buttonColor)),
        onPressed: onPressed,
        style: IconButton.styleFrom(padding: const EdgeInsets.all(Spacing.s)),
      ),
    );
  }
}
