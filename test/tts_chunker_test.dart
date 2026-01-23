import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/reader/tts_chunker.dart';

void main() {
  group('chunkTextWithOffsets', () {
    test('returns empty list for empty or whitespace', () {
      expect(chunkTextWithOffsets(''), isEmpty);
      expect(chunkTextWithOffsets('   '), isEmpty);
    });

    test('splits on sentence boundaries and respects maxLen', () {
      const text =
          'Hello world. New line? Third sentence!\nFourth line continues. This is a very long segment intended to exceed the max length and force splitting across chunks.';
      final chunks = chunkTextWithOffsets(text, maxLen: 30);

      expect(chunks.length, greaterThan(1));
      // First chunk should be within the cap
      expect(chunks.first.text.length, lessThanOrEqualTo(30));
      // First chunk should include early sentences but stay within cap
      expect(chunks.first.text.startsWith('Hello world.'), isTrue);
      expect(chunks.first.text.contains('New line?'), isTrue);
      // Ensure boundaries respected (no empty chunks)
      expect(chunks.any((c) => c.text.trim().isEmpty), isFalse);
    });

    test('handles very long single sentence exceeding maxLen', () {
      final long = 'A' * 80; // single sentence without punctuation
      final chunks = chunkTextWithOffsets(long, maxLen: 30);
      expect(chunks.length, greaterThan(1));
      expect(chunks.fold<int>(0, (sum, c) => sum + c.text.length), long.length);
    });

    test('splits across punctuation: ! ? . and newlines', () {
      const text = 'Hello! How are you? I am fine.\nNew line continues.';
      final chunks = chunkTextWithOffsets(text, maxLen: 40);
      expect(chunks.isNotEmpty, isTrue);
      // Verify that recognized sentences appear intact
      final joined = chunks.map((c) => c.text).join(' ');
      expect(joined.contains('Hello!'), isTrue);
      expect(joined.contains('How are you?'), isTrue);
      expect(joined.contains('I am fine.'), isTrue);
    });
  });
}
