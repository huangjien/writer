import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pattern.dart';
import '../state/pattern_providers.dart';
import '../state/providers.dart';
import '../l10n/app_localizations.dart';

const int _previewLen = 80;

class PatternsListScreen extends ConsumerStatefulWidget {
  const PatternsListScreen({super.key});
  @override
  ConsumerState<PatternsListScreen> createState() => _PatternsListScreenState();
}

class _PatternsListScreenState extends ConsumerState<PatternsListScreen> {
  DateTime? _lastRowTapAt;
  String? _lastRowTapId;

  String _preview(String s) {
    if (s.length <= _previewLen) return s;
    return '${s.substring(0, _previewLen)}…';
  }

  void _onRowTap(Pattern p) {
    final now = DateTime.now();
    if (_lastRowTapId == p.id &&
        _lastRowTapAt != null &&
        now.difference(_lastRowTapAt!) < const Duration(milliseconds: 300)) {
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
      final svc = ref.read(patternsServiceRefProvider);
      await svc.deletePattern(p.id);
      ref.invalidate(patternsProvider);
    }
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
            onPressed: isSupabaseEnabled ? () => context.push('/pattern_form') : null,
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
      body: patternsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            if (!isSupabaseEnabled) {
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
            return Center(child: Text(l10n.noPatterns));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            child: _table(items),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
