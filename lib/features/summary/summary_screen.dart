import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'summary_controller.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _sentenceController = TextEditingController();
  final _paragraphController = TextEditingController();
  final _pageController = TextEditingController();
  final _expandedController = TextEditingController();

  bool _saving = false;
  String? _error;
  bool _refreshing = false;
  bool _isDirty = false;

  late final SummaryController _controller;

  // Coach State
  bool _showCoach = false;
  bool _showSentenceCoach = false;

  @override
  void initState() {
    super.initState();
    _controller = SummaryController(ref.read(novelRepositoryProvider));
    _load();
  }

  Future<void> _load() async {
    setState(() => _refreshing = true);
    try {
      await _controller.load(widget.novelId);

      _sentenceController.text = _controller.baseSummary?.sentenceSummary ?? '';
      _paragraphController.text =
          _controller.baseSummary?.paragraphSummary ?? '';
      _pageController.text = _controller.baseSummary?.pageSummary ?? '';
      _expandedController.text = _controller.baseSummary?.expandedSummary ?? '';

      _isDirty = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    _paragraphController.dispose();
    _pageController.dispose();
    _expandedController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final dirty = _controller.isDirty(
      sentence: _sentenceController.text,
      paragraph: _paragraphController.text,
      page: _pageController.text,
      expanded: _expandedController.text,
    );

    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.novelId));

    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    // Main Content
    Widget buildMainContent() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ref
                .watch(novelProvider(widget.novelId))
                .when(
                  data: (novel) => _NovelHeader(novel: novel),
                  loading: () => _LoadingTile(label: l10n.loadingNovels),
                  error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
                ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sentence Summary
                  TextFormField(
                    controller: _sentenceController,
                    decoration: InputDecoration(
                      labelText: l10n.sentenceSummary,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showSentenceCoach
                              ? Icons.chat_bubble
                              : Icons.chat_bubble_outline,
                          color: _showSentenceCoach ? Colors.purple : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSentenceCoach = !_showSentenceCoach;
                            // Ensure only one coach is active at a time
                            if (_showSentenceCoach) {
                              _showCoach = false;
                            }
                          });
                        },
                        tooltip: 'AI sentence summary',
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Paragraph Summary
                  TextFormField(
                    controller: _paragraphController,
                    decoration: InputDecoration(
                      labelText: l10n.paragraphSummary,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Page Summary
                  TextFormField(
                    controller: _pageController,
                    decoration: InputDecoration(
                      labelText: l10n.pageSummary,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 8,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Expanded Summary (with Coach)
                  TextFormField(
                    controller: _expandedController,
                    decoration: InputDecoration(
                      labelText: l10n.expandedSummary,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showCoach
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color: _showCoach ? Colors.purple : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCoach = !_showCoach;
                            // Ensure only one coach is active at a time
                            if (_showCoach) {
                              _showSentenceCoach = false;
                            }
                          });
                        },
                        tooltip: l10n.toggleAiCoach,
                      ),
                    ),
                    minLines: 10,
                    maxLines: null,
                    onChanged: (_) => _onFieldChanged(),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: (_saving || !_isDirty)
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
                                  await _controller.save(
                                    sentence: _sentenceController.text,
                                    paragraph: _paragraphController.text,
                                    page: _pageController.text,
                                    expanded: _expandedController.text,
                                  );

                                  setState(() {
                                    _isDirty = false;
                                  });

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.saved)),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        child: Text(l10n.save),
                      ),
                      const SizedBox(width: 12),
                      if (_error != null)
                        Expanded(
                          child: Text(
                            _error!,
                            maxLines: 3,
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
              loading: () => _LoadingTile(label: l10n.loadingChapter),
              error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
            ),
          ],
        ),
      );
    }

    // Layout
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summary),
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
              onPressed: () async {
                setState(() => _refreshing = true);
                ref.invalidate(novelProvider(widget.novelId));
                ref.invalidate(chaptersProvider(widget.novelId));
                await _load();
                if (mounted) setState(() => _refreshing = false);
              },
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_showCoach || _showSentenceCoach) {
            final activeCoachContent = _showSentenceCoach
                ? SnowflakeCoachWidget(
                    novelId: widget.novelId,
                    currentSummary: _sentenceController.text,
                    onSummaryUpdated: (newSummary) {
                      _sentenceController.text = newSummary;
                      _onFieldChanged();
                    },
                  )
                : SnowflakeCoachWidget(
                    novelId: widget.novelId,
                    currentSummary: _expandedController.text,
                    onSummaryUpdated: (newSummary) {
                      _expandedController.text = newSummary;
                      _onFieldChanged();
                    },
                  );

            // Split View on large screens, or BottomSheet style on small?
            // Since this is likely a desktop app, let's just split 50/50 or use a sidebar
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(flex: 2, child: buildMainContent()),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 1, child: activeCoachContent),
                ],
              );
            } else {
              // On smaller screens, maybe column? Or just take space below?
              // Let's use column for now
              return Column(
                children: [
                  Expanded(flex: 1, child: buildMainContent()),
                  const Divider(height: 1),
                  Expanded(flex: 1, child: activeCoachContent),
                ],
              );
            }
          }
          return buildMainContent();
        },
      ),
    );
  }
}

class _NovelHeader extends StatelessWidget {
  const _NovelHeader({required this.novel});
  final Novel? novel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final title = novel?.title ?? l10n.unknownNovel;
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
            Text(l10n.languageLabel(language ?? 'en')),
            const SizedBox(width: 12),
            const Icon(Icons.lock_open, size: 16),
            const SizedBox(width: 6),
            Text(isPublic ? l10n.publicLabel : l10n.privateLabel),
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
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    if (chapters.isEmpty) {
      return Text(l10n.noChaptersFound);
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
            Text(l10n.chaptersCount(count)),
            const SizedBox(width: 12),
            const Icon(Icons.text_snippet, size: 16),
            const SizedBox(width: 6),
            Text(l10n.avgWordsPerChapter(avgWords)),
          ],
        ),
        const SizedBox(height: 12),
        ...sample.map((c) {
          final title = c.title?.trim();
          final label = title == null || title.isEmpty
              ? l10n.chapterLabel(c.idx)
              : l10n.chapterWithTitle(c.idx, title);
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
        Expanded(
          child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
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
        Expanded(
          child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
