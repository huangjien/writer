class TtsChunk {
  const TtsChunk({required this.text, required this.start});

  final String text;

  /// Start offset in the original full content string.
  final int start;
}

/// Utility to split long text into TTS-friendly chunks.
///
/// IMPORTANT:
/// - This returns chunks with offsets that map back to the original content.
/// - Offsets are used to keep reader highlighting in sync with TTS progress.
List<TtsChunk> chunkTextWithOffsets(
  String text, {
  int baseOffset = 0,
  int maxLen = 1200,
}) {
  if (text.isEmpty) return const [];

  final chunks = <TtsChunk>[];
  final sep = RegExp(r'(?:\r?\n\s*\r?\n)+');

  void addChunk(String s, int absStart) {
    final trimmedRight = s.trimRight();
    if (trimmedRight.isEmpty) return;
    chunks.add(TtsChunk(text: trimmedRight, start: absStart));
  }

  void addParagraph(int start, int end) {
    if (end <= start) return;
    final raw = text.substring(start, end);
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;

    final leadTrim = raw.indexOf(trimmed);
    final trimmedStart = start + leadTrim;

    if (trimmed.length <= maxLen) {
      addChunk(trimmed, baseOffset + trimmedStart);
      return;
    }

    final boundary = RegExp(r'(?<=[\.\!\?\u3002\uff01\uff1f])\s+');
    final breaks = <int>[0];
    for (final m in boundary.allMatches(trimmed)) {
      breaks.add(m.start);
    }
    if (breaks.last != trimmed.length) breaks.add(trimmed.length);

    int skipWs(int i) {
      var idx = i;
      while (idx < trimmed.length) {
        final c = trimmed.substring(idx, idx + 1);
        if (c.trim().isNotEmpty) break;
        idx += 1;
      }
      return idx;
    }

    var chunkStart = skipWs(0);
    var lastGoodEnd = 0;
    for (var i = 1; i < breaks.length; i++) {
      final endPos = breaks[i];
      final candidateLen = endPos - chunkStart;
      if (candidateLen <= maxLen) {
        lastGoodEnd = endPos;
        continue;
      }

      if (lastGoodEnd > chunkStart) {
        final part = trimmed.substring(chunkStart, lastGoodEnd);
        final leftTrim =
            part.length - part.replaceFirst(RegExp(r'^\s+'), '').length;
        addChunk(
          part.substring(leftTrim),
          baseOffset + trimmedStart + chunkStart + leftTrim,
        );
        chunkStart = skipWs(lastGoodEnd);
        lastGoodEnd = chunkStart;
        continue;
      }

      final hardEnd = (chunkStart + maxLen).clamp(0, trimmed.length);
      final part = trimmed.substring(chunkStart, hardEnd);
      final leftTrim =
          part.length - part.replaceFirst(RegExp(r'^\s+'), '').length;
      addChunk(
        part.substring(leftTrim),
        baseOffset + trimmedStart + chunkStart + leftTrim,
      );
      chunkStart = skipWs(hardEnd);
      lastGoodEnd = chunkStart;
    }

    if (chunkStart < trimmed.length) {
      final part = trimmed.substring(chunkStart);
      final leftTrim =
          part.length - part.replaceFirst(RegExp(r'^\s+'), '').length;
      addChunk(
        part.substring(leftTrim),
        baseOffset + trimmedStart + chunkStart + leftTrim,
      );
    }
  }

  var cursor = 0;
  for (final m in sep.allMatches(text)) {
    addParagraph(cursor, m.start);
    cursor = m.end;
  }
  addParagraph(cursor, text.length);

  return chunks;
}
