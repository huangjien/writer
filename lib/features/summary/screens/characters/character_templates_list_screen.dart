import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/shared/widgets/loading/skeleton_list_items.dart';
import 'package:writer/shared/widgets/error_state.dart';
import 'package:writer/features/summary/state/character_templates_list_providers.dart';

class _EditIntent extends Intent {
  const _EditIntent();
}

class CharacterTemplatesListScreen extends ConsumerStatefulWidget {
  const CharacterTemplatesListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<CharacterTemplatesListScreen> createState() =>
      _CharacterTemplatesListScreenState();
}

class _CharacterTemplatesListScreenState
    extends ConsumerState<CharacterTemplatesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    final notifier = ref.read(characterTemplatesListProvider.notifier);
    final state = ref.read(characterTemplatesListProvider);
    notifier.setLoading(true);
    notifier.setError(null);

    try {
      final repo = ref.read(templateRepositoryProvider);
      final items = ref.read(isSignedInProvider)
          ? await repo.listCharacterTemplates()
          : <CharacterTemplateRow>[];

      final q = state.searchCtrl.text.trim().toLowerCase();
      final displayItems = q.isEmpty
          ? items
          : items.where((t) {
              final title = (t.title ?? '').toLowerCase();
              return title.contains(q);
            }).toList();

      if (mounted) {
        notifier.setItems(items, displayItems);
        notifier.setLoading(false);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (mounted) {
        notifier.setError(e.toString());
        notifier.setLoading(false);
      }
    }
  }

  Future<void> _smartSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(characterTemplatesListProvider);
    final notifier = ref.read(characterTemplatesListProvider.notifier);
    final q = state.searchCtrl.text.trim();
    if (q.isEmpty) return;

    final isSignedIn = ref.read(isSignedInProvider);
    if (!isSignedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.smartSearchRequiresSignIn)));
      return;
    }

    notifier.setSearchLoading(true);

    try {
      final repo = ref.read(templateRepositoryProvider);
      final res = await repo.searchCharacterTemplates(q, limit: 5);

      if (mounted) {
        notifier.setItems(res, res);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      if (mounted) {
        notifier.setError(e.toString());
      }
    } finally {
      if (mounted) {
        notifier.setSearchLoading(false);
      }
    }
  }

  void _openEdit(CharacterTemplateRow it) {
    ref.read(characterTemplatesListProvider.notifier).setSelectedId(it.id);
    context.push('/novel/${widget.novelId}/character-templates/${it.id}');
  }

  void _onRowTap(CharacterTemplateRow it) {
    final state = ref.read(characterTemplatesListProvider);
    final notifier = ref.read(characterTemplatesListProvider.notifier);
    notifier.setSelectedId(it.id);

    final now = DateTime.now();
    if (state.lastRowTapId == it.id &&
        state.lastRowTapAt != null &&
        now.difference(state.lastRowTapAt!) < kDoubleTapThreshold) {
      _openEdit(it);
      notifier.setLastRowTap(null, null);
    } else {
      notifier.setLastRowTap(now, it.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(characterTemplatesListProvider);
    final notifier = ref.read(characterTemplatesListProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/')),
          title: Text(l10n.characterTemplates),
          actions: [
            if (state.isLoading || state.isSearchLoading)
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
              onPressed: () => context.push(
                '/novel/${widget.novelId}/character-templates/new',
              ),
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
        body: state.isLoading
            ? Center(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      const CharacterItemSkeleton(),
                ),
              )
            : state.error != null
            ? ErrorState(message: state.error!, onRetry: _load)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: state.searchCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.searchLabel,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.searchCtrl.text.isNotEmpty)
                              AppButtons.icon(
                                iconData: Icons.clear,
                                onPressed: () {
                                  state.searchCtrl.clear();
                                  notifier.setLocalSearch();
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
                      onChanged: (_) => notifier.setLocalSearch(),
                      onSubmitted: (_) => _smartSearch(context),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (ctx, i) {
                        final it = state.displayItems[i];
                        final title = it.title ?? l10n.untitled;
                        final rawSubtitle =
                            it.characterSummaries ?? it.characterSynopses ?? '';
                        final firstLine = rawSubtitle.split('\n').first;
                        final subtitle = firstLine.replaceAll('**', '').trim();
                        final theme = Theme.of(context);
                        final titleStyle = theme.textTheme.titleMedium;
                        final subtitleStyle = theme.textTheme.bodySmall
                            ?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            );

                        return Material(
                          color: Colors.transparent,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: () => _onRowTap(it),
                              hoverColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              child: Shortcuts(
                                shortcuts: const <ShortcutActivator, Intent>{
                                  SingleActivator(LogicalKeyboardKey.enter):
                                      _EditIntent(),
                                  SingleActivator(
                                    LogicalKeyboardKey.numpadEnter,
                                  ): _EditIntent(),
                                },
                                child: Actions(
                                  actions: <Type, Action<Intent>>{
                                    _EditIntent: CallbackAction<_EditIntent>(
                                      onInvoke: (_) {
                                        _openEdit(it);
                                        return null;
                                      },
                                    ),
                                  },
                                  child: Focus(
                                    canRequestFocus: true,
                                    onFocusChange: (hasFocus) {
                                      if (!hasFocus) return;
                                      ref
                                          .read(
                                            characterTemplatesListProvider
                                                .notifier,
                                          )
                                          .setSelectedId(it.id);
                                    },
                                    child: ListTile(
                                      selected: state.selectedId == it.id,
                                      selectedTileColor: theme
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.08),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: title,
                                              style: titleStyle,
                                            ),
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
                                                  title:
                                                      l10n.deleteTemplateTitle,
                                                  content: Text(
                                                    l10n.confirmDeleteGeneric,
                                                  ),
                                                  actions: [
                                                    AppButtons.text(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            d,
                                                            false,
                                                          ),
                                                      label: l10n.cancel,
                                                    ),
                                                    AppButtons.text(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            d,
                                                            true,
                                                          ),
                                                      label: l10n.delete,
                                                      color: Theme.of(
                                                        d,
                                                      ).colorScheme.error,
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (ok == true) {
                                                final repo = ref.read(
                                                  templateRepositoryProvider,
                                                );
                                                await repo
                                                    .deleteCharacterTemplate(
                                                      it.id,
                                                    );
                                                await _load();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: state.displayItems.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
