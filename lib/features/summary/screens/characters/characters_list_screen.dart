import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/error_state.dart';
import '../../state/template_list_state.dart';

class CharactersListScreen extends ConsumerWidget {
  const CharactersListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CharactersListContent(novelId: novelId);
  }
}

class _CharactersListContent extends ConsumerStatefulWidget {
  const _CharactersListContent({required this.novelId});
  final String novelId;

  @override
  ConsumerState<_CharactersListContent> createState() =>
      _CharactersListContentState();
}

class _CharactersListContentState
    extends ConsumerState<_CharactersListContent> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    ref.read(characterTemplateListProvider.notifier).setLoading(true);
    ref.read(characterTemplateListProvider.notifier).clearError();

    try {
      final repo = ref.read(localStorageRepositoryProvider);
      List<CharacterTemplateRow> items = [];
      items = await repo.listCharacterTemplates();
      ref.read(characterTemplateListProvider.notifier).setItems(items);
      _localSearch();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      ref.read(characterTemplateListProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) {
        ref.read(characterTemplateListProvider.notifier).setLoading(false);
      }
    }
  }

  void _localSearch() {
    final listState = ref.read(characterTemplateListProvider);
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      ref
          .read(characterTemplateListProvider.notifier)
          .setDisplayItems(listState.items);
      return;
    }
    final filtered = listState.items.where((t) {
      final title = (t.title ?? '').toLowerCase();
      return title.contains(q);
    }).toList();
    ref.read(characterTemplateListProvider.notifier).setDisplayItems(filtered);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEdit(CharacterTemplateRow it) {
    context.push('/novel/${widget.novelId}/characters/${it.id}');
  }

  void _onRowTap(CharacterTemplateRow it) {
    _openEdit(it);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listState = ref.watch(characterTemplateListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(l10n.characters),
        actions: [
          if (listState.isLoading)
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
                context.push('/novel/${widget.novelId}/characters/new'),
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
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _localSearch();
                              },
                              tooltip: 'Clear search',
                              padding: EdgeInsets.zero,
                            )
                          : null,
                    ),
                    onChanged: (_) {
                      _localSearch();
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (ctx, i) {
                      final it = listState.displayItems[i];
                      final title = it.title ?? l10n.untitled;
                      final rawSubtitle =
                          it.characterSummaries ?? it.characterSynopses ?? '';
                      final firstLine = rawSubtitle.split('\n').first;
                      final subtitle = firstLine.replaceAll('*', '').trim();
                      final theme = Theme.of(context);
                      final titleStyle = theme.textTheme.titleMedium;
                      final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      );
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onRowTap(it),
                          hoverColor: theme.colorScheme.surfaceContainerHighest,
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
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEdit(it),
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
    );
  }
}
