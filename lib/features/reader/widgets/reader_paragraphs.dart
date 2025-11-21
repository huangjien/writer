import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';

class ReaderParagraphs {
  static List<Widget> build(
    String text,
    int ttsIndex,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (text.isEmpty) {
      return [Text('', style: textTheme.bodyLarge)];
    }
    final paragraphs = <_Paragraph>[];
    int start = 0;
    final parts = text.split(RegExp(r"\n\n+"));
    for (final part in parts) {
      final end = start + part.length;
      paragraphs.add(_Paragraph(rangeStart: start, rangeEnd: end, text: part));
      final delimMatch = RegExp(r"\n\n+").matchAsPrefix(text, end);
      final delimLen = delimMatch?.group(0)?.length ?? 0;
      start = end + delimLen;
    }
    final baseStyle = textTheme.bodyLarge;
    final widgets = <Widget>[];
    for (var i = 0; i < paragraphs.length; i++) {
      final p = paragraphs[i];
      final isActive = ttsIndex >= p.rangeStart && ttsIndex < p.rangeEnd;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            key: isActive
                ? const ValueKey('current_paragraph')
                : ValueKey('paragraph_$i'),
            decoration: isActive
                ? BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(Radii.s),
                  )
                : null,
            padding: isActive ? const EdgeInsets.all(8) : EdgeInsets.zero,
            child: Text(p.text, style: baseStyle),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _Paragraph {
  final int rangeStart;
  final int rangeEnd;
  final String text;
  const _Paragraph({
    required this.rangeStart,
    required this.rangeEnd,
    required this.text,
  });
}
