import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../main.dart';
import '../../models/template.dart';
import '../../l10n/app_localizations.dart';

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

class _SceneTemplatesScreenState extends ConsumerState<SceneTemplatesScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late TabController _tabController;
  bool _saving = false;
  String? _error;
  bool _isDirty = false;
  String _baseName = '';
  String _baseDesc = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
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
    _baseName = _nameController.text;
    _baseDesc = _descController.text;
    _isDirty = false;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sceneTemplates), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.templateName),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.required : null,
                onChanged: (_) {
                  final dirty =
                      _nameController.text.trim() != _baseName.trim() ||
                      _descController.text.trim() != _baseDesc.trim();
                  if (dirty != _isDirty) setState(() => _isDirty = dirty);
                },
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.previewLabel),
                  Tab(text: l10n.edit),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Preview Mode
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Markdown(
                        data: _descController.text,
                        selectable: true,
                      ),
                    ),
                    // Edit Mode
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: l10n.markdownHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (_) {
                        final dirty =
                            _nameController.text.trim() != _baseName.trim() ||
                            _descController.text.trim() != _baseDesc.trim();
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: (_saving || !_isDirty)
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
                                SnackBar(content: Text(l10n.saved)),
                              );
                            } catch (e) {
                              setState(() => _error = e.toString());
                            } finally {
                              if (mounted) setState(() => _saving = false);
                            }
                          },
                    child: Text(l10n.save),
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
