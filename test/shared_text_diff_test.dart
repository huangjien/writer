import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/text_diff.dart';

void main() {
  group('splitWords', () {
    test('splits on all whitespace and removes empties', () {
      final words = splitWords('a  b\tc   d');
      expect(words, ['a', 'b', 'c', 'd']);
    });
  });

  group('wordDiffFlags', () {
    test('marks substitutions on both sides', () {
      final a = ['hello', 'world'];
      final b = ['hello', 'there'];
      final res = wordDiffFlags(a, b);
      expect(res.item1, [false, true]);
      expect(res.item2, [false, true]);
    });

    test('marks deletions and insertions', () {
      final a = ['one', 'two', 'three'];
      final b = ['one', 'three', 'four'];
      final res = wordDiffFlags(a, b);
      expect(res.item1, [false, true, false]);
      expect(res.item2, [false, false, true]);
    });
  });

  group('pairLines', () {
    test('identical single line has no changes', () {
      final pairs = pairLines('one two', 'one two');
      expect(pairs.length, 1);
      final p = pairs.first;
      expect(p.anyChanged, false);
      expect(p.origWords, ['one', 'two']);
      expect(p.draftWords, ['one', 'two']);
      expect(p.origChanged, [false, false]);
      expect(p.draftChanged, [false, false]);
    });

    test('modified words on same line are flagged', () {
      final pairs = pairLines('a b', 'a c');
      expect(pairs.length, 1);
      final p = pairs.first;
      expect(p.anyChanged, true);
      expect(p.origWords, ['a', 'b']);
      expect(p.draftWords, ['a', 'c']);
      expect(p.origChanged, [false, true]);
      expect(p.draftChanged, [false, true]);
    });

    test('added line appears with draft flags true', () {
      final pairs = pairLines('line1\nline2', 'line1\nline2\nline3');
      expect(pairs.length, 3);
      final added = pairs[2];
      expect(added.anyChanged, true);
      expect(added.origWords, <String>[]);
      expect(added.draftWords, ['line3']);
      expect(added.origChanged, <bool>[]);
      expect(added.draftChanged, [true]);
    });

    test('removed line appears with orig flags true', () {
      final pairs = pairLines('line1\nline2\nline3', 'line1\nline2');
      expect(pairs.length, 3);
      final removed = pairs[2];
      expect(removed.anyChanged, true);
      expect(removed.origWords, ['line3']);
      expect(removed.draftWords, <String>[]);
      expect(removed.origChanged, [true]);
      expect(removed.draftChanged, <bool>[]);
    });
  });

  group('buildWordSpans', () {
    test('applies styles to changed words and inserts spaces', () {
      const base = TextStyle(fontSize: 12, color: Colors.black);
      const bg = Colors.yellow;
      const fg = Colors.red;
      final spans = buildWordSpans(['a', 'b'], [false, true], base, bg, fg);
      expect(spans.length, 3);
      expect(spans[0].toPlainText(), 'a');
      expect(spans[0].style, base);
      expect(spans[1].toPlainText(), ' ');
      expect(spans[1].style, base);
      expect(spans[2].toPlainText(), 'b');
      expect(spans[2].style?.backgroundColor, bg);
      expect(spans[2].style?.color, fg);
    });

    test('returns a single empty span when no words', () {
      const base = TextStyle(fontSize: 12, color: Colors.black);
      final spans = buildWordSpans(
        const [],
        const [],
        base,
        Colors.yellow,
        Colors.red,
      );
      expect(spans.length, 1);
      expect(spans[0].toPlainText(), '');
      expect(spans[0].style, base);
    });
  });
}
