class ContextUtils {
  static const int maxContextTokens = 4000;
  static const int avgCharsPerToken = 4;

  static int estimateTokens(String text) {
    if (text.isEmpty) return 0;
    return (text.length / avgCharsPerToken).ceil();
  }

  static bool isContextTooLong(String context) {
    return estimateTokens(context) > maxContextTokens;
  }
}
