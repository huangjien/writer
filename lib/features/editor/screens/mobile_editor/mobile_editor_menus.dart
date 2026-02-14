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
        label: 'Writing prompts',
        icon: Icons.lightbulb_outline,
        value: 'writing_prompts',
        onPressed: onShowWritingPrompts,
      ),
      ActionSheetItem(
        label: 'Word Count',
        icon: Icons.format_size,
        value: 'wordcount',
        onPressed: onShowWordCount,
      ),
      ActionSheetItem(
        label: 'Character Count',
        icon: Icons.text_fields,
        value: 'charcount',
        onPressed: onShowCharacterCount,
      ),
      ActionSheetItem(
        label: 'Discard Changes',
        icon: Icons.delete_outline,
        value: 'discard',
        isDestructive: true,
        onPressed: onDiscardChanges,
      ),
      ActionSheetItem(
        label: 'Settings',
        icon: Icons.settings,
        value: 'settings',
        onPressed: onOpenSettings,
      ),
      ActionSheetItem(
        label: 'Keyboard shortcuts',
        icon: Icons.keyboard,
        value: 'shortcuts',
        onPressed: onShowShortcutsHelp,
      ),
    ],
  );
}

void showMobileEditorShortcutsHelp(BuildContext context) {
  MobileBottomSheet.show(
    context: context,
    title: 'Keyboard shortcuts',
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final items = <(String, String)>[
        (l10n.save, 'Ctrl/⌘ + S'),
        (l10n.previewLabel, 'Ctrl/⌘ + P'),
        ('Bold', 'Ctrl/⌘ + B'),
        ('Italic', 'Ctrl/⌘ + I'),
        ('Underline', 'Ctrl/⌘ + U'),
        ('Heading', 'Ctrl/⌘ + 1'),
        ('Insert link', 'Ctrl/⌘ + K'),
        ('Shortcuts help', 'Ctrl/⌘ + /'),
        ('Close', 'Esc'),
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
