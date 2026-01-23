import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../models/novel.dart';
import 'mobile_bottom_sheet.dart';
import 'mobile_gestures.dart';
import '../image_utils.dart';
import 'neumorphic_button.dart';
import 'gestures/swipe_actions.dart';
import 'gestures/pinch_to_zoom.dart';
import 'cover_placeholder.dart';
import 'progress_ring.dart';
import 'tag_pill.dart';
import 'focus_wrapper.dart';

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
    final title = novel.title;
    final author = novel.author;
    final percent = (progress * 100).round().clamp(0, 100);
    final labelParts = <String>[
      title,
      if (author != null && author.isNotEmpty) 'by $author',
      if (progress > 0) '$percent% read',
    ];
    final semanticsLabel = labelParts.join(', ');
    final semanticsActions = <CustomSemanticsAction, VoidCallback>{};
    if (onFavorite != null) {
      semanticsActions[CustomSemanticsAction(
        label: isFavorite ? 'Unfavorite' : 'Favorite',
      )] = () =>
          onFavorite?.call();
    }
    if (onDownload != null) {
      semanticsActions[const CustomSemanticsAction(label: 'Download')] = () =>
          onDownload?.call();
    }
    if (onDelete != null) {
      semanticsActions[const CustomSemanticsAction(label: 'Delete')] = () =>
          onDelete?.call();
    }
    semanticsActions[const CustomSemanticsAction(label: 'More actions')] = () =>
        _showActionMenu(context);

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

    return Semantics(
      container: true,
      button: true,
      label: semanticsLabel,
      hint: 'Double tap to open. Long press for actions.',
      customSemanticsActions: semanticsActions,
      child: SwipeActions(
        endActions: endActions,
        child: FocusWrapper(
          borderRadius: BorderRadius.circular(Radii.l),
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
                color: theme.cardBackgroundColor ?? theme.cardColor,
                borderRadius: BorderRadius.circular(Radii.l),
                boxShadow: theme.styleCardShadows,
                border: theme.styleCardBorder,
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
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Spacing.xs),
                        if (author != null && author.isNotEmpty)
                          Text(
                            author,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: Spacing.xs),
                        Wrap(
                          spacing: Spacing.xs,
                          runSpacing: Spacing.xs,
                          children: [
                            TagPill(
                              label: novel.languageCode.toUpperCase(),
                              icon: Icons.language,
                            ),
                            TagPill(
                              label: novel.isPublic ? 'Public' : 'Private',
                              icon: novel.isPublic
                                  ? Icons.public
                                  : Icons.lock_outline,
                            ),
                          ],
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
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, ThemeData theme) {
    const width = 48.0;
    const height = 64.0;
    final validCoverUrl = ImageUtils.getFilteredCoverUrl(novel.coverUrl);

    if (validCoverUrl == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            CoverPlaceholder(
              seed: novel.title.hashCode,
              borderRadius: BorderRadius.circular(Radii.s),
            ),
            if (progress > 0)
              Positioned(
                right: 4,
                bottom: 4,
                child: ProgressRing(
                  value: progress,
                  size: 18,
                  strokeWidth: 2.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  foregroundColor: Colors.white.withValues(alpha: 0.95),
                ),
              ),
          ],
        ),
      );
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
              BlurUpNetworkImage(
                imageUrl: validCoverUrl,
                placeholderSeed: novel.title.hashCode,
                width: width,
                height: height,
              ),
              if (progress > 0)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: ProgressRing(
                    value: progress,
                    size: 18,
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
            ],
          ),
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
          Tooltip(
            message: isFavorite ? 'Unfavorite' : 'Favorite',
            child: Semantics(
              button: true,
              label: isFavorite ? 'Unfavorite' : 'Favorite',
              child: FocusWrapper(
                borderRadius: BorderRadius.circular(Radii.m),
                child: SizedBox(
                  width: MobileSpacing.touchTargetMin,
                  height: MobileSpacing.touchTargetMin,
                  child: NeumorphicButton(
                    onPressed: () {
                      MobileGestures.toggleImpact();
                      onFavorite?.call();
                    },
                    padding: EdgeInsets.zero,
                    depth: 4,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? theme.colorScheme.error : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Tooltip(
          message: 'More',
          child: Semantics(
            button: true,
            label: 'More actions',
            child: FocusWrapper(
              borderRadius: BorderRadius.circular(Radii.m),
              child: SizedBox(
                width: MobileSpacing.touchTargetMin,
                height: MobileSpacing.touchTargetMin,
                child: NeumorphicButton(
                  key: ValueKey('more_actions_${novel.id}'),
                  onPressed: () {
                    MobileGestures.lightImpact();
                    _showActionMenu(context);
                  },
                  padding: EdgeInsets.zero,
                  depth: 4,
                  child: const Icon(Icons.more_vert),
                ),
              ),
            ),
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
