import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/state/supabase_config.dart';
import '../../main.dart';
import '../../models/scene_template_row.dart';

class SceneTemplatesListScreen extends ConsumerStatefulWidget {
  const SceneTemplatesListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<SceneTemplatesListScreen> createState() =>
      _SceneTemplatesListScreenState();
}

class _SceneTemplatesListScreenState
    extends ConsumerState<SceneTemplatesListScreen> {
  static const int _searchDebounceMs = 250;
  List<SceneTemplateRow> _items = const [];
  List<SceneTemplateRow> _displayItems = const [];
  bool _loading = true;
  bool _searchLoading = false;
  String? _error;
  final _searchCtrl = TextEditingController();
  Timer? _searchTimer;

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
      final repo = ref.read(localStorageRepositoryProvider);
      _items = await repo.listSceneTemplates();
      _displayItems = _items;
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _search({bool force = false}) async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      if (mounted) {
        setState(() {
          _searchLoading = false;
          _displayItems = _items;
        });
      }
      return;
    }

    if (!supabaseEnabled) {
      if (mounted) {
        setState(() {
          _searchLoading = false;
          _displayItems = _items
              .where(
                (t) => (t.title ?? '').toLowerCase().contains(q.toLowerCase()),
              )
              .toList();
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _searchLoading = true;
      });
    }
    try {
      final ai = ref.read(aiChatServiceProvider);
      final vec = await ai.embed(q);
      if (!mounted) return;
      if (vec == null || vec.isEmpty) {
        setState(() {
          _searchLoading = false;
          _displayItems = _items
              .where(
                (t) => (t.title ?? '').toLowerCase().contains(q.toLowerCase()),
              )
              .toList();
        });
        return;
      }
      final repo = ref.read(localStorageRepositoryProvider);
      final res = await repo.searchSceneTemplatesByVector(vec, limit: 50);
      if (!mounted) return;
      setState(() {
        _displayItems = res;
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
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
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
                        suffixText: '${_displayItems.length}',
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
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (ctx, i) {
                        final it = _displayItems[i];
                        final title = it.title ?? l10n.untitled;
                        final subtitle =
                            it.sceneSummaries ?? it.sceneSynopses ?? '';
                        return ListTile(
                          title: Text(title),
                          subtitle: subtitle.isEmpty
                              ? null
                              : Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  context.push(
                                    '/novel/${widget.novelId}/scene-templates/${it.id}',
                                  );
                                },
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
                                        localStorageRepositoryProvider,
                                      );
                                      await repo.deleteSceneTemplate(it.id);
                                      await _load();
                                      if (!context.mounted) return;
                                      await _search(force: true);
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
