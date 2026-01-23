import 'package:flutter/material.dart';
import '../../../models/chapter.dart';
import '../../../theme/design_tokens.dart';

/// Enhanced chapter list item with progress indicator
/// Features:
/// - Chapter number badge
/// - Progress bar for reading progress
/// - Status icons (current, read)
/// - Active state highlighting
class EnhancedChapterListItem extends StatelessWidget {
  const EnhancedChapterListItem({
    super.key,
    required this.chapter,
    required this.onTap,
    this.isCurrent = false,
    this.isRead = false,
    this.progress = 0.0,
  });

  final Chapter chapter;
  final VoidCallback onTap;
  final bool isCurrent;
  final bool isRead;
  final double progress; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = chapter.title?.trim();
    final displayTitle = (titleText == null || titleText.isEmpty)
        ? 'Chapter ${chapter.idx}'
        : 'Chapter ${chapter.idx}: $titleText';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: theme.colorScheme.surfaceContainerHighest,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          decoration: BoxDecoration(
            color: isCurrent ? theme.colorScheme.primaryContainer : null,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Chapter number badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chapter.idx}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.m),
              // Chapter title and progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (progress > 0 && progress < 1.0) ...[
                      const SizedBox(height: Spacing.xs),
                      Container(
                        height: 10,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(Radii.s),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  Radii.s - 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status icon
              if (isRead)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                )
              else if (isCurrent)
                Icon(
                  Icons.play_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
