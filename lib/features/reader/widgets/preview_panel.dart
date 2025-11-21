import 'package:flutter/material.dart';

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
    final pairs = _pairLines(originalContent, draftContent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(draftTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(originalTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...List.generate(pairs.length, (idx) {
          final p = pairs[idx];
          final draftSpans = _buildWordSpans(
            p.draftWords,
            p.draftChanged,
            Theme.of(context).textTheme.bodyLarge!,
            cs.primaryContainer,
            cs.onPrimaryContainer,
          );
          final origSpans = _buildWordSpans(
            p.origWords,
            p.origChanged,
            Theme.of(context).textTheme.bodyLarge!,
            cs.errorContainer,
            cs.onErrorContainer,
          );
          if (!p.anyChanged) {
            final baseStyle = Theme.of(context).textTheme.bodyLarge!;
            final spans = _buildWordSpans(
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

class _LinePair {
  _LinePair(
    this.origWords,
    this.draftWords,
    this.origChanged,
    this.draftChanged,
    this.anyChanged,
  );
  final List<String> origWords;
  final List<String> draftWords;
  final List<bool> origChanged;
  final List<bool> draftChanged;
  final bool anyChanged;
}

List<_LinePair> _pairLines(String orig, String draft) {
  final oLines = orig.replaceAll('\r\n', '\n').split('\n');
  final dLines = draft.replaceAll('\r\n', '\n').split('\n');
  final pairs = <_LinePair>[];
  int i = 0, j = 0;
  while (i < oLines.length || j < dLines.length) {
    final o = i < oLines.length ? oLines[i] : null;
    final d = j < dLines.length ? dLines[j] : null;
    if (o != null && d != null && o == d) {
      final words = _splitWords(o);
      final changed = List<bool>.filled(words.length, false);
      pairs.add(_LinePair(words, words, changed, changed, false));
      i++;
      j++;
      continue;
    }
    if (o != null && d != null) {
      final oW = _splitWords(o);
      final dW = _splitWords(d);
      final res = _wordDiffFlags(oW, dW);
      final any = res.item1.any((e) => e) || res.item2.any((e) => e);
      pairs.add(_LinePair(oW, dW, res.item1, res.item2, any));
      i++;
      j++;
      continue;
    }
    if (o != null) {
      final oW = _splitWords(o);
      final oFlags = List<bool>.filled(oW.length, true);
      pairs.add(_LinePair(oW, const [], oFlags, const [], true));
      i++;
      continue;
    }
    if (d != null) {
      final dW = _splitWords(d);
      final dFlags = List<bool>.filled(dW.length, true);
      pairs.add(_LinePair(const [], dW, const [], dFlags, true));
      j++;
      continue;
    }
  }
  return pairs;
}

List<String> _splitWords(String s) {
  final parts = s.split(RegExp(r"(\s+)"));
  return parts.where((e) => e.isNotEmpty).toList();
}

class _Tuple2<A, B> {
  _Tuple2(this.item1, this.item2);
  final A item1;
  final B item2;
}

_Tuple2<List<bool>, List<bool>> _wordDiffFlags(List<String> a, List<String> b) {
  final m = a.length;
  final n = b.length;
  final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
  for (var i = m - 1; i >= 0; i--) {
    for (var j = n - 1; j >= 0; j--) {
      if (a[i] == b[j]) {
        dp[i][j] = dp[i + 1][j + 1] + 1;
      } else {
        dp[i][j] = dp[i + 1][j].max(dp[i][j + 1]);
      }
    }
  }
  var i = 0, j = 0;
  final aChanged = List<bool>.filled(m, false);
  final bChanged = List<bool>.filled(n, false);
  while (i < m && j < n) {
    if (a[i] == b[j]) {
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      aChanged[i] = true;
      i++;
    } else {
      bChanged[j] = true;
      j++;
    }
  }
  while (i < m) {
    aChanged[i] = true;
    i++;
  }
  while (j < n) {
    bChanged[j] = true;
    j++;
  }
  return _Tuple2(aChanged, bChanged);
}

extension on int {
  int max(int other) => this > other ? this : other;
}

List<TextSpan> _buildWordSpans(
  List<String> words,
  List<bool> changed,
  TextStyle base,
  Color bg,
  Color fg,
) {
  final spans = <TextSpan>[];
  for (var k = 0; k < words.length; k++) {
    final w = words[k];
    final ch = changed.isNotEmpty && k < changed.length && changed[k];
    if (ch) {
      spans.add(
        TextSpan(
          text: w,
          style: base.copyWith(backgroundColor: bg, color: fg),
        ),
      );
    } else {
      spans.add(TextSpan(text: w, style: base));
    }
    if (k != words.length - 1) {
      spans.add(TextSpan(text: ' ', style: base));
    }
  }
  if (spans.isEmpty) {
    spans.add(TextSpan(text: '', style: base));
  }
  return spans;
}
