import 'package:flutter/material.dart';

class LineDiff {
  LineDiff(
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

List<LineDiff> pairLines(String orig, String draft) {
  final oLines = orig.replaceAll('\r\n', '\n').split('\n');
  final dLines = draft.replaceAll('\r\n', '\n').split('\n');
  final pairs = <LineDiff>[];
  int i = 0, j = 0;
  while (i < oLines.length || j < dLines.length) {
    final o = i < oLines.length ? oLines[i] : null;
    final d = j < dLines.length ? dLines[j] : null;
    if (o != null && d != null && o == d) {
      final words = splitWords(o);
      final changed = List<bool>.filled(words.length, false);
      pairs.add(LineDiff(words, words, changed, changed, false));
      i++;
      j++;
      continue;
    }
    if (o != null && d != null) {
      final oW = splitWords(o);
      final dW = splitWords(d);
      final res = wordDiffFlags(oW, dW);
      final any = res.item1.any((e) => e) || res.item2.any((e) => e);
      pairs.add(LineDiff(oW, dW, res.item1, res.item2, any));
      i++;
      j++;
      continue;
    }
    if (o != null) {
      final oW = splitWords(o);
      final oFlags = List<bool>.filled(oW.length, true);
      pairs.add(LineDiff(oW, const [], oFlags, const [], true));
      i++;
      continue;
    }
    if (d != null) {
      final dW = splitWords(d);
      final dFlags = List<bool>.filled(dW.length, true);
      pairs.add(LineDiff(const [], dW, const [], dFlags, true));
      j++;
      continue;
    }
  }
  return pairs;
}

List<String> splitWords(String s) {
  final parts = s.split(RegExp(r"(\s+)"));
  return parts.where((e) => e.isNotEmpty).toList();
}

class Tuple2<A, B> {
  Tuple2(this.item1, this.item2);
  final A item1;
  final B item2;
}

Tuple2<List<bool>, List<bool>> wordDiffFlags(List<String> a, List<String> b) {
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
  return Tuple2(aChanged, bChanged);
}

extension on int {
  int max(int other) => this > other ? this : other;
}

List<TextSpan> buildWordSpans(
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
