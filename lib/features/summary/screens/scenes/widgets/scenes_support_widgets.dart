import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/state/novel_providers.dart';

class SceneTemplateInfoButton extends StatelessWidget {
  const SceneTemplateInfoButton({super.key, required this.template});

  final SceneTemplateRow? template;

  @override
  Widget build(BuildContext context) {
    final summary = template?.sceneSummaries;
    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    return Tooltip(message: summary, child: const Icon(Icons.info_outline));
  }
}

class SceneConvertButton extends StatelessWidget {
  const SceneConvertButton({
    super.key,
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

class SceneSaveButton extends StatelessWidget {
  const SceneSaveButton({
    super.key,
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

class SceneNovelHeader extends StatelessWidget {
  const SceneNovelHeader({super.key, required this.novel});

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

class SceneLoadingTile extends StatelessWidget {
  const SceneLoadingTile({super.key, required this.label});

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

class SceneErrorTile extends StatelessWidget {
  const SceneErrorTile({
    super.key,
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
