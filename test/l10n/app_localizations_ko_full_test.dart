import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_ko.dart';

void main() {
  late AppLocalizationsKo ko;

  setUp(() {
    ko = AppLocalizationsKo();
  });

  group('AppLocalizationsKo - Full Coverage', () {
    test('all basic UI strings are non-empty', () {
      expect(ko.newChapter, isNotEmpty);
      expect(ko.back, isNotEmpty);
      expect(ko.helloWorld, isNotEmpty);
      expect(ko.settings, isNotEmpty);
      expect(ko.appTitle, isNotEmpty);
      expect(ko.about, isNotEmpty);
      expect(ko.continueLabel, isNotEmpty);
      expect(ko.reload, isNotEmpty);
      expect(ko.confirm, isNotEmpty);
      expect(ko.cancel, isNotEmpty);
      expect(ko.save, isNotEmpty);
      expect(ko.delete, isNotEmpty);
      expect(ko.edit, isNotEmpty);
      expect(ko.refresh, isNotEmpty);
    });

    test('all authentication strings work', () {
      expect(ko.email, isNotEmpty);
      expect(ko.password, isNotEmpty);
      expect(ko.signedInAs('test@test.com'), contains('test@test.com'));
      expect(ko.signIn, isNotEmpty);
      expect(ko.signOut, isNotEmpty);
      expect(ko.guest, isNotEmpty);
      expect(ko.notSignedIn, isNotEmpty);
      expect(ko.signInToSync, isNotEmpty);
      expect(ko.forgotPassword, isNotEmpty);
      expect(ko.signUp, isNotEmpty);
    });

    test('all theme strings work', () {
      expect(ko.themeMode, isNotEmpty);
      expect(ko.system, isNotEmpty);
      expect(ko.light, isNotEmpty);
      expect(ko.dark, isNotEmpty);
      expect(ko.colorTheme, isNotEmpty);
      expect(ko.themeLight, isNotEmpty);
      expect(ko.themeSepia, isNotEmpty);
      expect(ko.themeHighContrast, isNotEmpty);
    });

    test('all TTS strings work', () {
      expect(ko.ttsSettings, isNotEmpty);
      expect(ko.enableTTS, isNotEmpty);
      expect(ko.speechRate, isNotEmpty);
      expect(ko.volume, isNotEmpty);
      expect(ko.pitch, isNotEmpty);
      expect(ko.defaultTTSVoice, isNotEmpty);
      expect(ko.testVoice, isNotEmpty);
      expect(ko.stopTTS, isNotEmpty);
      expect(ko.speak, isNotEmpty);
      expect(ko.ttsError('error'), contains('error'));
    });

    test('all navigation strings work', () {
      expect(ko.navigation, isNotEmpty);
      expect(ko.home, isNotEmpty);
      expect(ko.libraryTitle, isNotEmpty);
      expect(ko.discover, isNotEmpty);
      expect(ko.profile, isNotEmpty);
      expect(ko.close, isNotEmpty);
    });

    test('all error strings work', () {
      expect(ko.error, isNotEmpty);
      expect(ko.errorLoadingProgress, isNotEmpty);
      expect(ko.errorLoadingNovels, isNotEmpty);
      expect(ko.errorSavingProgress, isNotEmpty);
      expect(ko.errorUnauthorized, isNotEmpty);
      expect(ko.errorForbidden, isNotEmpty);
      expect(ko.errorNotFound, isNotEmpty);
      expect(ko.loginFailed, isNotEmpty);
    });

    test('all novel strings work', () {
      expect(ko.novels, isNotEmpty);
      expect(ko.myNovels, isNotEmpty);
      expect(ko.createNovel, isNotEmpty);
      expect(ko.create, isNotEmpty);
      expect(ko.novel, isNotEmpty);
      expect(ko.chapters, isNotEmpty);
      expect(ko.chapter, isNotEmpty);
      expect(ko.noNovelsFound, isNotEmpty);
      expect(ko.noChaptersFound, isNotEmpty);
      expect(ko.updateNovel, isNotEmpty);
      expect(ko.deleteNovel, isNotEmpty);
    });

    test('all AI strings work', () {
      expect(ko.aiAssistant, isNotEmpty);
      expect(ko.aiChatHistory, isNotEmpty);
      expect(ko.aiChatNewChat, isNotEmpty);
      expect(ko.aiChatHint, isNotEmpty);
      expect(ko.aiThinking, isNotEmpty);
      expect(ko.aiChatEmpty, isNotEmpty);
      expect(ko.aiServiceUrl, isNotEmpty);
      expect(ko.aiChatError('error'), contains('error'));
      expect(ko.aiChatDeepAgentError('error'), contains('error'));
      expect(ko.aiDeepAgentStop('reason', 5), contains('reason'));
    });

    test('all summary strings work', () {
      expect(ko.sentenceSummary, isNotEmpty);
      expect(ko.paragraphSummary, isNotEmpty);
      expect(ko.pageSummary, isNotEmpty);
      expect(ko.expandedSummary, isNotEmpty);
      expect(ko.noSentenceSummary, isNotEmpty);
      expect(ko.noParagraphSummary, isNotEmpty);
      expect(ko.noPageSummary, isNotEmpty);
      expect(ko.noExpandedSummary, isNotEmpty);
    });

    test('all settings strings work', () {
      expect(ko.appSettings, isNotEmpty);
      expect(ko.supabaseSettings, isNotEmpty);
      expect(ko.supabaseNotEnabled, isNotEmpty);
      expect(ko.authDisabledInBuild, isNotEmpty);
      expect(ko.reduceMotion, isNotEmpty);
      expect(ko.gesturesEnabled, isNotEmpty);
      expect(ko.performanceSettings, isNotEmpty);
    });

    test('all progress strings work', () {
      expect(ko.loadingProgress, isNotEmpty);
      expect(ko.currentProgress, isNotEmpty);
      expect(ko.progressSaved, isNotEmpty);
      expect(ko.recentlyRead, isNotEmpty);
      expect(ko.continueReading, isNotEmpty);
      expect(ko.continueAtChapter('Chapter 1'), contains('Chapter 1'));
    });

    test('all template strings work', () {
      expect(ko.characterTemplates, isNotEmpty);
      expect(ko.sceneTemplates, isNotEmpty);
      expect(ko.templateLabel, isNotEmpty);
      expect(ko.templateName, isNotEmpty);
      expect(ko.exampleCharacterName, isNotEmpty);
    });

    test('all parameterized methods work', () {
      expect(ko.indexLabel(5), contains('5'));
      expect(ko.indexOutOfRange(1, 10), contains('1'));
      expect(ko.chaptersCount(100), contains('100'));
      expect(ko.chapterLabel(5), contains('5'));
      expect(ko.chapterWithTitle(5, 'Title'), contains('5'));
      expect(ko.avgWordsPerChapter(5000), contains('5000'));
      expect(ko.aiTokenCount(1000), contains('1000'));
      expect(ko.chaptersCount(10), contains('10'));
      expect(ko.languageLabel('en'), contains('en'));
      expect(ko.byAuthor('Author'), contains('Author'));
      expect(ko.pageOfTotal(1, 100), contains('1'));
      expect(ko.confirmDeleteDescription('Test'), contains('Test'));
      expect(ko.removedNovel('Test'), contains('Test'));
      expect(ko.wordCount(5000), contains('5000'));
      expect(ko.characterCount(10000), contains('10000'));
      expect(ko.progressPercentage(75), contains('75'));
    });
  });
}
