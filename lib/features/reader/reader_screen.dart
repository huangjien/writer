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

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.novelId, this.chapterId});

  final String novelId;
  final String? chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final chaptersAsync = supabaseEnabled
        ? ref.watch(chaptersProvider(novelId))
        : ref.watch(mockChaptersProvider(novelId));

    if (chapterId != null) {
      return chaptersAsync.when(
        data: (chapters) {
          final chapter = chapters.firstWhere(
            (c) => c.id == chapterId,
            orElse: () => chapters.first,
          );
          final chapterIndex = chapters.indexOf(chapter);

          return ChapterReaderScreen(
            chapterId: chapter.id,
            title: chapter.title ?? 'Chapter ${chapter.idx}',
            content: chapter.content,
            novelId: novelId,
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
      endDrawer: SideBar(novelId: novelId),
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
                        context.push('/novel/$novelId/chapters/${c.id}');
                      } catch (_) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChapterReaderScreen(
                              chapterId: c.id,
                              title: c.title ?? '${l10n.chapter} ${c.idx}',
                              content: c.content,
                              novelId: novelId,
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
