import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_it.dart';

void main() {
  late AppLocalizationsIt it;

  setUp(() {
    it = AppLocalizationsIt();
  });

  group('AppLocalizationsIt - Full Coverage', () {
    test('all basic UI strings are non-empty', () {
      expect(it.newChapter, isNotEmpty);
      expect(it.back, isNotEmpty);
      expect(it.helloWorld, isNotEmpty);
      expect(it.settings, isNotEmpty);
      expect(it.appTitle, isNotEmpty);
      expect(it.about, isNotEmpty);
      expect(it.continueLabel, isNotEmpty);
      expect(it.reload, isNotEmpty);
      expect(it.confirm, isNotEmpty);
      expect(it.cancel, isNotEmpty);
      expect(it.save, isNotEmpty);
      expect(it.delete, isNotEmpty);
      expect(it.edit, isNotEmpty);
      expect(it.refresh, isNotEmpty);
    });

    test('all authentication strings work', () {
      expect(it.email, isNotEmpty);
      expect(it.password, isNotEmpty);
      expect(it.signedInAs('test@test.com'), contains('test@test.com'));
      expect(it.signIn, isNotEmpty);
      expect(it.signOut, isNotEmpty);
      expect(it.guest, isNotEmpty);
      expect(it.notSignedIn, isNotEmpty);
      expect(it.signInToSync, isNotEmpty);
      expect(it.forgotPassword, isNotEmpty);
      expect(it.signUp, isNotEmpty);
    });

    test('all theme strings work', () {
      expect(it.themeMode, isNotEmpty);
      expect(it.system, isNotEmpty);
      expect(it.light, isNotEmpty);
      expect(it.dark, isNotEmpty);
      expect(it.colorTheme, isNotEmpty);
      expect(it.themeLight, isNotEmpty);
      expect(it.themeSepia, isNotEmpty);
      expect(it.themeHighContrast, isNotEmpty);
    });

    test('all TTS strings work', () {
      expect(it.ttsSettings, isNotEmpty);
      expect(it.enableTTS, isNotEmpty);
      expect(it.speechRate, isNotEmpty);
      expect(it.volume, isNotEmpty);
      expect(it.pitch, isNotEmpty);
      expect(it.defaultTTSVoice, isNotEmpty);
      expect(it.testVoice, isNotEmpty);
      expect(it.stopTTS, isNotEmpty);
      expect(it.speak, isNotEmpty);
      expect(it.ttsError('error'), contains('error'));
    });

    test('all navigation strings work', () {
      expect(it.navigation, isNotEmpty);
      expect(it.home, isNotEmpty);
      expect(it.libraryTitle, isNotEmpty);
      expect(it.discover, isNotEmpty);
      expect(it.profile, isNotEmpty);
      expect(it.close, isNotEmpty);
    });

    test('all error strings work', () {
      expect(it.error, isNotEmpty);
      expect(it.errorLoadingProgress, isNotEmpty);
      expect(it.errorLoadingNovels, isNotEmpty);
      expect(it.errorSavingProgress, isNotEmpty);
      expect(it.errorUnauthorized, isNotEmpty);
      expect(it.errorForbidden, isNotEmpty);
      expect(it.errorNotFound, isNotEmpty);
      expect(it.loginFailed, isNotEmpty);
    });

    test('all novel strings work', () {
      expect(it.novels, isNotEmpty);
      expect(it.myNovels, isNotEmpty);
      expect(it.createNovel, isNotEmpty);
      expect(it.create, isNotEmpty);
      expect(it.novel, isNotEmpty);
      expect(it.chapters, isNotEmpty);
      expect(it.chapter, isNotEmpty);
      expect(it.noNovelsFound, isNotEmpty);
      expect(it.noChaptersFound, isNotEmpty);
      expect(it.updateNovel, isNotEmpty);
      expect(it.deleteNovel, isNotEmpty);
    });

    test('all AI strings work', () {
      expect(it.aiAssistant, isNotEmpty);
      expect(it.aiChatHistory, isNotEmpty);
      expect(it.aiChatNewChat, isNotEmpty);
      expect(it.aiChatHint, isNotEmpty);
      expect(it.aiThinking, isNotEmpty);
      expect(it.aiChatEmpty, isNotEmpty);
      expect(it.aiServiceUrl, isNotEmpty);
      expect(it.aiChatError('error'), contains('error'));
      expect(it.aiChatDeepAgentError('error'), contains('error'));
      expect(it.aiDeepAgentStop('reason', 5), contains('reason'));
    });

    test('all summary strings work', () {
      expect(it.sentenceSummary, isNotEmpty);
      expect(it.paragraphSummary, isNotEmpty);
      expect(it.pageSummary, isNotEmpty);
      expect(it.expandedSummary, isNotEmpty);
      expect(it.noSentenceSummary, isNotEmpty);
      expect(it.noParagraphSummary, isNotEmpty);
      expect(it.noPageSummary, isNotEmpty);
      expect(it.noExpandedSummary, isNotEmpty);
    });

    test('all settings strings work', () {
      expect(it.appSettings, isNotEmpty);
      expect(it.supabaseSettings, isNotEmpty);
      expect(it.supabaseNotEnabled, isNotEmpty);
      expect(it.authDisabledInBuild, isNotEmpty);
      expect(it.reduceMotion, isNotEmpty);
      expect(it.gesturesEnabled, isNotEmpty);
      expect(it.performanceSettings, isNotEmpty);
    });

    test('all progress strings work', () {
      expect(it.loadingProgress, isNotEmpty);
      expect(it.currentProgress, isNotEmpty);
      expect(it.progressSaved, isNotEmpty);
      expect(it.recentlyRead, isNotEmpty);
      expect(it.continueReading, isNotEmpty);
      expect(it.continueAtChapter('Chapter 1'), contains('Chapter 1'));
    });

    test('all template strings work', () {
      expect(it.characterTemplates, isNotEmpty);
      expect(it.sceneTemplates, isNotEmpty);
      expect(it.templateLabel, isNotEmpty);
      expect(it.templateName, isNotEmpty);
      expect(it.exampleCharacterName, isNotEmpty);
    });

    test('all parameterized methods work', () {
      expect(it.indexLabel(5), contains('5'));
      expect(it.indexOutOfRange(1, 10), contains('1'));
      expect(it.chaptersCount(100), contains('100'));
      expect(it.chapterLabel(5), contains('5'));
      expect(it.chapterWithTitle(5, 'Title'), contains('5'));
      expect(it.avgWordsPerChapter(5000), contains('5000'));
      expect(it.aiTokenCount(1000), contains('1000'));
      expect(it.chaptersCount(10), contains('10'));
      expect(it.languageLabel('en'), contains('en'));
      expect(it.byAuthor('Author'), contains('Author'));
      expect(it.pageOfTotal(1, 100), contains('1'));
      expect(it.confirmDeleteDescription('Test'), contains('Test'));
      expect(it.removedNovel('Test'), contains('Test'));
      expect(it.wordCount(5000), contains('5000'));
      expect(it.characterCount(10000), contains('10000'));
      expect(it.progressPercentage(75), contains('75'));
    });
  });
}
