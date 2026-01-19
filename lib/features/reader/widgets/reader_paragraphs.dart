import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../theme/design_tokens.dart';

class ReaderParagraphs extends StatelessWidget {
  const ReaderParagraphs({
    super.key,
    required this.text,
    required this.ttsIndex,
    this.forceBold = false,
  });

  final String text;
  final int ttsIndex;
  final bool forceBold;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n\n+'));
    int currentStart = 0;
    final baseStyleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context));
    TextStyle? bold(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.bold);
    final styleSheet = forceBold
        ? baseStyleSheet.copyWith(
            p: bold(baseStyleSheet.p),
            a: bold(baseStyleSheet.a),
            blockquote: bold(baseStyleSheet.blockquote),
            code: bold(baseStyleSheet.code),
            h1: bold(baseStyleSheet.h1),
            h2: bold(baseStyleSheet.h2),
            h3: bold(baseStyleSheet.h3),
            h4: bold(baseStyleSheet.h4),
            h5: bold(baseStyleSheet.h5),
            h6: bold(baseStyleSheet.h6),
            listBullet: bold(baseStyleSheet.listBullet),
          )
        : null;

    return Column(
      key: const ValueKey('reader_paragraphs_column'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: paragraphs.map((p) {
        final len = p.length;
        // Determine if ttsIndex falls within this paragraph
        // We assume 2 chars for the split pattern for simple calculation,
        // or we could track actual indices if we didn't split.
        // For now, let's assume sequential.
        final end = currentStart + len;
        final isCurrent = ttsIndex >= currentStart && ttsIndex <= end;

        // Advance start for next paragraph (add 2 for newlines)
        // Note: RegExp split might consume more, but for simple cases +2 is close enough.
        // Ideally we should preserve delimiters to be exact.
        currentStart += len + 2;

        return Container(
          key: isCurrent ? const ValueKey('current_paragraph') : null,
          decoration: isCurrent
              ? BoxDecoration(
                  color: Theme.of(
                    context,
                  ).highlightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Radii.s),
                )
              : null,
          margin: const EdgeInsets.only(bottom: Spacing.l),
          child: MarkdownBody(data: p, styleSheet: styleSheet),
        );
      }).toList(),
    );
  }
}
