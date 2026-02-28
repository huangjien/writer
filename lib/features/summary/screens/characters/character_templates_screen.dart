import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:logging/logging.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/template.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/shared/widgets/language_indicator.dart';
import 'package:writer/shared/mixins/language_detection_helper.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/summary/state/template_form_state.dart';
import 'package:writer/utils/language_detector.dart';
import 'package:writer/theme/font_packs.dart';

final _logger = Logger('CharacterTemplatesScreen');

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
  String? _templateId;
  bool _isPollingCancelled = false;
  late final LanguageDetectionHelper _langDetection;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _templateId = widget.templateId;
    _langDetection = LanguageDetectionHelper();
    _nameController.addListener(_onNameChanged);
    _langDetection.notifier.addListener(_onLanguageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
        ref
            .read(aiContextProvider.notifier)
            .setContextDelegate(
              type: 'character_template',
              loader: () async {
                return 'Character Template: ${_nameController.text}\n\nDescription:\n${_descController.text}';
              },
            );
      }
    });
  }

  void _populateControllers(String? title, String? summaries) {
    _nameController.text = title ?? '';
    _descController.text = summaries ?? '';
  }

  void _onNameChanged() {
    _langDetection.updateDetection(_nameController.text);
  }

  void _onLanguageChanged() {
    _onFormChanged();
  }

  void _onFormChanged() {
    if (!mounted) return;
    final notifier = ref.read(templateFormProvider.notifier);
    notifier.updateDirty(
      _nameController.text,
      _descController.text,
      _langDetection.notifier.value,
    );
  }

  Future<void> _load() async {
    if (!mounted) return;

    final notifier = ref.read(templateFormProvider.notifier);
    final repo = ref.read(localStorageRepositoryProvider);
    try {
      if (_templateId != null) {
        if (ref.read(isSignedInProvider)) {
          final remote = await ref
              .read(templateRepositoryProvider)
              .getCharacterTemplateById(_templateId!);
          if (remote != null && mounted) {
            _populateControllers(remote.title, remote.characterSummaries);
          }
        } else {
          final row = await repo.getCharacterTemplateById(_templateId!);
          if (row != null && mounted) {
            _populateControllers(row.title, row.characterSummaries);
          }
        }
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        if (mounted) {
          _showSnackBar(
            AppLocalizations.of(context)!.sessionExpired,
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
        return;
      }
      if (mounted) {
        _showSnackBar(
          _extractErrorMessage(e),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
    final detected = LanguageDetector.detectLanguage(_nameController.text);
    notifier.setBaseValues(
      _nameController.text,
      _descController.text,
      detected,
    );
    notifier.updateDirty(_nameController.text, _descController.text, detected);
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

  void _showSnackBar(String message, {Color? backgroundColor}) {
    final fallback = chineseTextFallback();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamilyFallback: fallback)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _pollForContent(String templateId) async {
    _isPollingCancelled = false;
    const maxAttempts = 26;
    const initialDelay = Duration(seconds: 7);
    const maxDelay = Duration(seconds: 30);

    Duration currentDelay = initialDelay;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(currentDelay);

      if (!mounted || _isPollingCancelled) return;

      try {
        final repo = ref.read(templateRepositoryProvider);
        final template = await repo.getCharacterTemplateById(templateId);

        _logger.info(
          'Poll attempt $attempt/$maxAttempts: characterSummaries=${template?.characterSummaries != null ? "${template!.characterSummaries!.substring(0, template.characterSummaries!.length > 50 ? 50 : template.characterSummaries!.length)}..." : "null"} (${template?.characterSummaries?.length ?? 0} chars), characterSynopses=${template?.characterSynopses != null ? "${template!.characterSynopses!.substring(0, template.characterSynopses!.length > 50 ? 50 : template.characterSynopses!.length)}..." : "null"} (${template?.characterSynopses?.length ?? 0} chars)',
        );

        if (template != null &&
            template.characterSummaries != null &&
            template.characterSummaries!.isNotEmpty) {
          if (mounted) {
            _logger.info('Content ready! Stopping polling.');
            _populateControllers(template.title, template.characterSummaries);
            ref
                .read(templateFormProvider.notifier)
                .setLanguageCode(template.languageCode);
            ref.read(templateFormProvider.notifier).setRetrieving(false);

            _showSnackBar(
              AppLocalizations.of(context)!.profileRetrieved,
              backgroundColor: Theme.of(context).colorScheme.primary,
            );
          }
          return;
        }
      } catch (e) {
        _logger.warning('Error polling for template content: $e');
      }

      final nextDelay = (currentDelay.inSeconds * 1.2).floor();
      currentDelay = Duration(
        seconds: nextDelay.clamp(initialDelay.inSeconds, maxDelay.inSeconds),
      );
    }

    if (mounted) {
      _logger.warning('Polling exhausted after $maxAttempts attempts');
      ref.read(templateFormProvider.notifier).setRetrieving(false);
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(
        '${l10n.errorGatewayTimeout}. ${l10n.retrieveProfile} ${l10n.retry}',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  void dispose() {
    _isPollingCancelled = true;
    _nameController.removeListener(_onNameChanged);
    _langDetection.notifier.removeListener(_onLanguageChanged);
    _langDetection.dispose();
    try {
      ref.read(aiContextProvider.notifier).clearContextDelegate();
    } catch (_) {}
    _nameController.dispose();
    _descController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveRemote() async {
    final templateRepo = ref.read(templateRepositoryProvider);

    if (widget.templateId != null) {
      await templateRepo.upsertCharacterTemplate(
        id: widget.templateId,
        title: _nameController.text.trim(),
        summaries: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        languageCode: _langDetection.notifier.value,
      );
    } else {
      await templateRepo.upsertCharacterTemplate(
        title: _nameController.text.trim(),
        summaries: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        languageCode: _langDetection.notifier.value,
      );
    }
  }

  Future<void> _saveLocal() async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.saveCharacterTemplateForm(
      widget.novelId,
      TemplateItem(
        novelId: widget.novelId,
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      ),
    );
  }

  Future<void> _onRetrieve() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(templateFormProvider.notifier);
    notifier.setRetrieving(true);
    notifier.clearError();

    try {
      final templateRepo = ref.read(templateRepositoryProvider);
      final detectedLanguage = LanguageDetector.detectLanguage(name);
      final result = await templateRepo.generateCharacterTemplate(
        title: name,
        templateContent: _descController.text.trim().isEmpty
            ? 'Character: $name'
            : _descController.text.trim(),
        name: name,
        languageCode: detectedLanguage,
      );

      if (result != null && result.containsKey('id')) {
        if (mounted) {
          final newId = result['id'] as String;
          _templateId = newId;

          _showSnackBar(AppLocalizations.of(context)!.profileRetrieved);

          _pollForContent(newId);
        }
      } else {
        if (mounted) {
          _showSnackBar(AppLocalizations.of(context)!.noProfileFound);
          notifier.setRetrieving(false);
        }
      }
    } catch (e) {
      if (mounted) {
        if (e is ApiException && e.statusCode == 401) return;
        _showSnackBar(
          _extractErrorMessage(e),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        notifier.setRetrieving(false);
      }
    }
  }

  void _handleSave() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    final notifier = ref.read(templateFormProvider.notifier);
    notifier.setLoading(true);
    notifier.clearError();
    _saveAndNotify().then((_) {
      if (mounted) {
        notifier.setLoading(false);
      }
    });
  }

  Future<void> _saveAndNotify() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (ref.read(isSignedInProvider)) {
        await _saveRemote();
      } else {
        await _saveLocal();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return;
      }
      if (!mounted) return;
      final msg = e.toString().contains('Duplicate template name')
          ? AppLocalizations.of(context)!.templateNameExists
          : e.toString();
      ref.read(templateFormProvider.notifier).setError(msg);
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
                      onChanged: (_) => _onFormChanged(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LiveLanguageIndicator(
                      languageNotifier: _langDetection.notifier,
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
                      onChanged: (_) => _onFormChanged(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  AppButtons.primary(
                    label: l10n.save,
                    onPressed: _handleSave,
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
