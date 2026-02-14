import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/story_line.dart';
import '../shared/api_exception.dart';
import '../../state/story_line_providers.dart';
import '../../state/notifiers/story_line_list_notifier.dart';
import '../../state/notifiers/pattern_list_notifier.dart';
import '../../state/providers.dart';
import '../l10n/app_localizations.dart';
import '../shared/constants.dart';
import '../shared/widgets/app_buttons.dart';
import '../shared/widgets/app_dialog.dart';
import '../shared/widgets/loading/skeleton_list_items.dart';
import '../shared/widgets/error_state.dart';

const int _previewLen = kPreviewLenLong;

class StoryLinesListScreen extends ConsumerWidget {
  const StoryLinesListScreen({super.key});

  String _preview(String s) {
    final firstLine = s.split('\n').first.trim();
    if (firstLine.length <= _previewLen) return firstLine;
    return '${firstLine.substring(0, _previewLen)}…';
  }

  DataTable _table(
    BuildContext context,
    WidgetRef ref,
    List<StoryLine> src,
    Function(StoryLine) onRowTap,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return DataTable(
      columns: [
        DataColumn(label: Text(l10n.titleLabel)),
        DataColumn(label: Text(l10n.previewLabel)),
        DataColumn(label: Text(l10n.metaLabel)),
        DataColumn(label: Text(l10n.actions)),
      ],
      rows: src
          .map(
            (p) => DataRow(
              cells: [
                DataCell(Text(p.title), onTap: () => onRowTap(p)),
                DataCell(
                  Text(_preview(p.description ?? p.content)),
                  onTap: () => onRowTap(p),
                ),
                DataCell(
                  Row(
                    children: [
                      Text(p.language ?? 'en'),
                      const SizedBox(width: 8),
                      Icon(
                        p.locked == true ? Icons.lock : Icons.lock_open,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.push('/story_line_form', extra: p),
                        tooltip: l10n.editStoryLine,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStoryLine(context, ref, p),
                        tooltip: l10n.delete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Future<void> _deleteStoryLine(
    BuildContext context,
    WidgetRef ref,
    StoryLine p,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: l10n.confirmDelete,
        content: Text(l10n.confirmDeleteDescription(p.title)),
        actions: [
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx, false),
            label: l10n.cancel,
          ),
          AppButtons.text(
            onPressed: () => Navigator.pop(ctx, true),
            label: l10n.delete,
            color: Theme.of(ctx).colorScheme.error,
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final svc = ref.read(storyLinesServiceRefProvider);
        final success = await svc.deleteStoryLine(p.id);
        if (success) {
          final listState = ref.read(storyLineListProvider);
          final showingSearch =
              listState.items.isNotEmpty || listState.searchQuery.isNotEmpty;
          if (showingSearch) {
            ref.read(storyLineListProvider.notifier).removeItem(p.id);
          } else {
            ref.invalidate(storyLinesProvider);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deletedWithTitle(p.title))),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deleteFailedWithTitle(p.title))),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteErrorWithMessage(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _smartSearch(
    BuildContext context,
    WidgetRef ref,
    TextEditingController searchCtrl,
  ) async {
    final q = searchCtrl.text.trim();
    if (q.isEmpty) return;

    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.notSignedIn)),
        );
      }
      return;
    }

    ref.read(storyLineListProvider.notifier).setSearchLoading(true);

    try {
      final svc = ref.read(storyLinesServiceRefProvider);
      final res = await svc.smartSearchStoryLines(q, limit: 5);
      if (!context.mounted) return;
      if (res.isEmpty) {
        await ref
            .read(storyLineListProvider.notifier)
            .performSearch(force: true);
      } else {
        ref.read(storyLineListProvider.notifier).setSearchItems(res);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (!context.mounted) return;
      ref.read(storyLineListProvider.notifier).setError(e.toString());
    } finally {
      if (context.mounted) {
        ref.read(storyLineListProvider.notifier).setSearchLoading(false);
      }
    }
  }

  Widget _filters(
    BuildContext context,
    WidgetRef ref,
    TextEditingController searchCtrl,
    int count,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final listState = ref.watch(storyLineListProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                suffixText: '$count',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchCtrl.clear();
                          ref
                              .read(storyLineListProvider.notifier)
                              .clearSearch();
                        },
                        tooltip: 'Clear search',
                      ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      onPressed: () => _smartSearch(context, ref, searchCtrl),
                      tooltip: l10n.smartSearch,
                    ),
                  ],
                ),
              ),
              onChanged: (_) {
                ref
                    .read(storyLineListProvider.notifier)
                    .setSearchQuery(searchCtrl.text);
              },
              onSubmitted: (_) => ref
                  .read(storyLineListProvider.notifier)
                  .performSearch(force: true),
            ),
          ),
          SizedBox(
            width: 180,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.languageLabel(''),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: listState.filterLanguage,
                  isDense: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.allLabel)),
                    DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
                  ],
                  onChanged: (v) => ref
                      .read(storyLineListProvider.notifier)
                      .setFilterLanguage(v),
                ),
              ),
            ),
          ),
          Tooltip(
            message: listState.filterLocked == null
                ? l10n.filterByLocked
                : (listState.filterLocked!
                      ? l10n.lockedOnly
                      : l10n.unlockedOnly),
            child: IconButton(
              icon: Icon(
                listState.filterLocked == null
                    ? Icons.filter_alt_off
                    : (listState.filterLocked! ? Icons.lock : Icons.lock_open),
              ),
              onPressed: () {
                ref.read(storyLineListProvider.notifier).toggleFilterLocked();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    final storyLinesAsync = ref.watch(storyLinesProvider);
    final listState = ref.watch(storyLineListProvider);
    final searchCtrl = TextEditingController(text: listState.searchQuery);
    final lastRowTap = ref.watch(lastRowTapProvider);

    void onRowTap(StoryLine p) {
      final now = DateTime.now();
      if (lastRowTap.id == p.id &&
          lastRowTap.at != null &&
          now.difference(lastRowTap.at!) < kDoubleTapThreshold) {
        context.push('/story_line_form', extra: p);
        ref.read(lastRowTapProvider.notifier).clear();
      } else {
        ref.read(lastRowTapProvider.notifier).set(p.id, now);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(l10n.storyLines),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(storyLinesProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.reload,
          ),
          IconButton(
            onPressed: isSignedIn
                ? () => context.push('/story_line_form')
                : null,
            icon: const Icon(Icons.add),
            tooltip: l10n.newStoryLine,
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: l10n.home,
          ),
        ],
      ),
      body: !isSignedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.signInToSync),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push('/auth'),
                      child: Text(l10n.signIn),
                    ),
                  ],
                ),
              ),
            )
          : listState.searchLoading
          ? Center(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const StoryLineItemSkeleton(),
              ),
            )
          : listState.error != null
          ? ErrorState(
              message: listState.error!,
              onRetry: () => ref.invalidate(storyLinesProvider),
            )
          : storyLinesAsync.when(
              data: (items0) {
                final isSearching = searchCtrl.text.trim().isNotEmpty;
                var items = isSearching ? listState.items : items0;

                if (listState.filterLanguage != null) {
                  items = items
                      .where(
                        (p) => (p.language ?? 'en') == listState.filterLanguage,
                      )
                      .toList();
                }
                if (listState.filterLocked != null) {
                  items = items
                      .where(
                        (p) => (p.locked ?? false) == listState.filterLocked,
                      )
                      .toList();
                }

                if (items.isEmpty && !isSearching) {
                  return Center(child: Text(l10n.noStoryLines));
                }
                return Column(
                  children: [
                    _filters(context, ref, searchCtrl, items.length),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _table(context, ref, items, onRowTap),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      const StoryLineItemSkeleton(),
                ),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }
}
