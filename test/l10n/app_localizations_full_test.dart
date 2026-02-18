import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_de.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/l10n/app_localizations_es.dart';
import 'package:writer/l10n/app_localizations_fr.dart';
import 'package:writer/l10n/app_localizations_it.dart';
import 'package:writer/l10n/app_localizations_ja.dart';
import 'package:writer/l10n/app_localizations_ru.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  group('AppLocalizationsEn - Essential Getters', () {
    late AppLocalizationsEn en;

    setUp(() {
      en = AppLocalizationsEn();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(en.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(en.back, isNotEmpty));
    test(
      'helloWorld returns non-empty value',
      () => expect(en.helloWorld, isNotEmpty),
    );
    test(
      'settings returns non-empty value',
      () => expect(en.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(en.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(en.about, isNotEmpty));
    test(
      'aboutDescription returns non-empty value',
      () => expect(en.aboutDescription, isNotEmpty),
    );
    test(
      'aboutIntro returns non-empty value',
      () => expect(en.aboutIntro, isNotEmpty),
    );
    test(
      'aboutSecurity returns non-empty value',
      () => expect(en.aboutSecurity, isNotEmpty),
    );
    test(
      'aboutCoach returns non-empty value',
      () => expect(en.aboutCoach, isNotEmpty),
    );
    test(
      'aboutFeatureCreate returns non-empty value',
      () => expect(en.aboutFeatureCreate, isNotEmpty),
    );
    test(
      'aboutFeatureTemplates returns non-empty value',
      () => expect(en.aboutFeatureTemplates, isNotEmpty),
    );
    test(
      'aboutFeatureTracking returns non-empty value',
      () => expect(en.aboutFeatureTracking, isNotEmpty),
    );
    test(
      'aboutFeatureCoach returns non-empty value',
      () => expect(en.aboutFeatureCoach, isNotEmpty),
    );
    test(
      'aboutFeaturePrompts returns non-empty value',
      () => expect(en.aboutFeaturePrompts, isNotEmpty),
    );
    test(
      'aboutUsage returns non-empty value',
      () => expect(en.aboutUsage, isNotEmpty),
    );
    test(
      'aboutUsageList returns non-empty value',
      () => expect(en.aboutUsageList, isNotEmpty),
    );
    test(
      'version returns non-empty value',
      () => expect(en.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(en.appLanguage, isNotEmpty),
    );
    test(
      'english returns non-empty value',
      () => expect(en.english, isNotEmpty),
    );
    test(
      'chinese returns non-empty value',
      () => expect(en.chinese, isNotEmpty),
    );
    test(
      'supabaseIntegrationInitialized returns non-empty value',
      () => expect(en.supabaseIntegrationInitialized, isNotEmpty),
    );
    test(
      'configureEnvironment returns non-empty value',
      () => expect(en.configureEnvironment, isNotEmpty),
    );
    test('guest returns non-empty value', () => expect(en.guest, isNotEmpty));
    test(
      'notSignedIn returns non-empty value',
      () => expect(en.notSignedIn, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(en.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(en.continueLabel, isNotEmpty),
    );
    test('reload returns non-empty value', () => expect(en.reload, isNotEmpty));
    test(
      'signInToSync returns non-empty value',
      () => expect(en.signInToSync, isNotEmpty),
    );
    test(
      'currentProgress returns non-empty value',
      () => expect(en.currentProgress, isNotEmpty),
    );
    test(
      'loadingProgress returns non-empty value',
      () => expect(en.loadingProgress, isNotEmpty),
    );
    test(
      'recentlyRead returns non-empty value',
      () => expect(en.recentlyRead, isNotEmpty),
    );
    test(
      'noSupabase returns non-empty value',
      () => expect(en.noSupabase, isNotEmpty),
    );
    test(
      'errorLoadingProgress returns non-empty value',
      () => expect(en.errorLoadingProgress, isNotEmpty),
    );
    test(
      'noProgress returns non-empty value',
      () => expect(en.noProgress, isNotEmpty),
    );
    test(
      'errorLoadingNovels returns non-empty value',
      () => expect(en.errorLoadingNovels, isNotEmpty),
    );
    test(
      'loadingNovels returns non-empty value',
      () => expect(en.loadingNovels, isNotEmpty),
    );
    test(
      'titleLabel returns non-empty value',
      () => expect(en.titleLabel, isNotEmpty),
    );
    test(
      'authorLabel returns non-empty value',
      () => expect(en.authorLabel, isNotEmpty),
    );
    test(
      'noNovelsFound returns non-empty value',
      () => expect(en.noNovelsFound, isNotEmpty),
    );
    test(
      'myNovels returns non-empty value',
      () => expect(en.myNovels, isNotEmpty),
    );
    test(
      'createNovel returns non-empty value',
      () => expect(en.createNovel, isNotEmpty),
    );
    test('create returns non-empty value', () => expect(en.create, isNotEmpty));
    test(
      'errorLoadingChapters returns non-empty value',
      () => expect(en.errorLoadingChapters, isNotEmpty),
    );
    test(
      'loadingChapter returns non-empty value',
      () => expect(en.loadingChapter, isNotEmpty),
    );
    test(
      'notStarted returns non-empty value',
      () => expect(en.notStarted, isNotEmpty),
    );
    test(
      'unknownNovel returns non-empty value',
      () => expect(en.unknownNovel, isNotEmpty),
    );
    test(
      'unknownChapter returns non-empty value',
      () => expect(en.unknownChapter, isNotEmpty),
    );
    test(
      'chapter returns non-empty value',
      () => expect(en.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(en.novel, isNotEmpty));
    test(
      'chapterTitle returns non-empty value',
      () => expect(en.chapterTitle, isNotEmpty),
    );
    test(
      'scrollOffset returns non-empty value',
      () => expect(en.scrollOffset, isNotEmpty),
    );
    test(
      'ttsIndex returns non-empty value',
      () => expect(en.ttsIndex, isNotEmpty),
    );
    test(
      'speechRate returns non-empty value',
      () => expect(en.speechRate, isNotEmpty),
    );
    test('volume returns non-empty value', () => expect(en.volume, isNotEmpty));
    test(
      'defaultTTSVoice returns non-empty value',
      () => expect(en.defaultTTSVoice, isNotEmpty),
    );
    test(
      'defaultVoiceUpdated returns non-empty value',
      () => expect(en.defaultVoiceUpdated, isNotEmpty),
    );
    test(
      'defaultLanguageSet returns non-empty value',
      () => expect(en.defaultLanguageSet, isNotEmpty),
    );
    test(
      'searchByTitle returns non-empty value',
      () => expect(en.searchByTitle, isNotEmpty),
    );
    test(
      'chooseLanguage returns non-empty value',
      () => expect(en.chooseLanguage, isNotEmpty),
    );
    test('email returns non-empty value', () => expect(en.email, isNotEmpty));
    test(
      'password returns non-empty value',
      () => expect(en.password, isNotEmpty),
    );
    test(
      'signInWithGoogle returns non-empty value',
      () => expect(en.signInWithGoogle, isNotEmpty),
    );
    test(
      'signInWithApple returns non-empty value',
      () => expect(en.signInWithApple, isNotEmpty),
    );
    test(
      'testVoice returns non-empty value',
      () => expect(en.testVoice, isNotEmpty),
    );
    test(
      'reloadVoices returns non-empty value',
      () => expect(en.reloadVoices, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(en.signOut, isNotEmpty),
    );
    test(
      'signedOut returns non-empty value',
      () => expect(en.signedOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(en.appSettings, isNotEmpty),
    );
    test(
      'supabaseSettings returns non-empty value',
      () => expect(en.supabaseSettings, isNotEmpty),
    );
    test(
      'supabaseNotEnabled returns non-empty value',
      () => expect(en.supabaseNotEnabled, isNotEmpty),
    );
    test(
      'supabaseNotEnabledDescription returns non-empty value',
      () => expect(en.supabaseNotEnabledDescription, isNotEmpty),
    );
    test(
      'authDisabledInBuild returns non-empty value',
      () => expect(en.authDisabledInBuild, isNotEmpty),
    );
    test(
      'fetchFromSupabase returns non-empty value',
      () => expect(en.fetchFromSupabase, isNotEmpty),
    );
    test(
      'fetchFromSupabaseDescription returns non-empty value',
      () => expect(en.fetchFromSupabaseDescription, isNotEmpty),
    );
    test(
      'confirmFetch returns non-empty value',
      () => expect(en.confirmFetch, isNotEmpty),
    );
    test(
      'confirmFetchDescription returns non-empty value',
      () => expect(en.confirmFetchDescription, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(en.cancel, isNotEmpty));
    test('fetch returns non-empty value', () => expect(en.fetch, isNotEmpty));
    test(
      'downloadChapters returns non-empty value',
      () => expect(en.downloadChapters, isNotEmpty),
    );
    test(
      'modeSupabase returns non-empty value',
      () => expect(en.modeSupabase, isNotEmpty),
    );
    test(
      'modeMockData returns non-empty value',
      () => expect(en.modeMockData, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(en.error, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(en.ttsSettings, isNotEmpty),
    );
    test(
      'enableTTS returns non-empty value',
      () => expect(en.enableTTS, isNotEmpty),
    );
    test(
      'sentenceSummary returns non-empty value',
      () => expect(en.sentenceSummary, isNotEmpty),
    );
    test(
      'paragraphSummary returns non-empty value',
      () => expect(en.paragraphSummary, isNotEmpty),
    );
    test(
      'pageSummary returns non-empty value',
      () => expect(en.pageSummary, isNotEmpty),
    );
    test(
      'expandedSummary returns non-empty value',
      () => expect(en.expandedSummary, isNotEmpty),
    );
    test('pitch returns non-empty value', () => expect(en.pitch, isNotEmpty));
    test(
      'signInWithBiometrics returns non-empty value',
      () => expect(en.signInWithBiometrics, isNotEmpty),
    );
    test(
      'enableBiometricLogin returns non-empty value',
      () => expect(en.enableBiometricLogin, isNotEmpty),
    );
    test(
      'enableBiometricLoginDescription returns non-empty value',
      () => expect(en.enableBiometricLoginDescription, isNotEmpty),
    );
    test(
      'biometricAuthFailed returns non-empty value',
      () => expect(en.biometricAuthFailed, isNotEmpty),
    );
    test(
      'saveCredentialsForBiometric returns non-empty value',
      () => expect(en.saveCredentialsForBiometric, isNotEmpty),
    );
    test(
      'saveCredentialsForBiometricDescription returns non-empty value',
      () => expect(en.saveCredentialsForBiometricDescription, isNotEmpty),
    );
    test(
      'biometricTokensExpired returns non-empty value',
      () => expect(en.biometricTokensExpired, isNotEmpty),
    );
    test(
      'biometricNoTokens returns non-empty value',
      () => expect(en.biometricNoTokens, isNotEmpty),
    );
    test(
      'biometricTokenError returns non-empty value',
      () => expect(en.biometricTokenError, isNotEmpty),
    );
    test(
      'biometricTechnicalError returns non-empty value',
      () => expect(en.biometricTechnicalError, isNotEmpty),
    );
    test(
      'signedInAs formats correctly',
      () => expect(
        en.signedInAs('test@example.com'),
        'Signed in as test@example.com',
      ),
    );
  });

  group('AppLocalizationsZh - Essential Getters', () {
    late AppLocalizationsZh zh;

    setUp(() {
      zh = AppLocalizationsZh();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(zh.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(zh.back, isNotEmpty));
    test(
      'helloWorld returns non-empty value',
      () => expect(zh.helloWorld, isNotEmpty),
    );
    test(
      'settings returns non-empty value',
      () => expect(zh.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(zh.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(zh.about, isNotEmpty));
    test(
      'aboutDescription returns non-empty value',
      () => expect(zh.aboutDescription, isNotEmpty),
    );
    test(
      'aboutIntro returns non-empty value',
      () => expect(zh.aboutIntro, isNotEmpty),
    );
    test(
      'aboutSecurity returns non-empty value',
      () => expect(zh.aboutSecurity, isNotEmpty),
    );
    test(
      'aboutCoach returns non-empty value',
      () => expect(zh.aboutCoach, isNotEmpty),
    );
    test(
      'aboutFeatureCreate returns non-empty value',
      () => expect(zh.aboutFeatureCreate, isNotEmpty),
    );
    test(
      'aboutFeatureTemplates returns non-empty value',
      () => expect(zh.aboutFeatureTemplates, isNotEmpty),
    );
    test(
      'aboutFeatureTracking returns non-empty value',
      () => expect(zh.aboutFeatureTracking, isNotEmpty),
    );
    test(
      'aboutFeatureCoach returns non-empty value',
      () => expect(zh.aboutFeatureCoach, isNotEmpty),
    );
    test(
      'aboutFeaturePrompts returns non-empty value',
      () => expect(zh.aboutFeaturePrompts, isNotEmpty),
    );
    test(
      'aboutUsage returns non-empty value',
      () => expect(zh.aboutUsage, isNotEmpty),
    );
    test(
      'aboutUsageList returns non-empty value',
      () => expect(zh.aboutUsageList, isNotEmpty),
    );
    test(
      'version returns non-empty value',
      () => expect(zh.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(zh.appLanguage, isNotEmpty),
    );
    test(
      'english returns non-empty value',
      () => expect(zh.english, isNotEmpty),
    );
    test(
      'chinese returns non-empty value',
      () => expect(zh.chinese, isNotEmpty),
    );
    test(
      'supabaseIntegrationInitialized returns non-empty value',
      () => expect(zh.supabaseIntegrationInitialized, isNotEmpty),
    );
    test(
      'configureEnvironment returns non-empty value',
      () => expect(zh.configureEnvironment, isNotEmpty),
    );
    test('guest returns non-empty value', () => expect(zh.guest, isNotEmpty));
    test(
      'notSignedIn returns non-empty value',
      () => expect(zh.notSignedIn, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(zh.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(zh.continueLabel, isNotEmpty),
    );
    test('reload returns non-empty value', () => expect(zh.reload, isNotEmpty));
    test(
      'signInToSync returns non-empty value',
      () => expect(zh.signInToSync, isNotEmpty),
    );
    test(
      'currentProgress returns non-empty value',
      () => expect(zh.currentProgress, isNotEmpty),
    );
    test(
      'loadingProgress returns non-empty value',
      () => expect(zh.loadingProgress, isNotEmpty),
    );
    test(
      'recentlyRead returns non-empty value',
      () => expect(zh.recentlyRead, isNotEmpty),
    );
    test(
      'noSupabase returns non-empty value',
      () => expect(zh.noSupabase, isNotEmpty),
    );
    test(
      'errorLoadingProgress returns non-empty value',
      () => expect(zh.errorLoadingProgress, isNotEmpty),
    );
    test(
      'noProgress returns non-empty value',
      () => expect(zh.noProgress, isNotEmpty),
    );
    test(
      'errorLoadingNovels returns non-empty value',
      () => expect(zh.errorLoadingNovels, isNotEmpty),
    );
    test(
      'loadingNovels returns non-empty value',
      () => expect(zh.loadingNovels, isNotEmpty),
    );
    test(
      'titleLabel returns non-empty value',
      () => expect(zh.titleLabel, isNotEmpty),
    );
    test(
      'authorLabel returns non-empty value',
      () => expect(zh.authorLabel, isNotEmpty),
    );
    test(
      'noNovelsFound returns non-empty value',
      () => expect(zh.noNovelsFound, isNotEmpty),
    );
    test(
      'myNovels returns non-empty value',
      () => expect(zh.myNovels, isNotEmpty),
    );
    test(
      'createNovel returns non-empty value',
      () => expect(zh.createNovel, isNotEmpty),
    );
    test('create returns non-empty value', () => expect(zh.create, isNotEmpty));
    test(
      'errorLoadingChapters returns non-empty value',
      () => expect(zh.errorLoadingChapters, isNotEmpty),
    );
    test(
      'loadingChapter returns non-empty value',
      () => expect(zh.loadingChapter, isNotEmpty),
    );
    test(
      'notStarted returns non-empty value',
      () => expect(zh.notStarted, isNotEmpty),
    );
    test(
      'unknownNovel returns non-empty value',
      () => expect(zh.unknownNovel, isNotEmpty),
    );
    test(
      'unknownChapter returns non-empty value',
      () => expect(zh.unknownChapter, isNotEmpty),
    );
    test(
      'chapter returns non-empty value',
      () => expect(zh.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(zh.novel, isNotEmpty));
    test(
      'chapterTitle returns non-empty value',
      () => expect(zh.chapterTitle, isNotEmpty),
    );
    test(
      'scrollOffset returns non-empty value',
      () => expect(zh.scrollOffset, isNotEmpty),
    );
    test(
      'ttsIndex returns non-empty value',
      () => expect(zh.ttsIndex, isNotEmpty),
    );
    test(
      'speechRate returns non-empty value',
      () => expect(zh.speechRate, isNotEmpty),
    );
    test('volume returns non-empty value', () => expect(zh.volume, isNotEmpty));
    test(
      'defaultTTSVoice returns non-empty value',
      () => expect(zh.defaultTTSVoice, isNotEmpty),
    );
    test(
      'defaultVoiceUpdated returns non-empty value',
      () => expect(zh.defaultVoiceUpdated, isNotEmpty),
    );
    test(
      'defaultLanguageSet returns non-empty value',
      () => expect(zh.defaultLanguageSet, isNotEmpty),
    );
    test(
      'searchByTitle returns non-empty value',
      () => expect(zh.searchByTitle, isNotEmpty),
    );
    test(
      'chooseLanguage returns non-empty value',
      () => expect(zh.chooseLanguage, isNotEmpty),
    );
    test('email returns non-empty value', () => expect(zh.email, isNotEmpty));
    test(
      'password returns non-empty value',
      () => expect(zh.password, isNotEmpty),
    );
    test(
      'signInWithGoogle returns non-empty value',
      () => expect(zh.signInWithGoogle, isNotEmpty),
    );
    test(
      'signInWithApple returns non-empty value',
      () => expect(zh.signInWithApple, isNotEmpty),
    );
    test(
      'testVoice returns non-empty value',
      () => expect(zh.testVoice, isNotEmpty),
    );
    test(
      'reloadVoices returns non-empty value',
      () => expect(zh.reloadVoices, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(zh.signOut, isNotEmpty),
    );
    test(
      'signedOut returns non-empty value',
      () => expect(zh.signedOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(zh.appSettings, isNotEmpty),
    );
    test(
      'supabaseSettings returns non-empty value',
      () => expect(zh.supabaseSettings, isNotEmpty),
    );
    test(
      'supabaseNotEnabled returns non-empty value',
      () => expect(zh.supabaseNotEnabled, isNotEmpty),
    );
    test(
      'supabaseNotEnabledDescription returns non-empty value',
      () => expect(zh.supabaseNotEnabledDescription, isNotEmpty),
    );
    test(
      'authDisabledInBuild returns non-empty value',
      () => expect(zh.authDisabledInBuild, isNotEmpty),
    );
    test(
      'fetchFromSupabase returns non-empty value',
      () => expect(zh.fetchFromSupabase, isNotEmpty),
    );
    test(
      'fetchFromSupabaseDescription returns non-empty value',
      () => expect(zh.fetchFromSupabaseDescription, isNotEmpty),
    );
    test(
      'confirmFetch returns non-empty value',
      () => expect(zh.confirmFetch, isNotEmpty),
    );
    test(
      'confirmFetchDescription returns non-empty value',
      () => expect(zh.confirmFetchDescription, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(zh.cancel, isNotEmpty));
    test('fetch returns non-empty value', () => expect(zh.fetch, isNotEmpty));
    test(
      'downloadChapters returns non-empty value',
      () => expect(zh.downloadChapters, isNotEmpty),
    );
    test(
      'modeSupabase returns non-empty value',
      () => expect(zh.modeSupabase, isNotEmpty),
    );
    test(
      'modeMockData returns non-empty value',
      () => expect(zh.modeMockData, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(zh.error, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(zh.ttsSettings, isNotEmpty),
    );
    test(
      'enableTTS returns non-empty value',
      () => expect(zh.enableTTS, isNotEmpty),
    );
    test(
      'sentenceSummary returns non-empty value',
      () => expect(zh.sentenceSummary, isNotEmpty),
    );
    test(
      'paragraphSummary returns non-empty value',
      () => expect(zh.paragraphSummary, isNotEmpty),
    );
    test(
      'pageSummary returns non-empty value',
      () => expect(zh.pageSummary, isNotEmpty),
    );
    test(
      'expandedSummary returns non-empty value',
      () => expect(zh.expandedSummary, isNotEmpty),
    );
    test('pitch returns non-empty value', () => expect(zh.pitch, isNotEmpty));
    test(
      'signInWithBiometrics returns non-empty value',
      () => expect(zh.signInWithBiometrics, isNotEmpty),
    );
    test(
      'enableBiometricLogin returns non-empty value',
      () => expect(zh.enableBiometricLogin, isNotEmpty),
    );
    test(
      'enableBiometricLoginDescription returns non-empty value',
      () => expect(zh.enableBiometricLoginDescription, isNotEmpty),
    );
    test(
      'biometricAuthFailed returns non-empty value',
      () => expect(zh.biometricAuthFailed, isNotEmpty),
    );
    test(
      'saveCredentialsForBiometric returns non-empty value',
      () => expect(zh.saveCredentialsForBiometric, isNotEmpty),
    );
    test(
      'saveCredentialsForBiometricDescription returns non-empty value',
      () => expect(zh.saveCredentialsForBiometricDescription, isNotEmpty),
    );
    test(
      'biometricTokensExpired returns non-empty value',
      () => expect(zh.biometricTokensExpired, isNotEmpty),
    );
    test(
      'biometricNoTokens returns non-empty value',
      () => expect(zh.biometricNoTokens, isNotEmpty),
    );
    test(
      'biometricTokenError returns non-empty value',
      () => expect(zh.biometricTokenError, isNotEmpty),
    );
    test(
      'biometricTechnicalError returns non-empty value',
      () => expect(zh.biometricTechnicalError, isNotEmpty),
    );
    test(
      'signedInAs formats correctly',
      () => expect(
        zh.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsDe - Essential Getters', () {
    late AppLocalizationsDe de;

    setUp(() {
      de = AppLocalizationsDe();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(de.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(de.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(de.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(de.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(de.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(de.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(de.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(de.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(de.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(de.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(de.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(de.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(de.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(de.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(de.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(de.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(de.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        de.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsEs - Essential Getters', () {
    late AppLocalizationsEs es;

    setUp(() {
      es = AppLocalizationsEs();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(es.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(es.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(es.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(es.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(es.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(es.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(es.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(es.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(es.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(es.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(es.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(es.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(es.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(es.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(es.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(es.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(es.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        es.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsFr - Essential Getters', () {
    late AppLocalizationsFr fr;

    setUp(() {
      fr = AppLocalizationsFr();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(fr.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(fr.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(fr.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(fr.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(fr.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(fr.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(fr.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(fr.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(fr.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(fr.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(fr.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(fr.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(fr.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(fr.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(fr.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(fr.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(fr.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        fr.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsIt - Essential Getters', () {
    late AppLocalizationsIt it;

    setUp(() {
      it = AppLocalizationsIt();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(it.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(it.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(it.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(it.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(it.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(it.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(it.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(it.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(it.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(it.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(it.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(it.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(it.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(it.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(it.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(it.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(it.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        it.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsJa - Essential Getters', () {
    late AppLocalizationsJa ja;

    setUp(() {
      ja = AppLocalizationsJa();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(ja.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(ja.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(ja.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(ja.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(ja.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(ja.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(ja.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(ja.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(ja.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(ja.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(ja.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(ja.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(ja.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(ja.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(ja.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(ja.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(ja.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        ja.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });

  group('AppLocalizationsRu - Essential Getters', () {
    late AppLocalizationsRu ru;

    setUp(() {
      ru = AppLocalizationsRu();
    });

    test(
      'newChapter returns non-empty value',
      () => expect(ru.newChapter, isNotEmpty),
    );
    test('back returns non-empty value', () => expect(ru.back, isNotEmpty));
    test(
      'settings returns non-empty value',
      () => expect(ru.settings, isNotEmpty),
    );
    test(
      'appTitle returns non-empty value',
      () => expect(ru.appTitle, isNotEmpty),
    );
    test('about returns non-empty value', () => expect(ru.about, isNotEmpty));
    test(
      'version returns non-empty value',
      () => expect(ru.version, isNotEmpty),
    );
    test(
      'appLanguage returns non-empty value',
      () => expect(ru.appLanguage, isNotEmpty),
    );
    test('signIn returns non-empty value', () => expect(ru.signIn, isNotEmpty));
    test(
      'continueLabel returns non-empty value',
      () => expect(ru.continueLabel, isNotEmpty),
    );
    test(
      'signOut returns non-empty value',
      () => expect(ru.signOut, isNotEmpty),
    );
    test(
      'appSettings returns non-empty value',
      () => expect(ru.appSettings, isNotEmpty),
    );
    test('cancel returns non-empty value', () => expect(ru.cancel, isNotEmpty));
    test('create returns non-empty value', () => expect(ru.create, isNotEmpty));
    test(
      'chapter returns non-empty value',
      () => expect(ru.chapter, isNotEmpty),
    );
    test('novel returns non-empty value', () => expect(ru.novel, isNotEmpty));
    test(
      'ttsSettings returns non-empty value',
      () => expect(ru.ttsSettings, isNotEmpty),
    );
    test('error returns non-empty value', () => expect(ru.error, isNotEmpty));
    test(
      'signedInAs formats correctly',
      () => expect(
        ru.signedInAs('test@example.com'),
        contains('test@example.com'),
      ),
    );
  });
}
