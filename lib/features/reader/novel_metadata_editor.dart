import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/shared/strings.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/novel_repository.dart';

class NovelMetadataEditor extends ConsumerStatefulWidget {
  final String novelId;
  const NovelMetadataEditor({super.key, required this.novelId});

  @override
  ConsumerState<NovelMetadataEditor> createState() =>
      _NovelMetadataEditorState();
}

class _NovelMetadataEditorState extends ConsumerState<NovelMetadataEditor> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _contributorEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _coverUrlFocusNode = FocusNode();
  final _contributorEmailFocusNode = FocusNode();
  bool _initialized = false;
  bool _saving = false;
  bool _isValid = true;
  bool _coverValid = true;
  String? _error;
  String _languageCode = 'en';
  bool _isPublic = true;
  bool _isDirty = false;
  String _baseTitle = '';
  String _baseDescription = '';
  String _baseCoverUrl = '';
  String _baseLanguageCode = 'en';
  bool _baseIsPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _contributorEmailController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _coverUrlFocusNode.dispose();
    _contributorEmailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate before saving; guard against invalid form state.
    final currentState = _formKey.currentState;
    if (currentState != null) {
      final valid = currentState.validate();
      if (!valid) {
        setState(() => _isValid = false);
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(novelRepositoryProvider);
      await repo.updateNovelMetadata(
        widget.novelId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coverUrl: _coverUrlController.text.trim().isEmpty
            ? null
            : _coverUrlController.text.trim(),
        languageCode: _languageCode,
        isPublic: _isPublic,
      );
      ref.invalidate(novelProvider(widget.novelId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.progressSaved)),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateCoverUrl(String? raw) {
    final l10n = AppLocalizations.of(context)!;
    final value = trimOrEmpty(raw);
    if (value.isEmpty) return null; // optional field
    if (value.length > 2048) return l10n.invalidCoverUrl;
    if (value.contains(' ')) return l10n.invalidCoverUrl;
    final lower = value.toLowerCase();
    final hasValidScheme =
        lower.startsWith('http://') || lower.startsWith('https://');
    if (!hasValidScheme) return l10n.invalidCoverUrl;
    return null;
  }

  void _onCoverChanged(String _) {
    final error = _validateCoverUrl(_coverUrlController.text);
    final nowValid = error == null;
    // debugPrint can help us trace state changes during tests
    debugPrint(
      'NovelMetadataEditor: cover changed -> valid=$nowValid, text="${_coverUrlController.text}"',
    );
    if (nowValid != _coverValid) {
      setState(() => _coverValid = nowValid);
    }
    _recomputeFormValidity();
  }

  void _recomputeFormValidity() {
    final currentState = _formKey.currentState;
    final ok = currentState?.validate() ?? true;
    if (ok != _isValid) {
      setState(() => _isValid = ok);
    }
  }

  void _checkDirty() {
    final dirty =
        _titleController.text.trim() != _baseTitle.trim() ||
        _descriptionController.text.trim() != _baseDescription.trim() ||
        _coverUrlController.text.trim() != _baseCoverUrl.trim() ||
        _languageCode != _baseLanguageCode ||
        _isPublic != _baseIsPublic;

    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final novelAsync = ref.watch(novelProvider(widget.novelId));
    final roleAsync = ref.watch(editRoleProvider(widget.novelId));
    final isOwner = roleAsync.asData?.value == EditRole.owner;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              l10n.novelMetadata,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            novelAsync.when(
              data: (novel) {
                if (!_initialized && novel != null) {
                  _titleController.text = novel.title;
                  _descriptionController.text = novel.description ?? '';
                  _coverUrlController.text = novel.coverUrl ?? '';
                  _languageCode = novel.languageCode;
                  _isPublic = novel.isPublic;
                  _initialized = true;
                  _baseTitle = novel.title;
                  _baseDescription = novel.description ?? '';
                  _baseCoverUrl = novel.coverUrl ?? '';
                  _baseLanguageCode = novel.languageCode;
                  _baseIsPublic = novel.isPublic;
                  _isDirty = false;
                }
                return Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              decoration: InputDecoration(
                                labelText: l10n.titleLabel,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_descriptionFocusNode);
                              },
                              onChanged: (_) {
                                _recomputeFormValidity();
                                _checkDirty();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _languageCode,
                            onChanged: (code) {
                              if (code == null) return;
                              setState(() => _languageCode = code);
                              _checkDirty();
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
                          if (isOwner) ...[
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Switch(
                                  value: _isPublic,
                                  onChanged: (v) {
                                    setState(() => _isPublic = v);
                                    _checkDirty();
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(l10n.publicLabel),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionLabel,
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_coverUrlFocusNode);
                        },
                        onChanged: (_) {
                          _recomputeFormValidity();
                          _checkDirty();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _coverUrlController,
                        focusNode: _coverUrlFocusNode,
                        decoration: InputDecoration(
                          labelText: l10n.coverUrlLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateCoverUrl,
                        onFieldSubmitted: (_) {
                          if (isOwner) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_contributorEmailFocusNode);
                          }
                        },
                        onChanged: (s) {
                          _onCoverChanged(s);
                          _checkDirty();
                        },
                      ),
                      const SizedBox(height: 12),
                      if (isOwner) ...[
                        TextFormField(
                          controller: _contributorEmailController,
                          focusNode: _contributorEmailFocusNode,
                          decoration: InputDecoration(
                            labelText: l10n.contributorEmailLabel,
                            hintText: l10n.contributorEmailHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1),
                            label: Text(l10n.addContributor),
                            onPressed: () async {
                              final email = _contributorEmailController.text
                                  .trim();
                              if (email.isEmpty) return;
                              try {
                                final repo = ref.read(novelRepositoryProvider);
                                await repo.addContributorByEmail(
                                  novelId: widget.novelId,
                                  email: email,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.contributorAdded),
                                  ),
                                );
                                _contributorEmailController.clear();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${l10n.error}: $e')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_saving) const LinearProgressIndicator(),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save),
                          label: Text(l10n.save),
                          // Debug build trace for tests
                          onLongPress: () {
                            debugPrint(
                              'Save button longPress: saving=$_saving coverValid=$_coverValid',
                            );
                          },
                          onPressed: (_saving || !_coverValid || !_isDirty)
                              ? null
                              : _save,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
