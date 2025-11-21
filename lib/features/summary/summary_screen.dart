import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:novel_reader/models/novel.dart';
import 'package:novel_reader/models/chapter.dart';
import '../../main.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final local = ref.read(localStorageRepositoryProvider);
    final cached = await local.getSummaryText(widget.novelId);
    if (cached != null) {
      _summaryController.text = cached;
    } else {
      final novel = await ref.read(novelProvider(widget.novelId).future);
      final desc = novel?.description ?? '';
      _summaryController.text = desc;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = supabaseEnabled
        ? ref.watch(chaptersProvider(widget.novelId))
        : ref.watch(mockChaptersProvider(widget.novelId));

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supabaseEnabled)
              ref
                  .watch(novelProvider(widget.novelId))
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
                      final matches = novels.where(
                        (n) => n.id == widget.novelId,
                      );
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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(
                      labelText: 'Novel Summary',
                    ),
                    minLines: 4,
                    maxLines: null,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                final ok =
                                    _formKey.currentState?.validate() ?? false;
                                if (!ok) return;
                                setState(() {
                                  _saving = true;
                                  _error = null;
                                });
                                try {
                                  final local = ref.read(
                                    localStorageRepositoryProvider,
                                  );
                                  await local.saveSummaryText(
                                    widget.novelId,
                                    _summaryController.text.trim(),
                                  );
                                  if (supabaseEnabled) {
                                    final repo = ref.read(
                                      novelRepositoryProvider,
                                    );
                                    await repo.updateNovelMetadata(
                                      widget.novelId,
                                      description: _summaryController.text
                                          .trim(),
                                    );
                                  }
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      if (_error != null)
                        Expanded(
                          child: Text(
                            _error!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
