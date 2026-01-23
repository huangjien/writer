import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';

import '../../models/scene.dart';
import 'package:writer/repositories/notes_repository.dart';
import '../../state/providers.dart';
import 'package:writer/shared/api_exception.dart';
import '../../shared/widgets/app_buttons.dart';

class ScenesScreen extends ConsumerStatefulWidget {
  const ScenesScreen({super.key, required this.novelId, this.idx});

  final String novelId;
  final int? idx;

  @override
  ConsumerState<ScenesScreen> createState() => _ScenesScreenState();
}

class _ScenesScreenState extends ConsumerState<ScenesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  String _languageCode = 'en';
  bool _saving = false;
  String? _error;
  bool _isDirty = false;
  String _baseTitle = '';
  String _baseLocation = '';
  String _baseSummary = '';
  String _baseLanguageCode = 'en';

  List<SceneTemplateRow> _templates = [];
  SceneTemplateRow? _selectedTemplate;
  bool _isConverting = false;
  bool _showPreview = false;
  Timer? _templateSearchTimer;
  bool _templateSearchLoading = false;
  String _templateQuery = '';
  List<SceneTemplateRow> _templateSearchResults = [];
  TextEditingController? _templateController;

  @override
  void initState() {
    super.initState();
    _load();
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

    // Load from local draft first
    var item = await repo.getSceneForm(widget.novelId, idx: widget.idx);

    // If signed in, try to fetch from backend to get latest version if local is empty or we prefer remote?
    // Actually, usually we load what we have. If we are editing an existing scene (idx known), we might want to fetch it.
    if (widget.idx != null && ref.read(isSignedInProvider)) {
      try {
        final notes = await ref
            .read(notesRepositoryProvider)
            .listSceneNotes(widget.novelId);
        final match = notes.where((n) => n.idx == widget.idx).firstOrNull;
        if (match != null) {
          // Prefer remote if found? Or only if local is null?
          // Simplest is to use remote if local is null, or maybe just overwrite local?
          // Since this is a "Form" screen, maybe we assume local is latest draft?
          // But if I open scene 5 for first time on this device, local is empty.
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
    }
    _baseTitle = _titleController.text;
    _baseLocation = _locationController.text;
    _baseSummary = _summaryController.text;
    _baseLanguageCode = _languageCode;
    _isDirty = false;
    setState(() {});
  }

  Iterable<SceneTemplateRow> _templatesForLanguage(String languageCode) =>
      _templates.where((t) => t.languageCode == languageCode);

  void _scheduleTemplateSearch(String raw) {
    final q = raw.trim();
    _templateSearchTimer?.cancel();
    _templateQuery = q;
    if (q.isEmpty) {
      if (mounted) {
        setState(() {
          _templateSearchLoading = false;
          _templateSearchResults = [];
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _templateSearchLoading = true;
      });
    }
    _templateSearchTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        final repo = ref.read(localStorageRepositoryProvider);
        List<SceneTemplateRow> res = [];
        if (ref.read(isSignedInProvider)) {
          try {
            res = await ref
                .read(templateRepositoryProvider)
                .searchSceneTemplates(q, limit: 5, languageCode: _languageCode);
          } catch (_) {
            res = await repo.searchSceneTemplates(
              q,
              limit: 5,
              languageCode: _languageCode,
            );
          }
        } else {
          res = await repo.searchSceneTemplates(
            q,
            limit: 5,
            languageCode: _languageCode,
          );
        }
        if (!mounted) return;
        setState(() {
          _templateSearchLoading = false;
          _templateSearchResults = res.isEmpty
              ? _templatesForLanguage(_languageCode)
                    .where(
                      (t) => (t.title ?? '').toLowerCase().contains(
                        q.toLowerCase(),
                      ),
                    )
                    .toList()
              : res;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _templateSearchLoading = false;
        });
      }
    });
  }

  Future<void> _convertScene() async {
    if (_titleController.text.isEmpty || _selectedTemplate == null) return;

    setState(() {
      _isConverting = true;
    });

    try {
      final repo = ref.read(remoteRepositoryProvider);
      final result = await repo.convertScene(
        name: _titleController.text,
        templateContent: _selectedTemplate!.sceneSummaries ?? '',
        language: _languageCode,
      );

      if (result != null) {
        setState(() {
          _summaryController.text = result;
          _isDirty = true;
        });
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
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  Future<void> _saveScene() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(localStorageRepositoryProvider);
      final notesRepo = ref.read(notesRepositoryProvider);

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
          idx: useIdx,
          title: scene.title,
          synopses: scene.location,
          summaries: scene.summary,
          languageCode: _languageCode,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        return;
      }
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _templateSearchTimer?.cancel();
    _titleController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            onChanged: (_) {
                              final dirty =
                                  _titleController.text.trim() !=
                                      _baseTitle.trim() ||
                                  _locationController.text.trim() !=
                                      _baseLocation.trim() ||
                                  _summaryController.text.trim() !=
                                      _baseSummary.trim() ||
                                  _languageCode != _baseLanguageCode;
                              if (dirty != _isDirty) {
                                setState(() => _isDirty = dirty);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _languageCode,
                          onChanged: (code) {
                            if (code == null) {
                              return;
                            }
                            _templateSearchTimer?.cancel();
                            setState(() {
                              _languageCode = code;
                              _selectedTemplate = null;
                              _templateQuery = '';
                              _templateSearchResults = [];
                              _templateSearchLoading = false;
                              _templateController?.text = '';
                            });
                            final dirty =
                                _titleController.text.trim() !=
                                    _baseTitle.trim() ||
                                _locationController.text.trim() !=
                                    _baseLocation.trim() ||
                                _summaryController.text.trim() !=
                                    _baseSummary.trim() ||
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
                    const SizedBox(height: 12),
                    if (_templates.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Autocomplete<SceneTemplateRow>(
                              displayStringForOption: (option) =>
                                  option.title ?? '',
                              optionsBuilder: (textEditingValue) {
                                final q = textEditingValue.text.trim();
                                if (q.isEmpty) {
                                  return _templatesForLanguage(_languageCode);
                                }
                                if (_templateQuery == q &&
                                    _templateSearchResults.isNotEmpty) {
                                  return _templateSearchResults;
                                }
                                return _templatesForLanguage(
                                  _languageCode,
                                ).where(
                                  (t) => (t.title ?? '').toLowerCase().contains(
                                    q.toLowerCase(),
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
                                    _templateController = textEditingController;
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: l10n.templateLabel,
                                        border: const OutlineInputBorder(),
                                        suffixIcon: _templateSearchLoading
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      onChanged: (v) {
                                        if (_selectedTemplate != null) {
                                          setState(() {
                                            _selectedTemplate = null;
                                          });
                                        }
                                        _scheduleTemplateSearch(v);
                                      },
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                    );
                                  },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TemplateInfoButton(template: _selectedTemplate),
                          const SizedBox(width: 8),
                          _ConvertButton(
                            l10n: l10n,
                            isConverting: _isConverting,
                            onPressed:
                                (_isConverting ||
                                    _titleController.text.isEmpty ||
                                    _selectedTemplate == null)
                                ? null
                                : _convertScene,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.locationLabel,
                      ),
                      onChanged: (_) {
                        final dirty =
                            _titleController.text.trim() != _baseTitle.trim() ||
                            _locationController.text.trim() !=
                                _baseLocation.trim() ||
                            _summaryController.text.trim() !=
                                _baseSummary.trim() ||
                            _languageCode != _baseLanguageCode;
                        if (dirty != _isDirty) setState(() => _isDirty = dirty);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.descriptionLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showPreview = !_showPreview;
                                });
                              },
                              child: Text(
                                _showPreview ? l10n.edit : l10n.preview,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
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
                        child: MarkdownBody(data: _summaryController.text),
                      )
                    else
                      TextFormField(
                        controller: _summaryController,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionLabel,
                        ),
                        maxLines: 5,
                        onChanged: (_) {
                          final dirty =
                              _titleController.text.trim() !=
                                  _baseTitle.trim() ||
                              _locationController.text.trim() !=
                                  _baseLocation.trim() ||
                              _summaryController.text.trim() !=
                                  _baseSummary.trim() ||
                              _languageCode != _baseLanguageCode;
                          if (dirty != _isDirty) {
                            setState(() => _isDirty = dirty);
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _SaveButton(
                          l10n: l10n,
                          saving: _saving,
                          isDirty: _isDirty,
                          onSave: _saveScene,
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

class _TemplateInfoButton extends StatelessWidget {
  const _TemplateInfoButton({required this.template});

  final SceneTemplateRow? template;

  @override
  Widget build(BuildContext context) {
    return template != null && template!.sceneSummaries != null
        ? Tooltip(
            message: template!.sceneSummaries!,
            child: const Icon(Icons.info_outline),
          )
        : const SizedBox.shrink();
  }
}

class _ConvertButton extends StatelessWidget {
  const _ConvertButton({
    required this.l10n,
    required this.isConverting,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final bool isConverting;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.auto_awesome),
      label: isConverting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(l10n.aiConvert),
      onPressed: onPressed == null ? null : () => onPressed!(),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.l10n,
    required this.saving,
    required this.isDirty,
    required this.onSave,
  });

  final AppLocalizations l10n;
  final bool saving;
  final bool isDirty;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppButtons.primary(
      icon: Icons.save,
      label: l10n.save,
      onPressed: (saving || !isDirty) ? () {} : onSave,
      isLoading: saving,
      enabled: !(saving || !isDirty),
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
