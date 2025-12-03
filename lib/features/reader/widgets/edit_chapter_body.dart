import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/chapter_repository.dart';
import '../../../models/chapter.dart';
import '../../../state/chapter_edit_controller.dart';
import '../widgets/preview_panel.dart';
import '../novel_metadata_editor.dart';
import '../../../state/edit_permissions.dart';

class EditChapterBody extends ConsumerWidget {
  const EditChapterBody({
    super.key,
    required this.novelId,
    required this.current,
    required this.previewMode,
  });

  final String novelId;
  final Chapter current;
  final bool previewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final editState = ref.watch(chapterEditControllerProvider(current));
    final controller = ref.read(
      chapterEditControllerProvider(current).notifier,
    );
    final roleAsync = ref.watch(editRoleProvider(novelId));
    final isOwner = roleAsync.asData?.value == EditRole.owner;
    final originalTitle = current.title ?? '';
    final originalContent = current.content ?? '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isOwner) ...[
          NovelMetadataEditor(novelId: novelId),
          const SizedBox(height: 16),
        ],
        if (previewMode) ...[
          PreviewPanel(
            draftTitle: editState.title,
            draftContent: editState.content,
            originalTitle: originalTitle,
            originalContent: originalContent,
          ),
          const SizedBox(height: 12),
        ] else ...[
          TextFormField(
            initialValue: editState.title,
            decoration: InputDecoration(
              labelText: l10n.chapterTitle,
              hintText: l10n.enterChapterTitle,
            ),
            onChanged: controller.setTitle,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: editState.content,
            minLines: 12,
            maxLines: null,
            decoration: InputDecoration(
              labelText: l10n.chapterContent,
              hintText: l10n.enterChapterContent,
              alignLabelWithHint: true,
            ),
            onChanged: controller.setContent,
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final idxController = TextEditingController(
                text: editState.idx.toString(),
              );
              final messenger = ScaffoldMessenger.of(context);
              Future<void> submitWithMode(IndexRoundingMode mode) async {
                final raw = idxController.text;
                final v = double.tryParse(raw.trim());
                if (v == null) return;
                final repo = ref.read(chapterRepositoryProvider);
                int maxIdx;
                try {
                  final next = await repo.getNextIdx(novelId);
                  maxIdx = next - 1;
                } catch (_) {
                  maxIdx = editState.idx;
                }
                if (maxIdx < 1) maxIdx = 1;
                final minIdx = 1;
                final newIdx = mode == IndexRoundingMode.after
                    ? v.ceil()
                    : v.floor();
                if (newIdx == editState.idx) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.indexUnchanged)),
                  );
                  return;
                }
                if (newIdx < minIdx || newIdx > maxIdx) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.indexOutOfRange(minIdx, maxIdx)),
                    ),
                  );
                  return;
                }
                final ok = await controller.changeIndexFromFloat(v, mode: mode);
                if (ok) {
                  idxController.text = newIdx.toString();
                }
              }

              return TextFormField(
                controller: idxController,
                decoration: InputDecoration(
                  labelText: l10n.indexLabel(editState.idx),
                  hintText: l10n.enterFloatIndexHint,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onFieldSubmitted: (raw) =>
                    submitWithMode(IndexRoundingMode.after),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        if (editState.isSaving) const LinearProgressIndicator(),
        if (editState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            editState.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
