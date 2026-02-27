import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/state/notifiers/pattern_list_notifier.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/error_state.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/shared/api_exception.dart';

const int _previewLen = kPreviewLenLong;

class PatternsListScreen extends ConsumerWidget {
  const PatternsListScreen({super.key});

  String _preview(String s) {
    final firstLine = s.split('\n').first.trim();
    if (firstLine.length <= _previewLen) return firstLine;
    return '${firstLine.substring(0, _previewLen)}…';
  }

  DataTable _table(
    List<Pattern> src,
    BuildContext context,
    void Function(Pattern) onRowTap,
    void Function(Pattern) onDelete,
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
                            context.push('/pattern_form', extra: p),
                        tooltip: l10n.editPattern,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete(p),
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

  Future<void> _deletePattern(
    BuildContext context,
    WidgetRef ref,
    Pattern p,
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
        final svc = ref.read(patternsServiceRefProvider);
        final success = await svc.deletePattern(p.id);
        if (success) {
          final listState = ref.read(patternListProvider);
          final showingSearch =
              listState.items.isNotEmpty ||
              listState.searchQuery.trim().isNotEmpty;
          if (showingSearch) {
            ref.read(patternListProvider.notifier).removeItem(p.id);
          } else {
            ref.invalidate(patternsProvider);
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
        if (e is ApiException && e.statusCode == 401) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteErrorWithMessage(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    final patternsAsync = ref.watch(patternsProvider);
    final listState = ref.watch(patternListProvider);
    final searchCtrl = TextEditingController(text: listState.searchQuery);

    final lastRowTap = ref.watch(lastRowTapProvider);

    void onRowTap(Pattern p) {
      final now = DateTime.now();
      if (lastRowTap.id == p.id &&
          lastRowTap.at != null &&
          now.difference(lastRowTap.at!) < kDoubleTapThreshold) {
        context.push('/pattern_form', extra: p);
        ref.read(lastRowTapProvider.notifier).clear();
      } else {
        ref.read(lastRowTapProvider.notifier).set(p.id, now);
      }
    }

    void onDelete(Pattern p) {
      _deletePattern(context, ref, p);
    }

    void onSearchChanged(String query) {
      ref.read(patternListProvider.notifier).setSearchQuery(query);
    }

    void onClearSearch() {
      searchCtrl.clear();
      ref.read(patternListProvider.notifier).clearSearch();
    }

    void onSmartSearch() {
      ref.read(patternListProvider.notifier).smartSearch();
    }

    void onFilterLanguageChanged(String? language) {
      ref.read(patternListProvider.notifier).setFilterLanguage(language);
    }

    void onToggleFilterLocked() {
      ref.read(patternListProvider.notifier).toggleFilterLocked();
    }

    Widget filters(int count) {
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
                          onPressed: onClearSearch,
                          tooltip: 'Clear search',
                        ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        onPressed: onSmartSearch,
                        tooltip: l10n.smartSearch,
                      ),
                    ],
                  ),
                ),
                onChanged: onSearchChanged,
                onSubmitted: (_) => ref
                    .read(patternListProvider.notifier)
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
                    onChanged: onFilterLanguageChanged,
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
                key: const ValueKey('patternsLockedFilterButton'),
                icon: Icon(
                  listState.filterLocked == null
                      ? Icons.filter_alt_off
                      : (listState.filterLocked!
                            ? Icons.lock
                            : Icons.lock_open),
                ),
                onPressed: onToggleFilterLocked,
              ),
            ),
          ],
        ),
      );
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
        title: Text(l10n.patterns),
        actions: [
          AppButtons.icon(
            onPressed: () => ref.invalidate(patternsProvider),
            iconData: Icons.refresh,
            tooltip: l10n.reload,
          ),
          AppButtons.icon(
            onPressed: isSignedIn ? () => context.push('/pattern_form') : () {},
            iconData: Icons.add,
            tooltip: l10n.newPattern,
            enabled: isSignedIn,
          ),
          AppButtons.icon(
            onPressed: () => context.go('/'),
            iconData: Icons.home,
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
                itemBuilder: (context, index) => const PatternItemSkeleton(),
              ),
            )
          : listState.error != null
          ? ErrorState(
              message: listState.error!,
              onRetry: () => ref.invalidate(patternsProvider),
            )
          : patternsAsync.when(
              data: (items0) {
                final q = listState.searchQuery.trim();
                final isSearching =
                    q.isNotEmpty &&
                    (q.length >= kSearchMinLen || listState.items.isNotEmpty);
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
                  return Center(child: Text(l10n.noPatterns));
                }
                return Column(
                  children: [
                    filters(items.length),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _table(items, context, onRowTap, onDelete),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const PatternItemSkeleton(),
                ),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }
}
