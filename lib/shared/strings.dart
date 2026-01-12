String? trimToNull(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String trimOrEmpty(String? s) {
  if (s == null) return '';
  final t = s.trim();
  return t.isEmpty ? '' : t;
}

bool isBlank(String? s) {
  if (s == null) return true;
  return s.trim().isEmpty;
}

String trimOrDefault(String? s, String defaultValue) {
  if (s == null) return defaultValue;
  final t = s.trim();
  return t.isEmpty ? defaultValue : t;
}

int countWords(String text) {
  if (text.isEmpty) return 0;

  var count = 0;
  var inLatinWord = false;

  for (final cp in text.runes) {
    if (_isWhitespaceCodePoint(cp)) {
      if (inLatinWord) {
        count += 1;
        inLatinWord = false;
      }
      continue;
    }

    if (_isCjkLetter(cp)) {
      if (inLatinWord) {
        count += 1;
        inLatinWord = false;
      }
      count += 1;
      continue;
    }

    if (_isAsciiWordChar(cp)) {
      inLatinWord = true;
      continue;
    }

    if (inLatinWord) {
      count += 1;
      inLatinWord = false;
    }
  }

  if (inLatinWord) count += 1;
  return count;
}

bool _isWhitespaceCodePoint(int cp) {
  return cp == 0x20 ||
      cp == 0x09 ||
      cp == 0x0A ||
      cp == 0x0D ||
      cp == 0x0B ||
      cp == 0x0C ||
      cp == 0x3000;
}

bool _isAsciiWordChar(int cp) {
  return (cp >= 0x30 && cp <= 0x39) ||
      (cp >= 0x41 && cp <= 0x5A) ||
      (cp >= 0x61 && cp <= 0x7A) ||
      cp == 0x27;
}

bool _isCjkLetter(int cp) {
  if (cp >= 0x4E00 && cp <= 0x9FFF) return true; // CJK Unified Ideographs
  if (cp >= 0x3400 && cp <= 0x4DBF) return true; // Extension A
  if (cp >= 0x20000 && cp <= 0x2A6DF) return true; // Extension B
  if (cp >= 0x2A700 && cp <= 0x2B73F) return true; // Extension C
  if (cp >= 0x2B740 && cp <= 0x2B81F) return true; // Extension D
  if (cp >= 0x2B820 && cp <= 0x2CEAF) return true; // Extension E
  if (cp >= 0x2CEB0 && cp <= 0x2EBEF) return true; // Extension F
  if (cp >= 0x30000 && cp <= 0x3134F) return true; // Extension G

  if (cp >= 0x3040 && cp <= 0x309F) return true; // Hiragana
  if (cp >= 0x30A0 && cp <= 0x30FF) return true; // Katakana
  if (cp >= 0x31F0 && cp <= 0x31FF) return true; // Katakana Phonetic Extensions

  if (cp >= 0xAC00 && cp <= 0xD7AF) return true; // Hangul Syllables
  if (cp >= 0x1100 && cp <= 0x11FF) return true; // Hangul Jamo
  if (cp >= 0x3130 && cp <= 0x318F) return true; // Hangul Compatibility Jamo

  if (cp >= 0x3100 && cp <= 0x312F) return true; // Bopomofo
  if (cp >= 0x31A0 && cp <= 0x31BF) return true; // Bopomofo Extended

  return false;
}
