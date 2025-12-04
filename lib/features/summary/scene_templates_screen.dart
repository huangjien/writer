import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/template.dart';

class SceneTemplatesScreen extends ConsumerStatefulWidget {
  const SceneTemplatesScreen({
    super.key,
    required this.novelId,
    this.templateId,
  });
  final String novelId;
  final String? templateId;

  @override
  ConsumerState<SceneTemplatesScreen> createState() =>
      _SceneTemplatesScreenState();
}

class _SceneTemplatesScreenState extends ConsumerState<SceneTemplatesScreen> {
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
    if (widget.templateId != null) {
      final row = await repo.getSceneTemplateById(widget.templateId!);
      if (row != null) {
        _nameController.text = row.title ?? '';
        _descController.text = row.sceneSummaries ?? '';
      }
    } else {
      final item = await repo.getSceneTemplateForm(widget.novelId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scene Templates'), actions: const []),
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
                              if (widget.templateId != null) {
                                await repo.updateSceneTemplate(
                                  widget.templateId!,
                                  title: _nameController.text.trim(),
                                  summaries: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                  languageCode: 'en',
                                );
                              } else {
                                await repo.saveSceneTemplateForm(
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
