import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';

import '../../../models/novel.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../state/motion_settings.dart';
import '../../../shared/image_utils.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/gestures/pinch_to_zoom.dart';
import '../../../shared/widgets/theme_aware_card.dart';
import '../../reader/reader_screen.dart';

class LibraryGridItem extends ConsumerWidget {
  const LibraryGridItem({
    super.key,
    required this.novel,
    required this.isSignedIn,
    required this.canRemove,
    required this.canDownload,
    this.onRemove,
  });

  final Novel novel;
  final bool isSignedIn;
  final bool canRemove;
  final bool canDownload;
  final VoidCallback? onRemove;

  Widget _buildCover(
    BuildContext context, {
    double width = 120,
    double height = 180,
  }) {
    final validCoverUrl = ImageUtils.getFilteredCoverUrl(novel.coverUrl);

    if (validCoverUrl != null) {
      return GestureDetector(
        onLongPress: () {
          PinchToZoom.showNetworkImage(context, imageUrl: validCoverUrl);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.m),
          child: Image.network(
            validCoverUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildGradientCover(context, width: width, height: height);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.m),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return _buildGradientCover(context, width: width, height: height);
    }
  }

  Widget _buildGradientCover(
    BuildContext context, {
    double width = 120,
    double height = 180,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Generate gradient based on novel title for consistency
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
        borderRadius: BorderRadius.circular(Radii.m),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.s),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              color: Colors.white.withValues(alpha: 0.9),
              size: 32,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              novel.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      child: Text(
        'Not started',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final motion = ref.watch(motionSettingsProvider);

    return OpenContainer(
      closedElevation: 0, // Set to 0 to avoid double shadow with Card
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.m),
      ),
      closedColor: Colors.transparent, // Set to transparent
      openElevation: 8,
      openShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      openColor: theme.colorScheme.surface,
      transitionDuration: Duration(milliseconds: motion.reduceMotion ? 0 : 400),
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) {
        return Stack(
          children: [
            ThemeAwareCard(
              borderRadius: BorderRadius.circular(Radii.m),
              onTap: () {
                if (GoRouter.maybeOf(context) != null) {
                  context.push('/novel/${novel.id}');
                  return;
                }
                action();
              },
              child: Padding(
                padding: const EdgeInsets.all(Spacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image
                    Center(child: _buildCover(context)),
                    const SizedBox(height: Spacing.s),

                    // Title and author
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              novel.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (novel.author != null &&
                              novel.author!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              novel.author!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: Spacing.xs),

                    // Progress indicator
                    _buildProgressIndicator(context),
                  ],
                ),
              ),
            ),
            if (canRemove)
              Positioned(
                top: 0,
                right: 0,
                child: _GridItemMenuButton(onDelete: onRemove),
              ),
          ],
        );
      },
      openBuilder: (context, action) {
        return ReaderScreen(novelId: novel.id);
      },
    );
  }
}

class _GridItemMenuButton extends StatelessWidget {
  const _GridItemMenuButton({this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onDelete == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Builder(
      builder: (buttonContext) {
        return SizedBox(
          width: 38,
          height: 38,
          child: NeumorphicButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(Radii.m),
            depth: 6,
            onPressed: () async {
              final box = buttonContext.findRenderObject() as RenderBox;
              final overlay =
                  Overlay.of(buttonContext).context.findRenderObject()
                      as RenderBox;
              final rect = Rect.fromPoints(
                box.localToGlobal(Offset.zero, ancestor: overlay),
                box.localToGlobal(
                  box.size.bottomRight(Offset.zero),
                  ancestor: overlay,
                ),
              );

              final result = await showMenu<String>(
                context: buttonContext,
                position: RelativeRect.fromRect(
                  rect,
                  Offset.zero & overlay.size,
                ),
                items: [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.delete),
                  ),
                ],
              );

              if (result == 'delete') {
                onDelete?.call();
              }
            },
            child: const Icon(Icons.more_vert, size: 18),
          ),
        );
      },
    );
  }
}
