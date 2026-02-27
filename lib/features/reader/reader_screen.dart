import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/widgets/side_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/chapter.dart';
import 'chapter_reader_screen.dart' as cr;
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/empty_states/chapter_empty_state.dart';
import 'package:writer/shared/widgets/loading_state.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.novelId, this.chapterId});

  final String novelId;
  final String? chapterId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _refreshing = false;
  bool _pdfGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final chaptersAsync = ref.watch(chaptersProviderV2(widget.novelId));
    final editPermsAsync = ref.watch(editPermissionsProvider(widget.novelId));
    final canEdit = editPermsAsync.asData?.value ?? false;

    if (widget.chapterId != null) {
      return chaptersAsync.when(
        data: (chapters) {
          if (chapters.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.chapters)),
              body: Center(child: Text(l10n.noChaptersFound)),
            );
          }
          final chapter = chapters.firstWhere(
            (c) => c.id == widget.chapterId,
            orElse: () => chapters.first,
          );
          final chapterIndex = chapters.indexOf(chapter);

          return cr.ChapterReaderScreen(
            chapterId: chapter.id,
            title: chapter.title ?? l10n.chapterLabel(chapter.idx),
            content: chapter.content,
            novelId: widget.novelId,
            allChapters: chapters,
            currentIdx: chapterIndex,
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) {
          if (e is ApiException && e.statusCode == 401) {
            return const SizedBox.shrink();
          }
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.error}: $e'),
                  const SizedBox(height: 16),
                  AppButtons.secondary(
                    label: l10n.reload,
                    icon: Icons.refresh,
                    onPressed: () =>
                        ref.invalidate(chaptersProviderV2(widget.novelId)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chapters),
        automaticallyImplyLeading: false,
        actions: [
          if (canEdit)
            AppButtons.icon(
              iconData: Icons.add,
              tooltip: l10n.newLabel,
              onPressed: () {
                try {
                  context.push('/novel/${widget.novelId}/chapters/new');
                } catch (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: Center(child: Text(l10n.navigationError)),
                      ),
                    ),
                  );
                }
              },
            ),
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            AppButtons.icon(
              iconData: Icons.refresh,
              tooltip: l10n.refreshTooltip,
              onPressed: () async {
                setState(() => _refreshing = true);
                ref.invalidate(chaptersProviderV2(widget.novelId));
                await ref.read(chaptersProviderV2(widget.novelId).future);
                if (mounted) setState(() => _refreshing = false);
              },
            ),
          AppButtons.icon(
            iconData: Icons.picture_as_pdf,
            tooltip: l10n.pdf,
            enabled: !_pdfGenerating,
            onPressed: _pdfGenerating
                ? () {}
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final rootNavigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );
                    final errMsg = '${l10n.error}: ${l10n.pdfFailed}';
                    setState(() => _pdfGenerating = true);
                    final steps = <String>[
                      'Preparing chapters',
                      'Generating PDF',
                      'Sharing',
                    ];
                    final stories = <String>[
                      'Tip: Write one clear intention per scene.',
                      'Tip: Strong verbs make sentences feel alive.',
                      'Tip: If stuck, rewrite the last paragraph.',
                      'Tip: Dialogue reveals character faster than description.',
                    ];
                    final progress = ValueNotifier<int>(0);
                    unawaited(
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return PopScope(
                            canPop: false,
                            child: Dialog(
                              insetPadding: const EdgeInsets.all(Spacing.xl),
                              child: Padding(
                                padding: const EdgeInsets.all(Spacing.xl),
                                child: ValueListenableBuilder<int>(
                                  valueListenable: progress,
                                  builder: (context, step, _) {
                                    return LoadingState(
                                      steps: steps,
                                      currentStep: step,
                                      stories: stories,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                    try {
                      final chapters = await ref.read(
                        chaptersProviderV2(widget.novelId).future,
                      );
                      progress.value = 1;
                      final repo = ref.read(chapterRepositoryProvider);
                      final withContent = <Chapter>[];
                      for (final c in chapters) {
                        if ((c.content ?? '').isNotEmpty) {
                          withContent.add(c);
                        } else {
                          withContent.add(await repo.getChapter(c));
                        }
                      }

                      final novel = await ref.read(
                        novelProvider(widget.novelId).future,
                      );

                      if (novel == null) {
                        throw Exception(l10n.errorNovelNotFound);
                      }

                      progress.value = 2;
                      final pdfService = ref.read(pdfServiceProvider);
                      await pdfService.generateAndSharePdf(
                        novel: novel,
                        chapters: withContent,
                        l10nByAuthor: l10n.byAuthor,
                        l10nChapter: l10n.chapter,
                        l10nNovel: l10n.novel,
                        l10nLanguageLabel: l10n.languageLabel(
                          novel.languageCode,
                        ),
                        l10nTableOfContents: l10n.tableOfContents,
                        l10nPageOfTotal: l10n.pageOfTotal,
                      );
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text(errMsg)));
                    } finally {
                      if (mounted && rootNavigator.canPop()) {
                        rootNavigator.pop();
                      }
                      progress.dispose();
                      if (mounted) setState(() => _pdfGenerating = false);
                    }
                  },
          ),
          Builder(
            builder: (context) => AppButtons.icon(
              iconData: Icons.menu,
              tooltip: l10n.menu,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
      drawer: SideBar(novelId: widget.novelId),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: chaptersAsync.when(
          data: (chapters) {
            if (chapters.isEmpty) {
              return ChapterEmptyState(
                title: l10n.noChaptersFound,
                subtitle: l10n.createNextChapter,
                actionLabel: canEdit ? l10n.createNextChapter : null,
                onAction: canEdit
                    ? () =>
                          context.push('/novel/${widget.novelId}/chapters/new')
                    : null,
              );
            }
            return ListView.separated(
              itemCount: chapters.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = chapters[index];
                final titleText = c.title?.trim();
                final semanticsLabel = (titleText == null || titleText.isEmpty)
                    ? '${l10n.chapter} ${c.idx}'
                    : '${l10n.chapter} ${c.idx}: $titleText';
                return Semantics(
                  button: true,
                  label: semanticsLabel,
                  child: ListTile(
                    title: (titleText == null || titleText.isEmpty)
                        ? Text('${l10n.chapter} ${c.idx}')
                        : Row(
                            children: [
                              Text('${l10n.chapter} ${c.idx}'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  titleText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                    onTap: () {
                      try {
                        context.push(
                          '/novel/${widget.novelId}/chapters/${c.id}',
                        );
                      } catch (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChapterReaderScreen(
                              chapterId: c.id,
                              title: c.title ?? l10n.chapterLabel(c.idx),
                              content: c.content,
                              novelId: widget.novelId,
                              allChapters: chapters,
                              currentIdx: index,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            if (e is ApiException && e.statusCode == 401) {
              return const SizedBox.shrink();
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${l10n.error}: $e'),
                    const SizedBox(height: 16),
                    AppButtons.secondary(
                      label: l10n.reload,
                      icon: Icons.refresh,
                      onPressed: () =>
                          ref.invalidate(chaptersProviderV2(widget.novelId)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChapterReaderScreen extends ConsumerWidget {
  const ChapterReaderScreen({
    super.key,
    required this.chapterId,
    required this.title,
    this.content,
    required this.novelId,
    this.initialOffset = 0.0,
    this.initialTtsIndex = 0,
    this.allChapters,
    this.currentIdx,
    this.autoStartTts = false,
  });
  final String chapterId;
  final String title;
  final String? content;
  final String novelId;
  final double initialOffset;
  final int initialTtsIndex;
  final List<Chapter>? allChapters;
  final int? currentIdx;
  final bool autoStartTts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return cr.ChapterReaderScreen(
      chapterId: chapterId,
      title: title,
      content: content,
      novelId: novelId,
      initialOffset: initialOffset,
      initialTtsIndex: initialTtsIndex,
      allChapters: allChapters,
      currentIdx: currentIdx,
      autoStartTts: autoStartTts,
    );
  }
}
