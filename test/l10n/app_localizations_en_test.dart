import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  group('AppLocalizationsEn', () {
    late AppLocalizationsEn l10n;

    setUp(() {
      l10n = AppLocalizationsEn();
    });

    test('returns correct locale', () {
      expect(l10n.localeName, 'en');
    });

    test('returns non-empty strings for all getters', () {
      expect(l10n.helloWorld, isNotEmpty);
      expect(l10n.settings, isNotEmpty);
      expect(l10n.appTitle, isNotEmpty);
      expect(l10n.about, isNotEmpty);
      expect(l10n.aboutDescription, isNotEmpty);
      expect(l10n.aboutIntro, isNotEmpty);
      expect(l10n.aboutSecurity, isNotEmpty);
      expect(l10n.aboutCoach, isNotEmpty);
      expect(l10n.aboutFeatureCreate, isNotEmpty);
      expect(l10n.aboutFeatureTemplates, isNotEmpty);
      expect(l10n.aboutFeatureTracking, isNotEmpty);
      expect(l10n.aboutFeatureCoach, isNotEmpty);
      expect(l10n.aboutFeaturePrompts, isNotEmpty);
      expect(l10n.aboutUsage, isNotEmpty);
      expect(l10n.aboutUsageList, isNotEmpty);
      expect(l10n.version, isNotEmpty);
      expect(l10n.appLanguage, isNotEmpty);
      expect(l10n.english, isNotEmpty);
      expect(l10n.chinese, isNotEmpty);
      expect(l10n.supabaseIntegrationInitialized, isNotEmpty);
      expect(l10n.configureEnvironment, isNotEmpty);
      expect(l10n.guest, isNotEmpty);
      expect(l10n.notSignedIn, isNotEmpty);
      expect(l10n.signIn, isNotEmpty);
      expect(l10n.continueLabel, isNotEmpty);
    });

    test('signedInAs returns formatted string', () {
      expect(
        l10n.signedInAs('test@example.com'),
        'Signed in as test@example.com',
      );
    });

    test('specific values match expected English text', () {
      expect(l10n.appTitle, 'Writer');
      expect(l10n.settings, 'Settings');
      expect(l10n.helloWorld, 'Hello World!');
    });

    test('exercises additional getters for coverage', () {
      expect(l10n.newChapter, isNotEmpty);
      expect(l10n.back, isNotEmpty);
      expect(l10n.reload, isNotEmpty);
      expect(l10n.signInToSync, isNotEmpty);
      expect(l10n.currentProgress, isNotEmpty);
      expect(l10n.loadingProgress, isNotEmpty);
      expect(l10n.recentlyRead, isNotEmpty);
      expect(l10n.noSupabase, isNotEmpty);
      expect(l10n.errorLoadingProgress, isNotEmpty);
      expect(l10n.noProgress, isNotEmpty);
      expect(l10n.errorLoadingNovels, isNotEmpty);
      expect(l10n.loadingNovels, isNotEmpty);
      expect(l10n.titleLabel, isNotEmpty);
      expect(l10n.authorLabel, isNotEmpty);
      expect(l10n.noNovelsFound, isNotEmpty);
      expect(l10n.myNovels, isNotEmpty);
      expect(l10n.createNovel, isNotEmpty);
      expect(l10n.create, isNotEmpty);
      expect(l10n.errorLoadingChapters, isNotEmpty);
      expect(l10n.loadingChapter, isNotEmpty);
      expect(l10n.notStarted, isNotEmpty);
      expect(l10n.unknownNovel, isNotEmpty);
      expect(l10n.unknownChapter, isNotEmpty);
      expect(l10n.chapter, isNotEmpty);
      expect(l10n.novel, isNotEmpty);
      expect(l10n.chapterTitle, isNotEmpty);
      expect(l10n.scrollOffset, isNotEmpty);
      expect(l10n.ttsIndex, isNotEmpty);
      expect(l10n.speechRate, isNotEmpty);
      expect(l10n.volume, isNotEmpty);
      expect(l10n.defaultTTSVoice, isNotEmpty);
      expect(l10n.defaultVoiceUpdated, isNotEmpty);
      expect(l10n.defaultLanguageSet, isNotEmpty);
      expect(l10n.searchByTitle, isNotEmpty);
      expect(l10n.chooseLanguage, isNotEmpty);
    });

    test('exercises auth and settings getters for coverage', () {
      expect(l10n.email, isNotEmpty);
      expect(l10n.password, isNotEmpty);
      expect(l10n.signInWithGoogle, isNotEmpty);
      expect(l10n.signInWithApple, isNotEmpty);
      expect(l10n.signOut, isNotEmpty);
      expect(l10n.signedOut, isNotEmpty);
      expect(l10n.appSettings, isNotEmpty);
      expect(l10n.supabaseSettings, isNotEmpty);
      expect(l10n.supabaseNotEnabled, isNotEmpty);
      expect(l10n.authDisabledInBuild, isNotEmpty);
      expect(l10n.fetchFromSupabase, isNotEmpty);
      expect(l10n.confirmFetch, isNotEmpty);
      expect(l10n.fetch, isNotEmpty);
      expect(l10n.downloadChapters, isNotEmpty);
      expect(l10n.ttsSettings, isNotEmpty);
      expect(l10n.enableTTS, isNotEmpty);
      expect(l10n.pitch, isNotEmpty);
      expect(l10n.signInWithBiometrics, isNotEmpty);
      expect(l10n.enableBiometricLogin, isNotEmpty);
      expect(l10n.biometricAuthFailed, isNotEmpty);
      expect(l10n.biometricTokensExpired, isNotEmpty);
      expect(l10n.biometricNoTokens, isNotEmpty);
      expect(l10n.biometricTokenError, isNotEmpty);
      expect(l10n.ttsVoice, isNotEmpty);
      expect(l10n.ttsLanguage, isNotEmpty);
      expect(l10n.ttsSpeechRate, isNotEmpty);
      expect(l10n.ttsSpeechVolume, isNotEmpty);
      expect(l10n.ttsSpeechPitch, isNotEmpty);
      expect(l10n.novelsAndProgress, isNotEmpty);
      expect(l10n.noChaptersFound, isNotEmpty);
      expect(l10n.stopTTS, isNotEmpty);
      expect(l10n.speak, isNotEmpty);
      expect(l10n.progressSaved, isNotEmpty);
      expect(l10n.errorSavingProgress, isNotEmpty);
      expect(l10n.autoplayBlocked, isNotEmpty);
      expect(l10n.reachedLastChapter, isNotEmpty);
      expect(l10n.themeMode, isNotEmpty);
      expect(l10n.system, isNotEmpty);
      expect(l10n.light, isNotEmpty);
      expect(l10n.dark, isNotEmpty);
      expect(l10n.colorTheme, isNotEmpty);
      expect(l10n.themeDefault, isNotEmpty);
      expect(l10n.themeHighContrast, isNotEmpty);
      expect(l10n.themeNord, isNotEmpty);
      expect(l10n.separateDarkPalette, isNotEmpty);
    });

    test('exercises library and reader getters for coverage', () {
      expect(l10n.lightPalette, isNotEmpty);
      expect(l10n.darkPalette, isNotEmpty);
      expect(l10n.typographyPreset, isNotEmpty);
      expect(l10n.typographyComfortable, isNotEmpty);
      expect(l10n.typographyCompact, isNotEmpty);
      expect(l10n.typographySerifLike, isNotEmpty);
      expect(l10n.fontPack, isNotEmpty);
      expect(l10n.separateTypographyPresets, isNotEmpty);
      expect(l10n.typographyLight, isNotEmpty);
      expect(l10n.typographyDark, isNotEmpty);
      expect(l10n.readerBundles, isNotEmpty);
      expect(l10n.tokenUsage, isNotEmpty);
      expect(l10n.discover, isNotEmpty);
      expect(l10n.profile, isNotEmpty);
      expect(l10n.libraryTitle, isNotEmpty);
      expect(l10n.undo, isNotEmpty);
      expect(l10n.allFilter, isNotEmpty);
      expect(l10n.readingFilter, isNotEmpty);
      expect(l10n.completedFilter, isNotEmpty);
      expect(l10n.downloadedFilter, isNotEmpty);
      expect(l10n.searchNovels, isNotEmpty);
      expect(l10n.listView, isNotEmpty);
      expect(l10n.gridView, isNotEmpty);
      expect(l10n.userManagement, isNotEmpty);
      expect(l10n.totalThisMonth, isNotEmpty);
      expect(l10n.inputTokens, isNotEmpty);
      expect(l10n.outputTokens, isNotEmpty);
      expect(l10n.requests, isNotEmpty);
      expect(l10n.viewHistory, isNotEmpty);
      expect(l10n.noUsageThisMonth, isNotEmpty);
      expect(l10n.startUsingAiFeatures, isNotEmpty);
      expect(l10n.errorLoadingUsage, isNotEmpty);
      expect(l10n.refresh, isNotEmpty);
      expect(l10n.total, isNotEmpty);
      expect(l10n.noUsageHistory, isNotEmpty);
      expect(l10n.bundleNordCalm, isNotEmpty);
      expect(l10n.bundleSolarizedFocus, isNotEmpty);
      expect(l10n.bundleHighContrastReadability, isNotEmpty);
      expect(l10n.customFontFamily, isNotEmpty);
      expect(l10n.commonFonts, isNotEmpty);
      expect(l10n.readerFontSize, isNotEmpty);
      expect(l10n.textScale, isNotEmpty);
      expect(l10n.readerBackgroundDepth, isNotEmpty);
      expect(l10n.depthLow, isNotEmpty);
      expect(l10n.depthMedium, isNotEmpty);
      expect(l10n.depthHigh, isNotEmpty);
      expect(l10n.select, isNotEmpty);
      expect(l10n.clear, isNotEmpty);
      expect(l10n.adminMode, isNotEmpty);
      expect(l10n.reduceMotion, isNotEmpty);
      expect(l10n.reduceMotionDescription, isNotEmpty);
      expect(l10n.gesturesEnabled, isNotEmpty);
      expect(l10n.gesturesEnabledDescription, isNotEmpty);
      expect(l10n.readerSwipeSensitivity, isNotEmpty);
      expect(l10n.readerSwipeSensitivityDescription, isNotEmpty);
      expect(l10n.removedFromLibrary, isNotEmpty);
      expect(l10n.confirmDelete, isNotEmpty);
      expect(l10n.reachedFirstChapter, isNotEmpty);
      expect(l10n.previousChapter, isNotEmpty);
      expect(l10n.nextChapter, isNotEmpty);
      expect(l10n.performanceSettings, isNotEmpty);
      expect(l10n.prefetchNextChapter, isNotEmpty);
      expect(l10n.prefetchNextChapterDescription, isNotEmpty);
      expect(l10n.clearOfflineCache, isNotEmpty);
      expect(l10n.offlineCacheCleared, isNotEmpty);
      expect(l10n.edit, isNotEmpty);
      expect(l10n.exitEdit, isNotEmpty);
      expect(l10n.enterEditMode, isNotEmpty);
      expect(l10n.exitEditMode, isNotEmpty);
      expect(l10n.chapterContent, isNotEmpty);
      expect(l10n.saveAndExit, isNotEmpty);
      expect(l10n.descriptionLabel, isNotEmpty);
      expect(l10n.coverUrlLabel, isNotEmpty);
      expect(l10n.invalidCoverUrl, isNotEmpty);
      expect(l10n.navigation, isNotEmpty);
    });
  });
}
