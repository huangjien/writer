import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../models/novel.dart';
import 'mobile_bottom_sheet.dart';
import 'mobile_gestures.dart';
import '../image_utils.dart';
import 'gestures/swipe_actions.dart';
import 'gestures/pinch_to_zoom.dart';

/// Mobile-optimized novel card
/// Features:
/// - Horizontal layout for better readability
/// - Compact cover image
/// - Progress indicator
/// - Quick action buttons
/// - Swipe actions support
class MobileNovelCard extends StatelessWidget {
  const MobileNovelCard({
    super.key,
    required this.novel,
    this.onTap,
    this.onLongPress,
    this.onDownload,
    this.onDelete,
    this.onFavorite,
    this.isFavorite = false,
    this.progress = 0.0,
    this.lastRead,
    this.showActions = true,
  });

  final Novel novel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final double progress;
  final String? lastRead;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final endActions = <SwipeActionItem>[
      if (onFavorite != null)
        SwipeActionItem(
          label: isFavorite ? 'Unfavorite' : 'Favorite',
          icon: isFavorite ? Icons.favorite_border : Icons.favorite,
          onExecute: () async => onFavorite?.call(),
          undoMessage: isFavorite
              ? 'Removed from favorites'
              : 'Added to favorites',
          onUndo: () => onFavorite?.call(),
        ),
      if (onDownload != null)
        SwipeActionItem(
          label: 'Download',
          icon: Icons.download,
          onExecute: () async => onDownload?.call(),
        ),
      if (onDelete != null)
        SwipeActionItem(
          label: 'Delete',
          icon: Icons.delete,
          isDestructive: true,
          onExecute: () async => onDelete?.call(),
        ),
    ];

    return SwipeActions(
      endActions: endActions,
      child: InkWell(
        onTap: () {
          MobileGestures.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          MobileGestures.mediumImpact();
          if (onLongPress != null) {
            onLongPress?.call();
          } else {
            _showActionMenu(context);
          }
        },
        borderRadius: BorderRadius.circular(Radii.l),
        child: Container(
          padding: const EdgeInsets.all(MobileSpacing.cardPaddingMobile),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Radii.l),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildCover(context, theme),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (novel.author != null && novel.author!.isNotEmpty)
                      Text(
                        novel.author!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: Spacing.xs),
                    if (lastRead != null)
                      Text(
                        lastRead!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (progress > 0) ...[
                      const SizedBox(height: Spacing.s),
                      _buildProgressBar(context, theme),
                    ],
                  ],
                ),
              ),
              if (showActions) _buildActions(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, ThemeData theme) {
    const width = 48.0;
    const height = 64.0;
    final validCoverUrl = ImageUtils.getFilteredCoverUrl(novel.coverUrl);

    if (validCoverUrl == null) {
      return _buildGradientCover(context, width: width, height: height);
    }

    return GestureDetector(
      onLongPress: () {
        PinchToZoom.showNetworkImage(context, imageUrl: validCoverUrl);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.s),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildGradientCover(context, width: width, height: height),
              Image.network(
                validCoverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      child,
                      const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCover(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    final titleHash = novel.title.hashCode;
    final hue = (titleHash % 360).abs();
    final gradientColors = [
      HSLColor.fromAHSL(0.8, hue.toDouble(), 0.7, 0.6).toColor(),
      HSLColor.fromAHSL(0.9, (hue + 60) % 360.0, 0.8, 0.5).toColor(),
    ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.s),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        if (onFavorite != null)
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? theme.colorScheme.error : null,
            ),
            onPressed: () {
              MobileGestures.toggleImpact();
              onFavorite?.call();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: MobileSpacing.touchTargetMin,
              minHeight: MobileSpacing.touchTargetMin,
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            MobileGestures.lightImpact();
            _showActionMenu(context);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: MobileSpacing.touchTargetMin,
            minHeight: MobileSpacing.touchTargetMin,
          ),
        ),
      ],
    );
  }

  void _showActionMenu(BuildContext context) {
    MobileGestures.lightImpact();
    MobileBottomSheet.showActionSheet(
      context: context,
      items: [
        if (onDownload != null)
          ActionSheetItem(
            label: 'Download',
            icon: Icons.download,
            value: 'download',
            onPressed: () {
              MobileGestures.selectionClick();
              onDownload?.call();
            },
          ),
        if (onFavorite != null)
          ActionSheetItem(
            label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            icon: isFavorite ? Icons.favorite_border : Icons.favorite,
            value: 'favorite',
            onPressed: () {
              MobileGestures.toggleImpact();
              onFavorite?.call();
            },
          ),
        if (onDelete != null)
          ActionSheetItem(
            label: 'Delete',
            icon: Icons.delete,
            value: 'delete',
            isDestructive: true,
            onPressed: () {
              MobileGestures.heavyImpact();
              onDelete?.call();
            },
          ),
      ],
    );
  }
}
