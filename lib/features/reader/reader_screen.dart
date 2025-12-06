import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/side_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/novel_providers.dart';
import '../../state/mock_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chapter.dart';
import 'chapter_reader_screen.dart' as cr;
import '../../state/supabase_config.dart';
import '../../repositories/chapter_repository.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final chaptersAsync = supabaseEnabled
        ? ref.watch(chaptersProvider(widget.novelId))
        : ref.watch(mockChaptersProvider(widget.novelId));

    if (widget.chapterId != null) {
      return chaptersAsync.when(
        data: (chapters) {
          final chapter = chapters.firstWhere(
            (c) => c.id == widget.chapterId,
            orElse: () => chapters.first,
          );
          final chapterIndex = chapters.indexOf(chapter);

          return ChapterReaderScreen(
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
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chapters),
        automaticallyImplyLeading: false,
        actions: [
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
              tooltip: 'Refresh',
              onPressed: () async {
                setState(() => _refreshing = true);
                if (supabaseEnabled) {
                  ref.invalidate(chaptersProvider(widget.novelId));
                  await ref.read(chaptersProvider(widget.novelId).future);
                } else {
                  ref.invalidate(mockChaptersProvider(widget.novelId));
                  await ref.read(mockChaptersProvider(widget.novelId).future);
                }
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
                      final chapters = await (supabaseEnabled
                          ? ref.read(chaptersProvider(widget.novelId).future)
                          : ref.read(
                              mockChaptersProvider(widget.novelId).future,
                            ));
                      final List<Chapter> withContent = [];
                      if (supabaseEnabled) {
                        final repo = ref.read(chapterRepositoryProvider);
                        for (final c in chapters) {
                          final full = await repo.getChapter(c);
                          withContent.add(full);
                        }
                      } else {
                        withContent.addAll(chapters);
                      }

                      final novel = await (supabaseEnabled
                          ? ref.read(novelProvider(widget.novelId).future)
                          : (() async {
                              final novels = await ref.read(
                                mockNovelsProvider.future,
                              );
                              final matches = novels.where(
                                (n) => n.id == widget.novelId,
                              );
                              return matches.isNotEmpty ? matches.first : null;
                            })());

                      final chapterPrefix = l10n.chapter;
                      final doc = pw.Document();
                      doc.addPage(
                        pw.Page(
                          build: (context) => pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Spacer(),
                              pw.Center(
                                child: pw.Text(
                                  novel?.title ?? 'Novel',
                                  style: pw.TextStyle(
                                    fontSize: 32,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              if ((novel?.author ?? '').trim().isNotEmpty)
                                pw.Center(
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 12),
                                    child: pw.Text(
                                      l10n.byAuthor(novel!.author!),
                                      style: const pw.TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              pw.Spacer(),
                              pw.Text(
                                l10n.languageLabel(novel?.languageCode ?? 'en'),
                              ),
                            ],
                          ),
                        ),
                      );
                      doc.addPage(
                        pw.MultiPage(
                          header: (context) => pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            padding: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Text(
                              novel?.title ?? 'Novel',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                          footer: (context) => pw.Container(
                            alignment: pw.Alignment.centerRight,
                            padding: const pw.EdgeInsets.only(top: 8),
                            child: pw.Text(
                              l10n.pageOfTotal(
                                context.pageNumber,
                                context.pagesCount,
                              ),
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                          build: (context) {
                            final List<pw.Widget> content = [];
                            content.add(
                              pw.Header(level: 0, text: l10n.tableOfContents),
                            );
                            for (final c in withContent) {
                              final heading =
                                  (c.title == null || c.title!.trim().isEmpty)
                                  ? '$chapterPrefix ${c.idx}'
                                  : '$chapterPrefix ${c.idx}: ${c.title}';
                              final anchorName = 'chapter-${c.idx}';
                              content.add(
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: pw.Row(
                                    children: [
                                      pw.Expanded(
                                        child: pw.Link(
                                          destination: anchorName,
                                          child: pw.Text(heading),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            content.add(pw.SizedBox(height: 20));
                            content.add(
                              pw.Header(
                                level: 0,
                                text: novel?.title ?? 'Novel',
                              ),
                            );
                            for (final c in withContent) {
                              final heading =
                                  (c.title == null || c.title!.trim().isEmpty)
                                  ? '$chapterPrefix ${c.idx}'
                                  : '$chapterPrefix ${c.idx}: ${c.title}';
                              final anchorName = 'chapter-${c.idx}';
                              content.add(
                                pw.Anchor(
                                  name: anchorName,
                                  child: pw.Header(level: 1, text: heading),
                                ),
                              );
                              final body = (c.content ?? '').trim();
                              if (body.isNotEmpty) {
                                content.add(pw.Paragraph(text: body));
                              }
                            }
                            return content;
                          },
                        ),
                      );
                      final bytes = await doc.save();
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename:
                            '${(novel?.title ?? 'novel').replaceAll(' ', '_')}-${widget.novelId}.pdf',
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
              tooltip: 'Menu',
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
          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
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
