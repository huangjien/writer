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

  static final _titleFocusNode = FocusNode();
  static final _contentFocusNode = FocusNode();
  static final _indexFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final editState = ref.watch(chapterEditControllerProvider(current));
    final controller = ref.read(
      chapterEditControllerProvider(current).notifier,
    );
    ref.listen(chapterEditControllerProvider(current), (prev, next) {
      final prevStatus = prev?.embeddingStatus;
      final nextStatus = next.embeddingStatus;
      if (prevStatus != nextStatus && nextStatus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.of(context);
          final msg = nextStatus == 'embedding_updated'
              ? l10n.embeddingUpdated
              : l10n.embeddingFailed;
          messenger.showSnackBar(SnackBar(content: Text(msg)));
          controller.clearEmbeddingStatus();
        });
      }
    });
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
            focusNode: _titleFocusNode,
            decoration: InputDecoration(
              labelText: l10n.chapterTitle,
              hintText: l10n.enterChapterTitle,
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
              FocusScope.of(context).requestFocus(_contentFocusNode);
            },
            onChanged: controller.setTitle,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: editState.content,
            focusNode: _contentFocusNode,
            minLines: 12,
            maxLines: null,
            decoration: InputDecoration(
              labelText: l10n.chapterContent,
              hintText: l10n.enterChapterContent,
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
              FocusScope.of(context).requestFocus(_indexFocusNode);
            },
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
                focusNode: _indexFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.indexLabel(editState.idx),
                  hintText: l10n.enterFloatIndexHint,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (raw) =>
                    submitWithMode(IndexRoundingMode.after),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        if (editState.isSaving) const LinearProgressIndicator(),
        if (editState.embeddingInFlight) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
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
