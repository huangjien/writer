import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/template.dart';
import '../../repositories/remote_repository.dart';

class CharacterTemplatesScreen extends ConsumerStatefulWidget {
  const CharacterTemplatesScreen({
    super.key,
    required this.novelId,
    this.templateId,
  });
  final String novelId;
  final String? templateId;

  @override
  ConsumerState<CharacterTemplatesScreen> createState() =>
      _CharacterTemplatesScreenState();
}

class _CharacterTemplatesScreenState
    extends ConsumerState<CharacterTemplatesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;
  bool _retrieving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    if (widget.templateId != null) {
      final row = await repo.getCharacterTemplateById(widget.templateId!);
      if (row != null) {
        _nameController.text = row.title ?? '';
        _descController.text = row.characterSummaries ?? '';
      }
    } else {
      final item = await repo.getCharacterTemplateForm(widget.novelId);
      if (item != null) {
        _nameController.text = item.name;
        _descController.text = item.description ?? '';
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _retrieving = true;
      _error = null;
    });

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final profile = await repo.fetchCharacterProfile(name);

      if (profile != null) {
        final buffer = StringBuffer();

        void addSection(String title, dynamic content) {
          if (content == null) return;
          buffer.writeln('### $title');
          if (content is Map) {
            content.forEach((k, v) {
              buffer.writeln('- **$k**: $v');
            });
          } else if (content is List) {
            for (final item in content) {
              buffer.writeln('- $item');
            }
          } else {
            buffer.writeln(content.toString());
          }
          buffer.writeln();
        }

        if (profile['archetype'] != null) {
          buffer.writeln('**Archetype:** ${profile['archetype']}');
          buffer.writeln();
        }

        addSection('Role', profile['role_in_story']);
        addSection('Core Identity', profile['core_identity']);
        addSection('Backstory', profile['backstory']);
        addSection('Personality', profile['personality']);
        addSection('Conflict', profile['conflict']);
        addSection('Relationships', profile['relationships']);

        _descController.text = buffer.toString().trim();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile retrieved')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No profile found')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Retrieve failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _retrieving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Templates'),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Template Name',
                        hintText: 'e.g. Harry Potter',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton.filledTonal(
                      onPressed:
                          _retrieving || _nameController.text.trim().isEmpty
                          ? null
                          : _onRetrieve,
                      icon: _retrieving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      tooltip: 'Retrieve Profile',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 15,
                minLines: 5,
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
                              if (widget.templateId != null) {
                                await repo.updateCharacterTemplate(
                                  widget.templateId!,
                                  title: _nameController.text.trim(),
                                  summaries: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                  languageCode: 'en',
                                );
                              } else {
                                await repo.saveCharacterTemplateForm(
                                  widget.novelId,
                                  TemplateItem(
                                    novelId: widget.novelId,
                                    name: _nameController.text.trim(),
                                    description:
                                        _descController.text.trim().isEmpty
                                        ? null
                                        : _descController.text.trim(),
                                  ),
                                );
                              }
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
      ),
    );
  }
}
