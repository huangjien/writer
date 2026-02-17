import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - Extra Coverage Boost', () {
    test('all Deep Agent settings strings work', () {
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
      expect(zh.aiDeepAgentDetailsTitle, isNotEmpty);
    });

    test('all AI context strings work', () {
      expect(zh.aiContextLoadError('err'), contains('err'));
      expect(zh.aiChatContextTooLongCompressing(5000), contains('5000'));
      expect(zh.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(zh.aiChatSearchError('err'), contains('err'));
      expect(zh.aiServiceFailedToConnect('err'), contains('err'));
    });

    test('all RAG strings work', () {
      expect(zh.aiChatRagSearchResultsTitle, isNotEmpty);
      expect(zh.aiChatRagRefinedQuery('query'), contains('query'));
      expect(zh.aiChatRagNoResults, isNotEmpty);
      expect(zh.aiChatRagUnknownType, isNotEmpty);
    });

    test('all user management strings work', () {
      expect(zh.userManagement, isNotEmpty);
      expect(zh.contributorEmailLabel, isNotEmpty);
      expect(zh.contributorEmailHint, isNotEmpty);
      expect(zh.addContributor, isNotEmpty);
      expect(zh.contributorAdded, isNotEmpty);
      expect(zh.accessDeniedNoAdminPrivileges, isNotEmpty);
      expect(zh.failedToLoadUsers(404, 'err'), contains('404'));
      expect(zh.userIdCreated('123', '2024'), contains('123'));
    });

    test('all prompt/pattern management strings work', () {
      expect(zh.prompts, isNotEmpty);
      expect(zh.patterns, isNotEmpty);
      expect(zh.storyLines, isNotEmpty);
      expect(zh.newPrompt, isNotEmpty);
      expect(zh.newPattern, isNotEmpty);
      expect(zh.newStoryLine, isNotEmpty);
      expect(zh.editPrompt, isNotEmpty);
      expect(zh.editPattern, isNotEmpty);
      expect(zh.editStoryLine, isNotEmpty);
      expect(zh.deletedWithTitle('title'), contains('title'));
      expect(zh.deleteFailedWithTitle('title'), contains('title'));
      expect(zh.deleteErrorWithMessage('err'), contains('err'));
      expect(zh.conversionFailed('err'), contains('err'));
      expect(zh.retrieveFailed('err'), contains('err'));
      expect(zh.makePublicPromptConfirm('key', 'en'), contains('key'));
      expect(zh.deletePromptConfirm('key', 'en'), contains('key'));
    });

    test('all library filter strings work', () {
      expect(zh.allFilter, isNotEmpty);
      expect(zh.readingFilter, isNotEmpty);
      expect(zh.completedFilter, isNotEmpty);
      expect(zh.downloadedFilter, isNotEmpty);
      expect(zh.listView, isNotEmpty);
      expect(zh.gridView, isNotEmpty);
    });

    test('all token usage strings work', () {
      expect(zh.totalThisMonth, isNotEmpty);
      expect(zh.inputTokens, isNotEmpty);
      expect(zh.outputTokens, isNotEmpty);
      expect(zh.requests, isNotEmpty);
      expect(zh.viewHistory, isNotEmpty);
      expect(zh.noUsageThisMonth, isNotEmpty);
      expect(zh.startUsingAiFeatures, isNotEmpty);
      expect(zh.errorLoadingUsage, isNotEmpty);
      expect(zh.noUsageHistory, isNotEmpty);
    });

    test('all gesture/performance strings work', () {
      expect(zh.gesturesEnabledDescription, isNotEmpty);
      expect(zh.readerSwipeSensitivity, isNotEmpty);
      expect(zh.readerSwipeSensitivityDescription, isNotEmpty);
      expect(zh.prefetchNextChapter, isNotEmpty);
      expect(zh.prefetchNextChapterDescription, isNotEmpty);
      expect(zh.clearOfflineCache, isNotEmpty);
      expect(zh.offlineCacheCleared, isNotEmpty);
    });

    test('all edit mode strings work', () {
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
    });

    test('all password reset strings work', () {
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
    });

    test('all theme palette strings work', () {
      expect(zh.separateDarkPalette, isNotEmpty);
      expect(zh.lightPalette, isNotEmpty);
      expect(zh.darkPalette, isNotEmpty);
      expect(zh.separateTypographyPresets, isNotEmpty);
      expect(zh.typographyLight, isNotEmpty);
      expect(zh.typographyDark, isNotEmpty);
    });

    test('all hot topics strings work', () {
      expect(zh.hotTopics, isNotEmpty);
      expect(zh.hotTopicsSelectPlatform, isNotEmpty);
      expect(zh.hotTopicsAllPlatforms, isNotEmpty);
      expect(zh.hotTopicsPlatformWeibo, isNotEmpty);
      expect(zh.hotTopicsPlatformZhihu, isNotEmpty);
      expect(zh.hotTopicsPlatformDouyin, isNotEmpty);
    });

    test('all offline strings work', () {
      expect(zh.youreOfflineLabel, isNotEmpty);
      expect(zh.youreOffline('test'), contains('test'));
      expect(zh.changesWillSync, isNotEmpty);
      expect(zh.changesWillSyncCount(5), contains('5'));
    });

    test('all about strings work', () {
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
    });

    test('all biometric strings work', () {
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
    });

    test('all markdown/editor strings work', () {
      expect(zh.quote, isNotEmpty);
      expect(zh.inlineCode, isNotEmpty);
      expect(zh.bulletedList, isNotEmpty);
      expect(zh.numberedList, isNotEmpty);
      expect(zh.editTab, isNotEmpty);
      expect(zh.previewTab, isNotEmpty);
      expect(zh.editMode, isNotEmpty);
      expect(zh.previewMode, isNotEmpty);
    });

    test('all PDF strings work', () {
      expect(zh.pdf, isNotEmpty);
      expect(zh.generatingPdf, isNotEmpty);
      expect(zh.pdfFailed, isNotEmpty);
      expect(zh.tableOfContents, isNotEmpty);
    });

    test('all writing tip strings work', () {
      expect(zh.tipIntention, isNotEmpty);
      expect(zh.tipVerbs, isNotEmpty);
      expect(zh.tipStuck, isNotEmpty);
      expect(zh.tipDialogue, isNotEmpty);
    });

    test('all accessibility strings work', () {
      expect(zh.contrastIssuesDetected, isNotEmpty);
      expect(zh.foundContrastIssues(5), contains('5'));
      expect(zh.allGood, isNotEmpty);
      expect(zh.allGoodContrast, isNotEmpty);
    });

    test('all design system strings work', () {
      expect(zh.designSystemStyleGuide, isNotEmpty);
      expect(zh.styleGuide, isNotEmpty);
      expect(zh.styleGlassmorphism, isNotEmpty);
      expect(zh.styleNeumorphism, isNotEmpty);
      expect(zh.styleMinimalism, isNotEmpty);
    });

    test('all keyboard shortcut strings work', () {
      expect(zh.keyboardShortcuts, isNotEmpty);
      expect(zh.shortcutSpace, isNotEmpty);
      expect(zh.shortcutArrows, isNotEmpty);
      expect(zh.shortcutRate, isNotEmpty);
      expect(zh.shortcutVoice, isNotEmpty);
      expect(zh.shortcutHelp, isNotEmpty);
      expect(zh.shortcutEsc, isNotEmpty);
    });

    test('all statistics strings work', () {
      expect(zh.totalRecords(100), contains('100'));
    });

    test('all template strings work', () {
      expect(zh.failedToLoadChapter('err'), contains('err'));
    });

    test('all character count strings work', () {
      expect(zh.charsCount(1000), contains('1000'));
    });

    test('all cache strings work', () {
      expect(zh.showingCachedPublicData('test'), contains('test'));
    });
  });

  group('AppLocalizationsZhTw - Extra Coverage Boost', () {
    test('all Deep Agent settings strings work', () {
      expect(zhTW.deepAgentSettingsTitle, isNotEmpty);
      expect(zhTW.deepAgentPreferTitle, isNotEmpty);
      expect(zhTW.deepAgentFallbackTitle, isNotEmpty);
      expect(zhTW.deepAgentReflectionModeTitle, isNotEmpty);
      expect(zhTW.aiDeepAgentDetailsTitle, isNotEmpty);
    });

    test('all AI context strings work', () {
      expect(zhTW.aiContextLoadError('err'), contains('err'));
      expect(zhTW.aiChatContextTooLongCompressing(5000), contains('5000'));
      expect(zhTW.aiChatError('err'), contains('err'));
      expect(zhTW.aiServiceFailedToConnect('err'), contains('err'));
    });

    test('all RAG strings work', () {
      expect(zhTW.aiChatRagSearchResultsTitle, isNotEmpty);
      expect(zhTW.aiChatRagRefinedQuery('query'), contains('query'));
      expect(zhTW.aiChatRagNoResults, isNotEmpty);
    });

    test('all user management strings work', () {
      expect(zhTW.userManagement, isNotEmpty);
      expect(zhTW.contributorEmailLabel, isNotEmpty);
      expect(zhTW.addContributor, isNotEmpty);
      expect(zhTW.contributorAdded, isNotEmpty);
      expect(zhTW.accessDeniedNoAdminPrivileges, isNotEmpty);
    });

    test('all prompt/pattern management strings work', () {
      expect(zhTW.prompts, isNotEmpty);
      expect(zhTW.patterns, isNotEmpty);
      expect(zhTW.storyLines, isNotEmpty);
      expect(zhTW.deletedWithTitle('title'), contains('title'));
      expect(zhTW.conversionFailed('err'), contains('err'));
    });

    test('all library filter strings work', () {
      expect(zhTW.allFilter, isNotEmpty);
      expect(zhTW.readingFilter, isNotEmpty);
      expect(zhTW.listView, isNotEmpty);
    });

    test('all token usage strings work', () {
      expect(zhTW.totalThisMonth, isNotEmpty);
      expect(zhTW.inputTokens, isNotEmpty);
      expect(zhTW.noUsageThisMonth, isNotEmpty);
    });

    test('all edit mode strings work', () {
      expect(zhTW.exitEdit, isNotEmpty);
      expect(zhTW.enterEditMode, isNotEmpty);
      expect(zhTW.discardChangesTitle, isNotEmpty);
      expect(zhTW.keepEditing, isNotEmpty);
    });

    test('all password reset strings work', () {
      expect(zhTW.requestFailed, isNotEmpty);
      expect(zhTW.passwordsDoNotMatch, isNotEmpty);
      expect(zhTW.passwordUpdatedSuccessfully, isNotEmpty);
      expect(zhTW.noActiveSessionFound, isNotEmpty);
    });

    test('all theme palette strings work', () {
      expect(zhTW.separateDarkPalette, isNotEmpty);
      expect(zhTW.lightPalette, isNotEmpty);
      expect(zhTW.darkPalette, isNotEmpty);
    });

    test('all offline strings work', () {
      expect(zhTW.youreOfflineLabel, isNotEmpty);
      expect(zhTW.youreOffline('test'), contains('test'));
    });

    test('all biometric strings work', () {
      expect(zhTW.signInWithBiometrics, isNotEmpty);
      expect(zhTW.enableBiometricLogin, isNotEmpty);
      expect(zhTW.biometricTokensExpired, isNotEmpty);
      expect(zhTW.biometricNoTokens, isNotEmpty);
    });

    test('all accessibility strings work', () {
      expect(zhTW.contrastIssuesDetected, isNotEmpty);
      expect(zhTW.foundContrastIssues(5), contains('5'));
      expect(zhTW.allGood, isNotEmpty);
    });
  });
}
