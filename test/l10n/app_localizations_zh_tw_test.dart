import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZhTw - Traditional Chinese', () {
    test('all basic strings are non-empty', () {
      expect(zhTW.newChapter, isNotEmpty);
      expect(zhTW.back, isNotEmpty);
      expect(zhTW.helloWorld, isNotEmpty);
      expect(zhTW.settings, isNotEmpty);
      expect(zhTW.appTitle, isNotEmpty);
      expect(zhTW.about, isNotEmpty);
    });

    test('all authentication strings are non-empty', () {
      expect(zhTW.email, isNotEmpty);
      expect(zhTW.password, isNotEmpty);
      expect(zhTW.signedInAs('test@example.com'), contains('test@example.com'));
      expect(zhTW.signIn, isNotEmpty);
      expect(zhTW.signOut, isNotEmpty);
      expect(zhTW.guest, isNotEmpty);
      expect(zhTW.notSignedIn, isNotEmpty);
      expect(zhTW.continueLabel, isNotEmpty);
      expect(zhTW.reload, isNotEmpty);
      expect(zhTW.signInToSync, isNotEmpty);
    });

    test('all theme strings are non-empty', () {
      expect(zhTW.themeMode, isNotEmpty);
      expect(zhTW.system, isNotEmpty);
      expect(zhTW.light, isNotEmpty);
      expect(zhTW.dark, isNotEmpty);
      expect(zhTW.colorTheme, isNotEmpty);
      expect(zhTW.themeLight, isNotEmpty);
      expect(zhTW.themeSepia, isNotEmpty);
      expect(zhTW.themeHighContrast, isNotEmpty);
      expect(zhTW.themeDefault, isNotEmpty);
    });

    test('all TTS strings are non-empty', () {
      expect(zhTW.ttsSettings, isNotEmpty);
      expect(zhTW.enableTTS, isNotEmpty);
      expect(zhTW.speechRate, isNotEmpty);
      expect(zhTW.volume, isNotEmpty);
      expect(zhTW.pitch, isNotEmpty);
      expect(zhTW.defaultTTSVoice, isNotEmpty);
      expect(zhTW.testVoice, isNotEmpty);
      expect(zhTW.stopTTS, isNotEmpty);
      expect(zhTW.speak, isNotEmpty);
      expect(zhTW.ttsError('test'), contains('test'));
    });

    test('all navigation strings are non-empty', () {
      expect(zhTW.navigation, isNotEmpty);
      expect(zhTW.home, isNotEmpty);
      expect(zhTW.libraryTitle, isNotEmpty);
      expect(zhTW.discover, isNotEmpty);
      expect(zhTW.profile, isNotEmpty);
      expect(zhTW.back, isNotEmpty);
      expect(zhTW.close, isNotEmpty);
    });

    test('all error strings are non-empty', () {
      expect(zhTW.error, isNotEmpty);
      expect(zhTW.errorLoadingProgress, isNotEmpty);
      expect(zhTW.errorLoadingNovels, isNotEmpty);
      expect(zhTW.errorSavingProgress, isNotEmpty);
      expect(zhTW.errorUnauthorized, isNotEmpty);
      expect(zhTW.errorForbidden, isNotEmpty);
      expect(zhTW.errorNotFound, isNotEmpty);
      expect(zhTW.loginFailed, isNotEmpty);
    });

    test('all novel strings are non-empty', () {
      expect(zhTW.novels, isNotEmpty);
      expect(zhTW.myNovels, isNotEmpty);
      expect(zhTW.createNovel, isNotEmpty);
      expect(zhTW.create, isNotEmpty);
      expect(zhTW.novel, isNotEmpty);
      expect(zhTW.chapters, isNotEmpty);
      expect(zhTW.chapter, isNotEmpty);
      expect(zhTW.noNovelsFound, isNotEmpty);
      expect(zhTW.noChaptersFound, isNotEmpty);
    });

    test('all AI strings are non-empty', () {
      expect(zhTW.aiAssistant, isNotEmpty);
      expect(zhTW.aiChatHistory, isNotEmpty);
      expect(zhTW.aiChatNewChat, isNotEmpty);
      expect(zhTW.aiChatHint, isNotEmpty);
      expect(zhTW.aiThinking, isNotEmpty);
      expect(zhTW.aiChatEmpty, isNotEmpty);
      expect(zhTW.aiServiceUrl, isNotEmpty);
      expect(zhTW.aiChatError('test'), contains('test'));
      expect(zhTW.aiChatDeepAgentError('test'), contains('test'));
    });

    test('all summary strings are non-empty', () {
      expect(zhTW.sentenceSummary, isNotEmpty);
      expect(zhTW.paragraphSummary, isNotEmpty);
      expect(zhTW.pageSummary, isNotEmpty);
      expect(zhTW.expandedSummary, isNotEmpty);
      expect(zhTW.noSentenceSummary, isNotEmpty);
      expect(zhTW.noParagraphSummary, isNotEmpty);
      expect(zhTW.noPageSummary, isNotEmpty);
      expect(zhTW.noExpandedSummary, isNotEmpty);
    });

    test('all settings strings are non-empty', () {
      expect(zhTW.appSettings, isNotEmpty);
      expect(zhTW.supabaseSettings, isNotEmpty);
      expect(zhTW.supabaseNotEnabled, isNotEmpty);
      expect(zhTW.authDisabledInBuild, isNotEmpty);
      expect(zhTW.reduceMotion, isNotEmpty);
      expect(zhTW.gesturesEnabled, isNotEmpty);
      expect(zhTW.performanceSettings, isNotEmpty);
    });

    test('all UI strings are non-empty', () {
      expect(zhTW.cancel, isNotEmpty);
      expect(zhTW.confirm, isNotEmpty);
      expect(zhTW.save, isNotEmpty);
      expect(zhTW.delete, isNotEmpty);
      expect(zhTW.edit, isNotEmpty);
      expect(zhTW.refresh, isNotEmpty);
    });

    test('all progress strings are non-empty', () {
      expect(zhTW.loadingProgress, isNotEmpty);
      expect(zhTW.currentProgress, isNotEmpty);
      expect(zhTW.progressSaved, isNotEmpty);
      expect(zhTW.recentlyRead, isNotEmpty);
      expect(zhTW.continueReading, isNotEmpty);
    });

    test('all template strings are non-empty', () {
      expect(zhTW.characterTemplates, isNotEmpty);
      expect(zhTW.sceneTemplates, isNotEmpty);
      expect(zhTW.templateLabel, isNotEmpty);
      expect(zhTW.templateName, isNotEmpty);
      expect(zhTW.exampleCharacterName, isNotEmpty);
    });

    test('all action strings are non-empty', () {
      expect(zhTW.send, isNotEmpty);
      expect(zhTW.copy, isNotEmpty);
      expect(zhTW.undo, isNotEmpty);
      expect(zhTW.preview, isNotEmpty);
      expect(zhTW.download, isNotEmpty);
    });

    test('all reader strings are non-empty', () {
      expect(zhTW.readerBackgroundDepth, isNotEmpty);
      expect(zhTW.depthLow, isNotEmpty);
      expect(zhTW.depthMedium, isNotEmpty);
      expect(zhTW.depthHigh, isNotEmpty);
      expect(zhTW.readLabel, isNotEmpty);
      expect(zhTW.pause, isNotEmpty);
      expect(zhTW.start, isNotEmpty);
    });

    test('all strings with parameters work correctly', () {
      expect(zhTW.signedInAs('user@example.com'), contains('user@example.com'));
      expect(zhTW.continueAtChapter('Chapter 1'), contains('Chapter 1'));
      expect(zhTW.ttsError('Error message'), contains('Error message'));
      expect(zhTW.aiChatError('Test error'), contains('Test error'));
      expect(zhTW.aiChatDeepAgentError('Deep error'), contains('Deep error'));
      expect(zhTW.chaptersCount(10), contains('10'));
      expect(zhTW.chapterLabel(5), contains('5'));
      expect(zhTW.byAuthor('Author Name'), contains('Author Name'));
      expect(zhTW.pageOfTotal(1, 100), contains('1'));
    });

    test('all keyboard shortcuts are non-empty', () {
      expect(zhTW.keyboardShortcuts, isNotEmpty);
      expect(zhTW.shortcutSpace, isNotEmpty);
      expect(zhTW.shortcutArrows, isNotEmpty);
      expect(zhTW.shortcutRate, isNotEmpty);
      expect(zhTW.shortcutVoice, isNotEmpty);
      expect(zhTW.shortcutHelp, isNotEmpty);
      expect(zhTW.shortcutEsc, isNotEmpty);
    });

    test('all PDF strings are non-empty', () {
      expect(zhTW.pdf, isNotEmpty);
      expect(zhTW.generatingPdf, isNotEmpty);
      expect(zhTW.pdfFailed, isNotEmpty);
      expect(zhTW.tableOfContents, isNotEmpty);
      expect(zhTW.byAuthor('Test'), isNotEmpty);
      expect(zhTW.pageOfTotal(1, 10), isNotEmpty);
    });

    test('all writing tip strings are non-empty', () {
      expect(zhTW.tipIntention, isNotEmpty);
      expect(zhTW.tipVerbs, isNotEmpty);
      expect(zhTW.tipStuck, isNotEmpty);
      expect(zhTW.tipDialogue, isNotEmpty);
    });

    test('all accessibility strings are non-empty', () {
      expect(zhTW.contrastIssuesDetected, isNotEmpty);
      expect(zhTW.foundContrastIssues(5), contains('5'));
      expect(zhTW.allGood, isNotEmpty);
      expect(zhTW.allGoodContrast, isNotEmpty);
    });

    test('all design system strings are non-empty', () {
      expect(zhTW.designSystemStyleGuide, isNotEmpty);
      expect(zhTW.styleGuide, isNotEmpty);
      expect(zhTW.styleGlassmorphism, isNotEmpty);
      expect(zhTW.styleNeumorphism, isNotEmpty);
      expect(zhTW.styleMinimalism, isNotEmpty);
    });
  });
}
