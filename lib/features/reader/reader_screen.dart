import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/side_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/novel_providers.dart';
import '../../state/edit_permissions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';
import '../../models/chapter.dart';
import 'chapter_reader_screen.dart' as cr;
import '../../repositories/chapter_repository.dart';
import '../../shared/api_exception.dart';
import '../../state/providers.dart';

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
    final chaptersAsync = ref.watch(chaptersProvider(widget.novelId));
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
            title: chapter.title ?? 'Chapter ${chapter.idx}',
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
          return Scaffold(body: Center(child: Text('${l10n.error}: $e')));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chapters),
        automaticallyImplyLeading: false,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.newLabel,
              onPressed: () {
                try {
                  context.push('/novel/${widget.novelId}/chapters/new');
                } catch (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Navigation error')),
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
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
              onPressed: () async {
                setState(() => _refreshing = true);
                ref.invalidate(chaptersProvider(widget.novelId));
                await ref.read(chaptersProvider(widget.novelId).future);
                if (mounted) setState(() => _refreshing = false);
              },
            ),
          IconButton(
            icon: _pdfGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            tooltip: l10n.pdf,
            onPressed: _pdfGenerating
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final errMsg = '${l10n.error}: ${l10n.pdfFailed}';
                    setState(() => _pdfGenerating = true);
                    try {
                      final chapters = await ref.read(
                        chaptersProvider(widget.novelId).future,
                      );
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

                      if (novel == null) throw Exception('Novel not found');

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
                      if (mounted) setState(() => _pdfGenerating = false);
                    }
                  },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: l10n.menu,
            ),
          ),
        ],
      ),
      endDrawer: SideBar(novelId: widget.novelId),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: chaptersAsync.when(
          data: (chapters) {
            if (chapters.isEmpty) {
              return Center(child: Text(l10n.noChaptersFound));
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
                              title: c.title ?? '${l10n.chapter} ${c.idx}',
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
            return Center(child: Text('${l10n.error}: $e'));
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
