import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../models/novel.dart';
import 'mobile_bottom_sheet.dart';
import 'mobile_gestures.dart';
import '../image_utils.dart';

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

    return Dismissible(
      key: Key('novel_${novel.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          MobileGestures.mediumImpact();
          await MobileBottomSheet.showActionSheet(
            context: context,
            items: [
              ActionSheetItem(
                label: 'Download',
                icon: Icons.download,
                value: 'download',
                onPressed: () {
                  MobileGestures.selectionClick();
                  onDownload?.call();
                },
              ),
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
          return false;
        }
        return false;
      },
      background: _buildSwipeBackground(context, theme),
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
              // Cover image
              _buildCover(context, theme),
              const SizedBox(width: Spacing.m),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      novel.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Author
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
                    // Last read
                    if (lastRead != null)
                      Text(
                        lastRead!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    // Progress
                    if (progress > 0) ...[
                      const SizedBox(height: Spacing.s),
                      _buildProgressBar(context, theme),
                    ],
                  ],
                ),
              ),
              // Actions
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

    return ClipRRect(
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

  Widget _buildSwipeBackground(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Spacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
          const SizedBox(height: Spacing.xs),
          Text(
            'Delete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
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

/// Swipeable card wrapper for list items
class SwipeableCard extends StatelessWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActions,
    this.rightActions,
  });

  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: _getDismissDirection(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onSwipeRight != null) {
          onSwipeRight!();
          return false;
        } else if (direction == DismissDirection.endToStart &&
            onSwipeLeft != null) {
          onSwipeLeft!();
          return false;
        }
        return false;
      },
      background: leftActions != null
          ? _buildActionsBackground(context, leftActions!, true)
          : null,
      secondaryBackground: rightActions != null
          ? _buildActionsBackground(context, rightActions!, false)
          : null,
      child: child,
    );
  }

  DismissDirection _getDismissDirection() {
    if (leftActions != null && rightActions != null) {
      return DismissDirection.horizontal;
    } else if (leftActions != null) {
      return DismissDirection.startToEnd;
    } else if (rightActions != null) {
      return DismissDirection.endToStart;
    }
    return DismissDirection.none;
  }

  Widget _buildActionsBackground(
    BuildContext context,
    List<SwipeAction> actions,
    bool isLeft,
  ) {
    final theme = Theme.of(context);
    final alignment = isLeft ? Alignment.centerLeft : Alignment.centerRight;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: Spacing.l),
      decoration: BoxDecoration(
        color:
            actions.first.backgroundColor ??
            theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: actions
            .map((action) => _buildActionButton(context, action))
            .toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, SwipeAction action) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.s),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              color: action.iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              action.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: action.labelColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;
}
