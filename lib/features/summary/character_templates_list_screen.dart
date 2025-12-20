import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import '../../main.dart';
import '../../models/character_template_row.dart';
import '../../shared/constants.dart';

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
  List<CharacterTemplateRow> _items = const [];
  bool _loading = true;
  String? _error;
  DateTime? _lastRowTapAt;
  String? _lastRowTapId;
  String? _selectedId;

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
      _items = await repo.listCharacterTemplates();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _openEdit(CharacterTemplateRow it) {
    setState(() {
      _selectedId = it.id;
    });
    context.push('/novel/${widget.novelId}/character-templates/${it.id}');
  }

  void _onRowTap(CharacterTemplateRow it) {
    setState(() {
      _selectedId = it.id;
    });
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
          title: Text(l10n.characterTemplates),
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
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (ctx, i) {
                  final it = _items[i];
                  final title = it.title ?? l10n.untitled;
                  final subtitle =
                      (it.characterSummaries ?? it.characterSynopses ?? '')
                          .replaceAll('**', '')
                          .replaceAll(RegExp(r'\s+'), ' ')
                          .trim();
                  final theme = Theme.of(context);
                  final titleStyle = theme.textTheme.titleMedium;
                  final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  );

                  return Shortcuts(
                    shortcuts: const <ShortcutActivator, Intent>{
                      SingleActivator(LogicalKeyboardKey.enter): _EditIntent(),
                      SingleActivator(LogicalKeyboardKey.numpadEnter):
                          _EditIntent(),
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
                          setState(() {
                            _selectedId = it.id;
                          });
                        },
                        child: ListTile(
                          selected: _selectedId == it.id,
                          selectedTileColor: theme.colorScheme.primary
                              .withValues(alpha: 0.08),
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
                                    final repo = ref.read(
                                      localStorageRepositoryProvider,
                                    );
                                    await repo.deleteCharacterTemplate(it.id);
                                    await _load();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: _items.length,
              ),
      ),
    );
  }
}
