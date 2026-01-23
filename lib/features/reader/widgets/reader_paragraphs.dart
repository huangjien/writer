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
    this.reduceMotion = false,
  });

  final String text;
  final int ttsIndex;
  final bool forceBold;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final paragraphMatches = <_ParagraphMatch>[];
    final sep = RegExp(r'\n\n+');
    var cursor = 0;
    for (final m in sep.allMatches(text)) {
      final start = cursor;
      final end = m.start;
      if (end > start) {
        paragraphMatches.add(
          _ParagraphMatch(text.substring(start, end), start, end),
        );
      }
      cursor = m.end;
    }
    if (cursor < text.length) {
      paragraphMatches.add(
        _ParagraphMatch(text.substring(cursor), cursor, text.length),
      );
    }
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

        final theme = Theme.of(context);
        final highlight = theme.highlightColor.withValues(alpha: 0.2);
        return AnimatedContainer(
          key: isCurrent ? const ValueKey('current_paragraph') : null,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isCurrent ? highlight : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.s),
          ),
          margin: const EdgeInsets.only(bottom: Spacing.l),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.s,
            vertical: Spacing.xs,
          ),
          child: MarkdownBody(data: match.group(0), styleSheet: styleSheet),
        );
      }).toList(),
    );
  }
}
