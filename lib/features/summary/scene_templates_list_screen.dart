import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
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
  List<SceneTemplateRow> _items = const [];
  bool _loading = true;
  String? _error;

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
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sceneTemplates),
        actions: [
          if (_loading)
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (ctx, i) {
                final it = _items[i];
                final title = it.title ?? l10n.untitled;
                final subtitle = it.sceneSummaries ?? it.sceneSynopses ?? '';
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
                                  onPressed: () => Navigator.pop(d, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(d, true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            final repo = ref.read(
                              localStorageRepositoryProvider,
                            );
                            await repo.deleteSceneTemplate(it.id);
                            await _load();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: _items.length,
            ),
    );
  }
}
