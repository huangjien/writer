import 'package:flutter/material.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/shared/strings.dart';
import 'app_buttons.dart';

class RichTextToolbar extends StatelessWidget {
  const RichTextToolbar({
    super.key,
    required this.preview,
    required this.controller,
    required this.onTogglePreview,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onHeading,
    required this.onQuote,
    required this.onCode,
    required this.onBullet,
    required this.onNumbered,
    required this.onLink,
  });

  final bool preview;
  final TextEditingController controller;
  final VoidCallback onTogglePreview;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onCode;
  final VoidCallback onBullet;
  final VoidCallback onNumbered;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolButton(
                    icon: preview ? Icons.edit : Icons.visibility,
                    tooltip: preview ? 'Edit mode' : 'Preview mode',
                    semanticsLabel: preview ? 'Edit mode' : 'Preview mode',
                    isActive: preview,
                    onPressed: onTogglePreview,
                  ),
                  const SizedBox(width: Spacing.s),
                  _ToolButton(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    semanticsLabel: 'Bold',
                    isActive: false,
                    onPressed: onBold,
                  ),
                  _ToolButton(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    semanticsLabel: 'Italic',
                    isActive: false,
                    onPressed: onItalic,
                  ),
                  _ToolButton(
                    icon: Icons.format_underlined,
                    tooltip: 'Underline',
                    semanticsLabel: 'Underline',
                    isActive: false,
                    onPressed: onUnderline,
                  ),
                  const SizedBox(width: Spacing.s),
                  _ToolButton(
                    icon: Icons.title,
                    tooltip: 'Heading',
                    semanticsLabel: 'Heading',
                    isActive: false,
                    onPressed: onHeading,
                  ),
                  _ToolButton(
                    icon: Icons.format_quote,
                    tooltip: 'Quote',
                    semanticsLabel: 'Quote',
                    isActive: false,
                    onPressed: onQuote,
                  ),
                  _ToolButton(
                    icon: Icons.code,
                    tooltip: 'Inline code',
                    semanticsLabel: 'Inline code',
                    isActive: false,
                    onPressed: onCode,
                  ),
                  const SizedBox(width: Spacing.s),
                  _ToolButton(
                    icon: Icons.format_list_bulleted,
                    tooltip: 'Bulleted list',
                    semanticsLabel: 'Bulleted list',
                    isActive: false,
                    onPressed: onBullet,
                  ),
                  _ToolButton(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered list',
                    semanticsLabel: 'Numbered list',
                    isActive: false,
                    onPressed: onNumbered,
                  ),
                  const SizedBox(width: Spacing.s),
                  _ToolButton(
                    icon: Icons.link,
                    tooltip: 'Insert link',
                    semanticsLabel: 'Insert link',
                    isActive: false,
                    onPressed: onLink,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.s),
          _ToolbarStats(controller: controller),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.semanticsLabel,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final String semanticsLabel;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isActive) {
      return AppButtons.filledIcon(
        iconData: icon,
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: theme.colorScheme.primaryContainer,
        iconColor: theme.colorScheme.onPrimaryContainer,
      );
    }

    return AppButtons.icon(
      iconData: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

class _ToolbarStats extends StatelessWidget {
  const _ToolbarStats({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        final wordCount = countWords(text);
        final charCount = text.characters.length;
        final readingTimeLabel = _readingTimeLabel(wordCount);
        final label =
            '$wordCount words, $charCount characters, $readingTimeLabel read';

        return Semantics(
          container: true,
          label: label,
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: Text(
                '${wordCount}w • ${charCount}c • $readingTimeLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _readingTimeLabel(int words) {
    if (words <= 0) return '<1m';
    final minutes = (words / 200.0).ceil();
    return minutes <= 1 ? '<1m' : '${minutes}m';
  }
}
