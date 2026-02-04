import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../theme/design_tokens.dart';

class RichTextEditor extends StatelessWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    required this.preview,
    this.hintText,
    this.semanticsLabel = 'Editor content',
  });

  final TextEditingController controller;
  final bool preview;
  final String? hintText;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (preview) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Radii.m),
          border: Border.all(color: theme.dividerColor),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.m),
          child: MarkdownBody(data: controller.text),
        ),
      );
    }

    return Semantics(
      textField: true,
      label: semanticsLabel,
      child: TextField(
        key: const Key('editor_content'),
        controller: controller,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}

class MarkdownEditActions {
  static void toggleBold(TextEditingController controller) {
    _wrapSelection(controller, prefix: '**', suffix: '**');
  }

  static void toggleItalic(TextEditingController controller) {
    _wrapSelection(controller, prefix: '*', suffix: '*');
  }

  static void toggleUnderline(TextEditingController controller) {
    _wrapSelection(controller, prefix: '<u>', suffix: '</u>');
  }

  static void toggleInlineCode(TextEditingController controller) {
    final selection = controller.selection;
    final text = controller.text;
    final selected = _selectedText(text, selection);
    if (selected.contains('\n')) {
      _wrapSelection(controller, prefix: '```\n', suffix: '\n```');
      return;
    }
    _wrapSelection(controller, prefix: '`', suffix: '`');
  }

  static void insertHeading(TextEditingController controller) {
    _prefixCurrentLine(controller, '# ');
  }

  static void insertQuote(TextEditingController controller) {
    _prefixCurrentLine(controller, '> ');
  }

  static void insertBullet(TextEditingController controller) {
    _prefixCurrentLine(controller, '- ');
  }

  static void insertNumbered(TextEditingController controller) {
    _prefixCurrentLine(controller, '1. ');
  }

  static void insertLink(TextEditingController controller) {
    final selection = controller.selection;
    final text = controller.text;
    final selected = _selectedText(text, selection);
    final label = selected.isNotEmpty ? selected : 'link text';
    final insertion = '[$label](https://)';
    _replaceSelection(controller, insertion);
    final start = selection.isValid ? selection.start : text.length;
    final urlStart = start + 1 + label.length + 2;
    controller.selection = TextSelection(
      baseOffset: urlStart,
      extentOffset: urlStart + 'https://'.length,
    );
  }

  static void _wrapSelection(
    TextEditingController controller, {
    required String prefix,
    required String suffix,
  }) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = (start <= end) ? text.substring(start, end) : '';

    if (selected.isEmpty) {
      final insertion = '$prefix$suffix';
      final newText = text.replaceRange(start, end, insertion);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + prefix.length),
      );
      return;
    }

    final insertion = '$prefix$selected$suffix';
    final newText = text.replaceRange(start, end, insertion);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + insertion.length,
      ),
    );
  }

  static void _prefixCurrentLine(
    TextEditingController controller,
    String prefix,
  ) {
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.isValid ? selection.start : text.length;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
  }

  static String _selectedText(String text, TextSelection selection) {
    if (!selection.isValid) return '';
    final start = selection.start;
    final end = selection.end;
    if (start < 0 || end < 0 || start > text.length || end > text.length) {
      return '';
    }
    if (start == end) return '';
    return text.substring(start, end);
  }

  static void _replaceSelection(
    TextEditingController controller,
    String insertion,
  ) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final newText = text.replaceRange(start, end, insertion);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }
}
