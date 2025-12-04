import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../models/character_note.dart';

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
      final repo = ref.read(localStorageRepositoryProvider);
      _items = await repo.listCharacterNotes(widget.novelId);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characters'),
        actions: [
          IconButton(
            onPressed: () =>
                context.push('/novel/${widget.novelId}/characters/new'),
            icon: const Icon(Icons.add),
            tooltip: 'New',
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
                final title = it.title ?? 'Untitled';
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
                              title: const Text('Delete Character'),
                              content: const Text(
                                'Are you sure you want to delete this item?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(d, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(d, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            final repo = ref.read(
                              localStorageRepositoryProvider,
                            );
                            await repo.deleteCharacterNoteByIdx(
                              widget.novelId,
                              it.idx,
                            );
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
