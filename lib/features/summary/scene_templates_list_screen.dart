import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/shared/constants.dart';
import '../../models/scene_template_row.dart';
import '../../state/providers.dart';

class SceneTemplatesListScreen extends ConsumerStatefulWidget {
  const SceneTemplatesListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<SceneTemplatesListScreen> createState() =>
      _SceneTemplatesListScreenState();
}

class _SceneTemplatesListScreenState
    extends ConsumerState<SceneTemplatesListScreen> {
  List<SceneTemplateRow> _items = const [];
  List<SceneTemplateRow> _displayItems = const [];
  bool _loading = true;
  bool _searchLoading = false;
  String? _error;
  final _searchCtrl = TextEditingController();
  DateTime? _lastRowTapAt;
  String? _lastRowTapId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(templateRepositoryProvider);
      if (ref.read(isSignedInProvider)) {
        _items = await repo.listSceneTemplates();
      } else {
        _items = []; // Local items if supported
      }

      _localSearch();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _localSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      _displayItems = _items;
      return;
    }
    _displayItems = _items.where((t) {
      final title = (t.title ?? '').toLowerCase();
      return title.contains(q);
    }).toList();
  }

  Future<void> _smartSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;

    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Smart search requires sign in')),
      );
      return;
    }

    setState(() {
      _searchLoading = true;
    });

    try {
      final repo = ref.read(templateRepositoryProvider);
      final res = await repo.searchSceneTemplates(q, limit: 5);

      if (!mounted) return;
      setState(() {
        _displayItems = res.isEmpty ? _items : res;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _searchLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEdit(SceneTemplateRow it) {
    context.push('/novel/${widget.novelId}/scene-templates/${it.id}');
  }

  void _onRowTap(SceneTemplateRow it) {
    final now = DateTime.now();
    if (_lastRowTapId == it.id &&
        _lastRowTapAt != null &&
        now.difference(_lastRowTapAt!) < kDoubleTapThreshold) {
      _openEdit(it);
      _lastRowTapAt = null;
      _lastRowTapId = null;
    } else {
      _lastRowTapAt = now;
      _lastRowTapId = it.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/')),
          title: Text(l10n.sceneTemplates),
          actions: [
            if (_loading || _searchLoading)
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
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refreshTooltip,
              ),
            IconButton(
              onPressed: () =>
                  context.push('/novel/${widget.novelId}/scene-templates/new'),
              icon: const Icon(Icons.add),
              tooltip: l10n.newLabel,
            ),
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              tooltip: l10n.home,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.searchLabel,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          tooltip: 'Smart Search',
                          onPressed: _smartSearch,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _localSearch();
                        });
                      },
                      onSubmitted: (_) => _smartSearch(),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (ctx, i) {
                        final it = _displayItems[i];
                        final title = it.title ?? l10n.untitled;
                        final subtitle =
                            (it.sceneSummaries ?? it.sceneSynopses ?? '')
                                .replaceAll('**', '')
                                .replaceAll(RegExp(r'\s+'), ' ')
                                .trim();
                        final theme = Theme.of(context);
                        final titleStyle = theme.textTheme.titleMedium;
                        final subtitleStyle = theme.textTheme.bodySmall
                            ?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                        return ListTile(
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: title, style: titleStyle),
                                if (subtitle.isNotEmpty)
                                  TextSpan(
                                    text: '  $subtitle',
                                    style: subtitleStyle,
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _onRowTap(it),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openEdit(it),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (d) => AlertDialog(
                                      title: Text(l10n.deleteTemplateTitle),
                                      content: Text(l10n.confirmDeleteGeneric),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(d, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(d, true),
                                          child: Text(l10n.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    try {
                                      final repo = ref.read(
                                        templateRepositoryProvider,
                                      );
                                      await repo.deleteSceneTemplate(it.id);
                                      await _load();
                                      if (!context.mounted) return;
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: _displayItems.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
