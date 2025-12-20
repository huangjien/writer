import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import '../../main.dart';
import '../../models/template.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/remote_repository.dart';
import '../../state/providers.dart';

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
  bool _retrieving = false;
  String? _error;
  bool _isDirty = false;
  String _languageCode = 'en';
  String _baseName = '';
  String _baseDesc = '';
  String _baseLanguageCode = 'en';
  String? _templateId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _templateId = widget.templateId;
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    if (_templateId != null) {
      final row = await repo.getSceneTemplateById(_templateId!);
      if (row != null) {
        _nameController.text = row.title ?? '';
        _descController.text = row.sceneSummaries ?? '';
        _languageCode = row.languageCode;
      }
    } else {
      _nameController.text = '';
      _descController.text = '';
      _languageCode = 'en';
    }
    _baseName = _nameController.text;
    _baseDesc = _descController.text;
    _baseLanguageCode = _languageCode;
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

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _retrieving = true;
      _error = null;
    });

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final profile = await repo.fetchSceneProfile(name);

      if (profile != null) {
        _descController.text = profile.trim();
        if (mounted) {
          setState(() {
            _isDirty = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileRetrieved),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noProfileFound),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _error = l10n.retrieveFailed(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _retrieving = false);
      }
    }
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l10n.templateName),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.required : null,
                      onChanged: (_) {
                        final dirty =
                            _nameController.text.trim() != _baseName.trim() ||
                            _descController.text.trim() != _baseDesc.trim() ||
                            _languageCode != _baseLanguageCode;
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DropdownButton<String>(
                      value: _languageCode,
                      onChanged: (code) {
                        if (code == null) return;
                        setState(() {
                          _languageCode = code;
                          final dirty =
                              _nameController.text.trim() != _baseName.trim() ||
                              _descController.text.trim() != _baseDesc.trim() ||
                              _languageCode != _baseLanguageCode;
                          if (dirty != _isDirty) _isDirty = dirty;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l10n.english),
                        ),
                        DropdownMenuItem(
                          value: 'zh',
                          child: Text(l10n.chinese),
                        ),
                      ],
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
                      tooltip: l10n.retrieveProfile,
                    ),
                  ),
                ],
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
                            _descController.text.trim() != _baseDesc.trim() ||
                            _languageCode != _baseLanguageCode;
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
                            final isSupabaseEnabled = ref.read(
                              supabaseEnabledProvider,
                            );
                            if (!isSupabaseEnabled) {
                              setState(() => _error = l10n.noSupabase);
                              return;
                            }
                            final session = ref.read(supabaseSessionProvider);
                            if (session == null) {
                              setState(() => _error = l10n.signInToSync);
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
                              String? templateId = _templateId;
                              if (_templateId != null) {
                                await repo.updateSceneTemplate(
                                  _templateId!,
                                  title: _nameController.text.trim(),
                                  summaries: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                  languageCode: _languageCode,
                                );
                              } else {
                                templateId = await repo.saveSceneTemplateForm(
                                  widget.novelId,
                                  TemplateItem(
                                    novelId: widget.novelId,
                                    name: _nameController.text.trim(),
                                    description:
                                        _descController.text.trim().isEmpty
                                        ? null
                                        : _descController.text.trim(),
                                  ),
                                  languageCode: _languageCode,
                                );
                              }
                              if (templateId == null) {
                                throw Exception('Failed to persist template');
                              }
                              final persisted = await repo.getSceneTemplateById(
                                templateId,
                              );
                              if (persisted == null) {
                                throw Exception(
                                  'Template not found after save: $templateId',
                                );
                              }
                              final savedTitle = (persisted.title ?? '').trim();
                              final desiredTitle = _nameController.text.trim();
                              if (savedTitle.isNotEmpty &&
                                  desiredTitle.isNotEmpty &&
                                  savedTitle != desiredTitle) {
                                throw Exception(
                                  'Template title mismatch after save: $templateId',
                                );
                              }
                              if (isSupabaseEnabled &&
                                  _descController.text.trim().isNotEmpty) {
                                final ai = ref.read(aiChatServiceProvider);
                                final vec = await ai.embed(
                                  _descController.text.trim(),
                                  model: 'text-embedding-3-small',
                                );
                                if (vec != null && vec.isNotEmpty) {
                                  await repo.upsertSceneTemplateEmbedding(
                                    templateId,
                                    vec,
                                  );
                                }
                              }
                              _templateId = templateId;
                              _baseName = _nameController.text;
                              _baseDesc = _descController.text;
                              _baseLanguageCode = _languageCode;
                              _isDirty = false;
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.saved)),
                              );
                            } catch (e) {
                              final msg =
                                  e.toString().contains(
                                    'Duplicate template name',
                                  )
                                  ? AppLocalizations.of(
                                      context,
                                    )!.templateNameExists
                                  : e.toString();
                              setState(() => _error = msg);
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
