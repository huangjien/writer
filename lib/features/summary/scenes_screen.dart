import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/repositories/remote_repository.dart';
import '../../main.dart';
import '../../models/scene.dart';

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
      _templates = await repo.listSceneTemplates(limit: 50);
    } catch (_) {}

    final item = await repo.getSceneForm(widget.novelId, idx: widget.idx);
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
        final res = await repo.searchSceneTemplates(
          q,
          limit: 10,
          languageCode: _languageCode,
        );
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
                          if (_selectedTemplate != null &&
                              _selectedTemplate!.sceneSummaries != null)
                            Tooltip(
                              message: _selectedTemplate!.sceneSummaries!,
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
                        ElevatedButton(
                          onPressed: (_saving || !_isDirty)
                              ? null
                              : () async {
                                  final ok =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!ok) return;
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
                                        await repo.nextSceneIdx(widget.novelId);
                                    await repo.saveSceneForm(
                                      widget.novelId,
                                      Scene(
                                        novelId: widget.novelId,
                                        title: _titleController.text.trim(),
                                        location:
                                            _locationController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _locationController.text.trim(),
                                        summary:
                                            _summaryController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : _summaryController.text.trim(),
                                      ),
                                      idx: useIdx,
                                    );
                                    if (!context.mounted) return;
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
