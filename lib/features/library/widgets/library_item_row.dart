import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import '../../../theme/design_tokens.dart';
import '../../../state/motion_settings.dart';
import '../../../state/novel_providers.dart';
import '../../../state/progress_providers.dart';
import '../../../shared/image_utils.dart';
import '../../../repositories/chapter_repository.dart';
import '../../../models/chapter.dart';
import '../../../models/user_progress.dart';
import '../../library/library_providers.dart';
import '../../../shared/widgets/app_buttons.dart';

class _DownloadIntent extends Intent {
  const _DownloadIntent();
}

class _ContinueIntent extends Intent {
  const _ContinueIntent();
}

class _RemoveIntent extends Intent {
  const _RemoveIntent();
}

class LibraryItemRow extends ConsumerWidget {
  const LibraryItemRow({
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

  Widget _progressNotStarted(AppLocalizations l10n, MotionSettings motion) {
    final percentLabel = '${l10n.currentProgress}: 0%';
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: AnimatedSwitcher(
            duration: motion.reduceMotion ? Duration.zero : Motion.medium,
            child: Semantics(
              key: const ValueKey('ring-0'),
              label: percentLabel,
              child: const CircularProgressIndicator(
                value: 0.0,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(l10n.notStarted, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _progressLoaded(
    AppLocalizations l10n,
    MotionSettings motion,
    List<Chapter> chapters,
    UserProgress p,
  ) {
    final matched = chapters.where((c) => c.id == p.chapterId).toList();
    final title = matched.isNotEmpty
        ? matched.first.title
        : l10n.unknownChapter;
    final contentLen = matched.isNotEmpty
        ? (matched.first.content?.length ?? 0)
        : 0;
    final ringValue = (contentLen > 0 && p.ttsCharIndex > 0)
        ? (p.ttsCharIndex / contentLen).clamp(0.0, 1.0)
        : 0.0;
    final percent = (ringValue * 100).round();
    final percentLabel = '${l10n.currentProgress}: $percent%';
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: AnimatedSwitcher(
            duration: motion.reduceMotion ? Duration.zero : Motion.medium,
            child: Semantics(
              key: ValueKey('ring-$percent'),
              label: percentLabel,
              child: CircularProgressIndicator(
                value: ringValue,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.continueAtChapter(title ?? ''),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _progressWidget(
    AppLocalizations l10n,
    MotionSettings motion,
    AsyncValue<UserProgress?> lastProgressAsync,
    AsyncValue<List<Chapter>> chaptersAsync,
  ) {
    return lastProgressAsync.when(
      data: (p) {
        if (p == null) {
          return _progressNotStarted(l10n, motion);
        }
        return chaptersAsync.when(
          data: (chapters) => _progressLoaded(l10n, motion, chapters, p),
          loading: () => Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.loadingChapter,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          error: (e, _) => Text(l10n.errorLoadingChapters),
        );
      },
      loading: () => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l10n.loadingProgress, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      error: (e, _) => Text(l10n.errorLoadingProgress),
    );
  }

  Widget _downloadAction(
    AppLocalizations l10n,
    bool canDownload,
    String novelId,
    WidgetRef ref,
  ) {
    if (canDownload) {
      return FocusTraversalOrder(
        order: const NumericFocusOrder(1.0),
        child: Consumer(
          builder: (context, ref, child) {
            final isDownloading =
                ref.watch(downloadStateProvider)[novelId] ?? false;
            if (isDownloading) {
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Semantics(
              button: true,
              label: l10n.downloadChapters,
              hint: 'Press D',
              child: Tooltip(
                message: '${l10n.downloadChapters} (D)',
                child: KeyedSubtree(
                  key: Key('downloadButton_$novelId'),
                  child: AppButtons.icon(
                    iconData: Icons.download,
                    tooltip: l10n.downloadChapters,
                    onPressed: () async {
                      ref
                          .read(downloadStateProvider.notifier)
                          .update((state) => {...state, novelId: true});
                      try {
                        final chapterRepository = ref.read(
                          chapterRepositoryProvider,
                        );
                        final chapters = await chapterRepository.getChapters(
                          novelId,
                        );
                        for (final chapter in chapters) {
                          await chapterRepository.getChapter(chapter);
                        }
                      } finally {
                        ref
                            .read(downloadStateProvider.notifier)
                            .update((state) => {...state, novelId: false});
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return FocusTraversalOrder(
      order: const NumericFocusOrder(1.0),
      child: Tooltip(
        message: l10n.downloadChapters,
        child: KeyedSubtree(
          key: Key('downloadButton_$novelId'),
          child: AppButtons.icon(
            iconData: Icons.download,
            tooltip: l10n.downloadChapters,
            enabled: false,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _continueAction(
    AppLocalizations l10n,
    AsyncValue<UserProgress?> lastProgressAsync,
    String novelId,
    BuildContext context,
  ) {
    return lastProgressAsync.when(
      data: (p) {
        if (p == null) return const SizedBox.shrink();
        return FocusTraversalOrder(
          order: const NumericFocusOrder(2.0),
          child: Tooltip(
            message: '${l10n.continueLabel} (Enter)',
            child: Semantics(
              button: true,
              label: l10n.continueLabel,
              hint: 'Press Enter',
              child: KeyedSubtree(
                key: Key('continueButton_$novelId'),
                child: AppButtons.text(
                  label: l10n.continueLabel,
                  onPressed: () {
                    final dest = '/novel/$novelId/chapters/${p.chapterId}';
                    context.push(dest);
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _removeAction(
    AppLocalizations l10n,
    bool canRemove,
    bool isSignedIn,
    Novel n,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (!canRemove || onRemove == null) return const SizedBox.shrink();
    return FocusTraversalOrder(
      order: const NumericFocusOrder(3.0),
      child: Tooltip(
        message: '${l10n.remove} (Del)',
        child: Semantics(
          button: true,
          label: l10n.remove,
          hint: 'Press Delete',
          child: KeyedSubtree(
            key: Key('removeButton_${n.id}'),
            child: AppButtons.icon(
              iconData: Icons.delete_outline,
              tooltip: l10n.remove,
              onPressed: onRemove!,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadChapters(WidgetRef ref, String novelId) async {
    final notifier = ref.read(downloadStateProvider.notifier);
    notifier.update((state) => <String, bool>{...state, novelId: true});
    try {
      final chapterRepository = ref.read(chapterRepositoryProvider);
      final chapters = await chapterRepository.getChapters(novelId);
      for (final chapter in chapters) {
        await chapterRepository.getChapter(chapter);
      }
    } finally {
      notifier.update((state) => <String, bool>{...state, novelId: false});
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = novel;
    final l10n = AppLocalizations.of(context)!;
    final motion = ref.watch(motionSettingsProvider);
    final lastProgressAsync = ref.watch(lastProgressProvider(n.id));
    final chaptersAsync = ref.watch(chaptersProvider(n.id));

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyD): const _DownloadIntent(),
        const SingleActivator(LogicalKeyboardKey.enter):
            const _ContinueIntent(),
        if (canRemove) ...{
          const SingleActivator(LogicalKeyboardKey.delete):
              const _RemoveIntent(),
        },
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _DownloadIntent: CallbackAction<_DownloadIntent>(
            onInvoke: (_) {
              if (!canDownload) return null;
              unawaited(_downloadChapters(ref, n.id));
              return null;
            },
          ),
          _ContinueIntent: CallbackAction<_ContinueIntent>(
            onInvoke: (_) {
              lastProgressAsync.whenData((p) {
                if (p == null) return;
                final dest = '/novel/${n.id}/chapters/${p.chapterId}';
                if (context.mounted) {
                  context.push(dest);
                }
              });
              return null;
            },
          ),
          if (canRemove)
            _RemoveIntent: CallbackAction<_RemoveIntent>(
              onInvoke: (_) {
                if (canRemove && onRemove != null) {
                  onRemove!();
                }
                return null;
              },
            ),
        },
        child: Focus(
          canRequestFocus: true,
          child: Material(
            color: Colors.transparent,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => context.push('/novel/${n.id}'),
                hoverColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Radii.s),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(n.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (n.author != null) Text(n.author!),
                      if (n.description != null)
                        Text(
                          n.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      _progressWidget(
                        l10n,
                        motion,
                        lastProgressAsync,
                        chaptersAsync,
                      ),
                    ],
                  ),
                  leading: ImageUtils.getFilteredCoverUrl(n.coverUrl) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.s),
                          child: Image.network(
                            ImageUtils.getFilteredCoverUrl(n.coverUrl)!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              final isLoaded = loadingProgress == null;
                              return SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    const Icon(Icons.menu_book),
                                    AnimatedOpacity(
                                      opacity: isLoaded ? 1.0 : 0.0,
                                      duration: motion.reduceMotion
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                      curve: motion.reduceMotion
                                          ? Curves.linear
                                          : Curves.easeOut,
                                      child: child,
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(Icons.menu_book),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.menu_book),
                  trailing: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _downloadAction(l10n, canDownload, n.id, ref),
                        _continueAction(l10n, lastProgressAsync, n.id, context),
                        if (canRemove) const SizedBox(width: Spacing.s),
                        _removeAction(
                          l10n,
                          canRemove,
                          isSignedIn,
                          n,
                          context,
                          ref,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
