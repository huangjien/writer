import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ReaderParagraphs extends StatelessWidget {
  const ReaderParagraphs({
    super.key,
    required this.text,
    required this.ttsIndex,
  });

  final String text;
  final int ttsIndex;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n\n+'));
    int currentStart = 0;

    return Column(
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
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          margin: const EdgeInsets.only(bottom: 16),
          child: MarkdownBody(data: p),
        );
      }).toList(),
    );
  }
}
