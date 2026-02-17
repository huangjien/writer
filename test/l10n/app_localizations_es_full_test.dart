import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_es.dart';

void main() {
  late AppLocalizationsEs es;

  setUp(() {
    es = AppLocalizationsEs();
  });

  group('AppLocalizationsEs - Full Coverage', () {
    test('all basic UI strings are non-empty', () {
      expect(es.newChapter, isNotEmpty);
      expect(es.back, isNotEmpty);
      expect(es.helloWorld, isNotEmpty);
      expect(es.settings, isNotEmpty);
      expect(es.appTitle, isNotEmpty);
      expect(es.about, isNotEmpty);
      expect(es.continueLabel, isNotEmpty);
      expect(es.reload, isNotEmpty);
      expect(es.confirm, isNotEmpty);
      expect(es.cancel, isNotEmpty);
      expect(es.save, isNotEmpty);
      expect(es.delete, isNotEmpty);
      expect(es.edit, isNotEmpty);
      expect(es.refresh, isNotEmpty);
    });

    test('all authentication strings work', () {
      expect(es.email, isNotEmpty);
      expect(es.password, isNotEmpty);
      expect(es.signedInAs('test@test.com'), contains('test@test.com'));
      expect(es.signIn, isNotEmpty);
      expect(es.signOut, isNotEmpty);
      expect(es.guest, isNotEmpty);
      expect(es.notSignedIn, isNotEmpty);
      expect(es.signInToSync, isNotEmpty);
      expect(es.forgotPassword, isNotEmpty);
      expect(es.signUp, isNotEmpty);
    });

    test('all theme strings work', () {
      expect(es.themeMode, isNotEmpty);
      expect(es.system, isNotEmpty);
      expect(es.light, isNotEmpty);
      expect(es.dark, isNotEmpty);
      expect(es.colorTheme, isNotEmpty);
      expect(es.themeLight, isNotEmpty);
      expect(es.themeSepia, isNotEmpty);
      expect(es.themeHighContrast, isNotEmpty);
    });

    test('all TTS strings work', () {
      expect(es.ttsSettings, isNotEmpty);
      expect(es.enableTTS, isNotEmpty);
      expect(es.speechRate, isNotEmpty);
      expect(es.volume, isNotEmpty);
      expect(es.pitch, isNotEmpty);
      expect(es.defaultTTSVoice, isNotEmpty);
      expect(es.testVoice, isNotEmpty);
      expect(es.stopTTS, isNotEmpty);
      expect(es.speak, isNotEmpty);
      expect(es.ttsError('error'), contains('error'));
    });

    test('all navigation strings work', () {
      expect(es.navigation, isNotEmpty);
      expect(es.home, isNotEmpty);
      expect(es.libraryTitle, isNotEmpty);
      expect(es.discover, isNotEmpty);
      expect(es.profile, isNotEmpty);
      expect(es.close, isNotEmpty);
    });

    test('all error strings work', () {
      expect(es.error, isNotEmpty);
      expect(es.errorLoadingProgress, isNotEmpty);
      expect(es.errorLoadingNovels, isNotEmpty);
      expect(es.errorSavingProgress, isNotEmpty);
      expect(es.errorUnauthorized, isNotEmpty);
      expect(es.errorForbidden, isNotEmpty);
      expect(es.errorNotFound, isNotEmpty);
      expect(es.loginFailed, isNotEmpty);
    });

    test('all novel strings work', () {
      expect(es.novels, isNotEmpty);
      expect(es.myNovels, isNotEmpty);
      expect(es.createNovel, isNotEmpty);
      expect(es.create, isNotEmpty);
      expect(es.novel, isNotEmpty);
      expect(es.chapters, isNotEmpty);
      expect(es.chapter, isNotEmpty);
      expect(es.noNovelsFound, isNotEmpty);
      expect(es.noChaptersFound, isNotEmpty);
      expect(es.updateNovel, isNotEmpty);
      expect(es.deleteNovel, isNotEmpty);
    });

    test('all AI strings work', () {
      expect(es.aiAssistant, isNotEmpty);
      expect(es.aiChatHistory, isNotEmpty);
      expect(es.aiChatNewChat, isNotEmpty);
      expect(es.aiChatHint, isNotEmpty);
      expect(es.aiThinking, isNotEmpty);
      expect(es.aiChatEmpty, isNotEmpty);
      expect(es.aiServiceUrl, isNotEmpty);
      expect(es.aiChatError('error'), contains('error'));
      expect(es.aiChatDeepAgentError('error'), contains('error'));
      expect(es.aiDeepAgentStop('reason', 5), contains('reason'));
    });

    test('all summary strings work', () {
      expect(es.sentenceSummary, isNotEmpty);
      expect(es.paragraphSummary, isNotEmpty);
      expect(es.pageSummary, isNotEmpty);
      expect(es.expandedSummary, isNotEmpty);
      expect(es.noSentenceSummary, isNotEmpty);
      expect(es.noParagraphSummary, isNotEmpty);
      expect(es.noPageSummary, isNotEmpty);
      expect(es.noExpandedSummary, isNotEmpty);
    });

    test('all settings strings work', () {
      expect(es.appSettings, isNotEmpty);
      expect(es.supabaseSettings, isNotEmpty);
      expect(es.supabaseNotEnabled, isNotEmpty);
      expect(es.authDisabledInBuild, isNotEmpty);
      expect(es.reduceMotion, isNotEmpty);
      expect(es.gesturesEnabled, isNotEmpty);
      expect(es.performanceSettings, isNotEmpty);
    });

    test('all progress strings work', () {
      expect(es.loadingProgress, isNotEmpty);
      expect(es.currentProgress, isNotEmpty);
      expect(es.progressSaved, isNotEmpty);
      expect(es.recentlyRead, isNotEmpty);
      expect(es.continueReading, isNotEmpty);
      expect(es.continueAtChapter('Chapter 1'), contains('Chapter 1'));
    });

    test('all template strings work', () {
      expect(es.characterTemplates, isNotEmpty);
      expect(es.sceneTemplates, isNotEmpty);
      expect(es.templateLabel, isNotEmpty);
      expect(es.templateName, isNotEmpty);
      expect(es.exampleCharacterName, isNotEmpty);
    });

    test('all parameterized methods work', () {
      expect(es.indexLabel(5), contains('5'));
      expect(es.indexOutOfRange(1, 10), contains('1'));
      expect(es.chaptersCount(100), contains('100'));
      expect(es.chapterLabel(5), contains('5'));
      expect(es.chapterWithTitle(5, 'Title'), contains('5'));
      expect(es.avgWordsPerChapter(5000), contains('5000'));
      expect(es.aiTokenCount(1000), contains('1000'));
      expect(es.chaptersCount(10), contains('10'));
      expect(es.languageLabel('en'), contains('en'));
      expect(es.byAuthor('Author'), contains('Author'));
      expect(es.pageOfTotal(1, 100), contains('1'));
      expect(es.confirmDeleteDescription('Test'), contains('Test'));
      expect(es.removedNovel('Test'), contains('Test'));
      expect(es.wordCount(5000), contains('5000'));
      expect(es.characterCount(10000), contains('10000'));
      expect(es.progressPercentage(75), contains('75'));
    });
  });
}
