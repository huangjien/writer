import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:logging/logging.dart';
import 'package:writer/models/template.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/features/summary/state/template_form_state.dart';
import 'package:writer/utils/language_detector.dart';
import 'package:writer/theme/font_packs.dart';

final _logger = Logger('SceneTemplatesScreen');

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
  final _detectedLanguage = ValueNotifier<String>('en');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _templateId = widget.templateId;
    _nameController.addListener(_updateLanguageDetection);
    _load();
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateLanguageDetection);
    _detectedLanguage.dispose();
    _nameController.dispose();
    _descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateLanguageDetection() {
    _detectedLanguage.value = LanguageDetector.detectLanguage(
      _nameController.text,
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    final fallback = chineseTextFallback();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamilyFallback: fallback)),
        backgroundColor: backgroundColor,
      ),
    );
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
            _detectedLanguage.value = remote.languageCode;
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(remote.languageCode);
          }
        } else {
          final row = await repo.getSceneTemplateById(_templateId!);
          if (row != null) {
            _nameController.text = row.title ?? '';
            _descController.text = row.sceneSummaries ?? '';
            _detectedLanguage.value = row.languageCode;
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(row.languageCode);
          }
        }
      } else {
        _nameController.text = '';
        _descController.text = '';
        _detectedLanguage.value = 'en';
        ref.read(templateFormProvider.notifier).setLanguageCode('en');
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) return;
    }
    ref
        .read(templateFormProvider.notifier)
        .setBaseValues(
          _nameController.text,
          _descController.text,
          _detectedLanguage.value,
        );
  }

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(templateFormProvider.notifier).setRetrieving(true);
    ref.read(templateFormProvider.notifier).clearError();

    try {
      final templateRepo = ref.read(templateRepositoryProvider);
      final detectedLanguage = LanguageDetector.detectLanguage(name);
      final result = await templateRepo.generateSceneTemplate(
        title: name,
        templateContent: _descController.text.trim().isEmpty
            ? 'Scene: $name'
            : _descController.text.trim(),
        name: name,
        languageCode: detectedLanguage,
      );

      if (result != null && result.containsKey('id')) {
        if (mounted) {
          final newId = result['id'] as String;
          setState(() {
            _templateId = newId;
          });

          _showSnackBar(AppLocalizations.of(context)!.templateRetrieved);

          _pollForContent(newId);
        }
      } else {
        if (mounted) {
          _showSnackBar(AppLocalizations.of(context)!.noTemplateFound);
          ref.read(templateFormProvider.notifier).setRetrieving(false);
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is ApiException && e.statusCode == 401) return;
        _showSnackBar(
          _extractErrorMessage(e),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        ref.read(templateFormProvider.notifier).setRetrieving(false);
      }
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.errorResponse != null) {
        return error.errorResponse!.message;
      }
      return error.rawMessage ?? error.toString();
    }
    return error.toString();
  }

  Future<void> _pollForContent(String templateId) async {
    const maxAttempts = 26;
    const interval = Duration(seconds: 7);

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(interval);

      if (!mounted) return;

      try {
        final repo = ref.read(templateRepositoryProvider);
        final template = await repo.getSceneTemplateById(templateId);

        _logger.info(
          'Poll attempt $i/$maxAttempts: sceneSummaries=${template?.sceneSummaries != null ? "${template!.sceneSummaries!.substring(0, template.sceneSummaries!.length > 50 ? 50 : template.sceneSummaries!.length)}..." : "null"} (${template?.sceneSummaries?.length ?? 0} chars), sceneSynopses=${template?.sceneSynopses != null ? "${template!.sceneSynopses!.substring(0, template.sceneSynopses!.length > 50 ? 50 : template.sceneSynopses!.length)}..." : "null"} (${template?.sceneSynopses?.length ?? 0} chars)',
        );

        if (template != null &&
            template.sceneSummaries != null &&
            template.sceneSummaries!.isNotEmpty) {
          if (mounted) {
            _logger.info('Content ready! Stopping polling.');
            _nameController.text = template.title ?? '';
            _descController.text = template.sceneSummaries ?? '';
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(template.languageCode);
            ref.read(templateFormProvider.notifier).setRetrieving(false);

            _showSnackBar(
              AppLocalizations.of(context)!.templateRetrieved,
              backgroundColor: Theme.of(context).colorScheme.primary,
            );
          }
          return;
        }
      } catch (e) {
        _logger.warning('Error polling for template content: $e');
      }
    }

    if (mounted) {
      _logger.warning('Polling exhausted after $maxAttempts attempts');
      ref.read(templateFormProvider.notifier).setRetrieving(false);
    }
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
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        ValueListenableBuilder<String>(
                          valueListenable: _detectedLanguage,
                          builder: (context, language, _) {
                            return Text(
                              LanguageDetector.getLanguageName(language),
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          },
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
                      tooltip: l10n.retrieveTemplate,
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
                              _showSnackBar(l10n.saved);
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
