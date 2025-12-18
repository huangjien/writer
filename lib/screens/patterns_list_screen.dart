import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pattern.dart';
import '../state/pattern_providers.dart';
import '../state/providers.dart';
import '../l10n/app_localizations.dart';
import '../shared/constants.dart';

const int _previewLen = kPreviewLenLong;
const int _searchDebounceMs = kSearchDebounceMs;
const int _searchMinLen = kSearchMinLen;

class PatternsListScreen extends ConsumerStatefulWidget {
  const PatternsListScreen({super.key});
  @override
  ConsumerState<PatternsListScreen> createState() => _PatternsListScreenState();
}

class _PatternsListScreenState extends ConsumerState<PatternsListScreen> {
  DateTime? _lastRowTapAt;
  String? _lastRowTapId;
  final _searchCtrl = TextEditingController();
  Timer? _searchTimer;
  List<Pattern> _items = [];
  bool _searchLoading = false;
  String? _error;
  String? _filterLanguage;
  bool? _filterLocked;

  String _preview(String s) {
    if (s.length <= _previewLen) return s;
    return '${s.substring(0, _previewLen)}…';
  }

  void _onRowTap(Pattern p) {
    final now = DateTime.now();
    if (_lastRowTapId == p.id &&
        _lastRowTapAt != null &&
        now.difference(_lastRowTapAt!) < kDoubleTapThreshold) {
      context.push('/pattern_form', extra: p);
      _lastRowTapAt = null;
      _lastRowTapId = null;
    } else {
      _lastRowTapAt = now;
      _lastRowTapId = p.id;
    }
  }

  DataTable _table(List<Pattern> src) {
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
                DataCell(Text(p.title), onTap: () => _onRowTap(p)),
                DataCell(
                  Text(_preview(p.description ?? p.content)),
                  onTap: () => _onRowTap(p),
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
                        onPressed: () => _deletePattern(p),
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

  Future<void> _deletePattern(Pattern p) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteDescription(p.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        final svc = ref.read(patternsServiceRefProvider);
        final success = await svc.deletePattern(p.id);
        if (success) {
          final showingSearch =
              _items.isNotEmpty || _searchCtrl.text.trim().isNotEmpty;
          if (showingSearch) {
            setState(() {
              _items = _items.where((e) => e.id != p.id).toList();
            });
          } else {
            ref.invalidate(patternsProvider);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deletedWithTitle(p.title))),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.deleteFailedWithTitle(p.title))),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteErrorWithMessage(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _search({bool force = false}) async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _items = [];
        _error = null;
      });
      return;
    }
    if (!force && q.length < _searchMinLen) {
      return;
    }
    setState(() {
      _searchLoading = true;
      _error = null;
    });
    try {
      final svc = ref.read(patternsServiceRefProvider);
      final data = await svc.searchPatterns(q);
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _searchLoading = false;
      });
    }
  }

  Widget _filters(int count) {
    final l10n = AppLocalizations.of(context)!;
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
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                suffixText: '$count',
              ),
              onChanged: (_) {
                _searchTimer?.cancel();
                _searchTimer = Timer(
                  const Duration(milliseconds: _searchDebounceMs),
                  _search,
                );
              },
              onSubmitted: (_) => _search(force: true),
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
                  value: _filterLanguage,
                  isDense: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.allLabel)),
                    DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
                  ],
                  onChanged: (v) => setState(() => _filterLanguage = v),
                ),
              ),
            ),
          ),
          Tooltip(
            message: _filterLocked == null
                ? l10n.filterByLocked
                : (_filterLocked! ? l10n.lockedOnly : l10n.unlockedOnly),
            child: IconButton(
              icon: Icon(
                _filterLocked == null
                    ? Icons.filter_alt_off
                    : (_filterLocked! ? Icons.lock : Icons.lock_open),
              ),
              onPressed: () {
                setState(() {
                  if (_filterLocked == null) {
                    _filterLocked = true;
                  } else if (_filterLocked == true) {
                    _filterLocked = false;
                  } else {
                    _filterLocked = null;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSupabaseEnabled = ref.watch(supabaseEnabledProvider);
    final patternsAsync = ref.watch(patternsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patterns),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(patternsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.reload,
          ),
          IconButton(
            onPressed: isSupabaseEnabled
                ? () => context.push('/pattern_form')
                : null,
            icon: const Icon(Icons.add),
            tooltip: l10n.newPattern,
          ),
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            tooltip: l10n.home,
          ),
        ],
      ),
      body: _searchLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : patternsAsync.when(
              data: (items0) {
                final isSearching = _searchCtrl.text.trim().isNotEmpty;
                var items = isSearching ? _items : items0;

                if (_filterLanguage != null) {
                  items = items
                      .where((p) => (p.language ?? 'en') == _filterLanguage)
                      .toList();
                }
                if (_filterLocked != null) {
                  items = items
                      .where((p) => (p.locked ?? false) == _filterLocked)
                      .toList();
                }

                if (!isSupabaseEnabled && items0.isEmpty && !isSearching) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.supabaseNotEnabled,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.supabaseNotEnabledDescription,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.goNamed('settings'),
                            child: Text(l10n.supabaseSettings),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (items.isEmpty && !isSearching) {
                  return Center(child: Text(l10n.noPatterns));
                }
                return Column(
                  children: [
                    _filters(items.length),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _table(items),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
