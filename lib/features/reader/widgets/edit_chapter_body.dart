import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/chapter_repository.dart';
import '../../../models/chapter.dart';
import '../../../state/chapter_edit_controller.dart';
import '../../../theme/design_tokens.dart';
import '../widgets/preview_panel.dart';
import 'contrast_monitor.dart';
import 'contrast_alert_dialog.dart';

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
    final theme = Theme.of(context);
    final originalTitle = current.title ?? '';
    final originalContent = current.content ?? '';
    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: ContrastWidget(
        onContrastIssue: () {
          final alerts = ref.read(contrastMonitorProvider);
          if (alerts.any((alert) => alert.isCritical)) {
            showContrastAlertDialog(
              context,
              onApplyPreset: () {
                final monitor = ref.read(contrastMonitorProvider);
                if (monitor.isNotEmpty &&
                    monitor.first.suggestions.isNotEmpty) {
                  final bestSuggestion = monitor.first.suggestions.first;
                  ref
                      .read(contrastMonitorProvider.notifier)
                      .applySuggestion(
                        bestSuggestion,
                        monitor.first.elementName,
                      );
                }
              },
            );
          }
        },
        child: Column(
          children: [
            // Top metadata section (minimal) removed

            // Expanded content area
            Expanded(
              child: previewMode
                  ? PreviewPanel(
                      draftTitle: editState.title,
                      draftContent: editState.content,
                      originalTitle: originalTitle,
                      originalContent: originalContent,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title field
                        TextFormField(
                          initialValue: editState.title,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            hintText: l10n.enterChapterTitle,
                            labelText: l10n.chapterTitle,
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_contentFocusNode);
                          },
                          onChanged: controller.setTitle,
                        ),
                        const SizedBox(height: Spacing.m),

                        // Content field (expanded to fill available space)
                        Expanded(
                          child: TextFormField(
                            initialValue: editState.content,
                            focusNode: _contentFocusNode,
                            decoration: InputDecoration(
                              hintText: l10n.enterChapterContent,
                              labelText: l10n.chapterContent,
                              alignLabelWithHint: true,
                            ),
                            textInputAction: TextInputAction.newline,
                            onChanged: controller.setContent,
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                        const SizedBox(height: Spacing.m),

                        // Chapter index field
                        Builder(
                          builder: (context) {
                            final idxController = TextEditingController(
                              text: editState.idx.toString(),
                            );
                            final messenger = ScaffoldMessenger.of(context);
                            Future<void> submitWithMode(
                              IndexRoundingMode mode,
                            ) async {
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
                                    content: Text(
                                      l10n.indexOutOfRange(minIdx, maxIdx),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final ok = await controller.changeIndexFromFloat(
                                v,
                                mode: mode,
                              );
                              if (ok) {
                                idxController.text = newIdx.toString();
                              }
                            }

                            return TextFormField(
                              controller: idxController,
                              focusNode: _indexFocusNode,
                              decoration: InputDecoration(
                                hintText: l10n.enterFloatIndexHint,
                                labelText: l10n.indexLabel(editState.idx),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (raw) =>
                                  submitWithMode(IndexRoundingMode.after),
                            );
                          },
                        ),
                      ],
                    ),
            ),

            // Status indicators at the bottom
            if (editState.isSaving) ...[
              Container(
                height: 14,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Radii.s),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.s - 2),
                  child: _NeumorphicIndeterminateBar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s),
            ],
            if (editState.errorMessage != null) ...[
              const SizedBox(height: Spacing.s),
              Text(
                editState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NeumorphicIndeterminateBar extends StatefulWidget {
  const _NeumorphicIndeterminateBar({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;

  @override
  State<_NeumorphicIndeterminateBar> createState() =>
      _NeumorphicIndeterminateBarState();
}

class _NeumorphicIndeterminateBarState
    extends State<_NeumorphicIndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final barW = (w * 0.35).clamp(8.0, w);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            final left = (w + barW) * t - barW;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: widget.backgroundColor),
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: barW,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.foregroundColor,
                        borderRadius: BorderRadius.circular(Radii.s - 2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
