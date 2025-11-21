import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/template.dart';

class CharacterTemplatesScreen extends ConsumerStatefulWidget {
  const CharacterTemplatesScreen({super.key, required this.novelId});
  final String novelId;

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    final item = await repo.getCharacterTemplateForm(widget.novelId);
    if (item != null) {
      _nameController.text = item.name;
      _descController.text = item.description ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Template Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
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
