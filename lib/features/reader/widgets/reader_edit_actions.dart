import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/chapter_edit_controller.dart';
import '../../../models/chapter.dart';
import '../../../shared/widgets/app_buttons.dart';

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
    final Widget previewBtn = AppButtons.icon(
      iconData: previewMode ? Icons.visibility_off : Icons.visibility,
      tooltip: l10n.review,
      onPressed: onTogglePreview,
      enabled: previewEnabled,
    );
    final Widget formatBtn = AppButtons.icon(
      iconData: Icons.format_align_left,
      tooltip: l10n.format,
      onPressed: () => controller.formatContent(),
      enabled: !disabled,
    );
    // Summary edit mode: only show save button prominently
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview and format buttons on the left
        previewBtn,
        SizedBox(width: spacing),
        formatBtn,
        SizedBox(width: spacing),
        // Prominent save button
        AppButtons.primary(
          onPressed: () => controller.save(),
          icon: Icons.save,
          label: l10n.save,
          isLoading: editState.isSaving,
          enabled: !(disabled || !editState.isDirty),
        ),
      ],
    );
  }
}
