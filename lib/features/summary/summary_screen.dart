import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'summary_controller.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with TickerProviderStateMixin {
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

  // Tab Controllers
  late final TabController _tabController;
  late final TabController _sentenceTabController;
  late final TabController _paragraphTabController;
  late final TabController _pageTabController;
  late final TabController _expandedTabController;

  // Coach State
  bool _showCoach = false;
  bool _showSentenceCoach = false;
  bool _showParagraphCoach = false;
  bool _showPageCoach = false;

  void _resetCoaches() {
    _showCoach = false;
    _showSentenceCoach = false;
    _showParagraphCoach = false;
    _showPageCoach = false;
  }

  // AI satisfaction flags - true means user is satisfied, no auto AI calls
  bool _sentenceAiSatisfied = false;
  bool _paragraphAiSatisfied = false;
  bool _pageAiSatisfied = false;
  bool _expandedAiSatisfied = false;

  // Store last AI outputs to preserve chat history
  SnowflakeRefinementOutput? _sentenceLastOutput;
  SnowflakeRefinementOutput? _paragraphLastOutput;
  SnowflakeRefinementOutput? _pageLastOutput;
  SnowflakeRefinementOutput? _expandedLastOutput;

  @override
  void initState() {
    super.initState();
    _controller = SummaryController(ref.read(novelRepositoryProvider));

    // Initialize tab controllers
    _tabController = TabController(length: 4, vsync: this);
    _sentenceTabController = TabController(length: 2, vsync: this);
    _paragraphTabController = TabController(length: 2, vsync: this);
    _pageTabController = TabController(length: 2, vsync: this);
    _expandedTabController = TabController(length: 2, vsync: this);

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
      if (e is ApiException && e.statusCode == 401) {
        // Suppress 401 as it's handled by repo/redirect
      } else {
        _error = e.toString();
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sentenceTabController.dispose();
    _paragraphTabController.dispose();
    _pageTabController.dispose();
    _expandedTabController.dispose();
    _sentenceController.dispose();
    _paragraphController.dispose();
    _pageController.dispose();
    _expandedController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    // Reset AI satisfaction flags when user manually edits content
    if (_sentenceController.text != _controller.baseSummary?.sentenceSummary) {
      _sentenceAiSatisfied = false;
      _sentenceLastOutput = null;
    }
    if (_paragraphController.text !=
        _controller.baseSummary?.paragraphSummary) {
      _paragraphAiSatisfied = false;
      _paragraphLastOutput = null;
    }
    if (_pageController.text != _controller.baseSummary?.pageSummary) {
      _pageAiSatisfied = false;
      _pageLastOutput = null;
    }
    if (_expandedController.text != _controller.baseSummary?.expandedSummary) {
      _expandedAiSatisfied = false;
      _expandedLastOutput = null;
    }

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

  Widget _buildNovelHeader() {
    return NovelMetadataEditor(novelId: widget.novelId);
  }

  Widget _buildSummaryTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Column(
      children: [
        // Preview/Edit tabs
        TabBar(
          controller: _sentenceTabController,
          tabs: const [
            Tab(text: 'Preview'),
            Tab(text: 'Edit'),
          ],
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            child: TabBarView(
              controller: _sentenceTabController,
              children: [
                // Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    _sentenceController.text.isEmpty
                        ? 'No sentence summary available.'
                        : _sentenceController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Edit
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    child: TextFormField(
                      key: const Key('sentence_summary_field'),
                      controller: _sentenceController,
                      decoration: InputDecoration(
                        labelText: l10n.sentenceSummary,
                        border: const OutlineInputBorder(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: const Key('sentence_ai_coach_button'),
                              icon: Icon(
                                _showSentenceCoach
                                    ? Icons.auto_awesome
                                    : Icons.auto_awesome_outlined,
                                color:
                                    _showSentenceCoach || _sentenceAiSatisfied
                                    ? Colors.purple
                                    : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_showSentenceCoach) {
                                    _showSentenceCoach = false;
                                    _showCoach = false;
                                  } else {
                                    _resetCoaches();
                                    _showSentenceCoach = true;
                                  }
                                });
                              },
                              tooltip: 'AI sentence summary',
                            ),
                            if (_sentenceAiSatisfied &&
                                !_showSentenceCoach) ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle, size: 18),
                                color: Colors.green,
                                onPressed: () {
                                  setState(() => _sentenceAiSatisfied = false);
                                },
                                tooltip: l10n.imSatisfied,
                              ),
                            ],
                          ],
                        ),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraphTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Column(
      children: [
        // Preview/Edit tabs
        TabBar(
          controller: _paragraphTabController,
          tabs: const [
            Tab(text: 'Preview'),
            Tab(text: 'Edit'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _paragraphTabController,
            children: [
              // Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  _paragraphController.text.isEmpty
                      ? 'No paragraph summary available.'
                      : _paragraphController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Edit
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: TextFormField(
                    controller: _paragraphController,
                    decoration: InputDecoration(
                      labelText: l10n.paragraphSummary,
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _showParagraphCoach
                                  ? Icons.auto_awesome
                                  : Icons.auto_awesome_outlined,
                              color:
                                  _showParagraphCoach || _paragraphAiSatisfied
                                  ? Colors.purple
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _showParagraphCoach = !_showParagraphCoach;
                                if (_showParagraphCoach) {
                                  _showCoach = false;
                                  _showSentenceCoach = false;
                                  _showPageCoach = false;
                                }
                              });
                            },
                            tooltip: 'AI paragraph summary',
                          ),
                          if (_paragraphAiSatisfied &&
                              !_showParagraphCoach) ...[
                            IconButton(
                              icon: const Icon(Icons.check_circle, size: 18),
                              color: Colors.green,
                              onPressed: () {
                                setState(() => _paragraphAiSatisfied = false);
                              },
                              tooltip: l10n.imSatisfied,
                            ),
                          ],
                        ],
                      ),
                    ),
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Column(
      children: [
        // Preview/Edit tabs
        TabBar(
          controller: _pageTabController,
          tabs: const [
            Tab(text: 'Preview'),
            Tab(text: 'Edit'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _pageTabController,
            children: [
              // Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  _pageController.text.isEmpty
                      ? 'No page summary available.'
                      : _pageController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Edit
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: TextFormField(
                    controller: _pageController,
                    decoration: InputDecoration(
                      labelText: l10n.pageSummary,
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _showPageCoach
                                  ? Icons.auto_awesome
                                  : Icons.auto_awesome_outlined,
                              color: _showPageCoach || _pageAiSatisfied
                                  ? Colors.purple
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPageCoach = !_showPageCoach;
                                if (_showPageCoach) {
                                  _showCoach = false;
                                  _showSentenceCoach = false;
                                  _showParagraphCoach = false;
                                }
                              });
                            },
                            tooltip: 'AI page summary',
                          ),
                          if (_pageAiSatisfied && !_showPageCoach) ...[
                            IconButton(
                              icon: const Icon(Icons.check_circle, size: 18),
                              color: Colors.green,
                              onPressed: () {
                                setState(() => _pageAiSatisfied = false);
                              },
                              tooltip: l10n.imSatisfied,
                            ),
                          ],
                        ],
                      ),
                    ),
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Column(
      children: [
        // Preview/Edit tabs
        TabBar(
          controller: _expandedTabController,
          tabs: const [
            Tab(text: 'Preview'),
            Tab(text: 'Edit'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _expandedTabController,
            children: [
              // Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  _expandedController.text.isEmpty
                      ? 'No expanded summary available.'
                      : _expandedController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Edit
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _expandedController,
                    decoration: InputDecoration(
                      labelText: l10n.expandedSummary,
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _showCoach
                                  ? Icons.auto_awesome
                                  : Icons.auto_awesome_outlined,
                              color: _showCoach || _expandedAiSatisfied
                                  ? Colors.purple
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _showCoach = !_showCoach;
                                if (_showCoach) {
                                  _showSentenceCoach = false;
                                  _showParagraphCoach = false;
                                  _showPageCoach = false;
                                }
                              });
                            },
                            tooltip: l10n.toggleAiCoach,
                          ),
                          if (_expandedAiSatisfied && !_showCoach) ...[
                            IconButton(
                              icon: const Icon(Icons.check_circle, size: 18),
                              color: Colors.green,
                              onPressed: () {
                                setState(() => _expandedAiSatisfied = false);
                              },
                              tooltip: l10n.imSatisfied,
                            ),
                          ],
                        ],
                      ),
                    ),
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();

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
          final showCoach =
              _showCoach ||
              _showSentenceCoach ||
              _showParagraphCoach ||
              _showPageCoach;

          Widget? activeCoachContent;

          if (showCoach) {
            if (_showSentenceCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'sentence',
                currentSummary: _sentenceController.text,
                onSummaryUpdated: (newSummary) {
                  _sentenceController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !_sentenceAiSatisfied,
                lastOutput: _sentenceLastOutput,
                onAiCompleted: (output) {
                  setState(() {
                    _sentenceAiSatisfied = true;
                    _sentenceLastOutput = output;
                  });
                },
              );
            } else if (_showParagraphCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'paragraph',
                currentSummary: _paragraphController.text,
                onSummaryUpdated: (newSummary) {
                  _paragraphController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !_paragraphAiSatisfied,
                lastOutput: _paragraphLastOutput,
                onAiCompleted: (output) {
                  setState(() {
                    _paragraphAiSatisfied = true;
                    _paragraphLastOutput = output;
                  });
                },
              );
            } else if (_showPageCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'page',
                currentSummary: _pageController.text,
                onSummaryUpdated: (newSummary) {
                  _pageController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !_pageAiSatisfied,
                lastOutput: _pageLastOutput,
                onAiCompleted: (output) {
                  setState(() {
                    _pageAiSatisfied = true;
                    _pageLastOutput = output;
                  });
                },
              );
            } else {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'expanded',
                currentSummary: _expandedController.text,
                onSummaryUpdated: (newSummary) {
                  _expandedController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !_expandedAiSatisfied,
                lastOutput: _expandedLastOutput,
                onAiCompleted: (output) {
                  setState(() {
                    _expandedAiSatisfied = true;
                    _expandedLastOutput = output;
                  });
                },
              );
            }
          }

          Widget buildMainContent() {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  // Novel Header (above tabs as requested)
                  _buildNovelHeader(),
                  const SizedBox(height: 16),

                  // Main Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Sentence Summary'),
                      Tab(text: 'Paragraph Summary'),
                      Tab(text: 'Page Summary'),
                      Tab(text: 'Expanded Summary'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSummaryTab(),
                        _buildParagraphTab(),
                        _buildPageTab(),
                        _buildExpandedTab(),
                      ],
                    ),
                  ),

                  // Save Button and Error Display (at bottom as requested) - wrapped in Flexible to prevent overflow
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: (_saving || !_isDirty)
                                ? null
                                : () async {
                                    final ok =
                                        _formKey.currentState?.validate() ??
                                        false;
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(l10n.saved)),
                                      );
                                    } catch (e) {
                                      setState(() => _error = e.toString());
                                    } finally {
                                      if (mounted) {
                                        setState(() => _saving = false);
                                      }
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
                    ),
                  ),
                ],
              ),
            );
          }

          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(flex: 2, child: buildMainContent()),
                if (showCoach && activeCoachContent != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 1,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: activeCoachContent,
                    ),
                  ),
                ],
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(flex: 1, child: buildMainContent()),
                if (showCoach && activeCoachContent != null) ...[
                  const Divider(height: 1),
                  Expanded(
                    flex: 1,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: activeCoachContent,
                    ),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }
}
