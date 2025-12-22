import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import '../../models/character_note.dart';
import 'package:writer/repositories/notes_repository.dart';
import '../../state/providers.dart';

class CharactersListScreen extends ConsumerStatefulWidget {
  const CharactersListScreen({super.key, required this.novelId});
  final String novelId;

  @override
  ConsumerState<CharactersListScreen> createState() =>
      _CharactersListScreenState();
}

class _CharactersListScreenState extends ConsumerState<CharactersListScreen> {
  List<CharacterNote> _items = const [];
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
      final repo = ref.read(notesRepositoryProvider);
      if (ref.read(isSignedInProvider)) {
        _items = await repo.listCharacterNotes(widget.novelId);
      } else {
        _items = []; // Local support removed/needs caching
      }
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
        title: Text(l10n.characters),
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
                    it.characterSummaries ?? it.characterSynopses ?? '';
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
                            '/novel/${widget.novelId}/characters/${it.idx}',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (d) => AlertDialog(
                              title: Text(l10n.deleteCharacterTitle),
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
                            final repo = ref.read(notesRepositoryProvider);
                            // Deleting by ID if possible, but existing used idx.
                            // NotesRepository has deleteCharacterNoteByIdx.
                            if (ref.read(isSignedInProvider)) {
                              await repo.deleteCharacterNoteByIdx(
                                widget.novelId,
                                it.idx,
                              );
                            }
                            // Also delete local? Local is empty now.
                            // await ref.read(localStorageRepositoryProvider).deleteCharacterNoteByIdx...
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
