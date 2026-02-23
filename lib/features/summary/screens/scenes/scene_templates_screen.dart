import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/models/template.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import '../../state/template_form_state.dart';

class SceneTemplatesScreen extends ConsumerWidget {
  const SceneTemplatesScreen({
    super.key,
    required this.novelId,
    this.templateId,
  });

  final String novelId;
  final String? templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SceneTemplatesContent(novelId: novelId, templateId: templateId);
  }
}

class _SceneTemplatesContent extends ConsumerStatefulWidget {
  const _SceneTemplatesContent({required this.novelId, this.templateId});

  final String novelId;
  final String? templateId;

  @override
  ConsumerState<_SceneTemplatesContent> createState() =>
      _SceneTemplatesContentState();
}

class _SceneTemplatesContentState extends ConsumerState<_SceneTemplatesContent>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late TabController _tabController;
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
    try {
      if (_templateId != null) {
        if (ref.read(isSignedInProvider)) {
          final remote = await ref
              .read(templateRepositoryProvider)
              .getSceneTemplateById(_templateId!);
          if (remote != null) {
            _nameController.text = remote.title ?? '';
            _descController.text = remote.sceneSummaries ?? '';
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(remote.languageCode);
          }
        } else {
          final row = await repo.getSceneTemplateById(_templateId!);
          if (row != null) {
            _nameController.text = row.title ?? '';
            _descController.text = row.sceneSummaries ?? '';
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(row.languageCode);
          }
        }
      } else {
        _nameController.text = '';
        _descController.text = '';
        ref.read(templateFormProvider.notifier).setLanguageCode('en');
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
    }
    ref
        .read(templateFormProvider.notifier)
        .setBaseValues(_nameController.text, _descController.text, 'en');
  }

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(templateFormProvider.notifier).setRetrieving(true);
    ref.read(templateFormProvider.notifier).clearError();

    try {
      final templateRepo = ref.read(templateRepositoryProvider);
      final result = await templateRepo.generateSceneTemplate(
        title: name,
        templateContent: _descController.text.trim().isEmpty
            ? 'Scene: $name'
            : _descController.text.trim(),
        name: name,
        languageCode: 'en',
      );

      if (result != null && result.containsKey('id')) {
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
        ref
            .read(templateFormProvider.notifier)
            .setError(l10n.retrieveFailed(e.toString()));
      }
    } finally {
      if (mounted) {
        ref.read(templateFormProvider.notifier).setRetrieving(false);
      }
    }
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
    final formState = ref.watch(templateFormProvider);

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
                        ref
                            .read(templateFormProvider.notifier)
                            .updateDirty(
                              _nameController.text,
                              _descController.text,
                              formState.languageCode,
                            );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DropdownButton<String>(
                      value: formState.languageCode,
                      onChanged: (code) {
                        if (code == null) return;
                        ref
                            .read(templateFormProvider.notifier)
                            .setLanguageCode(code);
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
                          formState.isRetrieving ||
                              _nameController.text.trim().isEmpty
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
                        ref
                            .read(templateFormProvider.notifier)
                            .updateDirty(
                              _nameController.text,
                              _descController.text,
                              formState.languageCode,
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
                            final session = ref.read(sessionProvider);
                            if (session == null &&
                                ref.read(isSignedInProvider)) {}
                            ref
                                .read(templateFormProvider.notifier)
                                .setLoading(true);
                            ref
                                .read(templateFormProvider.notifier)
                                .clearError();
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
                                      languageCode: formState.languageCode,
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
                                  languageCode: formState.languageCode,
                                );
                                templateId = null;
                              }
                              if (templateId == null) {
                                throw Exception(l10n.failedToPersistTemplate);
                              }

                              final persisted = await templateRepo
                                  .getSceneTemplateById(templateId);
                              if (persisted == null) {}

                              if (ref.read(isSignedInProvider)) {}
                              _templateId = templateId;
                              ref
                                  .read(templateFormProvider.notifier)
                                  .setBaseValues(
                                    _nameController.text,
                                    _descController.text,
                                    formState.languageCode,
                                  );
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
                              ref
                                  .read(templateFormProvider.notifier)
                                  .setError(msg);
                            } finally {
                              if (mounted) {
                                ref
                                    .read(templateFormProvider.notifier)
                                    .setLoading(false);
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
