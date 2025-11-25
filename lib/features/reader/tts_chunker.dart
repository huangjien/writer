/// Utility to split long text into TTS-friendly chunks.
/// Splits on sentence boundaries and respects `maxLen`.
List<String> chunkText(String text, {int maxLen = 1200}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const [];
  final paragraphs = trimmed.split(RegExp(r"(?:\r?\n\s*\r?\n)+"));
  final chunks = <String>[];
  for (final p in paragraphs) {
    final para = p.trim();
    if (para.isEmpty) continue;
    if (para.length <= maxLen) {
      chunks.add(para);
      continue;
    }
    final sentences = para.split(RegExp(r"(?<=[.!?])\s+"));
    var current = StringBuffer();
    for (final s in sentences) {
      final add = s.trim();
      if (add.isEmpty) continue;
      final currentLen = current.toString().length;
      final separatorCost = currentLen > 0 ? 1 : 0;
      if (currentLen + add.length + separatorCost <= maxLen) {
        if (currentLen > 0) current.write(' ');
        current.write(add);
      } else {
        if (currentLen > 0) {
          chunks.add(current.toString());
        }
        current = StringBuffer(add);
      }
    }
    if (current.toString().isNotEmpty) chunks.add(current.toString());
  }
  return chunks;
}
