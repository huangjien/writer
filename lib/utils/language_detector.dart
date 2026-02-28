class LanguageDetector {
  static const int _chineseThreshold = 1;

  static String detectLanguage(String text) {
    if (text.isEmpty) return 'en';

    int chineseCharCount = 0;

    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);

      if (codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) {
        chineseCharCount++;
      }
    }

    return chineseCharCount >= _chineseThreshold ? 'zh' : 'en';
  }

  static bool containsChinese(String text) {
    return detectLanguage(text) == 'zh';
  }

  static String getLanguageName(String code) {
    switch (code) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}
