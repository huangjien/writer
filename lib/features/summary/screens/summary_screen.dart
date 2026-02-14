import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/features/summary/widgets/summary_coach_panel.dart';
import 'package:writer/features/summary/widgets/summary_main_content.dart';
import 'package:writer/features/summary/widgets/summary_preview_edit_tab.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/features/summary/state/summary_notifier.dart';

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

    return SummaryPreviewEditTab(
      tabController: _sentenceTabController,
      previewLabel: l10n.previewLabel,
      editLabel: l10n.edit,
      text: _sentenceController.text,
      emptyText: l10n.noSentenceSummary,
      fieldKey: const Key('sentence_summary_field'),
      editController: _sentenceController,
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
                ref.read(summaryProvider.notifier).resetCoaches();
                if (!summaryState.showSentenceCoach) {
                  ref.read(summaryProvider.notifier).toggleSentenceCoach();
                }
              },
              tooltip: l10n.aiSentenceSummaryTooltip,
            ),
            if (summaryState.sentenceAiSatisfied &&
                !summaryState.showSentenceCoach)
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
        ),
      ),
      onChanged: _onFieldChanged,
    );
  }

  Widget _buildParagraphTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return SummaryPreviewEditTab(
      tabController: _paragraphTabController,
      previewLabel: l10n.previewLabel,
      editLabel: l10n.edit,
      text: _paragraphController.text,
      emptyText: l10n.noParagraphSummary,
      editController: _paragraphController,
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
                ref.read(summaryProvider.notifier).toggleParagraphCoach();
              },
              tooltip: l10n.aiParagraphSummaryTooltip,
            ),
            if (summaryState.paragraphAiSatisfied &&
                !summaryState.showParagraphCoach)
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
        ),
      ),
      onChanged: _onFieldChanged,
    );
  }

  Widget _buildPageTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return SummaryPreviewEditTab(
      tabController: _pageTabController,
      previewLabel: l10n.previewLabel,
      editLabel: l10n.edit,
      text: _pageController.text,
      emptyText: l10n.noPageSummary,
      editController: _pageController,
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
                    summaryState.showPageCoach || summaryState.pageAiSatisfied
                    ? Colors.purple
                    : null,
              ),
              onPressed: () {
                ref.read(summaryProvider.notifier).togglePageCoach();
              },
              tooltip: l10n.toggleAiCoach,
            ),
            if (summaryState.pageAiSatisfied && !summaryState.showPageCoach)
              AppButtons.icon(
                iconData: Icons.check_circle,
                onPressed: () {
                  ref.read(summaryProvider.notifier).setPageAiSatisfied(false);
                },
                tooltip: l10n.imSatisfied,
                color: Colors.green,
              ),
          ],
        ),
      ),
      onChanged: _onFieldChanged,
    );
  }

  Widget _buildExpandedTab() {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final summaryState = ref.watch(summaryProvider);

    return SummaryPreviewEditTab(
      tabController: _expandedTabController,
      previewLabel: l10n.previewLabel,
      editLabel: l10n.edit,
      text: _expandedController.text,
      emptyText: l10n.noExpandedSummary,
      editController: _expandedController,
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
                    summaryState.showCoach || summaryState.expandedAiSatisfied
                    ? Colors.purple
                    : null,
              ),
              onPressed: () {
                ref.read(summaryProvider.notifier).toggleExpandedCoach();
              },
              tooltip: l10n.toggleAiCoach,
            ),
            if (summaryState.expandedAiSatisfied && !summaryState.showCoach)
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
        ),
      ),
      onChanged: _onFieldChanged,
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
          final activeCoachContent = buildSummaryCoachPanel(
            context: context,
            ref: ref,
            novelId: widget.novelId,
            summaryState: summaryState,
            sentenceController: _sentenceController,
            paragraphController: _paragraphController,
            pageController: _pageController,
            expandedController: _expandedController,
            onFieldChanged: _onFieldChanged,
          );

          final mainContent = SummaryMainContent(
            formKey: _formKey,
            novelHeader: _buildNovelHeader(),
            tabController: _tabController,
            tabs: [
              Tab(text: l10n.sentenceSummary),
              Tab(text: l10n.paragraphSummary),
              Tab(text: l10n.pageSummary),
              Tab(text: l10n.expandedSummary),
            ],
            tabViews: [
              _buildSummaryTab(),
              _buildParagraphTab(),
              _buildPageTab(),
              _buildExpandedTab(),
            ],
            footer: Flexible(
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
                                    _formKey.currentState?.validate() ?? false;
                                if (!ok) return;
                                try {
                                  await ref
                                      .read(summaryProvider.notifier)
                                      .save(
                                        sentence: _sentenceController.text,
                                        paragraph: _paragraphController.text,
                                        page: _pageController.text,
                                        expanded: _expandedController.text,
                                      );

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.saved)),
                                  );
                                } catch (_) {
                                  return;
                                }
                              },
                        enabled:
                            !(summaryState.saving || !summaryState.isDirty),
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
          );

          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(flex: 2, child: mainContent),
                if (activeCoachContent != null) ...[
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
                Expanded(flex: 1, child: mainContent),
                if (activeCoachContent != null) ...[
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
