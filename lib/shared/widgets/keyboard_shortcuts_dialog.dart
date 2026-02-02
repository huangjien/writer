import 'package:flutter/material.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/keyboard_shortcuts.dart';
import 'package:writer/shared/widgets/mobile_bottom_sheet.dart';
import 'package:writer/theme/design_tokens.dart';

/// Show keyboard shortcuts dialog as a modal (for desktop)
void showKeyboardShortcutsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _KeyboardShortcutsDialogContent(),
  );
}

/// Show keyboard shortcuts as a bottom sheet (for mobile)
void showKeyboardShortcutsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  MobileBottomSheet.show<void>(
    context: context,
    title: l10n.keyboardShortcuts,
    builder: (context) => const _KeyboardShortcutsSheetContent(),
  );
}

/// Helper to append shortcut to tooltip text
String appendShortcutToTooltip(String tooltip, String shortcut) {
  return '$tooltip ($shortcut)';
}

/// Widget to display a shortcut key in a formatted box
class ShortcutKey extends StatelessWidget {
  const ShortcutKey(this.keyLabel, {super.key});

  final String keyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        keyLabel,
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Widget to display a combination of shortcut keys
class ShortcutKeys extends StatelessWidget {
  const ShortcutKeys({super.key, required this.keys});

  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          ShortcutKey(keys[i]),
          if (i < keys.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '+',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Desktop dialog content for keyboard shortcuts
class _KeyboardShortcutsDialogContent extends StatelessWidget {
  const _KeyboardShortcutsDialogContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return AlertDialog(
      title: Text(l10n.keyboardShortcuts),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutGroup(context, l10n.navigation, textStyle, [
                _ShortcutItem(l10n.home, getShortcutLabel('H')),
                _ShortcutItem(l10n.settings, getShortcutLabel(',')),
                _ShortcutItem(l10n.back, getShortcutLabel('[')),
              ]),
              _buildShortcutGroup(context, l10n.actions, textStyle, [
                _ShortcutItem(l10n.save, getShortcutLabel('S')),
                _ShortcutItem(l10n.newLabel, getShortcutLabel('N')),
                _ShortcutItem(l10n.searchLabel, getShortcutLabel('F')),
                _ShortcutItem(l10n.refreshTooltip, getShortcutLabel('R')),
                _ShortcutItem(l10n.close, '$modifierKeyLabel+W'),
              ]),
              _buildShortcutGroup(context, l10n.editMode, textStyle, [
                _ShortcutItem(l10n.boldShortcut, getShortcutLabel('B')),
                _ShortcutItem(l10n.italicShortcut, getShortcutLabel('I')),
                _ShortcutItem(l10n.underlineShortcut, getShortcutLabel('U')),
                _ShortcutItem(l10n.insertLinkShortcut, getShortcutLabel('K')),
              ]),
              _buildShortcutGroup(context, l10n.readLabel, textStyle, [
                _ShortcutItem(l10n.pause, 'Space'),
                _ShortcutItem(l10n.nextChapter, getShortcutLabel('→')),
                _ShortcutItem(l10n.previousChapter, getShortcutLabel('←')),
                const _ShortcutItem('Fullscreen', 'F1'),
              ]),
              _buildShortcutGroup(context, l10n.settings, textStyle, [
                _ShortcutItem('App Settings', getShortcutLabel('1')),
                _ShortcutItem('Color Theme', getShortcutLabel('2')),
                _ShortcutItem('Typography', getShortcutLabel('3')),
                _ShortcutItem('Performance', getShortcutLabel('4')),
                _ShortcutItem('TTS Settings', getShortcutLabel('5')),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildShortcutGroup(
    BuildContext context,
    String title,
    TextStyle? textStyle,
    List<_ShortcutItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.s),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: textStyle),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.shortcut,
                    style: textStyle?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Mobile bottom sheet content for keyboard shortcuts
class _KeyboardShortcutsSheetContent extends StatelessWidget {
  const _KeyboardShortcutsSheetContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShortcutGroup(context, l10n.navigation, textStyle, [
              _ShortcutItem(l10n.home, getShortcutLabel('H')),
              _ShortcutItem(l10n.settings, getShortcutLabel(',')),
              _ShortcutItem(l10n.back, getShortcutLabel('[')),
            ]),
            const Divider(height: 32),
            _buildShortcutGroup(context, l10n.actions, textStyle, [
              _ShortcutItem(l10n.save, getShortcutLabel('S')),
              _ShortcutItem(l10n.newLabel, getShortcutLabel('N')),
              _ShortcutItem(l10n.searchLabel, getShortcutLabel('F')),
              _ShortcutItem(l10n.refreshTooltip, getShortcutLabel('R')),
              _ShortcutItem(l10n.close, '$modifierKeyLabel+W'),
            ]),
            const Divider(height: 32),
            _buildShortcutGroup(context, l10n.editMode, textStyle, [
              _ShortcutItem(l10n.boldShortcut, getShortcutLabel('B')),
              _ShortcutItem(l10n.italicShortcut, getShortcutLabel('I')),
              _ShortcutItem(l10n.underlineShortcut, getShortcutLabel('U')),
              _ShortcutItem(l10n.insertLinkShortcut, getShortcutLabel('K')),
              _ShortcutItem(l10n.headingShortcut, getShortcutLabel('1')),
            ]),
            const Divider(height: 32),
            _buildShortcutGroup(context, l10n.readLabel, textStyle, [
              _ShortcutItem(l10n.pause, 'Space'),
              _ShortcutItem(l10n.nextChapter, getShortcutLabel('→')),
              _ShortcutItem(l10n.previousChapter, getShortcutLabel('←')),
              _ShortcutItem(l10n.ttsSpeechRate, getShortcutLabel('R')),
              _ShortcutItem(l10n.ttsVoice, getShortcutLabel('V')),
              const _ShortcutItem('Fullscreen', 'F1'),
            ]),
            const Divider(height: 32),
            _buildShortcutGroup(context, l10n.settings, textStyle, [
              _ShortcutItem('App Settings', getShortcutLabel('1')),
              _ShortcutItem('Color Theme', getShortcutLabel('2')),
              _ShortcutItem('Typography', getShortcutLabel('3')),
              _ShortcutItem('Performance', getShortcutLabel('4')),
              _ShortcutItem('TTS Settings', getShortcutLabel('5')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutGroup(
    BuildContext context,
    String title,
    TextStyle? textStyle,
    List<_ShortcutItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.m),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.label, style: textStyle)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.shortcut,
                    style: textStyle?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutItem {
  final String label;
  final String shortcut;

  const _ShortcutItem(this.label, this.shortcut);
}
