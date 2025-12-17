import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../main.dart';

class CharactersScreen extends ConsumerStatefulWidget {
  const CharactersScreen({super.key, required this.novelId, this.idx});

  final String novelId;
  final int? idx;

  @override
  ConsumerState<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends ConsumerState<CharactersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summariesController = TextEditingController();
  final _synopsesController = TextEditingController();
  String _languageCode = 'en';
  bool _saving = false;
  String? _error;
  bool _isDirty = false;
  String _baseTitle = '';
  String _baseSummaries = '';
  String _baseSynopses = '';
  String _baseLanguageCode = 'en';

  List<CharacterTemplateRow> _templates = [];
  CharacterTemplateRow? _selectedTemplate;
  bool _isConverting = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localStorageRepositoryProvider);
    try {
      _templates = await repo.listCharacterTemplates();
    } catch (_) {}

    final data = await repo.getCharacterNoteForm(
      widget.novelId,
      idx: widget.idx,
    );
    if (data != null) {
      _titleController.text = (data['title'] as String?) ?? '';
      _summariesController.text =
          (data['character_summaries'] as String?) ?? '';
      _synopsesController.text = (data['character_synopses'] as String?) ?? '';
      final lc = (data['language_code'] as String?) ?? 'en';
      _languageCode = lc;
    }
    _baseTitle = _titleController.text;
    _baseSummaries = _summariesController.text;
    _baseSynopses = _synopsesController.text;
    _baseLanguageCode = _languageCode;
    _isDirty = false;
    setState(() {});
  }

  Future<void> _convertCharacter() async {
    if (_titleController.text.isEmpty || _selectedTemplate == null) return;

    setState(() {
      _isConverting = true;
    });

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final result = await repo.convertCharacter(
        name: _titleController.text,
        templateContent: _selectedTemplate!.characterSummaries ?? '',
        language: _languageCode,
      );

      if (result != null) {
        setState(() {
          _summariesController.text = result;
          _isDirty = true;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.conversionFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summariesController.dispose();
    _synopsesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.characters), actions: const []),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (supabaseEnabled)
                ref
                    .watch(novelProvider(widget.novelId))
                    .when(
                      data: (novel) => _NovelHeader(novel: novel),
                      loading: () => _LoadingTile(label: l10n.loadingNovels),
                      error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
                    )
              else
                ref
                    .watch(mockNovelsProvider)
                    .when(
                      data: (novels) {
                        final matches = novels.where(
                          (n) => n.id == widget.novelId,
                        );
                        final novel = matches.isNotEmpty ? matches.first : null;
                        return _NovelHeader(novel: novel);
                      },
                      loading: () => _LoadingTile(label: l10n.loadingNovels),
                      error: (e, _) => _ErrorTile(label: '${l10n.error}: $e'),
                    ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: l10n.titleLabel),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.required : null,
                      onChanged: (_) {
                        final dirty =
                            _titleController.text.trim() != _baseTitle.trim() ||
                            _summariesController.text.trim() !=
                                _baseSummaries.trim() ||
                            _synopsesController.text.trim() !=
                                _baseSynopses.trim() ||
                            _languageCode != _baseLanguageCode;
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
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
                                setState(() {
                                  _selectedTemplate = selection;
                                });
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: l10n.templateLabel,
                                        border: const OutlineInputBorder(),
                                      ),
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                    );
                                  },
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_selectedTemplate != null &&
                              _selectedTemplate!.characterSummaries != null)
                            Tooltip(
                              message: _selectedTemplate!.characterSummaries!,
                              child: const Icon(Icons.info_outline),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.auto_awesome),
                            label: _isConverting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.aiConvert),
                            onPressed:
                                _isConverting ||
                                    _titleController.text.isEmpty ||
                                    _selectedTemplate == null
                                ? null
                                : _convertCharacter,
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
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showPreview = !_showPreview;
                            });
                          },
                          child: Text(_showPreview ? l10n.edit : l10n.preview),
                        ),
                      ],
                    ),
                    if (_showPreview)
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
                        onChanged: (_) {
                          final dirty =
                              _titleController.text.trim() !=
                                  _baseTitle.trim() ||
                              _summariesController.text.trim() !=
                                  _baseSummaries.trim() ||
                              _synopsesController.text.trim() !=
                                  _baseSynopses.trim() ||
                              _languageCode != _baseLanguageCode;
                          if (dirty != _isDirty) {
                            setState(() => _isDirty = dirty);
                          }
                        },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _synopsesController,
                      decoration: InputDecoration(
                        labelText: l10n.synopsesLabel,
                      ),
                      maxLines: 5,
                      onChanged: (_) {
                        final dirty =
                            _titleController.text.trim() != _baseTitle.trim() ||
                            _summariesController.text.trim() !=
                                _baseSummaries.trim() ||
                            _synopsesController.text.trim() !=
                                _baseSynopses.trim() ||
                            _languageCode != _baseLanguageCode;
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text(l10n.chooseLanguage)),
                        DropdownButton<String>(
                          value: _languageCode,
                          onChanged: (code) {
                            if (code == null) {
                              return;
                            }
                            setState(() => _languageCode = code);
                            final dirty =
                                _titleController.text.trim() !=
                                    _baseTitle.trim() ||
                                _summariesController.text.trim() !=
                                    _baseSummaries.trim() ||
                                _synopsesController.text.trim() !=
                                    _baseSynopses.trim() ||
                                _languageCode != _baseLanguageCode;
                            if (dirty != _isDirty) {
                              setState(() => _isDirty = dirty);
                            }
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: (_saving || !_isDirty)
                              ? null
                              : () async {
                                  final ok =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!ok) {
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
                                    final useIdx =
                                        widget.idx ??
                                        await repo.nextCharacterIdx(
                                          widget.novelId,
                                        );
                                    await repo.saveCharacterNoteForm(
                                      widget.novelId,
                                      title: _titleController.text.trim(),
                                      summaries:
                                          _summariesController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _summariesController.text.trim(),
                                      synopses:
                                          _synopsesController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _synopsesController.text.trim(),
                                      languageCode: _languageCode,
                                      idx: useIdx,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.saved)),
                                    );
                                  } catch (e) {
                                    setState(() => _error = e.toString());
                                  } finally {
                                    if (mounted) {
                                      setState(() => _saving = false);
                                    }
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
  const _ErrorTile({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
