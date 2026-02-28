import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'widgets/scene_description_field.dart';
import 'widgets/scene_template_picker.dart';
import 'widgets/scenes_support_widgets.dart';
import 'package:writer/features/summary/state/scene_form_state.dart';
import 'package:writer/shared/widgets/language_indicator.dart';
import 'package:writer/shared/mixins/language_detection_helper.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key, required this.novelId, this.idx});

  final String novelId;
  final int? idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ScenesContent(novelId: novelId, idx: idx);
  }
}

class _ScenesContent extends ConsumerStatefulWidget {
  const _ScenesContent({required this.novelId, required this.idx});

  final String novelId;
  final int? idx;

  @override
  ConsumerState<_ScenesContent> createState() => _ScenesContentState();
}

class _ScenesContentState extends ConsumerState<_ScenesContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  late final LanguageDetectionHelper _langDetection;

  List<SceneTemplateRow> _templates = [];

  @override
  void initState() {
    super.initState();
    _langDetection = LanguageDetectionHelper();
    _titleController.addListener(_onTextChanged);
    _load();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _langDetection.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _langDetection.updateDetection(_titleController.text);
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    try {
      if (ref.read(isSignedInProvider)) {
        List<SceneTemplateRow> templates = [];
        try {
          templates = await ref
              .read(templateRepositoryProvider)
              .listSceneTemplates(limit: 200);
        } catch (_) {}
        if (templates.isNotEmpty) {
          _templates = templates;
        } else {
          _templates = await repo.listSceneTemplates(limit: 50);
        }
      } else {
        _templates = await repo.listSceneTemplates(limit: 50);
      }
    } catch (_) {}

    var item = await repo.getSceneForm(widget.novelId, idx: widget.idx);

    if (widget.idx != null && ref.read(isSignedInProvider)) {
      try {
        final notes = await ref
            .read(notesRepositoryProvider)
            .listSceneNotes(widget.novelId);
        final match = notes.where((n) => n.idx == widget.idx).firstOrNull;
        if (match != null) {
          if (item == null || item.title.isEmpty) {
            item = Scene(
              novelId: widget.novelId,
              title: match.title ?? '',
              location: match.sceneSynopses,
              summary: match.sceneSummaries,
            );
          }
        }
      } catch (_) {}
    }

    if (item != null) {
      _titleController.text = item.title;
      _locationController.text = item.location ?? '';
      _summaryController.text = item.summary ?? '';
      _langDetection.updateDetection(item.title);
    }

    ref
        .read(sceneFormProvider.notifier)
        .setBaseValues(
          _titleController.text,
          _locationController.text,
          _summaryController.text,
          ref.read(sceneFormProvider).languageCode,
        );
  }

  Iterable<SceneTemplateRow> _templatesForLanguage(String languageCode) =>
      _templates.where((t) => t.languageCode == languageCode);

  void _scheduleTemplateSearch(String raw) {
    final formState = ref.read(sceneFormProvider);
    final q = raw.trim();

    ref.read(sceneFormProvider.notifier).scheduleTemplateSearch(q, (
      query,
    ) async {
      final repo = ref.read(localStorageRepositoryProvider);
      List<SceneTemplateRow> res = [];
      if (ref.read(isSignedInProvider)) {
        try {
          res = await ref
              .read(templateRepositoryProvider)
              .searchSceneTemplates(
                query,
                limit: 5,
                languageCode: formState.languageCode,
              );
        } catch (_) {
          res = await repo.searchSceneTemplates(
            query,
            limit: 5,
            languageCode: formState.languageCode,
          );
        }
      } else {
        res = await repo.searchSceneTemplates(
          query,
          limit: 5,
          languageCode: formState.languageCode,
        );
      }
      if (res.isEmpty) {
        return _templatesForLanguage(formState.languageCode)
            .where(
              (t) =>
                  (t.title ?? '').toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      return res;
    });
  }

  Future<void> _convertScene() async {
    final formState = ref.read(sceneFormProvider);
    if (_titleController.text.isEmpty || formState.selectedTemplate == null) {
      return;
    }

    ref.read(sceneFormProvider.notifier).setConverting(true);
    ref.read(sceneFormProvider.notifier).clearError();

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final result = await repo.convertScene(
        name: _titleController.text,
        templateContent: formState.selectedTemplate!.sceneSummaries ?? '',
        language: formState.languageCode,
      );

      if (result != null) {
        _summaryController.text = result;
        _updateDirty();
      }
    } catch (e) {
      if (mounted) {
        if (e is ApiException && e.statusCode == 401) return;
        final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.conversionFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        ref.read(sceneFormProvider.notifier).setConverting(false);
      }
    }
  }

  Future<void> _saveScene() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    ref.read(sceneFormProvider.notifier).setLoading(true);
    ref.read(sceneFormProvider.notifier).clearError();

    try {
      final repo = ref.read(localStorageRepositoryProvider);
      final notesRepo = ref.read(notesRepositoryProvider);
      final formState = ref.read(sceneFormProvider);

      final useIdx = widget.idx ?? await repo.nextSceneIdx(widget.novelId);
      final scene = Scene(
        novelId: widget.novelId,
        title: _titleController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
      );

      await repo.saveSceneForm(widget.novelId, scene, idx: useIdx);

      if (ref.read(isSignedInProvider)) {
        await notesRepo.upsertSceneNote(
          novelId: widget.novelId,
          idx: widget.idx ?? 0,
          title: scene.title,
          synopses: scene.location,
          summaries: scene.summary,
          languageCode: formState.languageCode,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));

      ref
          .read(sceneFormProvider.notifier)
          .setBaseValues(
            _titleController.text,
            _locationController.text,
            _summaryController.text,
            formState.languageCode,
          );
      _updateDirty();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return;
      }
      ref.read(sceneFormProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) {
        ref.read(sceneFormProvider.notifier).setLoading(false);
      }
    }
  }

  void _updateDirty() {
    final formState = ref.read(sceneFormProvider);
    ref
        .read(sceneFormProvider.notifier)
        .updateDirty(
          _titleController.text,
          _locationController.text,
          _summaryController.text,
          formState.languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final formState = ref.watch(sceneFormProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scenes), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref
                  .watch(novelProvider(widget.novelId))
                  .when(
                    data: (novel) => SceneNovelHeader(novel: novel),
                    loading: () => SceneLoadingTile(label: l10n.loadingNovels),
                    error: (e, _) => SceneErrorTile(
                      label: '${l10n.error}: $e',
                      novelId: widget.novelId,
                      ref: ref,
                    ),
                  ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: l10n.titleLabel,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? l10n.required
                                : null,
                            onChanged: (_) => _updateDirty(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: kInputIndicatorPadding,
                          child: LiveLanguageIndicator(
                            languageNotifier: _langDetection.notifier,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: kInputIndicatorPadding,
                          child: DropdownButton<String>(
                            value: formState.languageCode,
                            onChanged: (code) {
                              if (code == null) return;
                              ref
                                  .read(sceneFormProvider.notifier)
                                  .setLanguageCode(code);
                              _updateDirty();
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_templates.isNotEmpty) ...[
                      SceneTemplatePicker(
                        l10n: l10n,
                        languageCode: formState.languageCode,
                        templatesForLanguage: _templatesForLanguage(
                          formState.languageCode,
                        ),
                        templateQuery: formState.templateQuery,
                        templateSearchResults: formState.templateSearchResults,
                        templateSearchLoading: formState.templateSearchLoading,
                        selectedTemplate: formState.selectedTemplate,
                        onSelectedTemplate: (tpl) {
                          ref
                              .read(sceneFormProvider.notifier)
                              .setSelectedTemplate(tpl);
                        },
                        onQueryChanged: _scheduleTemplateSearch,
                        onTemplateControllerAvailable: (controller) {},
                        isConverting: formState.isConverting,
                        onConvertPressed: _convertScene,
                        canConvert:
                            !(formState.isConverting ||
                                _titleController.text.isEmpty ||
                                formState.selectedTemplate == null),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.locationLabel,
                      ),
                      onChanged: (_) => _updateDirty(),
                    ),
                    const SizedBox(height: 12),
                    SceneDescriptionField(
                      l10n: l10n,
                      controller: _summaryController,
                      showPreview: formState.showPreview,
                      onTogglePreview: () {
                        ref.read(sceneFormProvider.notifier).togglePreview();
                      },
                      onChanged: (_) => _updateDirty(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SceneSaveButton(
                          l10n: l10n,
                          saving: formState.isLoading,
                          isDirty: formState.isDirty,
                          onSave: _saveScene,
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
            ],
          ),
        ),
      ),
    );
  }
}
