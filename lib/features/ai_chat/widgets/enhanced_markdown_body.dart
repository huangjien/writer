import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:highlight/highlight.dart' show highlight, Node, Result;
import 'package:url_launcher/url_launcher.dart';

class EnhancedMarkdownBody extends StatelessWidget {
  const EnhancedMarkdownBody({
    super.key,
    required this.data,
    this.selectable = true,
    this.onTapLink,
  });

  final String data;
  final bool selectable;
  final void Function(String href)? onTapLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final base = MarkdownStyleSheet.fromTheme(theme);

    final sheet = base.copyWith(
      p: base.p?.copyWith(color: theme.colorScheme.onSurface, height: 1.5),
      h1: base.h1?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      h2: base.h2?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      h3: base.h3?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h4: base.h4?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h5: base.h5?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h6: base.h6?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 4),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      blockquote: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
      ),
      listBullet: TextStyle(color: theme.colorScheme.primary),
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      tableHead: const TextStyle(fontWeight: FontWeight.bold),
      tableBody: null,
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outlineVariant,
        width: 1,
      ),
      tableHeadAlign: TextAlign.center,
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      tableColumnWidth: const IntrinsicColumnWidth(),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
    );

    final body = MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: sheet,
      builders: {'code': CodeBlockBuilder(isDark: isDark, theme: theme)},
      onTapLink: (text, href, title) {
        if (href != null) {
          if (onTapLink != null) {
            onTapLink!(href);
          } else {
            _launchUrl(href);
          }
        }
      },
      checkboxBuilder: (checked) => _buildCheckbox(checked, theme),
    );

    return body;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildCheckbox(bool checked, ThemeData theme) {
    return Icon(
      checked ? Icons.check_box : Icons.check_box_outline_blank,
      size: 18,
      color: checked
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;
  final ThemeData theme;

  CodeBlockBuilder({required this.isDark, required this.theme});

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final code = element.textContent;
    String? language;

    if (element.attributes['class'] != null) {
      final langClass = element.attributes['class']!;
      if (langClass.startsWith('language-')) {
        language = langClass.substring(9);
      }
    }

    Result? highlightResult;
    if (language != null && language.isNotEmpty) {
      try {
        highlightResult = highlight.parse(code, language: language);
      } catch (_) {
        highlightResult = null;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null && language.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFE8E8E8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _copyToClipboard(code);
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: highlightResult != null
                ? _buildHighlightedCode(highlightResult.nodes ?? [])
                : SelectableText(
                    code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedCode(List<Node> nodes) {
    return SelectableText.rich(
      TextSpan(
        children: nodes.map(_convertNode).toList(),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  TextSpan _convertNode(Node node) {
    final cssClass = node.className;
    Color textColor = isDark ? Colors.white : Colors.black87;

    if (cssClass != null) {
      textColor = _getColorForClass(cssClass);
    }

    final children = node.children ?? [];
    final text = node.value ?? '';

    if (children.isEmpty && text.isNotEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(color: textColor),
      );
    }

    return TextSpan(
      children: children.map(_convertNode).toList(),
      style: TextStyle(color: textColor),
    );
  }

  Color _getColorForClass(String className) {
    final darkThemeColors = {
      'hljs-keyword': const Color(0xFF569CD6),
      'hljs-built_in': const Color(0xFF4EC9B0),
      'hljs-type': const Color(0xFF4EC9B0),
      'hljs-literal': const Color(0xFF569CD6),
      'hljs-number': const Color(0xFFB5CEA8),
      'hljs-string': const Color(0xFFCE9178),
      'hljs-meta': const Color(0xFF9B9B9B),
      'hljs-title': const Color(0xFFDCDCAA),
      'hljs-function': const Color(0xFFDCDCAA),
      'hljs-variable': const Color(0xFF9CDCFE),
      'hljs-attr': const Color(0xFF9CDCFE),
      'hljs-attribute': const Color(0xFF9CDCFE),
      'hljs-selector-tag': const Color(0xFFD7BA7D),
      'hljs-selector-class': const Color(0xFFD7BA7D),
      'hljs-selector-id': const Color(0xFFD7BA7D),
      'hljs-selector-attr': const Color(0xFF9CDCFE),
      'hljs-comment': const Color(0xFF6A9955),
      'hljs-quote': const Color(0xFF6A9955),
      'hljs-doctag': const Color(0xFF608B4E),
      'hljs-formula': const Color(0xFFC586C0),
      'hljs-section': const Color(0xFF569CD6),
      'hljs-bullet': const Color(0xFF569CD6),
      'hljs-emphasis': const Color(0xFF569CD6),
      'hljs-strong': const Color(0xFF569CD6),
      'hljs-addition': const Color(0xFF4EC9B0),
      'hljs-deletion': const Color(0xFFCE9178),
      'hljs-symbol': const Color(0xFF4EC9B0),
      'hljs-link': const Color(0xFF4EC9B0),
      'hljs-name': const Color(0xFF569CD6),
      'hljs-regexp': const Color(0xFFD16969),
      'hljs-template-variable': const Color(0xFFD16969),
      'hljs-template-tag': const Color(0xFFD16969),
      'hljssubst': const Color(0xFF9CDCFE),
      'hljs-class': const Color(0xFF4EC9B0),
      'hljs-selector-pseudo': const Color(0xFFDCDCAA),
      'hljs-selector-combinator': const Color(0xFFDCDCAA),
      'hljs-params': const Color(0xFF9CDCFE),
      'hljs-property': const Color(0xFF9CDCFE),
      'hljs-operator': const Color(0xFFD4D4D4),
      'hljs-punctuation': const Color(0xFFD4D4D4),
    };

    final lightThemeColors = {
      'hljs-keyword': const Color(0xFF0000FF),
      'hljs-built_in': const Color(0xFF267F99),
      'hljs-type': const Color(0xFF267F99),
      'hljs-literal': const Color(0xFF0000FF),
      'hljs-number': const Color(0xFF098658),
      'hljs-string': const Color(0xFFA31515),
      'hljs-meta': const Color(0xFF808000),
      'hljs-title': const Color(0xFF795E26),
      'hljs-function': const Color(0xFF795E26),
      'hljs-variable': const Color(0xFF001080),
      'hljs-attr': const Color(0xFF001080),
      'hljs-attribute': const Color(0xFF001080),
      'hljs-selector-tag': const Color(0xFF800000),
      'hljs-selector-class': const Color(0xFF800000),
      'hljs-selector-id': const Color(0xFF800000),
      'hljs-selector-attr': const Color(0xFF800000),
      'hljs-comment': const Color(0xFF008000),
      'hljs-quote': const Color(0xFF008000),
      'hljs-doctag': const Color(0xFF008000),
      'hljs-formula': const Color(0xFF795E26),
      'hljs-section': const Color(0xFF0000FF),
      'hljs-bullet': const Color(0xFF0000FF),
      'hljs-emphasis': const Color(0xFF0000FF),
      'hljs-strong': const Color(0xFF0000FF),
      'hljs-addition': const Color(0xFF098658),
      'hljs-deletion': const Color(0xFFA31515),
      'hljs-symbol': const Color(0xFF267F99),
      'hljs-link': const Color(0xFF0000FF),
      'hljs-name': const Color(0xFF0000FF),
      'hljs-regexp': const Color(0xFFA31515),
      'hljs-template-variable': const Color(0xFF001080),
      'hljs-template-tag': const Color(0xFF001080),
      'hljssubst': const Color(0xFF001080),
      'hljs-class': const Color(0xFF267F99),
      'hljs-selector-pseudo': const Color(0xFF795E26),
      'hljs-selector-combinator': const Color(0xFF795E26),
      'hljs-params': const Color(0xFF001080),
      'hljs-property': const Color(0xFF001080),
      'hljs-operator': const Color(0xFF000000),
      'hljs-punctuation': const Color(0xFF000000),
    };

    final colors = isDark ? darkThemeColors : lightThemeColors;
    return colors[className] ?? (isDark ? Colors.white : Colors.black87);
  }

  void _copyToClipboard(String text) {
    // Copy functionality handled by SelectionArea
  }
}
