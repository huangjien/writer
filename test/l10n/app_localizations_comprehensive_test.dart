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
  group('Comprehensive Localization Tests', () {
    late List<AppLocalizations> locales;

    setUp(() {
      locales = [
        AppLocalizationsDe(),
        AppLocalizationsEn(),
        AppLocalizationsEs(),
        AppLocalizationsFr(),
        AppLocalizationsIt(),
        AppLocalizationsJa(),
        AppLocalizationsRu(),
        AppLocalizationsZh(),
      ];
    });

    test('all locales have non-empty basic strings', () {
      for (final locale in locales) {
        expect(
          locale.newChapter,
          isNotEmpty,
          reason: '${locale.localeName}: newChapter',
        );
        expect(locale.back, isNotEmpty, reason: '${locale.localeName}: back');
        expect(
          locale.settings,
          isNotEmpty,
          reason: '${locale.localeName}: settings',
        );
        expect(
          locale.helloWorld,
          isNotEmpty,
          reason: '${locale.localeName}: helloWorld',
        );
        expect(locale.about, isNotEmpty, reason: '${locale.localeName}: about');
        expect(
          locale.appTitle,
          isNotEmpty,
          reason: '${locale.localeName}: appTitle',
        );
        expect(
          locale.version,
          isNotEmpty,
          reason: '${locale.localeName}: version',
        );
        expect(locale.guest, isNotEmpty, reason: '${locale.localeName}: guest');
        expect(
          locale.signIn,
          isNotEmpty,
          reason: '${locale.localeName}: signIn',
        );
        expect(
          locale.signOut,
          isNotEmpty,
          reason: '${locale.localeName}: signOut',
        );
        expect(
          locale.cancel,
          isNotEmpty,
          reason: '${locale.localeName}: cancel',
        );
        expect(
          locale.create,
          isNotEmpty,
          reason: '${locale.localeName}: create',
        );
        expect(
          locale.chapter,
          isNotEmpty,
          reason: '${locale.localeName}: chapter',
        );
        expect(
          locale.chapters,
          isNotEmpty,
          reason: '${locale.localeName}: chapters',
        );
        expect(locale.novel, isNotEmpty, reason: '${locale.localeName}: novel');
        expect(
          locale.novels,
          isNotEmpty,
          reason: '${locale.localeName}: novels',
        );
        expect(locale.error, isNotEmpty, reason: '${locale.localeName}: error');
      }
    });

    test('all locales format parameterized strings correctly', () {
      for (final locale in locales) {
        expect(
          locale.signedInAs('test@example.com'),
          contains('test@example.com'),
          reason: '${locale.localeName}: signedInAs',
        );
        expect(
          locale.continueAtChapter('Test Chapter'),
          isNotEmpty,
          reason: '${locale.localeName}: continueAtChapter',
        );
        expect(
          locale.novelsAndProgressSummary(5, '50%'),
          isNotEmpty,
          reason: '${locale.localeName}: novelsAndProgressSummary',
        );
        expect(
          locale.indexLabel(1),
          isNotEmpty,
          reason: '${locale.localeName}: indexLabel',
        );
        expect(
          locale.indexOutOfRange(1, 10),
          isNotEmpty,
          reason: '${locale.localeName}: indexOutOfRange',
        );
        expect(
          locale.ttsError('test error'),
          isNotEmpty,
          reason: '${locale.localeName}: ttsError',
        );
      }
    });

    test('all locales have authentication strings', () {
      for (final locale in locales) {
        expect(locale.email, isNotEmpty, reason: '${locale.localeName}: email');
        expect(
          locale.password,
          isNotEmpty,
          reason: '${locale.localeName}: password',
        );
        expect(
          locale.signInWithGoogle,
          isNotEmpty,
          reason: '${locale.localeName}: signInWithGoogle',
        );
        expect(
          locale.signInWithApple,
          isNotEmpty,
          reason: '${locale.localeName}: signInWithApple',
        );
        expect(
          locale.signedOut,
          isNotEmpty,
          reason: '${locale.localeName}: signedOut',
        );
        expect(
          locale.notSignedIn,
          isNotEmpty,
          reason: '${locale.localeName}: notSignedIn',
        );
        expect(
          locale.continueLabel,
          isNotEmpty,
          reason: '${locale.localeName}: continueLabel',
        );
        expect(
          locale.reload,
          isNotEmpty,
          reason: '${locale.localeName}: reload',
        );
      }
    });

    test('all locales have TTS-related strings', () {
      for (final locale in locales) {
        expect(
          locale.ttsSettings,
          isNotEmpty,
          reason: '${locale.localeName}: ttsSettings',
        );
        expect(
          locale.enableTTS,
          isNotEmpty,
          reason: '${locale.localeName}: enableTTS',
        );
        expect(
          locale.testVoice,
          isNotEmpty,
          reason: '${locale.localeName}: testVoice',
        );
        expect(
          locale.reloadVoices,
          isNotEmpty,
          reason: '${locale.localeName}: reloadVoices',
        );
        expect(
          locale.ttsVoice,
          isNotEmpty,
          reason: '${locale.localeName}: ttsVoice',
        );
        expect(
          locale.loadingVoices,
          isNotEmpty,
          reason: '${locale.localeName}: loadingVoices',
        );
        expect(
          locale.selectVoice,
          isNotEmpty,
          reason: '${locale.localeName}: selectVoice',
        );
        expect(
          locale.ttsLanguage,
          isNotEmpty,
          reason: '${locale.localeName}: ttsLanguage',
        );
        expect(
          locale.selectLanguage,
          isNotEmpty,
          reason: '${locale.localeName}: selectLanguage',
        );
        expect(
          locale.stopTTS,
          isNotEmpty,
          reason: '${locale.localeName}: stopTTS',
        );
        expect(locale.speak, isNotEmpty, reason: '${locale.localeName}: speak');
      }
    });

    test('all locales have progress strings', () {
      for (final locale in locales) {
        expect(
          locale.progress,
          isNotEmpty,
          reason: '${locale.localeName}: progress',
        );
        expect(
          locale.currentProgress,
          isNotEmpty,
          reason: '${locale.localeName}: currentProgress',
        );
        expect(
          locale.loadingProgress,
          isNotEmpty,
          reason: '${locale.localeName}: loadingProgress',
        );
        expect(
          locale.recentlyRead,
          isNotEmpty,
          reason: '${locale.localeName}: recentlyRead',
        );
        expect(
          locale.notStarted,
          isNotEmpty,
          reason: '${locale.localeName}: notStarted',
        );
        expect(
          locale.progressSaved,
          isNotEmpty,
          reason: '${locale.localeName}: progressSaved',
        );
      }
    });

    test('all locales have settings strings', () {
      for (final locale in locales) {
        expect(
          locale.appSettings,
          isNotEmpty,
          reason: '${locale.localeName}: appSettings',
        );
        expect(
          locale.themeMode,
          isNotEmpty,
          reason: '${locale.localeName}: themeMode',
        );
        expect(
          locale.system,
          isNotEmpty,
          reason: '${locale.localeName}: system',
        );
        expect(locale.light, isNotEmpty, reason: '${locale.localeName}: light');
        expect(locale.dark, isNotEmpty, reason: '${locale.localeName}: dark');
        expect(
          locale.colorTheme,
          isNotEmpty,
          reason: '${locale.localeName}: colorTheme',
        );
      }
    });

    test('all locales have theme-specific strings', () {
      for (final locale in locales) {
        expect(
          locale.themeLight,
          isNotEmpty,
          reason: '${locale.localeName}: themeLight',
        );
        expect(
          locale.themeSepia,
          isNotEmpty,
          reason: '${locale.localeName}: themeSepia',
        );
        expect(
          locale.themeHighContrast,
          isNotEmpty,
          reason: '${locale.localeName}: themeHighContrast',
        );
        expect(
          locale.themeDefault,
          isNotEmpty,
          reason: '${locale.localeName}: themeDefault',
        );
        expect(
          locale.themeEmeraldGreen,
          isNotEmpty,
          reason: '${locale.localeName}: themeEmeraldGreen',
        );
        expect(
          locale.themeSolarizedTan,
          isNotEmpty,
          reason: '${locale.localeName}: themeSolarizedTan',
        );
        expect(
          locale.themeNord,
          isNotEmpty,
          reason: '${locale.localeName}: themeNord',
        );
        expect(
          locale.themeNordFrost,
          isNotEmpty,
          reason: '${locale.localeName}: themeNordFrost',
        );
      }
    });

    test('all locales have biometric strings', () {
      for (final locale in locales) {
        expect(
          locale.signInWithBiometrics,
          isNotEmpty,
          reason: '${locale.localeName}: signInWithBiometrics',
        );
        expect(
          locale.enableBiometricLogin,
          isNotEmpty,
          reason: '${locale.localeName}: enableBiometricLogin',
        );
        expect(
          locale.enableBiometricLoginDescription,
          isNotEmpty,
          reason: '${locale.localeName}: enableBiometricLoginDescription',
        );
        expect(
          locale.biometricAuthFailed,
          isNotEmpty,
          reason: '${locale.localeName}: biometricAuthFailed',
        );
      }
    });

    test('all locales have summary-related strings', () {
      for (final locale in locales) {
        expect(
          locale.sentenceSummary,
          isNotEmpty,
          reason: '${locale.localeName}: sentenceSummary',
        );
        expect(
          locale.paragraphSummary,
          isNotEmpty,
          reason: '${locale.localeName}: paragraphSummary',
        );
        expect(
          locale.pageSummary,
          isNotEmpty,
          reason: '${locale.localeName}: pageSummary',
        );
        expect(
          locale.expandedSummary,
          isNotEmpty,
          reason: '${locale.localeName}: expandedSummary',
        );
      }
    });

    test('all locales have error-related strings', () {
      for (final locale in locales) {
        expect(
          locale.errorLoadingProgress,
          isNotEmpty,
          reason: '${locale.localeName}: errorLoadingProgress',
        );
        expect(
          locale.errorLoadingNovels,
          isNotEmpty,
          reason: '${locale.localeName}: errorLoadingNovels',
        );
        expect(
          locale.errorLoadingChapters,
          isNotEmpty,
          reason: '${locale.localeName}: errorLoadingChapters',
        );
        expect(
          locale.errorSavingProgress,
          isNotEmpty,
          reason: '${locale.localeName}: errorSavingProgress',
        );
        expect(
          locale.noProgress,
          isNotEmpty,
          reason: '${locale.localeName}: noProgress',
        );
        expect(
          locale.noNovelsFound,
          isNotEmpty,
          reason: '${locale.localeName}: noNovelsFound',
        );
        expect(
          locale.noChaptersFound,
          isNotEmpty,
          reason: '${locale.localeName}: noChaptersFound',
        );
      }
    });

    test('all locales have loading strings', () {
      for (final locale in locales) {
        expect(
          locale.loadingNovels,
          isNotEmpty,
          reason: '${locale.localeName}: loadingNovels',
        );
        expect(
          locale.loadingChapter,
          isNotEmpty,
          reason: '${locale.localeName}: loadingChapter',
        );
        expect(
          locale.loadingLanguages,
          isNotEmpty,
          reason: '${locale.localeName}: loadingLanguages',
        );
      }
    });

    test('all locales have about section strings', () {
      for (final locale in locales) {
        expect(
          locale.aboutDescription,
          isNotEmpty,
          reason: '${locale.localeName}: aboutDescription',
        );
        expect(
          locale.aboutIntro,
          isNotEmpty,
          reason: '${locale.localeName}: aboutIntro',
        );
        expect(
          locale.aboutSecurity,
          isNotEmpty,
          reason: '${locale.localeName}: aboutSecurity',
        );
        expect(
          locale.aboutCoach,
          isNotEmpty,
          reason: '${locale.localeName}: aboutCoach',
        );
        expect(
          locale.aboutFeatureCreate,
          isNotEmpty,
          reason: '${locale.localeName}: aboutFeatureCreate',
        );
        expect(
          locale.aboutFeatureTemplates,
          isNotEmpty,
          reason: '${locale.localeName}: aboutFeatureTemplates',
        );
        expect(
          locale.aboutFeatureTracking,
          isNotEmpty,
          reason: '${locale.localeName}: aboutFeatureTracking',
        );
        expect(
          locale.aboutFeatureCoach,
          isNotEmpty,
          reason: '${locale.localeName}: aboutFeatureCoach',
        );
        expect(
          locale.aboutFeaturePrompts,
          isNotEmpty,
          reason: '${locale.localeName}: aboutFeaturePrompts',
        );
        expect(
          locale.aboutUsage,
          isNotEmpty,
          reason: '${locale.localeName}: aboutUsage',
        );
        expect(
          locale.aboutUsageList,
          isNotEmpty,
          reason: '${locale.localeName}: aboutUsageList',
        );
      }
    });
  });

  group('German (de) Comprehensive Tests', () {
    final de = AppLocalizationsDe();

    test('all basic strings are non-empty', () {
      expect(de.newChapter, isNotEmpty);
      expect(de.back, isNotEmpty);
      expect(de.settings, isNotEmpty);
      expect(de.helloWorld, isNotEmpty);
      expect(de.about, isNotEmpty);
      expect(de.appTitle, isNotEmpty);
      expect(de.version, isNotEmpty);
      expect(de.signIn, isNotEmpty);
      expect(de.signOut, isNotEmpty);
      expect(de.email, isNotEmpty);
      expect(de.password, isNotEmpty);
      expect(de.ttsSettings, isNotEmpty);
      expect(de.enableTTS, isNotEmpty);
      expect(de.themeMode, isNotEmpty);
      expect(de.appSettings, isNotEmpty);
      expect(de.myNovels, isNotEmpty);
      expect(de.createNovel, isNotEmpty);
      expect(de.novels, isNotEmpty);
      expect(de.chapters, isNotEmpty);
      expect(de.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(de.signedInAs('user@test.com'), contains('user@test.com'));
      expect(de.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(de.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(de.indexLabel(1), isNotEmpty);
      expect(de.indexOutOfRange(1, 10), isNotEmpty);
      expect(de.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(de.testVoice, isNotEmpty);
      expect(de.reloadVoices, isNotEmpty);
      expect(de.ttsVoice, isNotEmpty);
      expect(de.loadingVoices, isNotEmpty);
      expect(de.selectVoice, isNotEmpty);
      expect(de.stopTTS, isNotEmpty);
      expect(de.speak, isNotEmpty);
      expect(de.ttsSpeechRate, isNotEmpty);
      expect(de.ttsSpeechVolume, isNotEmpty);
      expect(de.ttsSpeechPitch, isNotEmpty);
      expect(de.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(de.system, isNotEmpty);
      expect(de.light, isNotEmpty);
      expect(de.dark, isNotEmpty);
      expect(de.colorTheme, isNotEmpty);
      expect(de.themeLight, isNotEmpty);
      expect(de.themeSepia, isNotEmpty);
      expect(de.themeHighContrast, isNotEmpty);
      expect(de.themeDefault, isNotEmpty);
      expect(de.themeEmeraldGreen, isNotEmpty);
      expect(de.themeSolarizedTan, isNotEmpty);
      expect(de.themeNord, isNotEmpty);
      expect(de.themeNordFrost, isNotEmpty);
    });
  });

  group('Spanish (es) Comprehensive Tests', () {
    final es = AppLocalizationsEs();

    test('all basic strings are non-empty', () {
      expect(es.newChapter, isNotEmpty);
      expect(es.back, isNotEmpty);
      expect(es.settings, isNotEmpty);
      expect(es.helloWorld, isNotEmpty);
      expect(es.about, isNotEmpty);
      expect(es.appTitle, isNotEmpty);
      expect(es.version, isNotEmpty);
      expect(es.signIn, isNotEmpty);
      expect(es.signOut, isNotEmpty);
      expect(es.email, isNotEmpty);
      expect(es.password, isNotEmpty);
      expect(es.ttsSettings, isNotEmpty);
      expect(es.enableTTS, isNotEmpty);
      expect(es.themeMode, isNotEmpty);
      expect(es.appSettings, isNotEmpty);
      expect(es.myNovels, isNotEmpty);
      expect(es.createNovel, isNotEmpty);
      expect(es.novels, isNotEmpty);
      expect(es.chapters, isNotEmpty);
      expect(es.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(es.signedInAs('user@test.com'), contains('user@test.com'));
      expect(es.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(es.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(es.indexLabel(1), isNotEmpty);
      expect(es.indexOutOfRange(1, 10), isNotEmpty);
      expect(es.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(es.testVoice, isNotEmpty);
      expect(es.reloadVoices, isNotEmpty);
      expect(es.ttsVoice, isNotEmpty);
      expect(es.loadingVoices, isNotEmpty);
      expect(es.selectVoice, isNotEmpty);
      expect(es.stopTTS, isNotEmpty);
      expect(es.speak, isNotEmpty);
      expect(es.ttsSpeechRate, isNotEmpty);
      expect(es.ttsSpeechVolume, isNotEmpty);
      expect(es.ttsSpeechPitch, isNotEmpty);
      expect(es.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(es.system, isNotEmpty);
      expect(es.light, isNotEmpty);
      expect(es.dark, isNotEmpty);
      expect(es.colorTheme, isNotEmpty);
      expect(es.themeLight, isNotEmpty);
      expect(es.themeSepia, isNotEmpty);
      expect(es.themeHighContrast, isNotEmpty);
      expect(es.themeDefault, isNotEmpty);
      expect(es.themeEmeraldGreen, isNotEmpty);
      expect(es.themeSolarizedTan, isNotEmpty);
      expect(es.themeNord, isNotEmpty);
      expect(es.themeNordFrost, isNotEmpty);
    });
  });

  group('French (fr) Comprehensive Tests', () {
    final fr = AppLocalizationsFr();

    test('all basic strings are non-empty', () {
      expect(fr.newChapter, isNotEmpty);
      expect(fr.back, isNotEmpty);
      expect(fr.settings, isNotEmpty);
      expect(fr.helloWorld, isNotEmpty);
      expect(fr.about, isNotEmpty);
      expect(fr.appTitle, isNotEmpty);
      expect(fr.version, isNotEmpty);
      expect(fr.signIn, isNotEmpty);
      expect(fr.signOut, isNotEmpty);
      expect(fr.email, isNotEmpty);
      expect(fr.password, isNotEmpty);
      expect(fr.ttsSettings, isNotEmpty);
      expect(fr.enableTTS, isNotEmpty);
      expect(fr.themeMode, isNotEmpty);
      expect(fr.appSettings, isNotEmpty);
      expect(fr.myNovels, isNotEmpty);
      expect(fr.createNovel, isNotEmpty);
      expect(fr.novels, isNotEmpty);
      expect(fr.chapters, isNotEmpty);
      expect(fr.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(fr.signedInAs('user@test.com'), contains('user@test.com'));
      expect(fr.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(fr.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(fr.indexLabel(1), isNotEmpty);
      expect(fr.indexOutOfRange(1, 10), isNotEmpty);
      expect(fr.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(fr.testVoice, isNotEmpty);
      expect(fr.reloadVoices, isNotEmpty);
      expect(fr.ttsVoice, isNotEmpty);
      expect(fr.loadingVoices, isNotEmpty);
      expect(fr.selectVoice, isNotEmpty);
      expect(fr.stopTTS, isNotEmpty);
      expect(fr.speak, isNotEmpty);
      expect(fr.ttsSpeechRate, isNotEmpty);
      expect(fr.ttsSpeechVolume, isNotEmpty);
      expect(fr.ttsSpeechPitch, isNotEmpty);
      expect(fr.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(fr.system, isNotEmpty);
      expect(fr.light, isNotEmpty);
      expect(fr.dark, isNotEmpty);
      expect(fr.colorTheme, isNotEmpty);
      expect(fr.themeLight, isNotEmpty);
      expect(fr.themeSepia, isNotEmpty);
      expect(fr.themeHighContrast, isNotEmpty);
      expect(fr.themeDefault, isNotEmpty);
      expect(fr.themeEmeraldGreen, isNotEmpty);
      expect(fr.themeSolarizedTan, isNotEmpty);
      expect(fr.themeNord, isNotEmpty);
      expect(fr.themeNordFrost, isNotEmpty);
    });
  });

  group('Italian (it) Comprehensive Tests', () {
    final it = AppLocalizationsIt();

    test('all basic strings are non-empty', () {
      expect(it.newChapter, isNotEmpty);
      expect(it.back, isNotEmpty);
      expect(it.settings, isNotEmpty);
      expect(it.helloWorld, isNotEmpty);
      expect(it.about, isNotEmpty);
      expect(it.appTitle, isNotEmpty);
      expect(it.version, isNotEmpty);
      expect(it.signIn, isNotEmpty);
      expect(it.signOut, isNotEmpty);
      expect(it.email, isNotEmpty);
      expect(it.password, isNotEmpty);
      expect(it.ttsSettings, isNotEmpty);
      expect(it.enableTTS, isNotEmpty);
      expect(it.themeMode, isNotEmpty);
      expect(it.appSettings, isNotEmpty);
      expect(it.myNovels, isNotEmpty);
      expect(it.createNovel, isNotEmpty);
      expect(it.novels, isNotEmpty);
      expect(it.chapters, isNotEmpty);
      expect(it.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(it.signedInAs('user@test.com'), contains('user@test.com'));
      expect(it.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(it.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(it.indexLabel(1), isNotEmpty);
      expect(it.indexOutOfRange(1, 10), isNotEmpty);
      expect(it.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(it.testVoice, isNotEmpty);
      expect(it.reloadVoices, isNotEmpty);
      expect(it.ttsVoice, isNotEmpty);
      expect(it.loadingVoices, isNotEmpty);
      expect(it.selectVoice, isNotEmpty);
      expect(it.stopTTS, isNotEmpty);
      expect(it.speak, isNotEmpty);
      expect(it.ttsSpeechRate, isNotEmpty);
      expect(it.ttsSpeechVolume, isNotEmpty);
      expect(it.ttsSpeechPitch, isNotEmpty);
      expect(it.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(it.system, isNotEmpty);
      expect(it.light, isNotEmpty);
      expect(it.dark, isNotEmpty);
      expect(it.colorTheme, isNotEmpty);
      expect(it.themeLight, isNotEmpty);
      expect(it.themeSepia, isNotEmpty);
      expect(it.themeHighContrast, isNotEmpty);
      expect(it.themeDefault, isNotEmpty);
      expect(it.themeEmeraldGreen, isNotEmpty);
      expect(it.themeSolarizedTan, isNotEmpty);
      expect(it.themeNord, isNotEmpty);
      expect(it.themeNordFrost, isNotEmpty);
    });
  });

  group('Japanese (ja) Comprehensive Tests', () {
    final ja = AppLocalizationsJa();

    test('all basic strings are non-empty', () {
      expect(ja.newChapter, isNotEmpty);
      expect(ja.back, isNotEmpty);
      expect(ja.settings, isNotEmpty);
      expect(ja.helloWorld, isNotEmpty);
      expect(ja.about, isNotEmpty);
      expect(ja.appTitle, isNotEmpty);
      expect(ja.version, isNotEmpty);
      expect(ja.signIn, isNotEmpty);
      expect(ja.signOut, isNotEmpty);
      expect(ja.email, isNotEmpty);
      expect(ja.password, isNotEmpty);
      expect(ja.ttsSettings, isNotEmpty);
      expect(ja.enableTTS, isNotEmpty);
      expect(ja.themeMode, isNotEmpty);
      expect(ja.appSettings, isNotEmpty);
      expect(ja.myNovels, isNotEmpty);
      expect(ja.createNovel, isNotEmpty);
      expect(ja.novels, isNotEmpty);
      expect(ja.chapters, isNotEmpty);
      expect(ja.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(ja.signedInAs('user@test.com'), contains('user@test.com'));
      expect(ja.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(ja.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(ja.indexLabel(1), isNotEmpty);
      expect(ja.indexOutOfRange(1, 10), isNotEmpty);
      expect(ja.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(ja.testVoice, isNotEmpty);
      expect(ja.reloadVoices, isNotEmpty);
      expect(ja.ttsVoice, isNotEmpty);
      expect(ja.loadingVoices, isNotEmpty);
      expect(ja.selectVoice, isNotEmpty);
      expect(ja.stopTTS, isNotEmpty);
      expect(ja.speak, isNotEmpty);
      expect(ja.ttsSpeechRate, isNotEmpty);
      expect(ja.ttsSpeechVolume, isNotEmpty);
      expect(ja.ttsSpeechPitch, isNotEmpty);
      expect(ja.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(ja.system, isNotEmpty);
      expect(ja.light, isNotEmpty);
      expect(ja.dark, isNotEmpty);
      expect(ja.colorTheme, isNotEmpty);
      expect(ja.themeLight, isNotEmpty);
      expect(ja.themeSepia, isNotEmpty);
      expect(ja.themeHighContrast, isNotEmpty);
      expect(ja.themeDefault, isNotEmpty);
      expect(ja.themeEmeraldGreen, isNotEmpty);
      expect(ja.themeSolarizedTan, isNotEmpty);
      expect(ja.themeNord, isNotEmpty);
      expect(ja.themeNordFrost, isNotEmpty);
    });
  });

  group('Russian (ru) Comprehensive Tests', () {
    final ru = AppLocalizationsRu();

    test('all basic strings are non-empty', () {
      expect(ru.newChapter, isNotEmpty);
      expect(ru.back, isNotEmpty);
      expect(ru.settings, isNotEmpty);
      expect(ru.helloWorld, isNotEmpty);
      expect(ru.about, isNotEmpty);
      expect(ru.appTitle, isNotEmpty);
      expect(ru.version, isNotEmpty);
      expect(ru.signIn, isNotEmpty);
      expect(ru.signOut, isNotEmpty);
      expect(ru.email, isNotEmpty);
      expect(ru.password, isNotEmpty);
      expect(ru.ttsSettings, isNotEmpty);
      expect(ru.enableTTS, isNotEmpty);
      expect(ru.themeMode, isNotEmpty);
      expect(ru.appSettings, isNotEmpty);
      expect(ru.myNovels, isNotEmpty);
      expect(ru.createNovel, isNotEmpty);
      expect(ru.novels, isNotEmpty);
      expect(ru.chapters, isNotEmpty);
      expect(ru.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(ru.signedInAs('user@test.com'), contains('user@test.com'));
      expect(ru.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(ru.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(ru.indexLabel(1), isNotEmpty);
      expect(ru.indexOutOfRange(1, 10), isNotEmpty);
      expect(ru.ttsError('test error'), isNotEmpty);
    });

    test('TTS-related strings are non-empty', () {
      expect(ru.testVoice, isNotEmpty);
      expect(ru.reloadVoices, isNotEmpty);
      expect(ru.ttsVoice, isNotEmpty);
      expect(ru.loadingVoices, isNotEmpty);
      expect(ru.selectVoice, isNotEmpty);
      expect(ru.stopTTS, isNotEmpty);
      expect(ru.speak, isNotEmpty);
      expect(ru.ttsSpeechRate, isNotEmpty);
      expect(ru.ttsSpeechVolume, isNotEmpty);
      expect(ru.ttsSpeechPitch, isNotEmpty);
      expect(ru.pitch, isNotEmpty);
    });

    test('theme strings are non-empty', () {
      expect(ru.system, isNotEmpty);
      expect(ru.light, isNotEmpty);
      expect(ru.dark, isNotEmpty);
      expect(ru.colorTheme, isNotEmpty);
      expect(ru.themeLight, isNotEmpty);
      expect(ru.themeSepia, isNotEmpty);
      expect(ru.themeHighContrast, isNotEmpty);
      expect(ru.themeDefault, isNotEmpty);
      expect(ru.themeEmeraldGreen, isNotEmpty);
      expect(ru.themeSolarizedTan, isNotEmpty);
      expect(ru.themeNord, isNotEmpty);
      expect(ru.themeNordFrost, isNotEmpty);
    });
  });

  group('Chinese (zh) Extended Coverage Tests', () {
    final zh = AppLocalizationsZh();

    test('all basic strings are non-empty', () {
      expect(zh.newChapter, isNotEmpty);
      expect(zh.back, isNotEmpty);
      expect(zh.settings, isNotEmpty);
      expect(zh.helloWorld, isNotEmpty);
      expect(zh.about, isNotEmpty);
      expect(zh.appTitle, isNotEmpty);
      expect(zh.version, isNotEmpty);
      expect(zh.signIn, isNotEmpty);
      expect(zh.signOut, isNotEmpty);
      expect(zh.email, isNotEmpty);
      expect(zh.password, isNotEmpty);
      expect(zh.ttsSettings, isNotEmpty);
      expect(zh.enableTTS, isNotEmpty);
      expect(zh.themeMode, isNotEmpty);
      expect(zh.appSettings, isNotEmpty);
      expect(zh.myNovels, isNotEmpty);
      expect(zh.createNovel, isNotEmpty);
      expect(zh.novels, isNotEmpty);
      expect(zh.chapters, isNotEmpty);
      expect(zh.error, isNotEmpty);
    });

    test('parameterized strings work correctly', () {
      expect(zh.signedInAs('user@test.com'), contains('user@test.com'));
      expect(zh.continueAtChapter('Test Chapter'), isNotEmpty);
      expect(zh.novelsAndProgressSummary(5, '50%'), isNotEmpty);
      expect(zh.indexLabel(1), isNotEmpty);
      expect(zh.indexOutOfRange(1, 10), isNotEmpty);
      expect(zh.ttsError('test error'), isNotEmpty);
    });

    test('extended zh coverage for more strings', () {
      expect(zh.appLanguage, isNotEmpty);
      expect(zh.english, isNotEmpty);
      expect(zh.chinese, isNotEmpty);
      expect(zh.supabaseIntegrationInitialized, isNotEmpty);
      expect(zh.configureEnvironment, isNotEmpty);
      expect(zh.guest, isNotEmpty);
      expect(zh.notSignedIn, isNotEmpty);
      expect(zh.signInToSync, isNotEmpty);
      expect(zh.noSupabase, isNotEmpty);
      expect(zh.titleLabel, isNotEmpty);
      expect(zh.authorLabel, isNotEmpty);
      expect(zh.searchByTitle, isNotEmpty);
      expect(zh.chooseLanguage, isNotEmpty);
      expect(zh.volume, isNotEmpty);
      expect(zh.defaultTTSVoice, isNotEmpty);
      expect(zh.defaultVoiceUpdated, isNotEmpty);
      expect(zh.defaultLanguageSet, isNotEmpty);
      expect(zh.chapterTitle, isNotEmpty);
      expect(zh.scrollOffset, isNotEmpty);
      expect(zh.ttsIndex, isNotEmpty);
      expect(zh.speechRate, isNotEmpty);
      expect(zh.sentenceSummary, isNotEmpty);
      expect(zh.paragraphSummary, isNotEmpty);
      expect(zh.pageSummary, isNotEmpty);
      expect(zh.expandedSummary, isNotEmpty);
      expect(zh.supabaseSettings, isNotEmpty);
      expect(zh.supabaseNotEnabled, isNotEmpty);
      expect(zh.supabaseNotEnabledDescription, isNotEmpty);
      expect(zh.authDisabledInBuild, isNotEmpty);
      expect(zh.fetchFromSupabase, isNotEmpty);
      expect(zh.fetchFromSupabaseDescription, isNotEmpty);
      expect(zh.confirmFetch, isNotEmpty);
      expect(zh.confirmFetchDescription, isNotEmpty);
      expect(zh.fetch, isNotEmpty);
      expect(zh.downloadChapters, isNotEmpty);
      expect(zh.modeSupabase, isNotEmpty);
      expect(zh.modeMockData, isNotEmpty);
      expect(zh.reachedLastChapter, isNotEmpty);
      expect(zh.supabaseProgressNotSaved, isNotEmpty);
      expect(zh.autoplayBlocked, isNotEmpty);
      expect(zh.autoplayBlockedInline, isNotEmpty);
      expect(zh.enterFloatIndexHint, isNotEmpty);
      expect(zh.indexUnchanged, isNotEmpty);
      expect(zh.roundingBefore, isNotEmpty);
      expect(zh.roundingAfter, isNotEmpty);
      expect(zh.separateDarkPalette, isNotEmpty);
      expect(zh.lightPalette, isNotEmpty);
      expect(zh.darkPalette, isNotEmpty);
      expect(zh.novelsAndProgress, isNotEmpty);
      expect(zh.unknownNovel, isNotEmpty);
      expect(zh.unknownChapter, isNotEmpty);
      expect(zh.saveCredentialsForBiometric, isNotEmpty);
      expect(zh.saveCredentialsForBiometricDescription, isNotEmpty);
      expect(zh.biometricTokensExpired, isNotEmpty);
      expect(zh.biometricNoTokens, isNotEmpty);
      expect(zh.biometricTokenError, isNotEmpty);
      expect(zh.biometricTechnicalError, isNotEmpty);
    });
  });
}
