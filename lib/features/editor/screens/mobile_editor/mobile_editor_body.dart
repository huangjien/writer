import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/app_buttons.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/features/editor/rich_text_editor.dart';
import 'package:writer/features/editor/writing_stats.dart';
import 'package:writer/features/editor/formatting_toolbar.dart';
import 'package:writer/features/editor/zen_mode.dart';

class MobileEditorBody extends StatelessWidget {
  const MobileEditorBody({
    super.key,
    required this.l10n,
    required this.theme,
    required this.keyboardHeight,
    required this.zenMode,
    required this.preview,
    required this.isSaving,
    required this.streakDays,
    required this.titleController,
    required this.contentController,
    required this.onSave,
    required this.onExitZenMode,
    required this.onTogglePreview,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final double keyboardHeight;
  final bool zenMode;
  final bool preview;
  final bool isSaving;
  final int streakDays;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;
  final VoidCallback onExitZenMode;
  final VoidCallback onTogglePreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (zenMode)
          ZenModeBar(
            onExit: onExitZenMode,
            onSave: onSave,
            preview: preview,
            onTogglePreview: onTogglePreview,
          ),
        if (!zenMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.m,
              Spacing.m,
              Spacing.m,
              Spacing.s,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: titleController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: l10n.chapterTitle,
                        hintText: l10n.enterChapterTitle,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.m,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Radii.m),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.s),
                AppButtons.primary(
                  onPressed: isSaving ? () {} : onSave,
                  icon: Icons.save,
                  label: l10n.save,
                  isLoading: isSaving,
                  enabled: !isSaving,
                ),
              ],
            ),
          ),
        if (!zenMode)
          RichTextToolbar(
            preview: preview,
            controller: contentController,
            onTogglePreview: onTogglePreview,
            onBold: () => MarkdownEditActions.toggleBold(contentController),
            onItalic: () => MarkdownEditActions.toggleItalic(contentController),
            onUnderline: () =>
                MarkdownEditActions.toggleUnderline(contentController),
            onHeading: () =>
                MarkdownEditActions.insertHeading(contentController),
            onQuote: () => MarkdownEditActions.insertQuote(contentController),
            onCode: () =>
                MarkdownEditActions.toggleInlineCode(contentController),
            onBullet: () => MarkdownEditActions.insertBullet(contentController),
            onNumbered: () =>
                MarkdownEditActions.insertNumbered(contentController),
            onLink: () => MarkdownEditActions.insertLink(contentController),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.zero,
            child: RichTextEditor(
              controller: contentController,
              preview: preview,
              hintText: l10n.startWriting,
              semanticsLabel: l10n.chapterContent,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: WritingStats(
            controller: contentController,
            streakDays: streakDays,
            showCounts: false,
          ),
        ),
        if (isSaving)
          Container(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Semantics(
              container: true,
              liveRegion: true,
              label: l10n.saving,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: Spacing.s),
                    Text(l10n.saving, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        if (!isSaving) SizedBox(height: keyboardHeight),
      ],
    );
  }
}
