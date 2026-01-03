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
    required this.onCreated,
    required this.isCompact,
    required this.isWideForEdit,
    required this.spacing,
    required this.iconSize,
  });

  final Chapter current;
  final bool previewMode;
  final VoidCallback onTogglePreview;
  final void Function(Chapter created) onCreated;
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
    final Widget previewBtn = IconButton(
      key: const ValueKey('btn_preview'),
      icon: Icon(previewMode ? Icons.visibility_off : Icons.visibility),
      iconSize: iconSize,
      onPressed: previewEnabled ? onTogglePreview : null,
    );
    final Widget formatBtn = IconButton(
      icon: const Icon(Icons.format_align_left),
      iconSize: iconSize,
      onPressed: disabled ? null : () => controller.formatContent(),
    );
    // Summary edit mode: only show save button prominently
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview and format buttons on the left
        Tooltip(message: 'Review', child: previewBtn),
        SizedBox(width: spacing),
        Tooltip(message: l10n.format, child: formatBtn),
        SizedBox(width: spacing),
        // Prominent save button
        ElevatedButton.icon(
          onPressed: (disabled || !editState.isDirty)
              ? null
              : () => controller.save(),
          icon: const Icon(Icons.save),
          label: Text(l10n.save),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
