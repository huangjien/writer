/// Utility to split long text into TTS-friendly chunks.
/// Splits on sentence boundaries and respects `maxLen`.
List<String> chunkText(String text, {int maxLen = 1200}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const [];
  final sentences = trimmed.split(RegExp(r"(?<=[.!?\n])\s+"));
  final chunks = <String>[];
  var current = StringBuffer();
  for (final s in sentences) {
    final add = s.trim();
    if (add.isEmpty) continue;
    final currentLen = current.toString().length;
    // Only add a space if there is existing content in the buffer
    final separatorCost = currentLen > 0 ? 1 : 0;
    if (currentLen + add.length + separatorCost <= maxLen) {
      if (currentLen > 0) current.write(' ');
      current.write(add);
    } else {
      // Avoid adding an empty chunk when the first sentence exceeds maxLen
      if (currentLen > 0) {
        chunks.add(current.toString());
      }
      current = StringBuffer(add);
    }
  }
  if (current.toString().isNotEmpty) chunks.add(current.toString());
  return chunks;
}
