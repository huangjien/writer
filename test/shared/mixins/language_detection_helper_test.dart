import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/mixins/language_detection_helper.dart';

void main() {
  group('LanguageDetectionHelper', () {
    test('initializes with default language', () {
      final helper = LanguageDetectionHelper();
      expect(helper.notifier.value, 'en');
      helper.dispose();
    });

    test('initializes with custom language', () {
      final helper = LanguageDetectionHelper(initialLanguage: 'zh');
      expect(helper.notifier.value, 'zh');
      helper.dispose();
    });

    test('detects Chinese text', () async {
      final helper = LanguageDetectionHelper();
      helper.updateDetection('中文测试');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(helper.notifier.value, 'zh');
      helper.dispose();
    });

    test('detects English text', () async {
      final helper = LanguageDetectionHelper();
      helper.updateDetection('Hello World');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(helper.notifier.value, 'en');
      helper.dispose();
    });

    test('defaults to English for empty text', () async {
      final helper = LanguageDetectionHelper();
      helper.updateDetection('');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(helper.notifier.value, 'en');
      helper.dispose();
    });

    test('debounces rapid updates', () async {
      final helper = LanguageDetectionHelper();

      helper.updateDetection('Hello');
      helper.updateDetection('Hello World');
      helper.updateDetection('中文');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(helper.notifier.value, 'zh');
      helper.dispose();
    });
  });
}
