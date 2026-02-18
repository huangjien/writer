import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_de.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/l10n/app_localizations_es.dart';
import 'package:writer/l10n/app_localizations_fr.dart';
import 'package:writer/l10n/app_localizations_it.dart';
import 'package:writer/l10n/app_localizations_ja.dart';
import 'package:writer/l10n/app_localizations_ru.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  group('AppLocalizationsEn Tests', () {
    late AppLocalizationsEn en;

    setUp(() {
      en = AppLocalizationsEn();
    });

    test('provides correct locale', () {
      expect(en.localeName, 'en');
    });

    test('newChapter returns correct value', () {
      expect(en.newChapter, 'New Chapter');
    });

    test('back returns correct value', () {
      expect(en.back, 'Back');
    });

    test('helloWorld returns correct value', () {
      expect(en.helloWorld, 'Hello World!');
    });

    test('settings returns correct value', () {
      expect(en.settings, 'Settings');
    });

    test('appTitle returns correct value', () {
      expect(en.appTitle, 'Writer');
    });

    test('about returns correct value', () {
      expect(en.about, 'About');
    });

    test('signedInAs formats correctly', () {
      expect(
        en.signedInAs('test@example.com'),
        'Signed in as test@example.com',
      );
    });
  });

  group('AppLocalizationsZh Tests', () {
    late AppLocalizationsZh zh;

    setUp(() {
      zh = AppLocalizationsZh();
    });

    test('provides correct locale', () {
      expect(zh.localeName, 'zh');
    });

    test('newChapter returns correct value', () {
      expect(zh.newChapter, '新章节');
    });

    test('back returns correct value', () {
      expect(zh.back, '返回');
    });

    test('helloWorld returns correct value', () {
      expect(zh.helloWorld, '你好世界！');
    });

    test('settings returns correct value', () {
      expect(zh.settings, '设置');
    });

    test('appTitle returns correct value', () {
      expect(zh.appTitle, '写手');
    });

    test('about returns correct value', () {
      expect(zh.about, '关于');
    });

    test('signedInAs formats correctly', () {
      expect(zh.signedInAs('test@example.com'), '已登录为 test@example.com');
    });
  });

  group('AppLocalizationsDe Tests', () {
    late AppLocalizationsDe de;

    setUp(() {
      de = AppLocalizationsDe();
    });

    test('provides correct locale', () {
      expect(de.localeName, 'de');
    });

    test('newChapter returns non-empty value', () {
      expect(de.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(de.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(de.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(de.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(de.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizationsEs Tests', () {
    late AppLocalizationsEs es;

    setUp(() {
      es = AppLocalizationsEs();
    });

    test('provides correct locale', () {
      expect(es.localeName, 'es');
    });

    test('newChapter returns non-empty value', () {
      expect(es.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(es.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(es.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(es.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(es.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizationsFr Tests', () {
    late AppLocalizationsFr fr;

    setUp(() {
      fr = AppLocalizationsFr();
    });

    test('provides correct locale', () {
      expect(fr.localeName, 'fr');
    });

    test('newChapter returns non-empty value', () {
      expect(fr.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(fr.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(fr.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(fr.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(fr.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizationsIt Tests', () {
    late AppLocalizationsIt it;

    setUp(() {
      it = AppLocalizationsIt();
    });

    test('provides correct locale', () {
      expect(it.localeName, 'it');
    });

    test('newChapter returns non-empty value', () {
      expect(it.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(it.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(it.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(it.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(it.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizationsJa Tests', () {
    late AppLocalizationsJa ja;

    setUp(() {
      ja = AppLocalizationsJa();
    });

    test('provides correct locale', () {
      expect(ja.localeName, 'ja');
    });

    test('newChapter returns non-empty value', () {
      expect(ja.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(ja.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(ja.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(ja.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(ja.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizationsRu Tests', () {
    late AppLocalizationsRu ru;

    setUp(() {
      ru = AppLocalizationsRu();
    });

    test('provides correct locale', () {
      expect(ru.localeName, 'ru');
    });

    test('newChapter returns non-empty value', () {
      expect(ru.newChapter, isNotEmpty);
    });

    test('back returns non-empty value', () {
      expect(ru.back, isNotEmpty);
    });

    test('settings returns non-empty value', () {
      expect(ru.settings, isNotEmpty);
    });

    test('appTitle returns non-empty value', () {
      expect(ru.appTitle, isNotEmpty);
    });

    test('signedInAs formats correctly', () {
      expect(ru.signedInAs('test@example.com'), contains('test@example.com'));
    });
  });

  group('AppLocalizations Consistency Tests', () {
    test('all locales provide essential getters', () {
      final locales = <AppLocalizations>[
        AppLocalizationsEn(),
        AppLocalizationsZh(),
        AppLocalizationsDe(),
        AppLocalizationsEs(),
        AppLocalizationsFr(),
        AppLocalizationsIt(),
        AppLocalizationsJa(),
        AppLocalizationsRu(),
      ];

      for (final locale in locales) {
        expect(locale.newChapter, isNotEmpty);
        expect(locale.back, isNotEmpty);
        expect(locale.settings, isNotEmpty);
        expect(locale.appTitle, isNotEmpty);
      }
    });

    test('all locales handle parameterized methods', () {
      final locales = <AppLocalizations>[
        AppLocalizationsEn(),
        AppLocalizationsZh(),
        AppLocalizationsDe(),
        AppLocalizationsEs(),
        AppLocalizationsFr(),
        AppLocalizationsIt(),
        AppLocalizationsJa(),
        AppLocalizationsRu(),
      ];

      for (final locale in locales) {
        final result = locale.signedInAs('test@example.com');
        expect(result, contains('test@example.com'));
      }
    });
  });
}
