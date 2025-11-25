import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/shared/strings.dart';
import 'package:writer/state/edit_permissions.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool _saving = false;
  bool _isValid = true;
  bool _coverValid = true;
  String? _error;
  String _languageCode = 'en';
  bool _isPublic = true;
  final _contributorEmailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _contributorEmailController.dispose();
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
              'Novel Metadata',
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
                }
                return Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: l10n.titleLabel),
                        onChanged: (_) => _recomputeFormValidity(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionLabel,
                          alignLabelWithHint: true,
                        ),
                        onChanged: (_) => _recomputeFormValidity(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _coverUrlController,
                        decoration: InputDecoration(
                          labelText: l10n.coverUrlLabel,
                        ),
                        validator: _validateCoverUrl,
                        onChanged: _onCoverChanged,
                      ),
                      const SizedBox(height: 12),
                      if (isOwner) ...[
                        SwitchListTile(
                          value: _isPublic,
                          title: const Text('Public'),
                          onChanged: (v) => setState(() => _isPublic = v),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(child: Text(l10n.chooseLanguage)),
                          DropdownButton<String>(
                            value: _languageCode,
                            onChanged: (code) {
                              if (code == null) return;
                              setState(() => _languageCode = code);
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
                      if (isOwner) ...[
                        TextFormField(
                          controller: _contributorEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Contributor Email',
                            hintText: 'Enter user email to add as contributor',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add Contributor'),
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
                                  const SnackBar(
                                    content: Text('Contributor added'),
                                  ),
                                );
                                _contributorEmailController.clear();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
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
                          onPressed: (_saving || !_coverValid) ? null : _save,
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
