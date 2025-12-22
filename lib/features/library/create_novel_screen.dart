import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/strings.dart';
import '../../state/providers.dart';
import '../../state/novel_providers.dart';
import '../../repositories/novel_repository.dart';

class CreateNovelScreen extends ConsumerStatefulWidget {
  const CreateNovelScreen({super.key});

  @override
  ConsumerState<CreateNovelScreen> createState() => _CreateNovelScreenState();
}

class _CreateNovelScreenState extends ConsumerState<CreateNovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  String _languageCode = 'en';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(novelRepositoryProvider);
      final novel = await repo.createNovel(
        title: trimOrDefault(_titleController.text, 'Untitled'),
        author: trimToNull(_authorController.text),
        description: trimToNull(_descriptionController.text),
        coverUrl: trimToNull(_coverUrlController.text),
        languageCode: _languageCode,
        isPublic: true,
      );
      if (!mounted) return;
      ref.invalidate(novelsProvider);
      context.goNamed('novel', pathParameters: {'id': novel.id});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSignedIn = ref.watch(isSignedInProvider);
    if (!isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.createNovel)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.signInToSync),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/auth'),
                child: Text(l10n.signIn),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createNovel)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: l10n.titleLabel),
                      validator: (v) => isBlank(v) ? l10n.titleLabel : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _languageCode,
                    onChanged: (code) {
                      if (code == null) return;
                      setState(() => _languageCode = code);
                    },
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                      DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: l10n.authorLabel),
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
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coverUrlController,
                decoration: InputDecoration(labelText: l10n.coverUrlLabel),
                validator: _validateCoverUrl,
              ),
              const SizedBox(height: 16),
              if (_saving) const LinearProgressIndicator(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.create),
                  onPressed: _saving ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
