import 'package:flutter/material.dart';
import 'package:writer/shared/text_diff.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.draftTitle,
    required this.draftContent,
    required this.originalTitle,
    required this.originalContent,
  });
  final String draftTitle;
  final String draftContent;
  final String originalTitle;
  final String originalContent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pairs = pairLines(originalContent, draftContent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(draftTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(originalTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(pairs.length, (idx) {
          final p = pairs[idx];
          final draftSpans = buildWordSpans(
            p.draftWords,
            p.draftChanged,
            Theme.of(context).textTheme.bodyLarge!,
            cs.primaryContainer,
            cs.onPrimaryContainer,
          );
          final origSpans = buildWordSpans(
            p.origWords,
            p.origChanged,
            Theme.of(context).textTheme.bodyLarge!,
            cs.errorContainer,
            cs.onErrorContainer,
          );
          if (!p.anyChanged) {
            final baseStyle = Theme.of(context).textTheme.bodyLarge!;
            final spans = buildWordSpans(
              p.draftWords,
              List<bool>.filled(p.draftWords.length, false),
              baseStyle,
              Colors.transparent,
              baseStyle.color ?? cs.onSurface,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                key: ValueKey('unchanged_cell_$idx'),
                text: TextSpan(children: spans),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              key: ValueKey('preview_row_$idx'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  key: ValueKey('draft_cell_$idx'),
                  text: TextSpan(children: draftSpans),
                ),
                const SizedBox(height: 4),
                RichText(
                  key: ValueKey('orig_cell_$idx'),
                  text: TextSpan(children: origSpans),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
