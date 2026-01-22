import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../theme/design_tokens.dart';

class _ParagraphMatch {
  _ParagraphMatch(this.text, this.start, this.end);

  final String text;
  final int start;
  final int end;

  String group(int? group) => text;
}

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
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final paragraphs = text.split(RegExp(r'\n\n+'));

    final paragraphMatches = paragraphs.map((p) {
      final start = text.indexOf(p);
      return _ParagraphMatch(p, start, start + p.length);
    }).toList();
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

    final textLength = text.length;
    final clampedIndex = ttsIndex.clamp(0, textLength);

    return Column(
      key: const ValueKey('reader_paragraphs_column'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: paragraphMatches.map((match) {
        final paragraphStart = match.start;
        final paragraphEnd = match.end;

        final isCurrent =
            ttsIndex >= 0 &&
            ttsIndex <= textLength &&
            ((clampedIndex >= paragraphStart && clampedIndex < paragraphEnd) ||
                (clampedIndex == textLength && paragraphEnd == textLength));

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
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: isCurrent ? 1.0 : 1.0,
            child: MarkdownBody(data: match.group(0), styleSheet: styleSheet),
          ),
        );
      }).toList(),
    );
  }
}
