import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/strings.dart';
import '../../../state/providers.dart';
import '../../../state/novel_providers.dart';
import '../../../repositories/novel_repository.dart';
import '../../../theme/design_tokens.dart';
import '../../../shared/widgets/neumorphic_dropdown.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../features/auth/state/auth_form_state.dart'
    show authFormProvider;

String? _urlValidator(String? value, AppLocalizations l10n) {
  if (value == null || value.trim().isEmpty) return null;
  final url = value.trim();
  if (url.length > 2048) {
    return l10n.invalidCoverUrl;
  }
  if (url.contains(' ')) {
    return l10n.invalidCoverUrl;
  }
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return l10n.invalidCoverUrl;
  }
  return null;
}

class CreateNovelScreen extends ConsumerWidget {
  const CreateNovelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _CreateNovelContent();
  }
}

class _CreateNovelContent extends ConsumerStatefulWidget {
  const _CreateNovelContent();

  @override
  ConsumerState<_CreateNovelContent> createState() =>
      _CreateNovelContentState();
}

class _CreateNovelContentState extends ConsumerState<_CreateNovelContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  String _languageCode = 'en';

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    final notifier = ref.read(authFormProvider.notifier);
    notifier.setLoading(true);
    notifier.clearError();
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
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;
      ref.invalidate(novelsProvider);
      context.goNamed('novel', pathParameters: {'id': novel.id});
      notifier.setSuccess(l10n.saved);
    } catch (e) {
      notifier.setError(e.toString());
    } finally {
      if (mounted) {
        notifier.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authFormState = ref.watch(authFormProvider);
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
              AppButtons.primary(
                onPressed: () => context.push('/auth'),
                label: l10n.signIn,
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
                    child: _NeumorphicTextFormField(
                      controller: _titleController,
                      hintText: l10n.titleLabel,
                      labelText: l10n.titleLabel,
                      validator: (v) => isBlank(v) ? l10n.titleLabel : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  NeumorphicDropdown<String>(
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
              _NeumorphicTextFormField(
                controller: _authorController,
                hintText: l10n.authorLabel,
                labelText: l10n.authorLabel,
              ),
              const SizedBox(height: 12),
              _NeumorphicTextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: null,
                hintText: l10n.descriptionLabel,
                labelText: l10n.descriptionLabel,
                alignLabelWithHint: true,
              ),
              const SizedBox(height: 12),
              _NeumorphicTextFormField(
                controller: _coverUrlController,
                hintText: l10n.coverUrlLabel,
                labelText: l10n.coverUrlLabel,
                validator: (v) => _urlValidator(v, l10n),
              ),
              const SizedBox(height: 16),
              if (authFormState.isLoading) const LinearProgressIndicator(),
              if (authFormState.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  authFormState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: AppButtons.primary(
                  icon: Icons.add,
                  label: l10n.create,
                  onPressed: authFormState.isLoading ? () {} : _submit,
                  isLoading: authFormState.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeumorphicTextFormField extends StatelessWidget {
  const _NeumorphicTextFormField({
    required this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.minLines,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final bool alignLabelWithHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        alignLabelWithHint: alignLabelWithHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.m,
        ),
      ),
    );
  }
}
