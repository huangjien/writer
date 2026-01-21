import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../models/template.dart';
import '../../repositories/remote_repository.dart';
import '../../repositories/template_repository.dart';
import '../../state/providers.dart';
import '../../shared/api_exception.dart';
import '../../shared/widgets/app_buttons.dart';

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
    extends ConsumerState<CharacterTemplatesScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late TabController _tabController;

  bool _saving = false;
  bool _retrieving = false;
  String? _error;
  bool _isDirty = false;
  String _baseName = '';
  String _baseDesc = '';

  @override
  void initState() {
    super.initState();
    // Default to Preview (index 0)
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    try {
      if (widget.templateId != null) {
        if (ref.read(isSignedInProvider)) {
          final remote = await ref
              .read(templateRepositoryProvider)
              .getCharacterTemplateById(widget.templateId!);
          if (remote != null) {
            _nameController.text = remote.title ?? '';
            _descController.text = remote.characterSummaries ?? '';
          }
        } else {
          final row = await repo.getCharacterTemplateById(widget.templateId!);
          if (row != null) {
            _nameController.text = row.title ?? '';
            _descController.text = row.characterSummaries ?? '';
          }
        }
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
      // Optionally handle other errors or just ignore as this is initial load
    }
    _baseName = _nameController.text;
    _baseDesc = _descController.text;
    _isDirty = false;
    if (mounted) setState(() {});
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
      final profile = await repo.fetchCharacterProfile(name);

      if (profile != null) {
        _descController.text = profile.trim();

        if (mounted) {
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
        if (e is ApiException && e.statusCode == 401) return;
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
      appBar: AppBar(title: Text(l10n.characterTemplates)),
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
                      decoration: InputDecoration(
                        labelText: l10n.templateName,
                        hintText: l10n.exampleCharacterName,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.required : null,
                      onChanged: (_) {
                        final dirty =
                            _nameController.text.trim() != _baseName.trim() ||
                            _descController.text.trim() != _baseDesc.trim();
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
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
                    // Preview Mode (now first)
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
                    // Edit Mode (now second)
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
                  AppButtons.primary(
                    label: l10n.save,
                    onPressed: (_saving || !_isDirty)
                        ? () {}
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

                              final templateRepo = ref.read(
                                templateRepositoryProvider,
                              );
                              if (widget.templateId != null &&
                                  ref.read(isSignedInProvider)) {
                                await templateRepo.upsertCharacterTemplate(
                                  id: widget.templateId,
                                  title: _nameController.text.trim(),
                                  summaries: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                  languageCode: 'en',
                                );
                              } else {
                                // For local save or creation, we might not have ID logic properly set up solely in local repo
                                // But if isSignedIn is false, we can only save to local.
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
                              // Creation logic for remote? If widget.templateId is null?
                              if (widget.templateId == null &&
                                  ref.read(isSignedInProvider)) {
                                await templateRepo.upsertCharacterTemplate(
                                  title: _nameController.text.trim(),
                                  summaries: _descController.text.trim().isEmpty
                                      ? null
                                      : _descController.text.trim(),
                                  languageCode: 'en',
                                );
                              }
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.saved)),
                              );
                            } catch (e) {
                              if (e is ApiException && e.statusCode == 401) {
                                return;
                              }
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
                    enabled: !(_saving || !_isDirty),
                    isLoading: _saving,
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
