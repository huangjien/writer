import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  group('AppLocalizationsZh - LocaleName Property', () {
    test('AppLocalizationsZh localeName property', () {
      final zh = AppLocalizationsZh();
      expect(zh.localeName, equals('zh'));
      expect(zh.localeName, isNotEmpty);
    });

    test('AppLocalizationsZhTw localeName property', () {
      final zhTW = AppLocalizationsZhTw();
      expect(zhTW.localeName, equals('zh_TW'));
      expect(zhTW.localeName, isNotEmpty);
    });

    test('localeName returns correct format', () {
      final zh = AppLocalizationsZh();
      final zhTW = AppLocalizationsZhTw();

      expect(zh.localeName, contains('zh'));
      expect(zhTW.localeName, contains('zh'));
      expect(zh.localeName, isNot(equals(zhTW.localeName)));
    });

    test('All basic properties with localeName', () {
      final zh = AppLocalizationsZh();
      final zhTW = AppLocalizationsZhTw();

      expect(zh.localeName, equals('zh'));
      expect(zh.helloWorld, isNotEmpty);
      expect(zh.appTitle, isNotEmpty);
      expect(zh.newChapter, isNotEmpty);
      expect(zh.back, isNotEmpty);
      expect(zh.settings, isNotEmpty);

      expect(zhTW.localeName, equals('zh_TW'));
      expect(zhTW.helloWorld, isNotEmpty);
      expect(zhTW.appTitle, isNotEmpty);
      expect(zhTW.newChapter, isNotEmpty);
      expect(zhTW.back, isNotEmpty);
      expect(zhTW.settings, isNotEmpty);
    });
  });
}
