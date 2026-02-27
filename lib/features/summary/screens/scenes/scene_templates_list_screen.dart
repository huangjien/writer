import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/error_state.dart';
import 'package:writer/features/summary/state/template_list_state.dart';

class SceneTemplatesListScreen extends ConsumerWidget {
  const SceneTemplatesListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SceneTemplatesListContent(novelId: novelId);
  }
}

class _SceneTemplatesListContent extends ConsumerStatefulWidget {
  const _SceneTemplatesListContent({required this.novelId});
  final String novelId;

  @override
  ConsumerState<_SceneTemplatesListContent> createState() =>
      _SceneTemplatesListContentState();
}

class _SceneTemplatesListContentState
    extends ConsumerState<_SceneTemplatesListContent> {
  final _searchCtrl = TextEditingController();
  DateTime? _lastRowTapAt;
  String? _lastRowTapId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(sceneTemplateListProvider.notifier).setLoading(true);
    ref.read(sceneTemplateListProvider.notifier).clearError();

    try {
      final repo = ref.read(templateRepositoryProvider);
      List<SceneTemplateRow> items = [];
      if (ref.read(isSignedInProvider)) {
        items = await repo.listSceneTemplates();
      } else {
        items = [];
      }

      ref.read(sceneTemplateListProvider.notifier).setItems(items);
      _localSearch();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      ref.read(sceneTemplateListProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) {
        ref.read(sceneTemplateListProvider.notifier).setLoading(false);
      }
    }
  }

  void _localSearch() {
    final listState = ref.read(sceneTemplateListProvider);
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      ref
          .read(sceneTemplateListProvider.notifier)
          .setDisplayItems(listState.items);
      return;
    }
    final filtered = listState.items.where((t) {
      final title = (t.title ?? '').toLowerCase();
      return title.contains(q);
    }).toList();
    ref.read(sceneTemplateListProvider.notifier).setDisplayItems(filtered);
  }

  Future<void> _smartSearch(BuildContext context) async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;

    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.smartSearchRequiresSignIn)));
      return;
    }

    ref.read(sceneTemplateListProvider.notifier).setSearchLoading(true);

    try {
      final repo = ref.read(templateRepositoryProvider);
      final res = await repo.searchSceneTemplates(q, limit: 5);

      if (mounted) {
        ref.read(sceneTemplateListProvider.notifier).setDisplayItems(res);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (mounted) {
        ref.read(sceneTemplateListProvider.notifier).setError(e.toString());
      }
    } finally {
      if (mounted) {
        ref.read(sceneTemplateListProvider.notifier).setSearchLoading(false);
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
    final l10n = AppLocalizations.of(context)!;
    final listState = ref.watch(sceneTemplateListProvider);

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
            if (listState.isLoading || listState.searchLoading)
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
        body: listState.isLoading
            ? Center(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const SceneItemSkeleton(),
                ),
              )
            : listState.error != null
            ? ErrorState(message: listState.error!, onRetry: _load)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.searchLabel,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchCtrl.text.isNotEmpty)
                              AppButtons.icon(
                                iconData: Icons.clear,
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _localSearch();
                                },
                                tooltip: 'Clear search',
                                focusPadding: EdgeInsets.zero,
                              ),
                            AppButtons.icon(
                              iconData: Icons.auto_awesome,
                              tooltip: l10n.smartSearch,
                              onPressed: () => _smartSearch(context),
                              focusPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      onChanged: (_) {
                        _localSearch();
                      },
                      onSubmitted: (_) => _smartSearch(context),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (ctx, i) {
                        final it = listState.displayItems[i];
                        final title = it.title ?? l10n.untitled;
                        final rawSubtitle =
                            it.sceneSummaries ?? it.sceneSynopses ?? '';
                        final firstLine = rawSubtitle.split('\n').first;
                        final subtitle = firstLine.replaceAll('*', '').trim();
                        final theme = Theme.of(context);
                        final titleStyle = theme.textTheme.titleMedium;
                        final subtitleStyle = theme.textTheme.bodySmall
                            ?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onRowTap(it),
                            hoverColor:
                                theme.colorScheme.surfaceContainerHighest,
                            child: ListTile(
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
                                        builder: (d) => AppDialog(
                                          title: l10n.deleteTemplateTitle,
                                          content: Text(
                                            l10n.confirmDeleteGeneric,
                                          ),
                                          actions: [
                                            AppButtons.text(
                                              onPressed: () =>
                                                  Navigator.pop(d, false),
                                              label: l10n.cancel,
                                            ),
                                            AppButtons.text(
                                              onPressed: () =>
                                                  Navigator.pop(d, true),
                                              label: l10n.delete,
                                              color: Theme.of(
                                                d,
                                              ).colorScheme.error,
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
                                          if (e is ApiException &&
                                              e.statusCode == 401) {
                                            return;
                                          }
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
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: listState.displayItems.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
