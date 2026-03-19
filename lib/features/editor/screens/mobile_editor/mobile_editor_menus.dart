import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';
import 'package:writer/theme/design_tokens.dart';

void showMobileEditorMoreMenu({
  required BuildContext context,
  required VoidCallback onEnterZenMode,
  required VoidCallback onShowFocusTimer,
  required VoidCallback onShowWritingPrompts,
  required VoidCallback onShowWordCount,
  required VoidCallback onShowCharacterCount,
  required VoidCallback onDiscardChanges,
  required VoidCallback onOpenSettings,
  required VoidCallback onShowShortcutsHelp,
}) {
  final l10n = AppLocalizations.of(context)!;
  MobileBottomSheet.showActionSheet(
    context: context,
    items: [
      ActionSheetItem(
        label: 'Zen mode',
        icon: Icons.center_focus_strong,
        value: 'zen',
        onPressed: onEnterZenMode,
      ),
      ActionSheetItem(
        label: 'Focus timer',
        icon: Icons.timer,
        value: 'focus_timer',
        onPressed: onShowFocusTimer,
      ),
      ActionSheetItem(
        label: l10n.prompts,
        icon: Icons.lightbulb_outline,
        value: 'writing_prompts',
        onPressed: onShowWritingPrompts,
      ),
      ActionSheetItem(
        label: l10n.wordCountLabel,
        icon: Icons.format_size,
        value: 'wordcount',
        onPressed: onShowWordCount,
      ),
      ActionSheetItem(
        label: l10n.characterCountLabel,
        icon: Icons.text_fields,
        value: 'charcount',
        onPressed: onShowCharacterCount,
      ),
      ActionSheetItem(
        label: l10n.discardChanges,
        icon: Icons.delete_outline,
        value: 'discard',
        isDestructive: true,
        onPressed: onDiscardChanges,
      ),
      ActionSheetItem(
        label: l10n.settings,
        icon: Icons.settings,
        value: 'settings',
        onPressed: onOpenSettings,
      ),
      ActionSheetItem(
        label: l10n.keyboardShortcuts,
        icon: Icons.keyboard,
        value: 'shortcuts',
        onPressed: onShowShortcutsHelp,
      ),
    ],
  );
}

void showMobileEditorShortcutsHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  MobileBottomSheet.show(
    context: context,
    title: l10n.keyboardShortcuts,
    builder: (context) {
      final items = <(String, String)>[
        (l10n.save, 'Ctrl/⌘ + S'),
        (l10n.previewLabel, 'Ctrl/⌘ + P'),
        (l10n.boldShortcut, 'Ctrl/⌘ + B'),
        (l10n.italicShortcut, 'Ctrl/⌘ + I'),
        (l10n.underlineShortcut, 'Ctrl/⌘ + U'),
        (l10n.headingShortcut, 'Ctrl/⌘ + 1'),
        (l10n.insertLinkShortcut, 'Ctrl/⌘ + K'),
        (l10n.shortcutsHelpShortcut, 'Ctrl/⌘ + /'),
        (l10n.closeShortcut, 'Esc'),
      ];
      return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Spacing.l),
        itemBuilder: (context, i) {
          final it = items[i];
          return Row(
            children: [
              Expanded(
                child: Text(
                  it.$1,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                it.$2,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
        separatorBuilder: (context, _) => const SizedBox(height: Spacing.m),
        itemCount: items.length,
      );
    },
  );
}
