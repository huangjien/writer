import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/template.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/summary/state/template_form_state.dart';

class CharacterTemplatesScreen extends ConsumerWidget {
  const CharacterTemplatesScreen({
    super.key,
    required this.novelId,
    this.templateId,
  });
  final String novelId;
  final String? templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CharacterTemplatesContent(novelId: novelId, templateId: templateId);
  }
}

class _CharacterTemplatesContent extends ConsumerStatefulWidget {
  const _CharacterTemplatesContent({required this.novelId, this.templateId});
  final String novelId;
  final String? templateId;

  @override
  ConsumerState<_CharacterTemplatesContent> createState() =>
      _CharacterTemplatesContentState();
}

class _CharacterTemplatesContentState
    extends ConsumerState<_CharacterTemplatesContent>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(aiContextProvider.notifier)
          .setContextDelegate(
            type: 'character_template',
            loader: () async {
              return "Character Template: ${_nameController.text}\n\nDescription:\n${_descController.text}";
            },
          );
    });
  }

  Future<void> _load() async {
    final notifier = ref.read(templateFormProvider.notifier);
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
    }
    notifier.setBaseValues(_nameController.text, _descController.text, 'en');
    notifier.updateDirty(_nameController.text, _descController.text, 'en');
  }

  @override
  void dispose() {
    try {
      ref.read(aiContextProvider.notifier).clearContextDelegate();
    } catch (_) {}
    _nameController.dispose();
    _descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(templateFormProvider.notifier);
    notifier.setRetrieving(true);
    notifier.clearError();

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
        notifier.setError(l10n.retrieveFailed(e.toString()));
      }
    } finally {
      if (mounted) {
        notifier.setRetrieving(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(templateFormProvider);
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
                        final notifier = ref.read(
                          templateFormProvider.notifier,
                        );
                        notifier.updateDirty(
                          _nameController.text,
                          _descController.text,
                          'en',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton.filledTonal(
                      onPressed:
                          (formState.isRetrieving ||
                              _nameController.text.trim().isEmpty)
                          ? null
                          : _onRetrieve,
                      icon: formState.isRetrieving
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
                    ListenableBuilder(
                      listenable: _descController,
                      builder: (context, _) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Markdown(
                            data: _descController.text,
                            selectable: true,
                          ),
                        );
                      },
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
                        final notifier = ref.read(
                          templateFormProvider.notifier,
                        );
                        notifier.updateDirty(
                          _nameController.text,
                          _descController.text,
                          'en',
                        );
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
                    onPressed: (formState.isLoading || !formState.isDirty)
                        ? () {}
                        : () async {
                            final ok =
                                _formKey.currentState?.validate() ?? false;
                            if (!ok) return;
                            final notifier = ref.read(
                              templateFormProvider.notifier,
                            );
                            notifier.setLoading(true);
                            notifier.clearError();
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
                              notifier.setError(msg);
                            } finally {
                              if (mounted) {
                                notifier.setLoading(false);
                              }
                            }
                          },
                    enabled: !(formState.isLoading || !formState.isDirty),
                    isLoading: formState.isLoading,
                  ),
                  const SizedBox(width: 12),
                  if (formState.error != null)
                    Expanded(
                      child: Text(
                        formState.error!,
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
