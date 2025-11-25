import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import '../../main.dart';

class CharactersScreen extends ConsumerStatefulWidget {
  const CharactersScreen({super.key, required this.novelId});

  final String novelId;

  @override
  ConsumerState<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends ConsumerState<CharactersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summariesController = TextEditingController();
  final _synopsesController = TextEditingController();
  String _languageCode = 'en';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    final data = await repo.getCharacterNoteForm(widget.novelId);
    if (data != null) {
      _titleController.text = (data['title'] as String?) ?? '';
      _summariesController.text =
          (data['character_summaries'] as String?) ?? '';
      _synopsesController.text = (data['character_synopses'] as String?) ?? '';
      final lc = (data['language_code'] as String?) ?? 'en';
      _languageCode = lc;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summariesController.dispose();
    _synopsesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Characters'), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (supabaseEnabled)
                ref
                    .watch(novelProvider(widget.novelId))
                    .when(
                      data: (novel) => _NovelHeader(novel: novel),
                      loading: () =>
                          const _LoadingTile(label: 'Loading novel…'),
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
                      loading: () =>
                          const _LoadingTile(label: 'Loading novel…'),
                      error: (e, _) => _ErrorTile(label: 'Error: $e'),
                    ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _summariesController,
                      decoration: const InputDecoration(labelText: 'Summaries'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _synopsesController,
                      decoration: const InputDecoration(labelText: 'Synopses'),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(child: Text('Language')),
                        DropdownButton<String>(
                          value: _languageCode,
                          onChanged: (code) {
                            if (code == null) {
                              return;
                            }
                            setState(() => _languageCode = code);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'zh',
                              child: Text('Chinese'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _saving
                              ? null
                              : () async {
                                  final ok =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!ok) {
                                    return;
                                  }
                                  setState(() {
                                    _saving = true;
                                    _error = null;
                                  });
                                  try {
                                    final repo = ref.read(
                                      localStorageRepositoryProvider,
                                    );
                                    await repo.saveCharacterNoteForm(
                                      widget.novelId,
                                      title: _titleController.text.trim(),
                                      summaries:
                                          _summariesController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _summariesController.text.trim(),
                                      synopses:
                                          _synopsesController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _synopsesController.text.trim(),
                                      languageCode: _languageCode,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Saved')),
                                    );
                                  } catch (e) {
                                    setState(() => _error = e.toString());
                                  } finally {
                                    if (mounted) {
                                      setState(() => _saving = false);
                                    }
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
