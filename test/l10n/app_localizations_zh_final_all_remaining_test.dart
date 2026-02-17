import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - Final All Remaining Properties', () {
    test('Motion and Gesture properties', () {
      expect(zh.gesturesEnabledDescription, isNotEmpty);
      expect(zh.readerSwipeSensitivity, isNotEmpty);
      expect(zh.readerSwipeSensitivityDescription, isNotEmpty);
      expect(zhTW.gesturesEnabledDescription, isNotEmpty);
      expect(zhTW.readerSwipeSensitivity, isNotEmpty);
    });

    test('Novel Management properties', () {
      expect(zh.remove, isNotEmpty);
      expect(zh.removedFromLibrary, isNotEmpty);
      expect(zh.confirmDelete, isNotEmpty);
      expect(zh.delete, isNotEmpty);
      expect(zhTW.remove, isNotEmpty);
      expect(zhTW.confirmDelete, isNotEmpty);
      expect(zhTW.delete, isNotEmpty);
    });

    test('Chapter Navigation properties', () {
      expect(zh.reachedFirstChapter, isNotEmpty);
      expect(zh.previousChapter, isNotEmpty);
      expect(zh.nextChapter, isNotEmpty);
      expect(zhTW.reachedFirstChapter, isNotEmpty);
      expect(zhTW.previousChapter, isNotEmpty);
      expect(zhTW.nextChapter, isNotEmpty);
    });

    test('Beta Evaluation properties', () {
      expect(zh.betaEvaluate, isNotEmpty);
      expect(zh.betaEvaluating, isNotEmpty);
      expect(zh.betaEvaluationReady, isNotEmpty);
      expect(zh.betaEvaluationFailed, isNotEmpty);
      expect(zhTW.betaEvaluate, isNotEmpty);
      expect(zhTW.betaEvaluationReady, isNotEmpty);
    });

    test('Performance Settings properties', () {
      expect(zh.performanceSettings, isNotEmpty);
      expect(zh.prefetchNextChapter, isNotEmpty);
      expect(zh.prefetchNextChapterDescription, isNotEmpty);
      expect(zh.clearOfflineCache, isNotEmpty);
      expect(zh.offlineCacheCleared, isNotEmpty);
      expect(zhTW.performanceSettings, isNotEmpty);
      expect(zhTW.clearOfflineCache, isNotEmpty);
    });

    test('Edit Mode properties', () {
      expect(zh.edit, isNotEmpty);
      expect(zh.exitEdit, isNotEmpty);
      expect(zh.enterEditMode, isNotEmpty);
      expect(zh.exitEditMode, isNotEmpty);
      expect(zh.chapterContent, isNotEmpty);
      expect(zh.save, isNotEmpty);
      expect(zhTW.edit, isNotEmpty);
      expect(zhTW.exitEdit, isNotEmpty);
      expect(zhTW.save, isNotEmpty);
    });

    test('Chapter Creation properties', () {
      expect(zh.enterChapterTitle, isNotEmpty);
      expect(zh.enterChapterContent, isNotEmpty);
      expect(zhTW.enterChapterTitle, isNotEmpty);
      expect(zhTW.enterChapterContent, isNotEmpty);
    });

    test('Discard Changes properties', () {
      expect(zh.discardChangesTitle, isNotEmpty);
      expect(zh.discardChangesMessage, isNotEmpty);
      expect(zh.keepEditing, isNotEmpty);
      expect(zh.discardChanges, isNotEmpty);
      expect(zh.saveAndExit, isNotEmpty);
      expect(zhTW.discardChangesTitle, isNotEmpty);
      expect(zhTW.keepEditing, isNotEmpty);
      expect(zhTW.saveAndExit, isNotEmpty);
    });

    test('Novel Metadata properties', () {
      expect(zh.descriptionLabel, isNotEmpty);
      expect(zh.coverUrlLabel, isNotEmpty);
      expect(zh.invalidCoverUrl, isNotEmpty);
      expect(zh.novelMetadata, isNotEmpty);
      expect(zhTW.descriptionLabel, isNotEmpty);
      expect(zhTW.coverUrlLabel, isNotEmpty);
      expect(zhTW.invalidCoverUrl, isNotEmpty);
    });

    test('Navigation properties', () {
      expect(zh.navigation, isNotEmpty);
      expect(zh.home, isNotEmpty);
      expect(zh.chapterIndex, isNotEmpty);
      expect(zhTW.navigation, isNotEmpty);
      expect(zhTW.home, isNotEmpty);
      expect(zhTW.chapterIndex, isNotEmpty);
    });

    test('Summary properties', () {
      expect(zh.summary, isNotEmpty);
      expect(zh.characters, isNotEmpty);
      expect(zh.scenes, isNotEmpty);
      expect(zh.characterTemplates, isNotEmpty);
      expect(zh.sceneTemplates, isNotEmpty);
      expect(zhTW.summary, isNotEmpty);
      expect(zhTW.characters, isNotEmpty);
      expect(zhTW.scenes, isNotEmpty);
    });

    test('Novel Update properties', () {
      expect(zh.updateNovel, isNotEmpty);
      expect(zh.deleteNovel, isNotEmpty);
      expect(zh.deleteNovelConfirmation, isNotEmpty);
      expect(zhTW.updateNovel, isNotEmpty);
      expect(zhTW.deleteNovel, isNotEmpty);
    });

    test('Format properties', () {
      expect(zh.format, isNotEmpty);
      expect(zh.aiServiceUrl, isNotEmpty);
      expect(zh.aiServiceUrlDescription, isNotEmpty);
      expect(zhTW.format, isNotEmpty);
      expect(zhTW.aiServiceUrl, isNotEmpty);
    });

    test('AI Assistant properties', () {
      expect(zh.aiAssistant, isNotEmpty);
      expect(zh.aiChatHistory, isNotEmpty);
      expect(zh.aiChatNewChat, isNotEmpty);
      expect(zh.aiChatNoHistory, isNotEmpty);
      expect(zh.aiChatHint, isNotEmpty);
      expect(zh.aiChatEmpty, isNotEmpty);
      expect(zh.aiThinking, isNotEmpty);
      expect(zh.aiChatContextLabel, isNotEmpty);
      expect(zhTW.aiAssistant, isNotEmpty);
      expect(zhTW.aiChatHistory, isNotEmpty);
      expect(zhTW.aiChatHint, isNotEmpty);
    });

    test('AI Error properties', () {
      expect(zh.aiChatSearchFailed, isNotEmpty);
      expect(zh.aiChatRagSearchResultsTitle, isNotEmpty);
      expect(zh.aiChatRagNoResults, isNotEmpty);
      expect(zh.aiChatRagUnknownType, isNotEmpty);
      expect(zh.aiServiceSignInRequired, isNotEmpty);
      expect(zh.aiServiceFeatureNotAvailable, isNotEmpty);
      expect(zh.aiServiceNoResponse, isNotEmpty);
      expect(zhTW.aiChatSearchFailed, isNotEmpty);
      expect(zhTW.aiChatRagNoResults, isNotEmpty);
    });

    test('Deep Agent properties', () {
      expect(zh.aiDeepAgentDetailsTitle, isNotEmpty);
      expect(zh.aiDeepAgentPlanLabel, isNotEmpty);
      expect(zh.aiDeepAgentToolsLabel, isNotEmpty);
      expect(zh.deepAgentSettingsTitle, isNotEmpty);
      expect(zh.deepAgentSettingsDescription, isNotEmpty);
      expect(zh.deepAgentPreferTitle, isNotEmpty);
      expect(zh.deepAgentPreferSubtitle, isNotEmpty);
      expect(zh.deepAgentFallbackTitle, isNotEmpty);
      expect(zh.deepAgentFallbackSubtitle, isNotEmpty);
      expect(zhTW.aiDeepAgentDetailsTitle, isNotEmpty);
      expect(zhTW.deepAgentSettingsTitle, isNotEmpty);
    });

    test('Deep Agent Reflection properties', () {
      expect(zh.deepAgentReflectionModeTitle, isNotEmpty);
      expect(zh.deepAgentReflectionModeSubtitle, isNotEmpty);
      expect(zh.deepAgentReflectionModeOff, isNotEmpty);
      expect(zh.deepAgentReflectionModeOnFailure, isNotEmpty);
      expect(zh.deepAgentReflectionModeAlways, isNotEmpty);
      expect(zhTW.deepAgentReflectionModeTitle, isNotEmpty);
      expect(zhTW.deepAgentReflectionModeOff, isNotEmpty);
    });

    test('Deep Agent Details properties', () {
      expect(zh.deepAgentShowDetailsTitle, isNotEmpty);
      expect(zh.deepAgentShowDetailsSubtitle, isNotEmpty);
      expect(zh.deepAgentMaxPlanSteps, isNotEmpty);
      expect(zh.deepAgentMaxToolRounds, isNotEmpty);
      expect(zhTW.deepAgentShowDetailsTitle, isNotEmpty);
      expect(zhTW.deepAgentMaxPlanSteps, isNotEmpty);
    });

    test('Action properties', () {
      expect(zh.send, isNotEmpty);
      expect(zh.resetToDefault, isNotEmpty);
      expect(zh.saved, isNotEmpty);
      expect(zhTW.send, isNotEmpty);
      expect(zhTW.resetToDefault, isNotEmpty);
      expect(zhTW.saved, isNotEmpty);
    });

    test('URL Validation properties', () {
      expect(zh.invalidUrl, isNotEmpty);
      expect(zh.urlTooLong, isNotEmpty);
      expect(zh.urlContainsSpaces, isNotEmpty);
      expect(zh.urlInvalidScheme, isNotEmpty);
      expect(zhTW.invalidUrl, isNotEmpty);
      expect(zhTW.urlTooLong, isNotEmpty);
    });

    test('Required and Labels properties', () {
      expect(zh.required, isNotEmpty);
      expect(zh.summariesLabel, isNotEmpty);
      expect(zh.synopsesLabel, isNotEmpty);
      expect(zh.locationLabel, isNotEmpty);
      expect(zhTW.required, isNotEmpty);
      expect(zhTW.summariesLabel, isNotEmpty);
      expect(zhTW.locationLabel, isNotEmpty);
    });

    test('Public/Private properties', () {
      expect(zh.publicLabel, isNotEmpty);
      expect(zh.privateLabel, isNotEmpty);
      expect(zhTW.publicLabel, isNotEmpty);
      expect(zhTW.privateLabel, isNotEmpty);
    });

    test('Novel Stats properties', () {
      expect(zh.refreshTooltip, isNotEmpty);
      expect(zh.untitled, isNotEmpty);
      expect(zh.newLabel, isNotEmpty);
      expect(zhTW.refreshTooltip, isNotEmpty);
      expect(zhTW.untitled, isNotEmpty);
    });

    test('Delete Confirmation properties', () {
      expect(zh.deleteSceneTitle, isNotEmpty);
      expect(zh.deleteCharacterTitle, isNotEmpty);
      expect(zh.deleteTemplateTitle, isNotEmpty);
      expect(zh.confirmDeleteGeneric, isNotEmpty);
      expect(zhTW.deleteSceneTitle, isNotEmpty);
      expect(zhTW.confirmDeleteGeneric, isNotEmpty);
    });

    test('Contributor properties', () {
      expect(zh.contributorEmailLabel, isNotEmpty);
      expect(zh.contributorEmailHint, isNotEmpty);
      expect(zh.addContributor, isNotEmpty);
      expect(zh.contributorAdded, isNotEmpty);
      expect(zhTW.contributorEmailLabel, isNotEmpty);
      expect(zhTW.addContributor, isNotEmpty);
    });

    test('PDF properties', () {
      expect(zh.pdf, isNotEmpty);
      expect(zh.generatingPdf, isNotEmpty);
      expect(zh.pdfFailed, isNotEmpty);
      expect(zh.tableOfContents, isNotEmpty);
      expect(zhTW.pdf, isNotEmpty);
      expect(zhTW.generatingPdf, isNotEmpty);
      expect(zhTW.tableOfContents, isNotEmpty);
    });

    test('Link properties', () {
      expect(zh.close, isNotEmpty);
      expect(zh.openLink, isNotEmpty);
      expect(zh.invalidLink, isNotEmpty);
      expect(zh.unableToOpenLink, isNotEmpty);
      expect(zhTW.close, isNotEmpty);
      expect(zhTW.openLink, isNotEmpty);
      expect(zhTW.invalidLink, isNotEmpty);
    });

    test('Clipboard properties', () {
      expect(zh.copy, isNotEmpty);
      expect(zh.copiedToClipboard, isNotEmpty);
      expect(zhTW.copy, isNotEmpty);
      expect(zhTW.copiedToClipboard, isNotEmpty);
    });

    test('Menu properties', () {
      expect(zh.menu, isNotEmpty);
      expect(zh.metaLabel, isNotEmpty);
      expect(zhTW.menu, isNotEmpty);
      expect(zhTW.metaLabel, isNotEmpty);
    });

    test('AI Service properties', () {
      expect(zh.aiServiceUnavailable, isNotEmpty);
      expect(zh.aiConfigurations, isNotEmpty);
      expect(zh.modelLabel, isNotEmpty);
      expect(zh.temperatureLabel, isNotEmpty);
      expect(zhTW.aiServiceUnavailable, isNotEmpty);
      expect(zhTW.modelLabel, isNotEmpty);
    });

    test('Save properties', () {
      expect(zh.saveFailed, isNotEmpty);
      expect(zh.saveMyVersion, isNotEmpty);
      expect(zh.resetToPublic, isNotEmpty);
      expect(zh.resetFailed, isNotEmpty);
      expect(zhTW.saveFailed, isNotEmpty);
      expect(zhTW.saveMyVersion, isNotEmpty);
    });

    test('Tools properties', () {
      expect(zh.prompts, isNotEmpty);
      expect(zh.patterns, isNotEmpty);
      expect(zh.storyLines, isNotEmpty);
      expect(zh.hotTopics, isNotEmpty);
      expect(zh.tools, isNotEmpty);
      expect(zhTW.prompts, isNotEmpty);
      expect(zhTW.patterns, isNotEmpty);
      expect(zhTW.tools, isNotEmpty);
    });

    test('Hot Topics Platform properties', () {
      expect(zh.hotTopicsSelectPlatform, isNotEmpty);
      expect(zh.hotTopicsAllPlatforms, isNotEmpty);
      expect(zh.hotTopicsPlatformWeibo, isNotEmpty);
      expect(zh.hotTopicsPlatformZhihu, isNotEmpty);
      expect(zh.hotTopicsPlatformDouyin, isNotEmpty);
      expect(zh.hotTopicsPlatformDescWeibo, isNotEmpty);
      expect(zh.hotTopicsPlatformDescZhihu, isNotEmpty);
      expect(zh.hotTopicsPlatformDescDouyin, isNotEmpty);
      expect(zhTW.hotTopicsSelectPlatform, isNotEmpty);
      expect(zhTW.hotTopicsPlatformWeibo, isNotEmpty);
    });

    test('Preview and Actions properties', () {
      expect(zh.preview, isNotEmpty);
      expect(zh.actions, isNotEmpty);
      expect(zh.searchLabel, isNotEmpty);
      expect(zh.allLabel, isNotEmpty);
      expect(zhTW.preview, isNotEmpty);
      expect(zhTW.actions, isNotEmpty);
      expect(zhTW.searchLabel, isNotEmpty);
    });

    test('Filter properties', () {
      expect(zh.filterByLocked, isNotEmpty);
      expect(zh.lockedOnly, isNotEmpty);
      expect(zh.unlockedOnly, isNotEmpty);
      expect(zhTW.filterByLocked, isNotEmpty);
      expect(zhTW.lockedOnly, isNotEmpty);
      expect(zhTW.unlockedOnly, isNotEmpty);
    });

    test('Prompt properties', () {
      expect(zh.promptKey, isNotEmpty);
      expect(zh.filterByKey, isNotEmpty);
      expect(zh.viewPublic, isNotEmpty);
      expect(zhTW.promptKey, isNotEmpty);
      expect(zhTW.viewPublic, isNotEmpty);
    });

    test('Group properties', () {
      expect(zh.groupNone, isNotEmpty);
      expect(zh.groupLanguage, isNotEmpty);
      expect(zh.groupKey, isNotEmpty);
      expect(zhTW.groupNone, isNotEmpty);
      expect(zhTW.groupLanguage, isNotEmpty);
    });

    test('New Items properties', () {
      expect(zh.newPrompt, isNotEmpty);
      expect(zh.newPattern, isNotEmpty);
      expect(zh.newStoryLine, isNotEmpty);
      expect(zh.editPrompt, isNotEmpty);
      expect(zh.editPattern, isNotEmpty);
      expect(zh.editStoryLine, isNotEmpty);
      expect(zhTW.newPrompt, isNotEmpty);
      expect(zhTW.newPattern, isNotEmpty);
      expect(zhTW.editPrompt, isNotEmpty);
    });

    test('Public properties', () {
      expect(zh.makePublic, isNotEmpty);
      expect(zh.noPrompts, isNotEmpty);
      expect(zh.noPatterns, isNotEmpty);
      expect(zh.noStoryLines, isNotEmpty);
      expect(zhTW.makePublic, isNotEmpty);
      expect(zhTW.noPrompts, isNotEmpty);
    });

    test('AI Coach properties', () {
      expect(zh.failedToAnalyze, isNotEmpty);
      expect(zh.aiCoachAnalyzing, isNotEmpty);
      expect(zh.retry, isNotEmpty);
      expect(zh.startAiCoaching, isNotEmpty);
      expect(zh.refinementComplete, isNotEmpty);
      expect(zh.coachQuestion, isNotEmpty);
      expect(zh.summaryLooksGood, isNotEmpty);
      expect(zh.howToImprove, isNotEmpty);
      expect(zhTW.failedToAnalyze, isNotEmpty);
      expect(zhTW.retry, isNotEmpty);
      expect(zhTW.startAiCoaching, isNotEmpty);
    });

    test('Suggestions properties', () {
      expect(zh.suggestionsLabel, isNotEmpty);
      expect(zh.reviewSuggestionsHint, isNotEmpty);
      expect(zh.aiGenerationComplete, isNotEmpty);
      expect(zh.clickRegenerateForNew, isNotEmpty);
      expect(zhTW.suggestionsLabel, isNotEmpty);
      expect(zhTW.aiGenerationComplete, isNotEmpty);
    });

    test('Parameterized methods - confirmDeleteDescription', () {
      expect(zh.confirmDeleteDescription('Test Novel'), contains('Test Novel'));
      expect(zh.confirmDeleteDescription('测试小说'), contains('测试小说'));
      expect(zhTW.confirmDeleteDescription('Test'), contains('Test'));
    });

    test('Parameterized methods - aiTokenCount', () {
      expect(zh.aiTokenCount(100), contains('100'));
      expect(zh.aiTokenCount(1000), contains('1000'));
      expect(zhTW.aiTokenCount(100), contains('100'));
    });

    test('Parameterized methods - aiContextLoadError', () {
      expect(zh.aiContextLoadError('Error loading'), contains('Error loading'));
      expect(zh.aiContextLoadError('Failed'), contains('Failed'));
      expect(zhTW.aiContextLoadError('Error'), contains('Error'));
    });

    test('Parameterized methods - aiChatContextTooLongCompressing', () {
      expect(zh.aiChatContextTooLongCompressing(5000), contains('5000'));
      expect(zh.aiChatContextTooLongCompressing(10000), contains('10000'));
      expect(zhTW.aiChatContextTooLongCompressing(5000), contains('5000'));
    });

    test('Parameterized methods - aiChatContextCompressionFailedNote', () {
      expect(zh.aiChatContextCompressionFailedNote('Error'), contains('Error'));
      expect(
        zh.aiChatContextCompressionFailedNote('Failed'),
        contains('Failed'),
      );
      expect(
        zhTW.aiChatContextCompressionFailedNote('Error'),
        contains('Error'),
      );
    });

    test('Parameterized methods - aiChatError', () {
      expect(zh.aiChatError('Network error'), contains('Network error'));
      expect(zh.aiChatError('Timeout'), contains('Timeout'));
      expect(zhTW.aiChatError('Error'), contains('Error'));
    });

    test('Parameterized methods - aiChatDeepAgentError', () {
      expect(zh.aiChatDeepAgentError('Error 1'), contains('Error 1'));
      expect(zh.aiChatDeepAgentError('Error 2'), contains('Error 2'));
      expect(zhTW.aiChatDeepAgentError('Error'), contains('Error'));
    });

    test('Parameterized methods - aiChatSearchError', () {
      expect(zh.aiChatSearchError('Search failed'), contains('Search failed'));
      expect(zh.aiChatSearchError('Timeout'), contains('Timeout'));
      expect(zhTW.aiChatSearchError('Error'), contains('Error'));
    });

    test('Parameterized methods - aiServiceFailedToConnect', () {
      expect(
        zh.aiServiceFailedToConnect('Connection failed'),
        contains('Connection failed'),
      );
      expect(zh.aiServiceFailedToConnect('Timeout'), contains('Timeout'));
      expect(zhTW.aiServiceFailedToConnect('Error'), contains('Error'));
    });

    test('Parameterized methods - aiDeepAgentStop', () {
      expect(zh.aiDeepAgentStop('Completed', 5), isNotEmpty);
      expect(zh.aiDeepAgentStop('Failed', 10), isNotEmpty);
      expect(zhTW.aiDeepAgentStop('Done', 3), isNotEmpty);
    });

    test('Parameterized methods - languageLabel', () {
      expect(zh.languageLabel('en'), contains('en'));
      expect(zh.languageLabel('zh'), contains('zh'));
      expect(zhTW.languageLabel('en'), contains('en'));
    });

    test('Parameterized methods - chaptersCount', () {
      expect(zh.chaptersCount(10), contains('10'));
      expect(zh.chaptersCount(100), contains('100'));
      expect(zhTW.chaptersCount(10), contains('10'));
    });

    test('Parameterized methods - avgWordsPerChapter', () {
      expect(zh.avgWordsPerChapter(1000), contains('1000'));
      expect(zh.avgWordsPerChapter(2000), contains('2000'));
      expect(zhTW.avgWordsPerChapter(1000), contains('1000'));
    });

    test('Parameterized methods - chapterLabel', () {
      expect(zh.chapterLabel(1), contains('1'));
      expect(zh.chapterLabel(10), contains('10'));
      expect(zhTW.chapterLabel(1), contains('1'));
    });

    test('Parameterized methods - chapterWithTitle', () {
      expect(zh.chapterWithTitle(1, 'Title 1'), contains('1'));
      expect(zh.chapterWithTitle(2, 'Title 2'), contains('2'));
      expect(zhTW.chapterWithTitle(1, 'Title'), contains('1'));
    });

    test('Parameterized methods - byAuthor', () {
      expect(zh.byAuthor('Author Name'), contains('Author Name'));
      expect(zh.byAuthor('作者'), contains('作者'));
      expect(zhTW.byAuthor('Author'), contains('Author'));
    });

    test('Parameterized methods - pageOfTotal', () {
      expect(zh.pageOfTotal(1, 100), contains('1'));
      expect(zh.pageOfTotal(50, 100), contains('50'));
      expect(zhTW.pageOfTotal(1, 100), contains('1'));
    });

    test('Parameterized methods - showingCachedPublicData', () {
      expect(
        zh.showingCachedPublicData('Cached data'),
        contains('Cached data'),
      );
      expect(zh.showingCachedPublicData('缓存数据'), contains('缓存数据'));
      expect(zhTW.showingCachedPublicData('Cached'), contains('Cached'));
    });

    test('Parameterized methods - deletedWithTitle', () {
      expect(zh.deletedWithTitle('Test Prompt'), contains('Test Prompt'));
      expect(zh.deletedWithTitle('测试'), contains('测试'));
      expect(zhTW.deletedWithTitle('Test'), contains('Test'));
    });

    test('Parameterized methods - deleteFailedWithTitle', () {
      expect(zh.deleteFailedWithTitle('Test'), contains('Test'));
      expect(zh.deleteFailedWithTitle('测试'), contains('测试'));
      expect(zhTW.deleteFailedWithTitle('Test'), contains('Test'));
    });

    test('Parameterized methods - deleteErrorWithMessage', () {
      expect(
        zh.deleteErrorWithMessage('Error message'),
        contains('Error message'),
      );
      expect(zh.deleteErrorWithMessage('错误信息'), contains('错误信息'));
      expect(zhTW.deleteErrorWithMessage('Error'), contains('Error'));
    });

    test('Parameterized methods - conversionFailed', () {
      expect(
        zh.conversionFailed('Failed to convert'),
        contains('Failed to convert'),
      );
      expect(zh.conversionFailed('转换失败'), contains('转换失败'));
      expect(zhTW.conversionFailed('Failed'), contains('Failed'));
    });

    test('Parameterized methods - aiChatRagRefinedQuery', () {
      expect(zh.aiChatRagRefinedQuery('Query 1'), contains('Query 1'));
      expect(zh.aiChatRagRefinedQuery('查询'), contains('查询'));
      expect(zhTW.aiChatRagRefinedQuery('Query'), contains('Query'));
    });

    test('Parameterized methods - failedToLoadChapter', () {
      expect(
        zh.failedToLoadChapter('Network error'),
        contains('Network error'),
      );
      expect(zh.failedToLoadChapter('超时'), contains('超时'));
      expect(zhTW.failedToLoadChapter('Error'), contains('Error'));
    });
  });
}
