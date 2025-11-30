import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/chapter_edit_controller.dart';
import '../../../models/chapter.dart';

class ReaderEditActions extends ConsumerWidget {
  const ReaderEditActions({
    super.key,
    required this.current,
    required this.previewMode,
    required this.onTogglePreview,
    required this.isCompact,
    required this.isWideForEdit,
    required this.spacing,
    required this.iconSize,
  });

  final Chapter current;
  final bool previewMode;
  final VoidCallback onTogglePreview;
  final bool isCompact;
  final bool isWideForEdit;
  final double spacing;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final editState = ref.watch(chapterEditControllerProvider(current));
    final controller = ref.read(
      chapterEditControllerProvider(current).notifier,
    );
    final bool disabled = editState.isSaving;
    final bool previewEnabled = editState.isDirty;
    final Widget previewBtn = (isCompact || !isWideForEdit)
        ? IconButton(
            key: const ValueKey('btn_preview'),
            icon: Icon(previewMode ? Icons.visibility_off : Icons.visibility),
            iconSize: iconSize,
            onPressed: previewEnabled ? onTogglePreview : null,
          )
        : IconButton(
            key: const ValueKey('btn_preview'),
            icon: Icon(previewMode ? Icons.visibility_off : Icons.visibility),
            iconSize: iconSize,
            onPressed: previewEnabled ? onTogglePreview : null,
          );
    final Widget saveBtn = IconButton(
      icon: const Icon(Icons.save),
      iconSize: iconSize,
      onPressed: (disabled || !editState.isDirty)
          ? null
          : () => controller.save(),
    );
    final Widget createBtn = IconButton(
      icon: const Icon(Icons.add),
      iconSize: iconSize,
      onPressed: disabled ? null : () => controller.createNextChapter(),
    );
    final Widget deleteBtn = IconButton(
      icon: const Icon(Icons.delete),
      iconSize: iconSize,
      onPressed: disabled ? null : () => controller.deleteCurrentChapter(),
    );
    final Widget formatBtn = IconButton(
      icon: const Icon(Icons.format_align_left),
      iconSize: iconSize,
      onPressed: disabled ? null : () => controller.formatContent(),
    );
    return Row(
      children: [
        Tooltip(message: 'Review', child: previewBtn),
        SizedBox(width: spacing),
        Tooltip(message: l10n.format, child: formatBtn),
        SizedBox(width: spacing),
        Tooltip(message: l10n.save, child: saveBtn),
        SizedBox(width: spacing),
        Tooltip(message: l10n.createNextChapter, child: createBtn),
        SizedBox(width: spacing),
        Tooltip(message: l10n.delete, child: deleteBtn),
      ],
    );
  }
}
