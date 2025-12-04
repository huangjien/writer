import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../models/character_template_row.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Templates'),
        actions: [
          IconButton(
            onPressed: () => context.push(
              '/novel/${widget.novelId}/character-templates/new',
            ),
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
                            '/novel/${widget.novelId}/character-templates/${it.id}',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (d) => AlertDialog(
                              title: const Text('Delete Template'),
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
                            await repo.deleteCharacterTemplate(it.id);
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
