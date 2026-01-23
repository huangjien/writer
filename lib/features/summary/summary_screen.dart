import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/features/summary/snowflake_coach_widget.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'summary_notifier.dart';

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

  // Tab Controllers
  late final TabController _tabController;
  late final TabController _sentenceTabController;
  late final TabController _paragraphTabController;
  late final TabController _pageTabController;
  late final TabController _expandedTabController;

  @override
  void initState() {
    super.initState();

    // Initialize tab controllers
    _tabController = TabController(length: 4, vsync: this);
    _sentenceTabController = TabController(length: 2, vsync: this);
    _paragraphTabController = TabController(length: 2, vsync: this);
    _pageTabController = TabController(length: 2, vsync: this);
    _expandedTabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    await ref.read(summaryProvider.notifier).load(widget.novelId);
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
    ref
        .read(summaryProvider.notifier)
        .onFieldChanged(
          sentence: _sentenceController.text,
          paragraph: _paragraphController.text,
          page: _pageController.text,
          expanded: _expandedController.text,
        );
  }

  Widget _buildNovelHeader() {
    return NovelMetadataEditor(novelId: widget.novelId);
  }

  Widget _buildSummaryTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return Column(
      children: [
        TabBar(
          controller: _sentenceTabController,
          tabs: [
            Tab(text: l10n.previewLabel),
            Tab(text: l10n.edit),
          ],
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            child: TabBarView(
              controller: _sentenceTabController,
              children: [
                _SummaryPreviewPanel(
                  text: _sentenceController.text,
                  emptyText: l10n.noSentenceSummary,
                ),
                _SummaryEditField(
                  fieldKey: const Key('sentence_summary_field'),
                  controller: _sentenceController,
                  decoration: InputDecoration(
                    labelText: l10n.sentenceSummary,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButtons.icon(
                          iconData: summaryState.showSentenceCoach
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color:
                              summaryState.showSentenceCoach ||
                                  summaryState.sentenceAiSatisfied
                              ? Colors.purple
                              : null,
                          onPressed: () {
                            if (summaryState.showSentenceCoach) {
                              ref.read(summaryProvider.notifier).resetCoaches();
                            } else {
                              ref.read(summaryProvider.notifier).resetCoaches();
                              ref
                                  .read(summaryProvider.notifier)
                                  .toggleSentenceCoach();
                            }
                          },
                          tooltip: l10n.aiSentenceSummaryTooltip,
                        ),
                        if (summaryState.sentenceAiSatisfied &&
                            !summaryState.showSentenceCoach) ...[
                          AppButtons.icon(
                            iconData: Icons.check_circle,
                            onPressed: () {
                              ref
                                  .read(summaryProvider.notifier)
                                  .setSentenceAiSatisfied(false);
                            },
                            tooltip: l10n.imSatisfied,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),
                  onChanged: _onFieldChanged,
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
    final summaryState = ref.watch(summaryProvider);

    return Column(
      children: [
        TabBar(
          controller: _paragraphTabController,
          tabs: [
            Tab(text: l10n.previewLabel),
            Tab(text: l10n.edit),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _paragraphTabController,
            children: [
              _SummaryPreviewPanel(
                text: _paragraphController.text,
                emptyText: l10n.noParagraphSummary,
              ),
              _SummaryEditField(
                controller: _paragraphController,
                decoration: InputDecoration(
                  labelText: l10n.paragraphSummary,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          summaryState.showParagraphCoach
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color:
                              summaryState.showParagraphCoach ||
                                  summaryState.paragraphAiSatisfied
                              ? Colors.purple
                              : null,
                        ),
                        onPressed: () {
                          ref
                              .read(summaryProvider.notifier)
                              .toggleParagraphCoach();
                        },
                        tooltip: l10n.aiParagraphSummaryTooltip,
                      ),
                      if (summaryState.paragraphAiSatisfied &&
                          !summaryState.showParagraphCoach) ...[
                        AppButtons.icon(
                          iconData: Icons.check_circle,
                          onPressed: () {
                            ref
                                .read(summaryProvider.notifier)
                                .setParagraphAiSatisfied(false);
                          },
                          tooltip: l10n.imSatisfied,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
                onChanged: _onFieldChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return Column(
      children: [
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
              _SummaryPreviewPanel(
                text: _pageController.text,
                emptyText: l10n.noPageSummary,
              ),
              _SummaryEditField(
                controller: _pageController,
                decoration: InputDecoration(
                  labelText: l10n.pageSummary,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          summaryState.showPageCoach
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color:
                              summaryState.showPageCoach ||
                                  summaryState.pageAiSatisfied
                              ? Colors.purple
                              : null,
                        ),
                        onPressed: () {
                          ref.read(summaryProvider.notifier).togglePageCoach();
                        },
                        tooltip: 'AI page summary',
                      ),
                      if (summaryState.pageAiSatisfied &&
                          !summaryState.showPageCoach) ...[
                        AppButtons.icon(
                          iconData: Icons.check_circle,
                          onPressed: () {
                            ref
                                .read(summaryProvider.notifier)
                                .setPageAiSatisfied(false);
                          },
                          tooltip: l10n.imSatisfied,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
                onChanged: _onFieldChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return Column(
      children: [
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
              _SummaryPreviewPanel(
                text: _expandedController.text,
                emptyText: 'No expanded summary available.',
              ),
              _SummaryEditField(
                controller: _expandedController,
                decoration: InputDecoration(
                  labelText: l10n.expandedSummary,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          summaryState.showCoach
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color:
                              summaryState.showCoach ||
                                  summaryState.expandedAiSatisfied
                              ? Colors.purple
                              : null,
                        ),
                        onPressed: () {
                          ref
                              .read(summaryProvider.notifier)
                              .toggleExpandedCoach();
                        },
                        tooltip: l10n.toggleAiCoach,
                      ),
                      if (summaryState.expandedAiSatisfied &&
                          !summaryState.showCoach) ...[
                        IconButton(
                          icon: const Icon(Icons.check_circle, size: 18),
                          color: Colors.green,
                          onPressed: () {
                            ref
                                .read(summaryProvider.notifier)
                                .setExpandedAiSatisfied(false);
                          },
                          tooltip: l10n.imSatisfied,
                        ),
                      ],
                    ],
                  ),
                ),
                onChanged: _onFieldChanged,
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
    final summaryState = ref.watch(summaryProvider);

    ref.listen<SummaryState>(summaryProvider, (previous, next) {
      if (previous?.baseSummary != next.baseSummary) {
        _sentenceController.text = next.baseSummary?.sentenceSummary ?? '';
        _paragraphController.text = next.baseSummary?.paragraphSummary ?? '';
        _pageController.text = next.baseSummary?.pageSummary ?? '';
        _expandedController.text = next.baseSummary?.expandedSummary ?? '';
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summary),
        actions: [
          if (summaryState.refreshing)
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
                ref.invalidate(novelProvider(widget.novelId));
                await _load();
              },
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showCoach =
              summaryState.showCoach ||
              summaryState.showSentenceCoach ||
              summaryState.showParagraphCoach ||
              summaryState.showPageCoach;

          Widget? activeCoachContent;

          if (showCoach) {
            if (summaryState.showSentenceCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'sentence',
                currentSummary: _sentenceController.text,
                onSummaryUpdated: (newSummary) {
                  _sentenceController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !summaryState.sentenceAiSatisfied,
                lastOutput: summaryState.sentenceLastOutput,
                onAiCompleted: (output) {
                  ref
                      .read(summaryProvider.notifier)
                      .setSentenceLastOutput(output);
                  ref
                      .read(summaryProvider.notifier)
                      .setSentenceAiSatisfied(true);
                },
              );
            } else if (summaryState.showParagraphCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'paragraph',
                currentSummary: _paragraphController.text,
                onSummaryUpdated: (newSummary) {
                  _paragraphController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !summaryState.paragraphAiSatisfied,
                lastOutput: summaryState.paragraphLastOutput,
                onAiCompleted: (output) {
                  ref
                      .read(summaryProvider.notifier)
                      .setParagraphLastOutput(output);
                  ref
                      .read(summaryProvider.notifier)
                      .setParagraphAiSatisfied(true);
                },
              );
            } else if (summaryState.showPageCoach) {
              activeCoachContent = SnowflakeCoachWidget(
                novelId: widget.novelId,
                summaryType: 'page',
                currentSummary: _pageController.text,
                onSummaryUpdated: (newSummary) {
                  _pageController.text = newSummary;
                  _onFieldChanged();
                },
                autoAnalyze: !summaryState.pageAiSatisfied,
                lastOutput: summaryState.pageLastOutput,
                onAiCompleted: (output) {
                  ref.read(summaryProvider.notifier).setPageLastOutput(output);
                  ref.read(summaryProvider.notifier).setPageAiSatisfied(true);
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
                autoAnalyze: !summaryState.expandedAiSatisfied,
                lastOutput: summaryState.expandedLastOutput,
                onAiCompleted: (output) {
                  ref
                      .read(summaryProvider.notifier)
                      .setExpandedLastOutput(output);
                  ref
                      .read(summaryProvider.notifier)
                      .setExpandedAiSatisfied(true);
                },
              );
            }
          }

          Widget buildMainContent() {
            final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
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
                    tabs: [
                      Tab(text: l10n.sentenceSummary),
                      Tab(text: l10n.paragraphSummary),
                      Tab(text: l10n.pageSummary),
                      Tab(text: l10n.expandedSummary),
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
                          Flexible(
                            child: AppButtons.primary(
                              icon: Icons.save,
                              label: l10n.save,
                              onPressed:
                                  (summaryState.saving || !summaryState.isDirty)
                                  ? () {}
                                  : () async {
                                      final ok =
                                          _formKey.currentState?.validate() ??
                                          false;
                                      if (!ok) return;
                                      try {
                                        await ref
                                            .read(summaryProvider.notifier)
                                            .save(
                                              sentence:
                                                  _sentenceController.text,
                                              paragraph:
                                                  _paragraphController.text,
                                              page: _pageController.text,
                                              expanded:
                                                  _expandedController.text,
                                            );

                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(l10n.saved)),
                                        );
                                      } catch (_) {
                                        return;
                                      }
                                    },
                              enabled:
                                  !(summaryState.saving ||
                                      !summaryState.isDirty),
                              isLoading: summaryState.saving,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (summaryState.error != null)
                            Expanded(
                              child: Text(
                                summaryState.error!,
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

class _SummaryPreviewPanel extends StatelessWidget {
  const _SummaryPreviewPanel({required this.text, required this.emptyText});

  final String text;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        text.isEmpty ? emptyText : text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _SummaryEditField extends StatelessWidget {
  const _SummaryEditField({
    this.fieldKey,
    required this.controller,
    required this.decoration,
    required this.onChanged,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final InputDecoration decoration;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        decoration: decoration,
        expands: true,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
