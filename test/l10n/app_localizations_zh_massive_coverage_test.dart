import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - Massive Coverage Boost', () {
    test('ALL string getters are non-empty - Part 1', () {
      // Basic
      expect(zh.newChapter, isNotEmpty);
      expect(zh.back, isNotEmpty);
      expect(zh.helloWorld, isNotEmpty);
      expect(zh.settings, isNotEmpty);
      expect(zh.appTitle, isNotEmpty);
      expect(zh.about, isNotEmpty);

      // About
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

      // Version/Language
      expect(zh.version, isNotEmpty);
      expect(zh.appLanguage, isNotEmpty);
      expect(zh.english, isNotEmpty);
      expect(zh.chinese, isNotEmpty);
      expect(zh.supabaseIntegrationInitialized, isNotEmpty);
      expect(zh.configureEnvironment, isNotEmpty);

      // Auth
      expect(zh.email, isNotEmpty);
      expect(zh.password, isNotEmpty);
      expect(zh.guest, isNotEmpty);
      expect(zh.notSignedIn, isNotEmpty);
      expect(zh.signIn, isNotEmpty);
      expect(zh.continueLabel, isNotEmpty);
      expect(zh.reload, isNotEmpty);
      expect(zh.signInToSync, isNotEmpty);
      expect(zh.signInWithGoogle, isNotEmpty);
      expect(zh.signInWithApple, isNotEmpty);
      expect(zh.signOut, isNotEmpty);
      expect(zh.signedOut, isNotEmpty);

      // Progress
      expect(zh.currentProgress, isNotEmpty);
      expect(zh.loadingProgress, isNotEmpty);
      expect(zh.recentlyRead, isNotEmpty);
      expect(zh.noSupabase, isNotEmpty);
      expect(zh.errorLoadingProgress, isNotEmpty);
      expect(zh.noProgress, isNotEmpty);

      // Novels
      expect(zh.errorLoadingNovels, isNotEmpty);
      expect(zh.loadingNovels, isNotEmpty);
      expect(zh.titleLabel, isNotEmpty);
      expect(zh.authorLabel, isNotEmpty);
      expect(zh.noNovelsFound, isNotEmpty);
      expect(zh.myNovels, isNotEmpty);
      expect(zh.createNovel, isNotEmpty);
      expect(zh.create, isNotEmpty);
      expect(zh.novel, isNotEmpty);
      expect(zh.chapters, isNotEmpty);
      expect(zh.chapter, isNotEmpty);
      expect(zh.novelMetadata, isNotEmpty);
      expect(zh.descriptionLabel, isNotEmpty);
      expect(zh.coverUrlLabel, isNotEmpty);
      expect(zh.invalidCoverUrl, isNotEmpty);
      expect(zh.updateNovel, isNotEmpty);
      expect(zh.deleteNovel, isNotEmpty);
      expect(zh.deleteNovelConfirmation, isNotEmpty);

      // Chapters
      expect(zh.errorLoadingChapters, isNotEmpty);
      expect(zh.loadingChapter, isNotEmpty);
      expect(zh.notStarted, isNotEmpty);
      expect(zh.unknownNovel, isNotEmpty);
      expect(zh.unknownChapter, isNotEmpty);
      expect(zh.chapterTitle, isNotEmpty);
      expect(zh.noChaptersFound, isNotEmpty);

      // TTS
      expect(zh.ttsSettings, isNotEmpty);
      expect(zh.enableTTS, isNotEmpty);
      expect(zh.speechRate, isNotEmpty);
      expect(zh.volume, isNotEmpty);
      expect(zh.pitch, isNotEmpty);
      expect(zh.defaultTTSVoice, isNotEmpty);
      expect(zh.testVoice, isNotEmpty);
      expect(zh.stopTTS, isNotEmpty);
      expect(zh.speak, isNotEmpty);
      expect(zh.reloadVoices, isNotEmpty);
      expect(zh.defaultVoiceUpdated, isNotEmpty);
      expect(zh.defaultLanguageSet, isNotEmpty);
      expect(zh.searchByTitle, isNotEmpty);
      expect(zh.chooseLanguage, isNotEmpty);

      // Settings
      expect(zh.appSettings, isNotEmpty);
      expect(zh.supabaseSettings, isNotEmpty);
      expect(zh.supabaseNotEnabled, isNotEmpty);
      expect(zh.supabaseNotEnabledDescription, isNotEmpty);
      expect(zh.authDisabledInBuild, isNotEmpty);
      expect(zh.fetchFromSupabase, isNotEmpty);
      expect(zh.fetchFromSupabaseDescription, isNotEmpty);
      expect(zh.confirmFetch, isNotEmpty);
      expect(zh.confirmFetchDescription, isNotEmpty);
      expect(zh.cancel, isNotEmpty);
      expect(zh.fetch, isNotEmpty);
      expect(zh.downloadChapters, isNotEmpty);
      expect(zh.modeSupabase, isNotEmpty);
      expect(zh.modeMockData, isNotEmpty);

      // Error
      expect(zh.error, isNotEmpty);
      expect(zh.errorSavingProgress, isNotEmpty);
      expect(zh.errorUnauthorized, isNotEmpty);
      expect(zh.errorForbidden, isNotEmpty);
      expect(zh.errorNotFound, isNotEmpty);
      expect(zh.loginFailed, isNotEmpty);

      // Themes
      expect(zh.themeMode, isNotEmpty);
      expect(zh.system, isNotEmpty);
      expect(zh.light, isNotEmpty);
      expect(zh.dark, isNotEmpty);
      expect(zh.colorTheme, isNotEmpty);
      expect(zh.themeLight, isNotEmpty);
      expect(zh.themeSepia, isNotEmpty);
      expect(zh.themeHighContrast, isNotEmpty);
      expect(zh.themeDefault, isNotEmpty);
      expect(zh.separateDarkPalette, isNotEmpty);
      expect(zh.lightPalette, isNotEmpty);
      expect(zh.darkPalette, isNotEmpty);
      expect(zh.separateTypographyPresets, isNotEmpty);
      expect(zh.typographyLight, isNotEmpty);
      expect(zh.typographyDark, isNotEmpty);

      // Navigation
      expect(zh.navigation, isNotEmpty);
      expect(zh.home, isNotEmpty);
      expect(zh.libraryTitle, isNotEmpty);
      expect(zh.discover, isNotEmpty);
      expect(zh.profile, isNotEmpty);
      expect(zh.close, isNotEmpty);
    });

    test('ALL string getters are non-empty - Part 2', () {
      // Summaries
      expect(zh.sentenceSummary, isNotEmpty);
      expect(zh.paragraphSummary, isNotEmpty);
      expect(zh.pageSummary, isNotEmpty);
      expect(zh.expandedSummary, isNotEmpty);
      expect(zh.noSentenceSummary, isNotEmpty);
      expect(zh.noParagraphSummary, isNotEmpty);
      expect(zh.noPageSummary, isNotEmpty);
      expect(zh.noExpandedSummary, isNotEmpty);

      // Biometrics
      expect(zh.signInWithBiometrics, isNotEmpty);
      expect(zh.enableBiometricLogin, isNotEmpty);
      expect(zh.enableBiometricLoginDescription, isNotEmpty);
      expect(zh.biometricAuthFailed, isNotEmpty);
      expect(zh.saveCredentialsForBiometric, isNotEmpty);
      expect(zh.saveCredentialsForBiometricDescription, isNotEmpty);
      expect(zh.biometricTokensExpired, isNotEmpty);
      expect(zh.biometricNoTokens, isNotEmpty);
      expect(zh.biometricTokenError, isNotEmpty);
      expect(zh.biometricTechnicalError, isNotEmpty);

      // Performance
      expect(zh.reduceMotion, isNotEmpty);
      expect(zh.gesturesEnabled, isNotEmpty);
      expect(zh.gesturesEnabledDescription, isNotEmpty);
      expect(zh.readerSwipeSensitivity, isNotEmpty);
      expect(zh.readerSwipeSensitivityDescription, isNotEmpty);
      expect(zh.prefetchNextChapter, isNotEmpty);
      expect(zh.prefetchNextChapterDescription, isNotEmpty);
      expect(zh.clearOfflineCache, isNotEmpty);
      expect(zh.offlineCacheCleared, isNotEmpty);
      expect(zh.performanceSettings, isNotEmpty);

      // Library
      expect(zh.allFilter, isNotEmpty);
      expect(zh.readingFilter, isNotEmpty);
      expect(zh.completedFilter, isNotEmpty);
      expect(zh.downloadedFilter, isNotEmpty);
      expect(zh.listView, isNotEmpty);
      expect(zh.gridView, isNotEmpty);

      // Progress tracking
      expect(zh.progressSaved, isNotEmpty);
      expect(zh.continueReading, isNotEmpty);
      expect(zh.continueAtChapter('Ch1'), contains('Ch1'));
      expect(zh.scrollOffset, isNotEmpty);
      expect(zh.ttsIndex, isNotEmpty);

      // Templates
      expect(zh.characterTemplates, isNotEmpty);
      expect(zh.sceneTemplates, isNotEmpty);
      expect(zh.templateLabel, isNotEmpty);
      expect(zh.templateName, isNotEmpty);
      expect(zh.exampleCharacterName, isNotEmpty);
      expect(zh.failedToLoadChapter('err'), contains('err'));

      // AI
      expect(zh.aiAssistant, isNotEmpty);
      expect(zh.aiChatHistory, isNotEmpty);
      expect(zh.aiChatNewChat, isNotEmpty);
      expect(zh.aiChatHint, isNotEmpty);
      expect(zh.aiThinking, isNotEmpty);
      expect(zh.aiChatEmpty, isNotEmpty);
      expect(zh.aiServiceUrl, isNotEmpty);
      expect(zh.aiContextLoadError('err'), contains('err'));
      expect(zh.aiChatContextTooLongCompressing(100), contains('100'));
      expect(zh.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(zh.aiChatError('err'), contains('err'));
      expect(zh.aiChatSearchError('err'), contains('err'));
      expect(zh.aiServiceFailedToConnect('err'), contains('err'));

      // Deep Agent
      expect(zh.aiDeepAgentDetailsTitle, isNotEmpty);
      expect(zh.deepAgentSettingsTitle, isNotEmpty);
      expect(zh.deepAgentSettingsDescription, isNotEmpty);
      expect(zh.deepAgentPreferTitle, isNotEmpty);
      expect(zh.deepAgentPreferSubtitle, isNotEmpty);
      expect(zh.deepAgentFallbackTitle, isNotEmpty);
      expect(zh.deepAgentFallbackSubtitle, isNotEmpty);
      expect(zh.deepAgentReflectionModeTitle, isNotEmpty);
      expect(zh.deepAgentReflectionModeSubtitle, isNotEmpty);
      expect(zh.deepAgentReflectionModeOff, isNotEmpty);
      expect(zh.deepAgentReflectionModeOnFailure, isNotEmpty);
      expect(zh.deepAgentReflectionModeAlways, isNotEmpty);

      // Tokens
      expect(zh.totalThisMonth, isNotEmpty);
      expect(zh.inputTokens, isNotEmpty);
      expect(zh.outputTokens, isNotEmpty);
      expect(zh.requests, isNotEmpty);
      expect(zh.viewHistory, isNotEmpty);
      expect(zh.noUsageThisMonth, isNotEmpty);
      expect(zh.startUsingAiFeatures, isNotEmpty);
      expect(zh.errorLoadingUsage, isNotEmpty);
      expect(zh.noUsageHistory, isNotEmpty);

      // RAG
      expect(zh.aiChatRagSearchResultsTitle, isNotEmpty);
      expect(zh.aiChatRagRefinedQuery('q'), contains('q'));
      expect(zh.aiChatRagNoResults, isNotEmpty);
      expect(zh.aiChatRagUnknownType, isNotEmpty);

      // User Management
      expect(zh.userManagement, isNotEmpty);
      expect(zh.contributorEmailLabel, isNotEmpty);
      expect(zh.contributorEmailHint, isNotEmpty);
      expect(zh.addContributor, isNotEmpty);
      expect(zh.contributorAdded, isNotEmpty);
      expect(zh.accessDeniedNoAdminPrivileges, isNotEmpty);
      expect(zh.failedToLoadUsers(404, 'msg'), contains('404'));
      expect(zh.userIdCreated('id', 'date'), contains('id'));

      // Prompts/Patterns
      expect(zh.prompts, isNotEmpty);
      expect(zh.patterns, isNotEmpty);
      expect(zh.storyLines, isNotEmpty);
      expect(zh.newPrompt, isNotEmpty);
      expect(zh.newPattern, isNotEmpty);
      expect(zh.newStoryLine, isNotEmpty);
      expect(zh.editPrompt, isNotEmpty);
      expect(zh.editPattern, isNotEmpty);
      expect(zh.editStoryLine, isNotEmpty);
      expect(zh.deletedWithTitle('t'), contains('t'));
      expect(zh.deleteFailedWithTitle('t'), contains('t'));
      expect(zh.deleteErrorWithMessage('e'), contains('e'));
      expect(zh.conversionFailed('e'), contains('e'));
      expect(zh.retrieveFailed('e'), contains('e'));
      expect(zh.makePublicPromptConfirm('k', 'l'), contains('k'));
      expect(zh.deletePromptConfirm('k', 'l'), contains('k'));

      // Fonts
      expect(zh.customFontFamily, isNotEmpty);
      expect(zh.commonFonts, isNotEmpty);
      expect(zh.systemFont, isNotEmpty);
      expect(zh.fontInter, isNotEmpty);
      expect(zh.fontMerriweather, isNotEmpty);
      expect(zh.readerFontSize, isNotEmpty);
      expect(zh.textScale, isNotEmpty);

      // Bundles
      expect(zh.bundleNordCalm, isNotEmpty);
      expect(zh.bundleSolarizedFocus, isNotEmpty);
      expect(zh.bundleHighContrastReadability, isNotEmpty);
      expect(zh.themeOceanDepths, isNotEmpty);
      expect(zh.themeSunsetBoulevard, isNotEmpty);
      expect(zh.themeForestCanopy, isNotEmpty);
      expect(zh.themeModernMinimalist, isNotEmpty);

      // AI Coach
      expect(zh.failedToAnalyze, isNotEmpty);
      expect(zh.aiCoachAnalyzing, isNotEmpty);
      expect(zh.startAiCoaching, isNotEmpty);
      expect(zh.refinementComplete, isNotEmpty);
      expect(zh.coachQuestion, isNotEmpty);
      expect(zh.summaryLooksGood, isNotEmpty);
      expect(zh.howToImprove, isNotEmpty);
      expect(zh.suggestionsLabel, isNotEmpty);

      // Edit Mode
      expect(zh.exitEdit, isNotEmpty);
      expect(zh.enterEditMode, isNotEmpty);
      expect(zh.exitEditMode, isNotEmpty);
      expect(zh.chapterContent, isNotEmpty);
      expect(zh.createNextChapter, isNotEmpty);
      expect(zh.enterChapterTitle, isNotEmpty);
      expect(zh.enterChapterContent, isNotEmpty);
      expect(zh.discardChangesTitle, isNotEmpty);
      expect(zh.discardChangesMessage, isNotEmpty);
      expect(zh.keepEditing, isNotEmpty);
      expect(zh.discardChanges, isNotEmpty);
      expect(zh.saveAndExit, isNotEmpty);

      // Password Reset
      expect(zh.requestFailed, isNotEmpty);
      expect(zh.ifAccountExistsResetLinkSent, isNotEmpty);
      expect(zh.enterEmailForResetLink, isNotEmpty);
      expect(zh.sendResetLink, isNotEmpty);
      expect(zh.passwordsDoNotMatch, isNotEmpty);
      expect(zh.sessionInvalidLoginAgain, isNotEmpty);
      expect(zh.updateFailed, isNotEmpty);
      expect(zh.passwordUpdatedSuccessfully, isNotEmpty);
      expect(zh.resetPassword, isNotEmpty);
      expect(zh.newPassword, isNotEmpty);
      expect(zh.confirmPassword, isNotEmpty);
      expect(zh.updatePassword, isNotEmpty);
      expect(zh.noActiveSessionFound, isNotEmpty);
      expect(zh.authenticationFailedSignInAgain, isNotEmpty);

      // Hot Topics
      expect(zh.hotTopics, isNotEmpty);
      expect(zh.hotTopicsSelectPlatform, isNotEmpty);
      expect(zh.hotTopicsAllPlatforms, isNotEmpty);
      expect(zh.hotTopicsPlatformWeibo, isNotEmpty);
      expect(zh.hotTopicsPlatformZhihu, isNotEmpty);
      expect(zh.hotTopicsPlatformDouyin, isNotEmpty);

      // Smart Search
      expect(zh.smartSearchRequiresSignIn, isNotEmpty);
      expect(zh.smartSearch, isNotEmpty);
      expect(zh.tryAdjustingSearchCreateNovel, isNotEmpty);

      // Offline
      expect(zh.youreOfflineLabel, isNotEmpty);
      expect(zh.youreOffline('t'), contains('t'));
      expect(zh.changesWillSync, isNotEmpty);
      expect(zh.changesWillSyncCount(5), contains('5'));

      // Reader
      expect(zh.readLabel, isNotEmpty);
      expect(zh.pause, isNotEmpty);
      expect(zh.start, isNotEmpty);
      expect(zh.readerBackgroundDepth, isNotEmpty);
      expect(zh.depthLow, isNotEmpty);
      expect(zh.depthMedium, isNotEmpty);
      expect(zh.depthHigh, isNotEmpty);

      // Actions
      expect(zh.send, isNotEmpty);
      expect(zh.copy, isNotEmpty);
      expect(zh.undo, isNotEmpty);
      expect(zh.preview, isNotEmpty);
      expect(zh.download, isNotEmpty);
      expect(zh.select, isNotEmpty);
      expect(zh.confirm, isNotEmpty);
      expect(zh.save, isNotEmpty);
      expect(zh.delete, isNotEmpty);
      expect(zh.edit, isNotEmpty);
      expect(zh.refresh, isNotEmpty);

      // Checkbox/Switch/Slider
      expect(zh.checkboxState(true), contains('true'));
      expect(zh.switchState(false), contains('false'));
      expect(zh.sliderValue('10'), contains('10'));

      // Contrast
      expect(zh.contrastIssuesDetected, isNotEmpty);
      expect(zh.foundContrastIssues(5), contains('5'));
      expect(zh.allGood, isNotEmpty);
      expect(zh.allGoodContrast, isNotEmpty);

      // Design System
      expect(zh.designSystemStyleGuide, isNotEmpty);
      expect(zh.styleGuide, isNotEmpty);
      expect(zh.styleGlassmorphism, isNotEmpty);
      expect(zh.styleNeumorphism, isNotEmpty);
      expect(zh.styleMinimalism, isNotEmpty);

      // Keyboard Shortcuts
      expect(zh.keyboardShortcuts, isNotEmpty);
      expect(zh.shortcutSpace, isNotEmpty);
      expect(zh.shortcutArrows, isNotEmpty);
      expect(zh.shortcutRate, isNotEmpty);
      expect(zh.shortcutVoice, isNotEmpty);
      expect(zh.shortcutHelp, isNotEmpty);
      expect(zh.shortcutEsc, isNotEmpty);

      // PDF
      expect(zh.pdf, isNotEmpty);
      expect(zh.generatingPdf, isNotEmpty);
      expect(zh.pdfFailed, isNotEmpty);
      expect(zh.tableOfContents, isNotEmpty);

      // Writing Tips
      expect(zh.tipIntention, isNotEmpty);
      expect(zh.tipVerbs, isNotEmpty);
      expect(zh.tipStuck, isNotEmpty);
      expect(zh.tipDialogue, isNotEmpty);

      // Markdown
      expect(zh.quote, isNotEmpty);
      expect(zh.inlineCode, isNotEmpty);
      expect(zh.bulletedList, isNotEmpty);
      expect(zh.numberedList, isNotEmpty);
      expect(zh.editTab, isNotEmpty);
      expect(zh.previewTab, isNotEmpty);
      expect(zh.editMode, isNotEmpty);
      expect(zh.previewMode, isNotEmpty);

      // Index
      expect(zh.indexLabel(1), contains('1'));
      expect(zh.indexOutOfRange(1, 10), contains('1'));

      // Chapters
      expect(zh.chaptersCount(100), contains('100'));
      expect(zh.chapterLabel(5), contains('5'));
      expect(zh.chapterWithTitle(5, 'T'), contains('5'));
      expect(zh.avgWordsPerChapter(5000), contains('5000'));

      // AI Token
      expect(zh.aiTokenCount(1000), contains('1000'));

      // Language
      expect(zh.languageLabel('en'), contains('en'));

      // Novel Actions
      expect(zh.confirmDeleteDescription('N'), contains('N'));
      expect(zh.removedNovel('N'), contains('N'));
      expect(zh.byAuthor('A'), contains('A'));

      // Page
      expect(zh.pageOfTotal(1, 100), contains('1'));

      // Cache
      expect(zh.showingCachedPublicData('d'), contains('d'));

      // Character Count
      expect(zh.charsCount(1000), contains('1000'));

      // Statistics
      expect(zh.totalRecords(100), contains('100'));

      // Word/Character Count
      expect(zh.wordCount(5000), contains('5000'));
      expect(zh.characterCount(10000), contains('10000'));

      // Progress Percentage
      expect(zh.progressPercentage(75), contains('75'));

      // Deep Agent Stop
      expect(zh.aiDeepAgentStop('r', 5), contains('r'));

      // Forgot Password
      expect(zh.forgotPassword, isNotEmpty);
      expect(zh.signUp, isNotEmpty);
      expect(zh.createAccount, isNotEmpty);
      expect(zh.backToSignIn, isNotEmpty);
      expect(zh.alreadyHaveAccountSignIn, isNotEmpty);
    });
  });

  group('AppLocalizationsZhTw - Mirror Tests', () {
    test('mirror ALL tests from Zh - Part 1', () {
      expect(zhTW.newChapter, isNotEmpty);
      expect(zhTW.back, isNotEmpty);
      expect(zhTW.helloWorld, isNotEmpty);
      expect(zhTW.settings, isNotEmpty);
      expect(zhTW.appTitle, isNotEmpty);
      expect(zhTW.about, isNotEmpty);
      expect(zhTW.aboutDescription, isNotEmpty);
      expect(zhTW.aboutIntro, isNotEmpty);
      expect(zhTW.aboutSecurity, isNotEmpty);
      expect(zhTW.aboutCoach, isNotEmpty);
      expect(zhTW.aboutFeatureCreate, isNotEmpty);
      expect(zhTW.aboutFeatureTemplates, isNotEmpty);
      expect(zhTW.aboutFeatureTracking, isNotEmpty);
      expect(zhTW.aboutFeatureCoach, isNotEmpty);
      expect(zhTW.aboutFeaturePrompts, isNotEmpty);
      expect(zhTW.aboutUsage, isNotEmpty);
      expect(zhTW.aboutUsageList, isNotEmpty);
      expect(zhTW.version, isNotEmpty);
      expect(zhTW.appLanguage, isNotEmpty);
      expect(zhTW.english, isNotEmpty);
      expect(zhTW.chinese, isNotEmpty);
      expect(zhTW.supabaseIntegrationInitialized, isNotEmpty);
      expect(zhTW.configureEnvironment, isNotEmpty);
      expect(zhTW.email, isNotEmpty);
      expect(zhTW.password, isNotEmpty);
      expect(zhTW.guest, isNotEmpty);
      expect(zhTW.notSignedIn, isNotEmpty);
      expect(zhTW.signIn, isNotEmpty);
      expect(zhTW.continueLabel, isNotEmpty);
      expect(zhTW.reload, isNotEmpty);
      expect(zhTW.signInToSync, isNotEmpty);
      expect(zhTW.signInWithGoogle, isNotEmpty);
      expect(zhTW.signInWithApple, isNotEmpty);
      expect(zhTW.signOut, isNotEmpty);
      expect(zhTW.signedOut, isNotEmpty);
      expect(zhTW.currentProgress, isNotEmpty);
      expect(zhTW.loadingProgress, isNotEmpty);
      expect(zhTW.recentlyRead, isNotEmpty);
      expect(zhTW.noSupabase, isNotEmpty);
      expect(zhTW.errorLoadingProgress, isNotEmpty);
      expect(zhTW.noProgress, isNotEmpty);
      expect(zhTW.errorLoadingNovels, isNotEmpty);
      expect(zhTW.loadingNovels, isNotEmpty);
      expect(zhTW.titleLabel, isNotEmpty);
      expect(zhTW.authorLabel, isNotEmpty);
      expect(zhTW.noNovelsFound, isNotEmpty);
      expect(zhTW.myNovels, isNotEmpty);
      expect(zhTW.createNovel, isNotEmpty);
      expect(zhTW.create, isNotEmpty);
      expect(zhTW.novel, isNotEmpty);
      expect(zhTW.chapters, isNotEmpty);
      expect(zhTW.chapter, isNotEmpty);
      expect(zhTW.novelMetadata, isNotEmpty);
      expect(zhTW.deleteNovelConfirmation, isNotEmpty);
      expect(zhTW.errorLoadingChapters, isNotEmpty);
      expect(zhTW.loadingChapter, isNotEmpty);
      expect(zhTW.notStarted, isNotEmpty);
      expect(zhTW.unknownNovel, isNotEmpty);
      expect(zhTW.unknownChapter, isNotEmpty);
      expect(zhTW.chapterTitle, isNotEmpty);
      expect(zhTW.noChaptersFound, isNotEmpty);
      expect(zhTW.ttsSettings, isNotEmpty);
      expect(zhTW.enableTTS, isNotEmpty);
      expect(zhTW.speechRate, isNotEmpty);
      expect(zhTW.volume, isNotEmpty);
      expect(zhTW.pitch, isNotEmpty);
      expect(zhTW.defaultTTSVoice, isNotEmpty);
      expect(zhTW.testVoice, isNotEmpty);
      expect(zhTW.stopTTS, isNotEmpty);
      expect(zhTW.speak, isNotEmpty);
      expect(zhTW.reloadVoices, isNotEmpty);
      expect(zhTW.defaultVoiceUpdated, isNotEmpty);
      expect(zhTW.defaultLanguageSet, isNotEmpty);
      expect(zhTW.searchByTitle, isNotEmpty);
      expect(zhTW.chooseLanguage, isNotEmpty);
      expect(zhTW.appSettings, isNotEmpty);
      expect(zhTW.supabaseSettings, isNotEmpty);
      expect(zhTW.supabaseNotEnabled, isNotEmpty);
      expect(zhTW.supabaseNotEnabledDescription, isNotEmpty);
      expect(zhTW.authDisabledInBuild, isNotEmpty);
      expect(zhTW.fetchFromSupabase, isNotEmpty);
      expect(zhTW.fetchFromSupabaseDescription, isNotEmpty);
      expect(zhTW.confirmFetch, isNotEmpty);
      expect(zhTW.confirmFetchDescription, isNotEmpty);
      expect(zhTW.cancel, isNotEmpty);
      expect(zhTW.fetch, isNotEmpty);
      expect(zhTW.downloadChapters, isNotEmpty);
      expect(zhTW.modeSupabase, isNotEmpty);
      expect(zhTW.modeMockData, isNotEmpty);
      expect(zhTW.error, isNotEmpty);
      expect(zhTW.errorSavingProgress, isNotEmpty);
      expect(zhTW.errorUnauthorized, isNotEmpty);
      expect(zhTW.errorForbidden, isNotEmpty);
      expect(zhTW.errorNotFound, isNotEmpty);
      expect(zhTW.loginFailed, isNotEmpty);
      expect(zhTW.themeMode, isNotEmpty);
      expect(zhTW.system, isNotEmpty);
      expect(zhTW.light, isNotEmpty);
      expect(zhTW.dark, isNotEmpty);
      expect(zhTW.colorTheme, isNotEmpty);
      expect(zhTW.themeLight, isNotEmpty);
      expect(zhTW.themeSepia, isNotEmpty);
      expect(zhTW.themeHighContrast, isNotEmpty);
      expect(zhTW.themeDefault, isNotEmpty);
      expect(zhTW.separateDarkPalette, isNotEmpty);
      expect(zhTW.lightPalette, isNotEmpty);
      expect(zhTW.darkPalette, isNotEmpty);
      expect(zhTW.separateTypographyPresets, isNotEmpty);
      expect(zhTW.typographyLight, isNotEmpty);
      expect(zhTW.typographyDark, isNotEmpty);
      expect(zhTW.navigation, isNotEmpty);
      expect(zhTW.home, isNotEmpty);
      expect(zhTW.libraryTitle, isNotEmpty);
      expect(zhTW.discover, isNotEmpty);
      expect(zhTW.profile, isNotEmpty);
      expect(zhTW.close, isNotEmpty);
    });

    test('mirror ALL tests from Zh - Part 2', () {
      expect(zhTW.sentenceSummary, isNotEmpty);
      expect(zhTW.paragraphSummary, isNotEmpty);
      expect(zhTW.pageSummary, isNotEmpty);
      expect(zhTW.expandedSummary, isNotEmpty);
      expect(zhTW.noSentenceSummary, isNotEmpty);
      expect(zhTW.noParagraphSummary, isNotEmpty);
      expect(zhTW.noPageSummary, isNotEmpty);
      expect(zhTW.noExpandedSummary, isNotEmpty);
      expect(zhTW.signInWithBiometrics, isNotEmpty);
      expect(zhTW.enableBiometricLogin, isNotEmpty);
      expect(zhTW.enableBiometricLoginDescription, isNotEmpty);
      expect(zhTW.biometricAuthFailed, isNotEmpty);
      expect(zhTW.saveCredentialsForBiometric, isNotEmpty);
      expect(zhTW.saveCredentialsForBiometricDescription, isNotEmpty);
      expect(zhTW.biometricTokensExpired, isNotEmpty);
      expect(zhTW.biometricNoTokens, isNotEmpty);
      expect(zhTW.biometricTokenError, isNotEmpty);
      expect(zhTW.biometricTechnicalError, isNotEmpty);
      expect(zhTW.reduceMotion, isNotEmpty);
      expect(zhTW.gesturesEnabled, isNotEmpty);
      expect(zhTW.gesturesEnabledDescription, isNotEmpty);
      expect(zhTW.readerSwipeSensitivity, isNotEmpty);
      expect(zhTW.readerSwipeSensitivityDescription, isNotEmpty);
      expect(zhTW.prefetchNextChapter, isNotEmpty);
      expect(zhTW.prefetchNextChapterDescription, isNotEmpty);
      expect(zhTW.clearOfflineCache, isNotEmpty);
      expect(zhTW.offlineCacheCleared, isNotEmpty);
      expect(zhTW.performanceSettings, isNotEmpty);
      expect(zhTW.allFilter, isNotEmpty);
      expect(zhTW.readingFilter, isNotEmpty);
      expect(zhTW.completedFilter, isNotEmpty);
      expect(zhTW.downloadedFilter, isNotEmpty);
      expect(zhTW.listView, isNotEmpty);
      expect(zhTW.gridView, isNotEmpty);
      expect(zhTW.progressSaved, isNotEmpty);
      expect(zhTW.continueReading, isNotEmpty);
      expect(zhTW.characterTemplates, isNotEmpty);
      expect(zhTW.sceneTemplates, isNotEmpty);
      expect(zhTW.templateLabel, isNotEmpty);
      expect(zhTW.templateName, isNotEmpty);
      expect(zhTW.exampleCharacterName, isNotEmpty);
      expect(zhTW.aiAssistant, isNotEmpty);
      expect(zhTW.aiChatHistory, isNotEmpty);
      expect(zhTW.aiChatNewChat, isNotEmpty);
      expect(zhTW.aiChatHint, isNotEmpty);
      expect(zhTW.aiThinking, isNotEmpty);
      expect(zhTW.aiChatEmpty, isNotEmpty);
      expect(zhTW.aiServiceUrl, isNotEmpty);
      expect(zhTW.aiDeepAgentDetailsTitle, isNotEmpty);
      expect(zhTW.deepAgentSettingsTitle, isNotEmpty);
      expect(zhTW.deepAgentPreferTitle, isNotEmpty);
      expect(zhTW.deepAgentFallbackTitle, isNotEmpty);
      expect(zhTW.deepAgentReflectionModeTitle, isNotEmpty);
      expect(zhTW.totalThisMonth, isNotEmpty);
      expect(zhTW.inputTokens, isNotEmpty);
      expect(zhTW.outputTokens, isNotEmpty);
      expect(zhTW.noUsageThisMonth, isNotEmpty);
      expect(zhTW.aiChatRagSearchResultsTitle, isNotEmpty);
      expect(zhTW.aiChatRagNoResults, isNotEmpty);
      expect(zhTW.userManagement, isNotEmpty);
      expect(zhTW.contributorEmailLabel, isNotEmpty);
      expect(zhTW.contributorEmailHint, isNotEmpty);
      expect(zhTW.addContributor, isNotEmpty);
      expect(zhTW.contributorAdded, isNotEmpty);
      expect(zhTW.accessDeniedNoAdminPrivileges, isNotEmpty);
      expect(zhTW.prompts, isNotEmpty);
      expect(zhTW.patterns, isNotEmpty);
      expect(zhTW.storyLines, isNotEmpty);
      expect(zhTW.newPrompt, isNotEmpty);
      expect(zhTW.newPattern, isNotEmpty);
      expect(zhTW.newStoryLine, isNotEmpty);
      expect(zhTW.editPrompt, isNotEmpty);
      expect(zhTW.editPattern, isNotEmpty);
      expect(zhTW.editStoryLine, isNotEmpty);
      expect(zhTW.customFontFamily, isNotEmpty);
      expect(zhTW.commonFonts, isNotEmpty);
      expect(zhTW.systemFont, isNotEmpty);
      expect(zhTW.readerFontSize, isNotEmpty);
      expect(zhTW.bundleNordCalm, isNotEmpty);
      expect(zhTW.bundleSolarizedFocus, isNotEmpty);
      expect(zhTW.themeOceanDepths, isNotEmpty);
      expect(zhTW.themeSunsetBoulevard, isNotEmpty);
      expect(zhTW.failedToAnalyze, isNotEmpty);
      expect(zhTW.aiCoachAnalyzing, isNotEmpty);
      expect(zhTW.startAiCoaching, isNotEmpty);
      expect(zhTW.refinementComplete, isNotEmpty);
      expect(zhTW.coachQuestion, isNotEmpty);
      expect(zhTW.exitEdit, isNotEmpty);
      expect(zhTW.enterEditMode, isNotEmpty);
      expect(zhTW.exitEditMode, isNotEmpty);
      expect(zhTW.chapterContent, isNotEmpty);
      expect(zhTW.createNextChapter, isNotEmpty);
      expect(zhTW.discardChangesTitle, isNotEmpty);
      expect(zhTW.discardChangesMessage, isNotEmpty);
      expect(zhTW.keepEditing, isNotEmpty);
      expect(zhTW.discardChanges, isNotEmpty);
      expect(zhTW.saveAndExit, isNotEmpty);
      expect(zhTW.requestFailed, isNotEmpty);
      expect(zhTW.passwordsDoNotMatch, isNotEmpty);
      expect(zhTW.passwordUpdatedSuccessfully, isNotEmpty);
      expect(zhTW.resetPassword, isNotEmpty);
      expect(zhTW.newPassword, isNotEmpty);
      expect(zhTW.confirmPassword, isNotEmpty);
      expect(zhTW.updatePassword, isNotEmpty);
      expect(zhTW.noActiveSessionFound, isNotEmpty);
      expect(zhTW.hotTopics, isNotEmpty);
      expect(zhTW.hotTopicsSelectPlatform, isNotEmpty);
      expect(zhTW.hotTopicsAllPlatforms, isNotEmpty);
      expect(zhTW.hotTopicsPlatformWeibo, isNotEmpty);
      expect(zhTW.hotTopicsPlatformZhihu, isNotEmpty);
      expect(zhTW.hotTopicsPlatformDouyin, isNotEmpty);
      expect(zhTW.smartSearchRequiresSignIn, isNotEmpty);
      expect(zhTW.smartSearch, isNotEmpty);
      expect(zhTW.youreOfflineLabel, isNotEmpty);
      expect(zhTW.youreOffline('t'), contains('t'));
      expect(zhTW.changesWillSync, isNotEmpty);
      expect(zhTW.readLabel, isNotEmpty);
      expect(zhTW.pause, isNotEmpty);
      expect(zhTW.start, isNotEmpty);
      expect(zhTW.depthLow, isNotEmpty);
      expect(zhTW.depthMedium, isNotEmpty);
      expect(zhTW.depthHigh, isNotEmpty);
      expect(zhTW.send, isNotEmpty);
      expect(zhTW.copy, isNotEmpty);
      expect(zhTW.undo, isNotEmpty);
      expect(zhTW.preview, isNotEmpty);
      expect(zhTW.download, isNotEmpty);
      expect(zhTW.select, isNotEmpty);
      expect(zhTW.confirm, isNotEmpty);
      expect(zhTW.save, isNotEmpty);
      expect(zhTW.delete, isNotEmpty);
      expect(zhTW.edit, isNotEmpty);
      expect(zhTW.refresh, isNotEmpty);
      expect(zhTW.checkboxState(true), contains('true'));
      expect(zhTW.switchState(false), contains('false'));
      expect(zhTW.sliderValue('10'), contains('10'));
      expect(zhTW.contrastIssuesDetected, isNotEmpty);
      expect(zhTW.foundContrastIssues(5), contains('5'));
      expect(zhTW.allGood, isNotEmpty);
      expect(zhTW.allGoodContrast, isNotEmpty);
      expect(zhTW.designSystemStyleGuide, isNotEmpty);
      expect(zhTW.styleGuide, isNotEmpty);
      expect(zhTW.styleGlassmorphism, isNotEmpty);
      expect(zhTW.styleNeumorphism, isNotEmpty);
      expect(zhTW.styleMinimalism, isNotEmpty);
      expect(zhTW.keyboardShortcuts, isNotEmpty);
      expect(zhTW.shortcutSpace, isNotEmpty);
      expect(zhTW.shortcutArrows, isNotEmpty);
      expect(zhTW.shortcutRate, isNotEmpty);
      expect(zhTW.shortcutVoice, isNotEmpty);
      expect(zhTW.shortcutHelp, isNotEmpty);
      expect(zhTW.shortcutEsc, isNotEmpty);
      expect(zhTW.pdf, isNotEmpty);
      expect(zhTW.generatingPdf, isNotEmpty);
      expect(zhTW.pdfFailed, isNotEmpty);
      expect(zhTW.tableOfContents, isNotEmpty);
      expect(zhTW.tipIntention, isNotEmpty);
      expect(zhTW.tipVerbs, isNotEmpty);
      expect(zhTW.tipStuck, isNotEmpty);
      expect(zhTW.tipDialogue, isNotEmpty);
      expect(zhTW.quote, isNotEmpty);
      expect(zhTW.inlineCode, isNotEmpty);
      expect(zhTW.bulletedList, isNotEmpty);
      expect(zhTW.numberedList, isNotEmpty);
      expect(zhTW.editTab, isNotEmpty);
      expect(zhTW.previewTab, isNotEmpty);
      expect(zhTW.editMode, isNotEmpty);
      expect(zhTW.previewMode, isNotEmpty);
      expect(zhTW.indexLabel(1), contains('1'));
      expect(zhTW.indexOutOfRange(1, 10), contains('1'));
      expect(zhTW.chaptersCount(100), contains('100'));
      expect(zhTW.chapterLabel(5), contains('5'));
      expect(zhTW.chapterWithTitle(5, 'T'), contains('5'));
      expect(zhTW.avgWordsPerChapter(5000), contains('5000'));
      expect(zhTW.aiTokenCount(1000), contains('1000'));
      expect(zhTW.languageLabel('en'), contains('en'));
      expect(zhTW.confirmDeleteDescription('N'), contains('N'));
      expect(zhTW.removedNovel('N'), contains('N'));
      expect(zhTW.byAuthor('A'), contains('A'));
      expect(zhTW.pageOfTotal(1, 100), contains('1'));
      expect(zhTW.deletedWithTitle('t'), contains('t'));
      expect(zhTW.conversionFailed('e'), contains('e'));
      expect(zhTW.charsCount(1000), contains('1000'));
      expect(zhTW.totalRecords(100), contains('100'));
      expect(zhTW.wordCount(5000), contains('5000'));
      expect(zhTW.characterCount(10000), contains('10000'));
      expect(zhTW.progressPercentage(75), contains('75'));
      expect(zhTW.aiDeepAgentStop('r', 5), contains('r'));
      expect(zhTW.forgotPassword, isNotEmpty);
      expect(zhTW.signUp, isNotEmpty);
      expect(zhTW.createAccount, isNotEmpty);
      expect(zhTW.backToSignIn, isNotEmpty);
      expect(zhTW.alreadyHaveAccountSignIn, isNotEmpty);
    });
  });
}
