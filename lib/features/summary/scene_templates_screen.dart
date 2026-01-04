import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../models/template.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/remote_repository.dart';
import '../../repositories/template_repository.dart';
import '../../state/providers.dart';
import '../../state/session_state.dart';

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
      if (ref.read(isSignedInProvider)) {
        final remote = await ref
            .read(templateRepositoryProvider)
            .getSceneTemplateById(_templateId!);
        if (remote != null) {
          _nameController.text = remote.title ?? '';
          _descController.text = remote.sceneSummaries ?? '';
          _languageCode = remote.languageCode;
        }
      } else {
        final row = await repo.getSceneTemplateById(_templateId!);
        if (row != null) {
          _nameController.text = row.title ?? '';
          _descController.text = row.sceneSummaries ?? '';
          _languageCode = row.languageCode;
        }
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
                            final session = ref.read(sessionProvider);
                            if (session == null &&
                                ref.read(isSignedInProvider)) {
                              // If they think they are signed in but no session?
                            }
                            setState(() {
                              _saving = true;
                              _error = null;
                            });
                            try {
                              final repo = ref.read(
                                localStorageRepositoryProvider,
                              );
                              final templateRepo = ref.read(
                                templateRepositoryProvider,
                              );
                              String? templateId = _templateId;
                              if (ref.read(isSignedInProvider)) {
                                templateId = await templateRepo
                                    .upsertSceneTemplate(
                                      id: _templateId,
                                      title: _nameController.text.trim(),
                                      summaries:
                                          _descController.text.trim().isEmpty
                                          ? null
                                          : _descController.text.trim(),
                                      languageCode: _languageCode,
                                    );
                              } else {
                                // Local save doesn't satisfy ID requirement for "persisted" check below,
                                // unless we mock it or change logic.
                                // For now, we only support full "Save" logic if signed in, or just save draft.
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
                                  languageCode: _languageCode,
                                );
                                // Skip "persisted" checks if local
                                templateId = null; // or fake
                              }
                              if (templateId == null) {
                                throw Exception(l10n.failedToPersistTemplate);
                              }

                              final persisted = await templateRepo
                                  .getSceneTemplateById(templateId);
                              if (persisted == null) {
                                // This might happen if immediate read isn't consistent, or if we are local only.
                                // If local only, templateId is likely null, so we didn't enter here.
                              }

                              if (ref.read(isSignedInProvider)) {
                                // embedding refresh removed
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
