import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - Final 85% Boost', () {
    test('All basic strings final check', () {
      expect(zh.helloWorld, isNotEmpty);
      expect(zh.appTitle, isNotEmpty);
      expect(zh.newChapter, isNotEmpty);
      expect(zh.back, isNotEmpty);
      expect(zh.settings, isNotEmpty);
      expect(zhTW.helloWorld, isNotEmpty);
      expect(zhTW.appTitle, isNotEmpty);
      expect(zhTW.back, isNotEmpty);
    });

    test('All About section final check', () {
      expect(zh.about, isNotEmpty);
      expect(zh.aboutDescription, isNotEmpty);
      expect(zh.aboutIntro, isNotEmpty);
      expect(zh.aboutSecurity, isNotEmpty);
      expect(zh.aboutCoach, isNotEmpty);
      expect(zh.aboutFeatureCreate, isNotEmpty);
      expect(zh.aboutFeatureTemplates, isNotEmpty);
      expect(zh.aboutFeatureTracking, isNotEmpty);
      expect(zh.aboutFeatureCoach, isNotEmpty);
      expect(zh.aboutFeaturePrompts, isNotEmpty);
      expect(zh.aboutUsage, isNotEmpty);
      expect(zh.aboutUsageList, isNotEmpty);
      expect(zh.version, isNotEmpty);
      expect(zhTW.about, isNotEmpty);
      expect(zhTW.aboutDescription, isNotEmpty);
      expect(zhTW.aboutIntro, isNotEmpty);
    });

    test('All Authentication final check', () {
      expect(zh.email, isNotEmpty);
      expect(zh.password, isNotEmpty);
      expect(zh.signIn, isNotEmpty);
      expect(zh.signInWithGoogle, isNotEmpty);
      expect(zh.signInWithApple, isNotEmpty);
      expect(zh.signInWithBiometrics, isNotEmpty);
      expect(zh.signOut, isNotEmpty);
      expect(zh.signedOut, isNotEmpty);
      expect(zh.guest, isNotEmpty);
      expect(zh.notSignedIn, isNotEmpty);
      expect(zhTW.email, isNotEmpty);
      expect(zhTW.password, isNotEmpty);
      expect(zhTW.signIn, isNotEmpty);
    });

    test('All Biometric final check', () {
      expect(zh.enableBiometricLogin, isNotEmpty);
      expect(zh.enableBiometricLoginDescription, isNotEmpty);
      expect(zh.biometricAuthFailed, isNotEmpty);
      expect(zh.saveCredentialsForBiometric, isNotEmpty);
      expect(zh.saveCredentialsForBiometricDescription, isNotEmpty);
      expect(zh.biometricTokensExpired, isNotEmpty);
      expect(zh.biometricNoTokens, isNotEmpty);
      expect(zh.biometricTokenError, isNotEmpty);
      expect(zh.biometricTechnicalError, isNotEmpty);
      expect(zhTW.enableBiometricLogin, isNotEmpty);
      expect(zhTW.biometricAuthFailed, isNotEmpty);
    });

    test('All Novel/Chapter final check', () {
      expect(zh.novel, isNotEmpty);
      expect(zh.myNovels, isNotEmpty);
      expect(zh.createNovel, isNotEmpty);
      expect(zh.noNovelsFound, isNotEmpty);
      expect(zh.unknownNovel, isNotEmpty);
      expect(zh.titleLabel, isNotEmpty);
      expect(zh.authorLabel, isNotEmpty);
      expect(zh.chapter, isNotEmpty);
      expect(zh.newChapter, isNotEmpty);
      expect(zh.chapterTitle, isNotEmpty);
      expect(zh.unknownChapter, isNotEmpty);
      expect(zh.notStarted, isNotEmpty);
      expect(zhTW.novel, isNotEmpty);
      expect(zhTW.createNovel, isNotEmpty);
      expect(zhTW.chapter, isNotEmpty);
    });

    test('All Loading/Error final check', () {
      expect(zh.loadingNovels, isNotEmpty);
      expect(zh.loadingChapter, isNotEmpty);
      expect(zh.errorLoadingNovels, isNotEmpty);
      expect(zh.errorLoadingChapters, isNotEmpty);
      expect(zh.error, isNotEmpty);
      expect(zhTW.loadingNovels, isNotEmpty);
      expect(zhTW.errorLoadingChapters, isNotEmpty);
      expect(zhTW.error, isNotEmpty);
    });

    test('All Progress final check', () {
      expect(zh.currentProgress, isNotEmpty);
      expect(zh.loadingProgress, isNotEmpty);
      expect(zh.recentlyRead, isNotEmpty);
      expect(zh.noProgress, isNotEmpty);
      expect(zh.errorLoadingProgress, isNotEmpty);
      expect(zhTW.currentProgress, isNotEmpty);
      expect(zhTW.loadingProgress, isNotEmpty);
      expect(zhTW.recentlyRead, isNotEmpty);
    });

    test('All TTS final check', () {
      expect(zh.ttsSettings, isNotEmpty);
      expect(zh.enableTTS, isNotEmpty);
      expect(zh.testVoice, isNotEmpty);
      expect(zh.reloadVoices, isNotEmpty);
      expect(zh.speechRate, isNotEmpty);
      expect(zh.volume, isNotEmpty);
      expect(zh.pitch, isNotEmpty);
      expect(zh.defaultTTSVoice, isNotEmpty);
      expect(zh.defaultVoiceUpdated, isNotEmpty);
      expect(zh.defaultLanguageSet, isNotEmpty);
      expect(zhTW.ttsSettings, isNotEmpty);
      expect(zhTW.testVoice, isNotEmpty);
      expect(zhTW.speechRate, isNotEmpty);
    });

    test('All Settings final check', () {
      expect(zh.appSettings, isNotEmpty);
      expect(zh.supabaseSettings, isNotEmpty);
      expect(zh.appLanguage, isNotEmpty);
      expect(zh.chooseLanguage, isNotEmpty);
      expect(zh.english, isNotEmpty);
      expect(zh.chinese, isNotEmpty);
      expect(zhTW.appSettings, isNotEmpty);
      expect(zhTW.supabaseSettings, isNotEmpty);
      expect(zhTW.appLanguage, isNotEmpty);
    });

    test('All Summary final check', () {
      expect(zh.sentenceSummary, isNotEmpty);
      expect(zh.paragraphSummary, isNotEmpty);
      expect(zh.pageSummary, isNotEmpty);
      expect(zh.expandedSummary, isNotEmpty);
      expect(zhTW.sentenceSummary, isNotEmpty);
      expect(zhTW.paragraphSummary, isNotEmpty);
      expect(zhTW.pageSummary, isNotEmpty);
    });

    test('All Supabase final check', () {
      expect(zh.supabaseIntegrationInitialized, isNotEmpty);
      expect(zh.configureEnvironment, isNotEmpty);
      expect(zh.supabaseNotEnabled, isNotEmpty);
      expect(zh.supabaseNotEnabledDescription, isNotEmpty);
      expect(zh.authDisabledInBuild, isNotEmpty);
      expect(zh.fetchFromSupabase, isNotEmpty);
      expect(zh.fetchFromSupabaseDescription, isNotEmpty);
      expect(zh.confirmFetch, isNotEmpty);
      expect(zh.confirmFetchDescription, isNotEmpty);
      expect(zhTW.supabaseNotEnabled, isNotEmpty);
      expect(zhTW.fetchFromSupabase, isNotEmpty);
    });

    test('All Navigation final check', () {
      expect(zh.continueLabel, isNotEmpty);
      expect(zh.reload, isNotEmpty);
      expect(zh.cancel, isNotEmpty);
      expect(zh.create, isNotEmpty);
      expect(zh.searchByTitle, isNotEmpty);
      expect(zhTW.continueLabel, isNotEmpty);
      expect(zhTW.reload, isNotEmpty);
      expect(zhTW.cancel, isNotEmpty);
    });

    test('All Mode final check', () {
      expect(zh.modeSupabase, isNotEmpty);
      expect(zh.modeMockData, isNotEmpty);
      expect(zh.noSupabase, isNotEmpty);
      expect(zh.signInToSync, isNotEmpty);
      expect(zhTW.modeSupabase, isNotEmpty);
      expect(zhTW.modeMockData, isNotEmpty);
    });

    test('All Scroll final check', () {
      expect(zh.scrollOffset, isNotEmpty);
      expect(zh.ttsIndex, isNotEmpty);
      expect(zhTW.scrollOffset, isNotEmpty);
      expect(zhTW.ttsIndex, isNotEmpty);
    });

    test('SignedInAs parameterized final check', () {
      expect(zh.signedInAs('user@test.com'), contains('user@test.com'));
      expect(zh.signedInAs('admin@test.com'), contains('admin@test.com'));
      expect(zhTW.signedInAs('user@test.com'), contains('user@test.com'));
    });

    test('ContinueAtChapter parameterized final check', () {
      expect(zh.continueAtChapter('Chapter 1'), contains('Chapter 1'));
      expect(zh.continueAtChapter('Chapter 2'), contains('Chapter 2'));
      expect(zhTW.continueAtChapter('Chapter 1'), contains('Chapter 1'));
    });

    test('FailedToLoadChapter parameterized final check', () {
      expect(
        zh.failedToLoadChapter('Network error'),
        contains('Network error'),
      );
      expect(zh.failedToLoadChapter('Timeout'), contains('Timeout'));
      expect(zhTW.failedToLoadChapter('Error'), contains('Error'));
    });

    test('ChaptersCount parameterized final check', () {
      expect(zh.chaptersCount(0), contains('0'));
      expect(zh.chaptersCount(1), contains('1'));
      expect(zh.chaptersCount(10), contains('10'));
      expect(zh.chaptersCount(100), contains('100'));
      expect(zhTW.chaptersCount(0), contains('0'));
      expect(zhTW.chaptersCount(1), contains('1'));
    });

    test('ChapterLabel parameterized final check', () {
      expect(zh.chapterLabel(0), contains('0'));
      expect(zh.chapterLabel(1), contains('1'));
      expect(zhTW.chapterLabel(0), contains('0'));
      expect(zhTW.chapterLabel(1), contains('1'));
    });

    test('ChapterWithTitle parameterized final check', () {
      expect(zh.chapterWithTitle(0, 'Title'), contains('0'));
      expect(zh.chapterWithTitle(1, 'Title'), contains('1'));
      expect(zhTW.chapterWithTitle(0, 'Title'), contains('0'));
    });

    test('AvgWordsPerChapter parameterized final check', () {
      expect(zh.avgWordsPerChapter(100), contains('100'));
      expect(zh.avgWordsPerChapter(1000), contains('1000'));
      expect(zhTW.avgWordsPerChapter(100), contains('100'));
    });

    test('ByAuthor parameterized final check', () {
      expect(zh.byAuthor('Author Name'), contains('Author Name'));
      expect(zh.byAuthor('Test Author'), contains('Test Author'));
      expect(zhTW.byAuthor('Author'), contains('Author'));
    });

    test('PageOfTotal parameterized final check', () {
      expect(zh.pageOfTotal(1, 100), contains('1'));
      expect(zh.pageOfTotal(50, 100), contains('50'));
      expect(zhTW.pageOfTotal(1, 100), contains('1'));
    });

    test('AiTokenCount parameterized final check', () {
      expect(zh.aiTokenCount(100), contains('100'));
      expect(zh.aiTokenCount(1000), contains('1000'));
      expect(zhTW.aiTokenCount(100), contains('100'));
    });

    test('AiContextLoadError parameterized final check', () {
      expect(zh.aiContextLoadError('Error'), contains('Error'));
      expect(zh.aiContextLoadError('Failed'), contains('Failed'));
      expect(zhTW.aiContextLoadError('Error'), contains('Error'));
    });

    test('AiChatContextTooLongCompressing parameterized final check', () {
      expect(zh.aiChatContextTooLongCompressing(1000), contains('1000'));
      expect(zh.aiChatContextTooLongCompressing(5000), contains('5000'));
      expect(zhTW.aiChatContextTooLongCompressing(1000), contains('1000'));
    });

    test('AiChatError parameterized final check', () {
      expect(zh.aiChatError('Network error'), contains('Network error'));
      expect(zh.aiChatError('Timeout'), contains('Timeout'));
      expect(zhTW.aiChatError('Error'), contains('Error'));
    });

    test('AiChatDeepAgentError parameterized final check', () {
      expect(zh.aiChatDeepAgentError('Plan failed'), contains('Plan failed'));
      expect(zh.aiChatDeepAgentError('Tool error'), contains('Tool error'));
      expect(zhTW.aiChatDeepAgentError('Error'), contains('Error'));
    });

    test('AiServiceFailedToConnect parameterized final check', () {
      expect(
        zh.aiServiceFailedToConnect('Connection failed'),
        contains('Connection failed'),
      );
      expect(zh.aiServiceFailedToConnect('Timeout'), contains('Timeout'));
      expect(zhTW.aiServiceFailedToConnect('Error'), contains('Error'));
    });

    test('LanguageLabel parameterized final check', () {
      expect(zh.languageLabel('en'), contains('en'));
      expect(zh.languageLabel('zh'), contains('zh'));
      expect(zhTW.languageLabel('en'), contains('en'));
    });

    test('ConfirmDeleteDescription parameterized final check', () {
      expect(zh.confirmDeleteDescription('Test'), contains('Test'));
      expect(zh.confirmDeleteDescription('Novel'), contains('Novel'));
      expect(zhTW.confirmDeleteDescription('Test'), contains('Test'));
    });

    test('DeletedWithTitle parameterized final check', () {
      expect(zh.deletedWithTitle('Test'), contains('Test'));
      expect(zh.deletedWithTitle('Item'), contains('Item'));
      expect(zhTW.deletedWithTitle('Test'), contains('Test'));
    });

    test('DeleteFailedWithTitle parameterized final check', () {
      expect(zh.deleteFailedWithTitle('Test'), contains('Test'));
      expect(zh.deleteFailedWithTitle('Item'), contains('Item'));
      expect(zhTW.deleteFailedWithTitle('Test'), contains('Test'));
    });

    test('DeleteErrorWithMessage parameterized final check', () {
      expect(zh.deleteErrorWithMessage('Error'), contains('Error'));
      expect(zh.deleteErrorWithMessage('Failed'), contains('Failed'));
      expect(zhTW.deleteErrorWithMessage('Error'), contains('Error'));
    });

    test('ConversionFailed parameterized final check', () {
      expect(zh.conversionFailed('Failed'), contains('Failed'));
      expect(zh.conversionFailed('Error'), contains('Error'));
      expect(zhTW.conversionFailed('Failed'), contains('Failed'));
    });

    test('AiChatRagRefinedQuery parameterized final check', () {
      expect(zh.aiChatRagRefinedQuery('Query'), contains('Query'));
      expect(zh.aiChatRagRefinedQuery('Search'), contains('Search'));
      expect(zhTW.aiChatRagRefinedQuery('Query'), contains('Query'));
    });
  });
}
