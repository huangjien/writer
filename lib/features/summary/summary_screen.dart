import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/chapter.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.novelId});

  final String novelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = supabaseEnabled
        ? ref.watch(chaptersProvider(novelId))
        : ref.watch(mockChaptersProvider(novelId));

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supabaseEnabled)
              ref
                  .watch(novelProvider(novelId))
                  .when(
                    data: (novel) => _NovelHeader(novel: novel),
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  )
            else
              ref
                  .watch(mockNovelsProvider)
                  .when(
                    data: (novels) {
                      Novel? novel;
                      final matches = novels.where((n) => n.id == novelId);
                      if (matches.isNotEmpty) {
                        novel = matches.first;
                      } else {
                        novel = null;
                      }
                      return _NovelHeader(novel: novel);
                    },
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  ),
            const SizedBox(height: 16),
            chaptersAsync.when(
              data: (chapters) => _ChaptersSummary(chapters: chapters),
              loading: () => const _LoadingTile(label: 'Loading chapters…'),
              error: (e, _) => _ErrorTile(label: 'Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NovelHeader extends StatelessWidget {
  const _NovelHeader({required this.novel});
  final Novel? novel;

  @override
  Widget build(BuildContext context) {
    final title = novel?.title ?? 'Unknown Novel';
    final author = novel?.author;
    final description = novel?.description;
    final language = novel?.languageCode;
    final isPublic = novel?.isPublic ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (author != null && author.isNotEmpty) Text(author),
        if (description != null && description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.language, size: 16),
            const SizedBox(width: 6),
            Text('Language: ${language ?? 'en'}'),
            const SizedBox(width: 12),
            const Icon(Icons.lock_open, size: 16),
            const SizedBox(width: 6),
            Text(isPublic ? 'Public' : 'Private'),
          ],
        ),
      ],
    );
  }
}

class _ChaptersSummary extends StatelessWidget {
  const _ChaptersSummary({required this.chapters});
  final List<Chapter> chapters;

  String _snippet(String? content) {
    if (content == null || content.isEmpty) return '';
    final s = content.trim();
    if (s.length <= 140) return s;
    return '${s.substring(0, 140)}…';
  }

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) {
      return const Text('No chapters found.');
    }
    final count = chapters.length;
    final sample = chapters.take(5).toList();
    final totalWords = chapters
        .map((c) => (c.content ?? '').trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s.split(RegExp(r'\s+')).length)
        .fold<int>(0, (a, b) => a + b);
    final avgWords = count > 0 ? (totalWords / count).round() : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list, size: 16),
            const SizedBox(width: 6),
            Text('Chapters: $count'),
            const SizedBox(width: 12),
            const Icon(Icons.text_snippet, size: 16),
            const SizedBox(width: 6),
            Text('Avg words/chapter: $avgWords'),
          ],
        ),
        const SizedBox(height: 12),
        ...sample.map((c) {
          final title = c.title?.trim();
          final label = title == null || title.isEmpty
              ? 'Chapter ${c.idx}'
              : 'Chapter ${c.idx}: $title';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if ((c.content ?? '').isNotEmpty)
                  Text(
                    _snippet(c.content),
                    style: const TextStyle(color: Colors.black54),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
