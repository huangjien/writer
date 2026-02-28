import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/shared/constants.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/features/summary/state/character_form_state.dart';
import 'package:writer/shared/widgets/language_indicator.dart';
import 'package:writer/shared/mixins/language_detection_helper.dart';

class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key, required this.novelId, this.idx});

  final String novelId;
  final int? idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CharactersContent(novelId: novelId, idx: idx);
  }
}

class _CharactersContent extends ConsumerStatefulWidget {
  const _CharactersContent({required this.novelId, required this.idx});

  final String novelId;
  final int? idx;

  @override
  ConsumerState<_CharactersContent> createState() => _CharactersContentState();
}

class _CharactersContentState extends ConsumerState<_CharactersContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summariesController = TextEditingController();
  final _synopsesController = TextEditingController();
  late final LanguageDetectionHelper _langDetection;

  List<CharacterTemplateRow> _templates = [];

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
    _summariesController.dispose();
    _synopsesController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _langDetection.updateDetection(_titleController.text);
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    try {
      _templates = await repo.listCharacterTemplates();
    } catch (_) {}

    var data = await repo.getCharacterNoteForm(widget.novelId, idx: widget.idx);

    if (widget.idx != null && ref.read(isSignedInProvider)) {
      try {
        final notes = await ref
            .read(notesRepositoryProvider)
            .listCharacterNotes(widget.novelId);
        final match = notes.where((n) => n.idx == widget.idx).firstOrNull;
        if (match != null) {
          data ??= {
            'title': match.title,
            'character_summaries': match.characterSummaries,
            'character_synopses': match.characterSynopses,
            'language_code': match.languageCode,
          };
        }
      } catch (_) {}
    }

    if (data != null) {
      _titleController.text = (data['title'] as String?) ?? '';
      _summariesController.text =
          (data['character_summaries'] as String?) ?? '';
      _synopsesController.text = (data['character_synopses'] as String?) ?? '';
      final lc = (data['language_code'] as String?) ?? 'en';
      ref.read(characterFormProvider.notifier).setLanguageCode(lc);
      _langDetection.updateDetection(_titleController.text);
    }

    ref
        .read(characterFormProvider.notifier)
        .setBaseValues(
          _titleController.text,
          _summariesController.text,
          _synopsesController.text,
          ref.read(characterFormProvider).languageCode,
        );
  }

  Future<void> _convertCharacter() async {
    final formState = ref.read(characterFormProvider);
    if (_titleController.text.isEmpty || formState.selectedTemplate == null) {
      return;
    }

    ref.read(characterFormProvider.notifier).setConverting(true);
    ref.read(characterFormProvider.notifier).clearError();

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final result = await repo.convertCharacter(
        name: _titleController.text,
        templateContent: formState.selectedTemplate!.characterSummaries ?? '',
        language: formState.languageCode,
      );

      if (result != null) {
        _summariesController.text = result;
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
        ref.read(characterFormProvider.notifier).setConverting(false);
      }
    }
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    ref.read(characterFormProvider.notifier).setLoading(true);
    ref.read(characterFormProvider.notifier).clearError();

    try {
      final repo = ref.read(localStorageRepositoryProvider);
      final notesRepo = ref.read(notesRepositoryProvider);
      final formState = ref.read(characterFormProvider);

      final useIdx = widget.idx ?? await repo.nextCharacterIdx(widget.novelId);

      final title = _titleController.text.trim();
      final summaries = _summariesController.text.trim().isEmpty
          ? null
          : _summariesController.text.trim();
      final synopses = _synopsesController.text.trim().isEmpty
          ? null
          : _synopsesController.text.trim();

      await repo.saveCharacterNoteForm(
        widget.novelId,
        title: title,
        summaries: summaries,
        synopses: synopses,
        languageCode: formState.languageCode,
        idx: useIdx,
      );

      if (ref.read(isSignedInProvider)) {
        await notesRepo.upsertCharacterNote(
          novelId: widget.novelId,
          idx: useIdx,
          title: title,
          summaries: summaries,
          synopses: synopses,
          languageCode: formState.languageCode,
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));

      ref
          .read(characterFormProvider.notifier)
          .setBaseValues(
            _titleController.text,
            _summariesController.text,
            _synopsesController.text,
            formState.languageCode,
          );
      _updateDirty();
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return;
      }
      ref.read(characterFormProvider.notifier).setError(e.toString());
    } finally {
      if (mounted) {
        ref.read(characterFormProvider.notifier).setLoading(false);
      }
    }
  }

  void _updateDirty() {
    final formState = ref.read(characterFormProvider);
    ref
        .read(characterFormProvider.notifier)
        .updateDirty(
          _titleController.text,
          _summariesController.text,
          _synopsesController.text,
          formState.languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final formState = ref.watch(characterFormProvider);
    final baseDecoration = const InputDecoration().applyDefaults(
      Theme.of(context).inputDecorationTheme,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.characters), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref
                  .watch(novelProvider(widget.novelId))
                  .when(
                    data: (novel) => _NovelHeader(novel: novel),
                    loading: () => _LoadingTile(label: l10n.loadingNovels),
                    error: (e, _) => _ErrorTile(
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
                            decoration: baseDecoration.copyWith(
                              hintText: l10n.titleLabel,
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
                          child: NeumorphicDropdown<String>(
                            value: formState.languageCode,
                            onChanged: (code) {
                              if (code == null) return;
                              ref
                                  .read(characterFormProvider.notifier)
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
                      Row(
                        children: [
                          Expanded(
                            child: Autocomplete<CharacterTemplateRow>(
                              displayStringForOption: (option) =>
                                  option.title ?? '',
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return _templates;
                                }
                                return _templates.where(
                                  (t) => (t.title ?? '').toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                              },
                              onSelected: (selection) {
                                ref
                                    .read(characterFormProvider.notifier)
                                    .setSelectedTemplate(selection);
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    final baseDecoration =
                                        const InputDecoration().applyDefaults(
                                          Theme.of(
                                            context,
                                          ).inputDecorationTheme,
                                        );
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      decoration: baseDecoration.copyWith(
                                        hintText: l10n.templateLabel,
                                        labelText: l10n.templateLabel,
                                      ),
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                    );
                                  },
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (formState.selectedTemplate != null &&
                              formState.selectedTemplate!.characterSummaries !=
                                  null)
                            Tooltip(
                              message: formState
                                  .selectedTemplate!
                                  .characterSummaries!,
                              child: const Icon(Icons.info_outline),
                            ),
                          const SizedBox(width: 8),
                          AppButtons.primary(
                            icon: Icons.auto_awesome,
                            label: l10n.aiConvert,
                            onPressed:
                                formState.isConverting ||
                                    _titleController.text.isEmpty ||
                                    formState.selectedTemplate == null
                                ? () {}
                                : _convertCharacter,
                            enabled:
                                !(formState.isConverting ||
                                    _titleController.text.isEmpty ||
                                    formState.selectedTemplate == null),
                            isLoading: formState.isConverting,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.summariesLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ref
                                    .read(characterFormProvider.notifier)
                                    .togglePreview();
                              },
                              child: Text(
                                formState.showPreview
                                    ? l10n.edit
                                    : l10n.preview,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (formState.showPreview)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        constraints: const BoxConstraints(minHeight: 100),
                        child: MarkdownBody(data: _summariesController.text),
                      )
                    else
                      TextFormField(
                        controller: _summariesController,
                        decoration: InputDecoration(
                          hintText: l10n.summariesLabel,
                        ),
                        maxLines: 10,
                        onChanged: (_) => _updateDirty(),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _synopsesController,
                      decoration: InputDecoration(
                        labelText: l10n.synopsesLabel,
                      ),
                      maxLines: 5,
                      onChanged: (_) => _updateDirty(),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        AppButtons.primary(
                          label: l10n.save,
                          onPressed: (formState.isLoading || !formState.isDirty)
                              ? () {}
                              : _save,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _NovelHeader extends StatelessWidget {
  const _NovelHeader({required this.novel});
  final Novel? novel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final title = novel?.title ?? l10n.unknownNovel;
    final author = novel?.author;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (author != null && author.isNotEmpty) Text(author),
      ],
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({
    required this.label,
    required this.novelId,
    required this.ref,
  });
  final String label;
  final String novelId;
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        AppButtons.icon(
          iconData: Icons.refresh,
          tooltip: l10n.reload,
          onPressed: () => ref.invalidate(novelProvider(novelId)),
        ),
      ],
    );
  }
}
