import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/novel_providers.dart';
import 'package:novel_reader/state/mock_providers.dart';
import 'package:novel_reader/state/supabase_config.dart';
import 'package:novel_reader/models/novel.dart';
import '../../main.dart';
import '../../models/character.dart';

class CharactersScreen extends ConsumerStatefulWidget {
  const CharactersScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends ConsumerState<CharactersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _bioController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    final item = await repo.getCharacterForm(widget.novelId);
    if (item != null) {
      _nameController.text = item.name;
      _roleController.text = item.role ?? '';
      _bioController.text = item.bio ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Characters'), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supabaseEnabled)
              ref
                  .watch(novelProvider(widget.novelId))
                  .when(
                    data: (novel) => _NovelHeader(novel: novel),
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  )
            else
              ref
                  .watch(mockNovelsProvider)
                  .when(
                    data: (novels) {
                      final matches = novels.where(
                        (n) => n.id == widget.novelId,
                      );
                      final novel = matches.isNotEmpty ? matches.first : null;
                      return _NovelHeader(novel: novel);
                    },
                    loading: () => const _LoadingTile(label: 'Loading novel…'),
                    error: (e, _) => _ErrorTile(label: 'Error: $e'),
                  ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roleController,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                final ok =
                                    _formKey.currentState?.validate() ?? false;
                                if (!ok) return;
                                setState(() {
                                  _saving = true;
                                  _error = null;
                                });
                                try {
                                  final repo = ref.read(
                                    localStorageRepositoryProvider,
                                  );
                                  await repo.saveCharacterForm(
                                    widget.novelId,
                                    Character(
                                      novelId: widget.novelId,
                                      name: _nameController.text.trim(),
                                      role: _roleController.text.trim().isEmpty
                                          ? null
                                          : _roleController.text.trim(),
                                      bio: _bioController.text.trim().isEmpty
                                          ? null
                                          : _bioController.text.trim(),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  );
                                } catch (e) {
                                  setState(() => _error = e.toString());
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
                      if (_error != null)
                        Expanded(
                          child: Text(
                            _error!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NovelHeader extends StatelessWidget {
  const _NovelHeader({required this.novel});
  final Novel? novel;

  @override
  Widget build(BuildContext context) {
    final title = novel?.title ?? 'Unknown Novel';
    final author = novel?.author;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (author != null && author.isNotEmpty) Text(author),
      ],
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
