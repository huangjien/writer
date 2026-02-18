import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/l10n/app_localizations_de.dart';
import 'package:writer/l10n/app_localizations_en.dart';
import 'package:writer/l10n/app_localizations_es.dart';
import 'package:writer/l10n/app_localizations_fr.dart';
import 'package:writer/l10n/app_localizations_it.dart';
import 'package:writer/l10n/app_localizations_ja.dart';
import 'package:writer/l10n/app_localizations_ru.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  group('Extended Localization Coverage Tests', () {
    late List<AppLocalizations> locales;

    setUp(() {
      locales = [
        AppLocalizationsDe(),
        AppLocalizationsEn(),
        AppLocalizationsEs(),
        AppLocalizationsFr(),
        AppLocalizationsIt(),
        AppLocalizationsJa(),
        AppLocalizationsRu(),
        AppLocalizationsZh(),
      ];
    });

    test('all locales have typography strings', () {
      for (final locale in locales) {
        expect(
          locale.typographyPreset,
          isNotEmpty,
          reason: '${locale.localeName}: typographyPreset',
        );
        expect(
          locale.typographyComfortable,
          isNotEmpty,
          reason: '${locale.localeName}: typographyComfortable',
        );
        expect(
          locale.typographyCompact,
          isNotEmpty,
          reason: '${locale.localeName}: typographyCompact',
        );
        expect(
          locale.typographySerifLike,
          isNotEmpty,
          reason: '${locale.localeName}: typographySerifLike',
        );
        expect(
          locale.fontPack,
          isNotEmpty,
          reason: '${locale.localeName}: fontPack',
        );
        expect(
          locale.separateTypographyPresets,
          isNotEmpty,
          reason: '${locale.localeName}: separateTypographyPresets',
        );
        expect(
          locale.typographyLight,
          isNotEmpty,
          reason: '${locale.localeName}: typographyLight',
        );
        expect(
          locale.typographyDark,
          isNotEmpty,
          reason: '${locale.localeName}: typographyDark',
        );
      }
    });

    test('all locales have palette strings', () {
      for (final locale in locales) {
        expect(
          locale.separateDarkPalette,
          isNotEmpty,
          reason: '${locale.localeName}: separateDarkPalette',
        );
        expect(
          locale.lightPalette,
          isNotEmpty,
          reason: '${locale.localeName}: lightPalette',
        );
        expect(
          locale.darkPalette,
          isNotEmpty,
          reason: '${locale.localeName}: darkPalette',
        );
      }
    });

    test('all locales have token usage strings', () {
      for (final locale in locales) {
        expect(
          locale.tokenUsage,
          isNotEmpty,
          reason: '${locale.localeName}: tokenUsage',
        );
        expect(
          locale.userManagement,
          isNotEmpty,
          reason: '${locale.localeName}: userManagement',
        );
        expect(
          locale.totalThisMonth,
          isNotEmpty,
          reason: '${locale.localeName}: totalThisMonth',
        );
        expect(
          locale.inputTokens,
          isNotEmpty,
          reason: '${locale.localeName}: inputTokens',
        );
        expect(
          locale.outputTokens,
          isNotEmpty,
          reason: '${locale.localeName}: outputTokens',
        );
        expect(
          locale.requests,
          isNotEmpty,
          reason: '${locale.localeName}: requests',
        );
        expect(
          locale.viewHistory,
          isNotEmpty,
          reason: '${locale.localeName}: viewHistory',
        );
        expect(
          locale.noUsageThisMonth,
          isNotEmpty,
          reason: '${locale.localeName}: noUsageThisMonth',
        );
        expect(
          locale.startUsingAiFeatures,
          isNotEmpty,
          reason: '${locale.localeName}: startUsingAiFeatures',
        );
        expect(
          locale.errorLoadingUsage,
          isNotEmpty,
          reason: '${locale.localeName}: errorLoadingUsage',
        );
        expect(
          locale.refresh,
          isNotEmpty,
          reason: '${locale.localeName}: refresh',
        );
        expect(locale.total, isNotEmpty, reason: '${locale.localeName}: total');
        expect(
          locale.noUsageHistory,
          isNotEmpty,
          reason: '${locale.localeName}: noUsageHistory',
        );
      }
    });

    test('all locales have library strings', () {
      for (final locale in locales) {
        expect(
          locale.discover,
          isNotEmpty,
          reason: '${locale.localeName}: discover',
        );
        expect(
          locale.profile,
          isNotEmpty,
          reason: '${locale.localeName}: profile',
        );
        expect(
          locale.libraryTitle,
          isNotEmpty,
          reason: '${locale.localeName}: libraryTitle',
        );
        expect(locale.undo, isNotEmpty, reason: '${locale.localeName}: undo');
        expect(
          locale.allFilter,
          isNotEmpty,
          reason: '${locale.localeName}: allFilter',
        );
        expect(
          locale.readingFilter,
          isNotEmpty,
          reason: '${locale.localeName}: readingFilter',
        );
        expect(
          locale.completedFilter,
          isNotEmpty,
          reason: '${locale.localeName}: completedFilter',
        );
        expect(
          locale.downloadedFilter,
          isNotEmpty,
          reason: '${locale.localeName}: downloadedFilter',
        );
        expect(
          locale.searchNovels,
          isNotEmpty,
          reason: '${locale.localeName}: searchNovels',
        );
        expect(
          locale.listView,
          isNotEmpty,
          reason: '${locale.localeName}: listView',
        );
        expect(
          locale.gridView,
          isNotEmpty,
          reason: '${locale.localeName}: gridView',
        );
      }
    });

    test('all locales have reader bundle strings', () {
      for (final locale in locales) {
        expect(
          locale.readerBundles,
          isNotEmpty,
          reason: '${locale.localeName}: readerBundles',
        );
        expect(
          locale.bundleNordCalm,
          isNotEmpty,
          reason: '${locale.localeName}: bundleNordCalm',
        );
        expect(
          locale.bundleSolarizedFocus,
          isNotEmpty,
          reason: '${locale.localeName}: bundleSolarizedFocus',
        );
        expect(
          locale.bundleHighContrastReadability,
          isNotEmpty,
          reason: '${locale.localeName}: bundleHighContrastReadability',
        );
      }
    });

    test('all locales have font settings strings', () {
      for (final locale in locales) {
        expect(
          locale.customFontFamily,
          isNotEmpty,
          reason: '${locale.localeName}: customFontFamily',
        );
        expect(
          locale.commonFonts,
          isNotEmpty,
          reason: '${locale.localeName}: commonFonts',
        );
        expect(
          locale.readerFontSize,
          isNotEmpty,
          reason: '${locale.localeName}: readerFontSize',
        );
        expect(
          locale.textScale,
          isNotEmpty,
          reason: '${locale.localeName}: textScale',
        );
      }
    });

    test('all locales have reader background strings', () {
      for (final locale in locales) {
        expect(
          locale.readerBackgroundDepth,
          isNotEmpty,
          reason: '${locale.localeName}: readerBackgroundDepth',
        );
        expect(
          locale.depthLow,
          isNotEmpty,
          reason: '${locale.localeName}: depthLow',
        );
        expect(
          locale.depthMedium,
          isNotEmpty,
          reason: '${locale.localeName}: depthMedium',
        );
        expect(
          locale.depthHigh,
          isNotEmpty,
          reason: '${locale.localeName}: depthHigh',
        );
      }
    });

    test('all locales have action strings', () {
      for (final locale in locales) {
        expect(
          locale.select,
          isNotEmpty,
          reason: '${locale.localeName}: select',
        );
        expect(locale.clear, isNotEmpty, reason: '${locale.localeName}: clear');
        expect(
          locale.remove,
          isNotEmpty,
          reason: '${locale.localeName}: remove',
        );
        expect(
          locale.removedFromLibrary,
          isNotEmpty,
          reason: '${locale.localeName}: removedFromLibrary',
        );
        expect(
          locale.confirmDelete,
          isNotEmpty,
          reason: '${locale.localeName}: confirmDelete',
        );
        expect(
          locale.delete,
          isNotEmpty,
          reason: '${locale.localeName}: delete',
        );
      }
    });

    test('all locales have chapter navigation strings', () {
      for (final locale in locales) {
        expect(
          locale.reachedFirstChapter,
          isNotEmpty,
          reason: '${locale.localeName}: reachedFirstChapter',
        );
        expect(
          locale.reachedLastChapter,
          isNotEmpty,
          reason: '${locale.localeName}: reachedLastChapter',
        );
        expect(
          locale.previousChapter,
          isNotEmpty,
          reason: '${locale.localeName}: previousChapter',
        );
        expect(
          locale.nextChapter,
          isNotEmpty,
          reason: '${locale.localeName}: nextChapter',
        );
      }
    });

    test('all locales have beta evaluation strings', () {
      for (final locale in locales) {
        expect(
          locale.betaEvaluate,
          isNotEmpty,
          reason: '${locale.localeName}: betaEvaluate',
        );
        expect(
          locale.betaEvaluating,
          isNotEmpty,
          reason: '${locale.localeName}: betaEvaluating',
        );
        expect(
          locale.betaEvaluationReady,
          isNotEmpty,
          reason: '${locale.localeName}: betaEvaluationReady',
        );
        expect(
          locale.betaEvaluationFailed,
          isNotEmpty,
          reason: '${locale.localeName}: betaEvaluationFailed',
        );
      }
    });

    test('all locales have performance settings strings', () {
      for (final locale in locales) {
        expect(
          locale.performanceSettings,
          isNotEmpty,
          reason: '${locale.localeName}: performanceSettings',
        );
        expect(
          locale.prefetchNextChapter,
          isNotEmpty,
          reason: '${locale.localeName}: prefetchNextChapter',
        );
        expect(
          locale.prefetchNextChapterDescription,
          isNotEmpty,
          reason: '${locale.localeName}: prefetchNextChapterDescription',
        );
        expect(
          locale.clearOfflineCache,
          isNotEmpty,
          reason: '${locale.localeName}: clearOfflineCache',
        );
        expect(
          locale.offlineCacheCleared,
          isNotEmpty,
          reason: '${locale.localeName}: offlineCacheCleared',
        );
      }
    });

    test('all locales have edit mode strings', () {
      for (final locale in locales) {
        expect(locale.edit, isNotEmpty, reason: '${locale.localeName}: edit');
        expect(
          locale.exitEdit,
          isNotEmpty,
          reason: '${locale.localeName}: exitEdit',
        );
        expect(
          locale.enterEditMode,
          isNotEmpty,
          reason: '${locale.localeName}: enterEditMode',
        );
        expect(
          locale.exitEditMode,
          isNotEmpty,
          reason: '${locale.localeName}: exitEditMode',
        );
        expect(
          locale.chapterContent,
          isNotEmpty,
          reason: '${locale.localeName}: chapterContent',
        );
        expect(locale.save, isNotEmpty, reason: '${locale.localeName}: save');
        expect(
          locale.createNextChapter,
          isNotEmpty,
          reason: '${locale.localeName}: createNextChapter',
        );
        expect(
          locale.enterChapterTitle,
          isNotEmpty,
          reason: '${locale.localeName}: enterChapterTitle',
        );
        expect(
          locale.enterChapterContent,
          isNotEmpty,
          reason: '${locale.localeName}: enterChapterContent',
        );
      }
    });

    test('all locales have discard changes strings', () {
      for (final locale in locales) {
        expect(
          locale.discardChangesTitle,
          isNotEmpty,
          reason: '${locale.localeName}: discardChangesTitle',
        );
        expect(
          locale.discardChangesMessage,
          isNotEmpty,
          reason: '${locale.localeName}: discardChangesMessage',
        );
        expect(
          locale.keepEditing,
          isNotEmpty,
          reason: '${locale.localeName}: keepEditing',
        );
        expect(
          locale.discardChanges,
          isNotEmpty,
          reason: '${locale.localeName}: discardChanges',
        );
        expect(
          locale.saveAndExit,
          isNotEmpty,
          reason: '${locale.localeName}: saveAndExit',
        );
      }
    });

    test('all locales have novel form strings', () {
      for (final locale in locales) {
        expect(
          locale.descriptionLabel,
          isNotEmpty,
          reason: '${locale.localeName}: descriptionLabel',
        );
        expect(
          locale.coverUrlLabel,
          isNotEmpty,
          reason: '${locale.localeName}: coverUrlLabel',
        );
        expect(
          locale.invalidCoverUrl,
          isNotEmpty,
          reason: '${locale.localeName}: invalidCoverUrl',
        );
      }
    });

    test('all locales have navigation strings', () {
      for (final locale in locales) {
        expect(
          locale.navigation,
          isNotEmpty,
          reason: '${locale.localeName}: navigation',
        );
        expect(locale.home, isNotEmpty, reason: '${locale.localeName}: home');
        expect(
          locale.chapterIndex,
          isNotEmpty,
          reason: '${locale.localeName}: chapterIndex',
        );
        expect(
          locale.summary,
          isNotEmpty,
          reason: '${locale.localeName}: summary',
        );
        expect(
          locale.characters,
          isNotEmpty,
          reason: '${locale.localeName}: characters',
        );
        expect(
          locale.scenes,
          isNotEmpty,
          reason: '${locale.localeName}: scenes',
        );
        expect(
          locale.characterTemplates,
          isNotEmpty,
          reason: '${locale.localeName}: characterTemplates',
        );
        expect(
          locale.sceneTemplates,
          isNotEmpty,
          reason: '${locale.localeName}: sceneTemplates',
        );
      }
    });

    test('all locales have novel action strings', () {
      for (final locale in locales) {
        expect(
          locale.updateNovel,
          isNotEmpty,
          reason: '${locale.localeName}: updateNovel',
        );
        expect(
          locale.deleteNovel,
          isNotEmpty,
          reason: '${locale.localeName}: deleteNovel',
        );
        expect(
          locale.deleteNovelConfirmation,
          isNotEmpty,
          reason: '${locale.localeName}: deleteNovelConfirmation',
        );
        expect(
          locale.format,
          isNotEmpty,
          reason: '${locale.localeName}: format',
        );
      }
    });

    test('all locales have AI service strings', () {
      for (final locale in locales) {
        expect(
          locale.aiServiceUrl,
          isNotEmpty,
          reason: '${locale.localeName}: aiServiceUrl',
        );
        expect(
          locale.aiServiceUrlDescription,
          isNotEmpty,
          reason: '${locale.localeName}: aiServiceUrlDescription',
        );
        expect(
          locale.aiAssistant,
          isNotEmpty,
          reason: '${locale.localeName}: aiAssistant',
        );
        expect(
          locale.aiChatHistory,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatHistory',
        );
        expect(
          locale.aiChatNewChat,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatNewChat',
        );
        expect(
          locale.aiChatNoHistory,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatNoHistory',
        );
        expect(
          locale.aiChatHint,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatHint',
        );
        expect(
          locale.aiChatEmpty,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatEmpty',
        );
        expect(
          locale.aiThinking,
          isNotEmpty,
          reason: '${locale.localeName}: aiThinking',
        );
        expect(
          locale.aiChatContextLabel,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatContextLabel',
        );
        expect(
          locale.aiChatSearchFailed,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatSearchFailed',
        );
        expect(
          locale.aiChatRagNoResults,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatRagNoResults',
        );
        expect(
          locale.aiChatRagUnknownType,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatRagUnknownType',
        );
        expect(
          locale.aiServiceSignInRequired,
          isNotEmpty,
          reason: '${locale.localeName}: aiServiceSignInRequired',
        );
        expect(
          locale.aiServiceFeatureNotAvailable,
          isNotEmpty,
          reason: '${locale.localeName}: aiServiceFeatureNotAvailable',
        );
        expect(
          locale.aiServiceNoResponse,
          isNotEmpty,
          reason: '${locale.localeName}: aiServiceNoResponse',
        );
        expect(locale.send, isNotEmpty, reason: '${locale.localeName}: send');
      }
    });

    test('all locales have AI Deep Agent strings', () {
      for (final locale in locales) {
        expect(
          locale.aiDeepAgentDetailsTitle,
          isNotEmpty,
          reason: '${locale.localeName}: aiDeepAgentDetailsTitle',
        );
        expect(
          locale.aiDeepAgentPlanLabel,
          isNotEmpty,
          reason: '${locale.localeName}: aiDeepAgentPlanLabel',
        );
        expect(
          locale.aiDeepAgentToolsLabel,
          isNotEmpty,
          reason: '${locale.localeName}: aiDeepAgentToolsLabel',
        );
        expect(
          locale.deepAgentSettingsTitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentSettingsTitle',
        );
        expect(
          locale.deepAgentSettingsDescription,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentSettingsDescription',
        );
        expect(
          locale.deepAgentPreferTitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentPreferTitle',
        );
        expect(
          locale.deepAgentPreferSubtitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentPreferSubtitle',
        );
        expect(
          locale.deepAgentFallbackTitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentFallbackTitle',
        );
        expect(
          locale.deepAgentFallbackSubtitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentFallbackSubtitle',
        );
        expect(
          locale.deepAgentReflectionModeTitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentReflectionModeTitle',
        );
        expect(
          locale.deepAgentReflectionModeSubtitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentReflectionModeSubtitle',
        );
        expect(
          locale.deepAgentReflectionModeOff,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentReflectionModeOff',
        );
        expect(
          locale.deepAgentReflectionModeOnFailure,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentReflectionModeOnFailure',
        );
        expect(
          locale.deepAgentReflectionModeAlways,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentReflectionModeAlways',
        );
        expect(
          locale.deepAgentShowDetailsTitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentShowDetailsTitle',
        );
        expect(
          locale.deepAgentShowDetailsSubtitle,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentShowDetailsSubtitle',
        );
        expect(
          locale.deepAgentMaxPlanSteps,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentMaxPlanSteps',
        );
        expect(
          locale.deepAgentMaxToolRounds,
          isNotEmpty,
          reason: '${locale.localeName}: deepAgentMaxToolRounds',
        );
      }
    });

    test('all locales have validation strings', () {
      for (final locale in locales) {
        expect(
          locale.resetToDefault,
          isNotEmpty,
          reason: '${locale.localeName}: resetToDefault',
        );
        expect(
          locale.invalidUrl,
          isNotEmpty,
          reason: '${locale.localeName}: invalidUrl',
        );
        expect(
          locale.urlTooLong,
          isNotEmpty,
          reason: '${locale.localeName}: urlTooLong',
        );
        expect(
          locale.urlContainsSpaces,
          isNotEmpty,
          reason: '${locale.localeName}: urlContainsSpaces',
        );
        expect(
          locale.urlInvalidScheme,
          isNotEmpty,
          reason: '${locale.localeName}: urlInvalidScheme',
        );
        expect(locale.saved, isNotEmpty, reason: '${locale.localeName}: saved');
        expect(
          locale.required,
          isNotEmpty,
          reason: '${locale.localeName}: required',
        );
      }
    });

    test('all locales have summary strings', () {
      for (final locale in locales) {
        expect(
          locale.summariesLabel,
          isNotEmpty,
          reason: '${locale.localeName}: summariesLabel',
        );
        expect(
          locale.synopsesLabel,
          isNotEmpty,
          reason: '${locale.localeName}: synopsesLabel',
        );
        expect(
          locale.locationLabel,
          isNotEmpty,
          reason: '${locale.localeName}: locationLabel',
        );
        expect(
          locale.publicLabel,
          isNotEmpty,
          reason: '${locale.localeName}: publicLabel',
        );
        expect(
          locale.privateLabel,
          isNotEmpty,
          reason: '${locale.localeName}: privateLabel',
        );
      }
    });

    test('all locales have chapter info strings', () {
      for (final locale in locales) {
        expect(
          locale.refreshTooltip,
          isNotEmpty,
          reason: '${locale.localeName}: refreshTooltip',
        );
        expect(
          locale.untitled,
          isNotEmpty,
          reason: '${locale.localeName}: untitled',
        );
      }
    });

    test('all locales format parameterized strings correctly - extended', () {
      for (final locale in locales) {
        expect(
          locale.removedNovel('Test Novel'),
          isNotEmpty,
          reason: '${locale.localeName}: removedNovel',
        );
        expect(
          locale.totalRecords(100),
          isNotEmpty,
          reason: '${locale.localeName}: totalRecords',
        );
        expect(
          locale.confirmDeleteDescription('Test'),
          contains('Test'),
          reason: '${locale.localeName}: confirmDeleteDescription',
        );
        expect(
          locale.languageLabel('en'),
          contains('en'),
          reason: '${locale.localeName}: languageLabel',
        );
        expect(
          locale.chaptersCount(10),
          isNotEmpty,
          reason: '${locale.localeName}: chaptersCount',
        );
        expect(
          locale.avgWordsPerChapter(5000),
          isNotEmpty,
          reason: '${locale.localeName}: avgWordsPerChapter',
        );
        expect(
          locale.chapterLabel(5),
          isNotEmpty,
          reason: '${locale.localeName}: chapterLabel',
        );
        expect(
          locale.chapterWithTitle(1, 'Test Title'),
          contains('Test Title'),
          reason: '${locale.localeName}: chapterWithTitle',
        );
        expect(
          locale.aiTokenCount(1000),
          isNotEmpty,
          reason: '${locale.localeName}: aiTokenCount',
        );
        expect(
          locale.aiContextLoadError('test error'),
          contains('test error'),
          reason: '${locale.localeName}: aiContextLoadError',
        );
        expect(
          locale.aiChatContextTooLongCompressing(5000),
          isNotEmpty,
          reason: '${locale.localeName}: aiChatContextTooLongCompressing',
        );
        expect(
          locale.aiChatContextCompressionFailedNote('error'),
          contains('error'),
          reason: '${locale.localeName}: aiChatContextCompressionFailedNote',
        );
        expect(
          locale.aiChatError('error'),
          contains('error'),
          reason: '${locale.localeName}: aiChatError',
        );
        expect(
          locale.aiChatDeepAgentError('error'),
          contains('error'),
          reason: '${locale.localeName}: aiChatDeepAgentError',
        );
        expect(
          locale.aiChatSearchError('error'),
          contains('error'),
          reason: '${locale.localeName}: aiChatSearchError',
        );
        expect(
          locale.aiChatRagRefinedQuery('query'),
          contains('query'),
          reason: '${locale.localeName}: aiChatRagRefinedQuery',
        );
        expect(
          locale.aiServiceFailedToConnect('error'),
          contains('error'),
          reason: '${locale.localeName}: aiServiceFailedToConnect',
        );
        expect(
          locale.aiDeepAgentStop('max_rounds', 5),
          isNotEmpty,
          reason: '${locale.localeName}: aiDeepAgentStop',
        );
      }
    });

    test('all locales have admin mode strings', () {
      for (final locale in locales) {
        expect(
          locale.adminMode,
          isNotEmpty,
          reason: '${locale.localeName}: adminMode',
        );
      }
    });

    test('all locales have accessibility strings', () {
      for (final locale in locales) {
        expect(
          locale.reduceMotion,
          isNotEmpty,
          reason: '${locale.localeName}: reduceMotion',
        );
        expect(
          locale.reduceMotionDescription,
          isNotEmpty,
          reason: '${locale.localeName}: reduceMotionDescription',
        );
        expect(
          locale.gesturesEnabled,
          isNotEmpty,
          reason: '${locale.localeName}: gesturesEnabled',
        );
        expect(
          locale.gesturesEnabledDescription,
          isNotEmpty,
          reason: '${locale.localeName}: gesturesEnabledDescription',
        );
        expect(
          locale.readerSwipeSensitivity,
          isNotEmpty,
          reason: '${locale.localeName}: readerSwipeSensitivity',
        );
        expect(
          locale.readerSwipeSensitivityDescription,
          isNotEmpty,
          reason: '${locale.localeName}: readerSwipeSensitivityDescription',
        );
      }
    });

    test('all locales have RAG search strings', () {
      for (final locale in locales) {
        expect(
          locale.aiChatRagSearchResultsTitle,
          isNotEmpty,
          reason: '${locale.localeName}: aiChatRagSearchResultsTitle',
        );
      }
    });
  });

  group('German Extended Coverage Tests', () {
    final de = AppLocalizationsDe();

    test('extended property coverage', () {
      expect(de.typographyPreset, isNotEmpty);
      expect(de.tokenUsage, isNotEmpty);
      expect(de.libraryTitle, isNotEmpty);
      expect(de.readerBundles, isNotEmpty);
      expect(de.performanceSettings, isNotEmpty);
      expect(de.edit, isNotEmpty);
      expect(de.summary, isNotEmpty);
      expect(de.characters, isNotEmpty);
      expect(de.scenes, isNotEmpty);
      expect(de.aiAssistant, isNotEmpty);
      expect(de.deepAgentSettingsTitle, isNotEmpty);
      expect(de.summariesLabel, isNotEmpty);
      expect(de.synopsesLabel, isNotEmpty);
      expect(de.locationLabel, isNotEmpty);
      expect(de.publicLabel, isNotEmpty);
      expect(de.privateLabel, isNotEmpty);
      expect(de.refreshTooltip, isNotEmpty);
      expect(de.untitled, isNotEmpty);
      expect(de.adminMode, isNotEmpty);
      expect(de.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(de.removedNovel('Test'), isNotEmpty);
      expect(de.totalRecords(100), isNotEmpty);
      expect(de.confirmDeleteDescription('Test'), contains('Test'));
      expect(de.languageLabel('en'), contains('en'));
      expect(de.chaptersCount(10), isNotEmpty);
      expect(de.avgWordsPerChapter(5000), isNotEmpty);
      expect(de.chapterLabel(5), isNotEmpty);
      expect(de.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(de.aiTokenCount(1000), isNotEmpty);
      expect(de.aiContextLoadError('err'), contains('err'));
      expect(de.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(de.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(de.aiChatError('err'), contains('err'));
      expect(de.aiChatDeepAgentError('err'), contains('err'));
      expect(de.aiChatSearchError('err'), contains('err'));
      expect(de.aiChatRagRefinedQuery('q'), contains('q'));
      expect(de.aiServiceFailedToConnect('err'), contains('err'));
      expect(de.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('Spanish Extended Coverage Tests', () {
    final es = AppLocalizationsEs();

    test('extended property coverage', () {
      expect(es.typographyPreset, isNotEmpty);
      expect(es.tokenUsage, isNotEmpty);
      expect(es.libraryTitle, isNotEmpty);
      expect(es.readerBundles, isNotEmpty);
      expect(es.performanceSettings, isNotEmpty);
      expect(es.edit, isNotEmpty);
      expect(es.summary, isNotEmpty);
      expect(es.characters, isNotEmpty);
      expect(es.scenes, isNotEmpty);
      expect(es.aiAssistant, isNotEmpty);
      expect(es.deepAgentSettingsTitle, isNotEmpty);
      expect(es.summariesLabel, isNotEmpty);
      expect(es.synopsesLabel, isNotEmpty);
      expect(es.locationLabel, isNotEmpty);
      expect(es.publicLabel, isNotEmpty);
      expect(es.privateLabel, isNotEmpty);
      expect(es.refreshTooltip, isNotEmpty);
      expect(es.untitled, isNotEmpty);
      expect(es.adminMode, isNotEmpty);
      expect(es.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(es.removedNovel('Test'), isNotEmpty);
      expect(es.totalRecords(100), isNotEmpty);
      expect(es.confirmDeleteDescription('Test'), contains('Test'));
      expect(es.languageLabel('en'), contains('en'));
      expect(es.chaptersCount(10), isNotEmpty);
      expect(es.avgWordsPerChapter(5000), isNotEmpty);
      expect(es.chapterLabel(5), isNotEmpty);
      expect(es.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(es.aiTokenCount(1000), isNotEmpty);
      expect(es.aiContextLoadError('err'), contains('err'));
      expect(es.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(es.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(es.aiChatError('err'), contains('err'));
      expect(es.aiChatDeepAgentError('err'), contains('err'));
      expect(es.aiChatSearchError('err'), contains('err'));
      expect(es.aiChatRagRefinedQuery('q'), contains('q'));
      expect(es.aiServiceFailedToConnect('err'), contains('err'));
      expect(es.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('French Extended Coverage Tests', () {
    final fr = AppLocalizationsFr();

    test('extended property coverage', () {
      expect(fr.typographyPreset, isNotEmpty);
      expect(fr.tokenUsage, isNotEmpty);
      expect(fr.libraryTitle, isNotEmpty);
      expect(fr.readerBundles, isNotEmpty);
      expect(fr.performanceSettings, isNotEmpty);
      expect(fr.edit, isNotEmpty);
      expect(fr.summary, isNotEmpty);
      expect(fr.characters, isNotEmpty);
      expect(fr.scenes, isNotEmpty);
      expect(fr.aiAssistant, isNotEmpty);
      expect(fr.deepAgentSettingsTitle, isNotEmpty);
      expect(fr.summariesLabel, isNotEmpty);
      expect(fr.synopsesLabel, isNotEmpty);
      expect(fr.locationLabel, isNotEmpty);
      expect(fr.publicLabel, isNotEmpty);
      expect(fr.privateLabel, isNotEmpty);
      expect(fr.refreshTooltip, isNotEmpty);
      expect(fr.untitled, isNotEmpty);
      expect(fr.adminMode, isNotEmpty);
      expect(fr.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(fr.removedNovel('Test'), isNotEmpty);
      expect(fr.totalRecords(100), isNotEmpty);
      expect(fr.confirmDeleteDescription('Test'), contains('Test'));
      expect(fr.languageLabel('en'), contains('en'));
      expect(fr.chaptersCount(10), isNotEmpty);
      expect(fr.avgWordsPerChapter(5000), isNotEmpty);
      expect(fr.chapterLabel(5), isNotEmpty);
      expect(fr.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(fr.aiTokenCount(1000), isNotEmpty);
      expect(fr.aiContextLoadError('err'), contains('err'));
      expect(fr.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(fr.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(fr.aiChatError('err'), contains('err'));
      expect(fr.aiChatDeepAgentError('err'), contains('err'));
      expect(fr.aiChatSearchError('err'), contains('err'));
      expect(fr.aiChatRagRefinedQuery('q'), contains('q'));
      expect(fr.aiServiceFailedToConnect('err'), contains('err'));
      expect(fr.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('Italian Extended Coverage Tests', () {
    final it = AppLocalizationsIt();

    test('extended property coverage', () {
      expect(it.typographyPreset, isNotEmpty);
      expect(it.tokenUsage, isNotEmpty);
      expect(it.libraryTitle, isNotEmpty);
      expect(it.readerBundles, isNotEmpty);
      expect(it.performanceSettings, isNotEmpty);
      expect(it.edit, isNotEmpty);
      expect(it.summary, isNotEmpty);
      expect(it.characters, isNotEmpty);
      expect(it.scenes, isNotEmpty);
      expect(it.aiAssistant, isNotEmpty);
      expect(it.deepAgentSettingsTitle, isNotEmpty);
      expect(it.summariesLabel, isNotEmpty);
      expect(it.synopsesLabel, isNotEmpty);
      expect(it.locationLabel, isNotEmpty);
      expect(it.publicLabel, isNotEmpty);
      expect(it.privateLabel, isNotEmpty);
      expect(it.refreshTooltip, isNotEmpty);
      expect(it.untitled, isNotEmpty);
      expect(it.adminMode, isNotEmpty);
      expect(it.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(it.removedNovel('Test'), isNotEmpty);
      expect(it.totalRecords(100), isNotEmpty);
      expect(it.confirmDeleteDescription('Test'), contains('Test'));
      expect(it.languageLabel('en'), contains('en'));
      expect(it.chaptersCount(10), isNotEmpty);
      expect(it.avgWordsPerChapter(5000), isNotEmpty);
      expect(it.chapterLabel(5), isNotEmpty);
      expect(it.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(it.aiTokenCount(1000), isNotEmpty);
      expect(it.aiContextLoadError('err'), contains('err'));
      expect(it.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(it.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(it.aiChatError('err'), contains('err'));
      expect(it.aiChatDeepAgentError('err'), contains('err'));
      expect(it.aiChatSearchError('err'), contains('err'));
      expect(it.aiChatRagRefinedQuery('q'), contains('q'));
      expect(it.aiServiceFailedToConnect('err'), contains('err'));
      expect(it.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('Japanese Extended Coverage Tests', () {
    final ja = AppLocalizationsJa();

    test('extended property coverage', () {
      expect(ja.typographyPreset, isNotEmpty);
      expect(ja.tokenUsage, isNotEmpty);
      expect(ja.libraryTitle, isNotEmpty);
      expect(ja.readerBundles, isNotEmpty);
      expect(ja.performanceSettings, isNotEmpty);
      expect(ja.edit, isNotEmpty);
      expect(ja.summary, isNotEmpty);
      expect(ja.characters, isNotEmpty);
      expect(ja.scenes, isNotEmpty);
      expect(ja.aiAssistant, isNotEmpty);
      expect(ja.deepAgentSettingsTitle, isNotEmpty);
      expect(ja.summariesLabel, isNotEmpty);
      expect(ja.synopsesLabel, isNotEmpty);
      expect(ja.locationLabel, isNotEmpty);
      expect(ja.publicLabel, isNotEmpty);
      expect(ja.privateLabel, isNotEmpty);
      expect(ja.refreshTooltip, isNotEmpty);
      expect(ja.untitled, isNotEmpty);
      expect(ja.adminMode, isNotEmpty);
      expect(ja.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(ja.removedNovel('Test'), isNotEmpty);
      expect(ja.totalRecords(100), isNotEmpty);
      expect(ja.confirmDeleteDescription('Test'), contains('Test'));
      expect(ja.languageLabel('en'), contains('en'));
      expect(ja.chaptersCount(10), isNotEmpty);
      expect(ja.avgWordsPerChapter(5000), isNotEmpty);
      expect(ja.chapterLabel(5), isNotEmpty);
      expect(ja.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(ja.aiTokenCount(1000), isNotEmpty);
      expect(ja.aiContextLoadError('err'), contains('err'));
      expect(ja.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(ja.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(ja.aiChatError('err'), contains('err'));
      expect(ja.aiChatDeepAgentError('err'), contains('err'));
      expect(ja.aiChatSearchError('err'), contains('err'));
      expect(ja.aiChatRagRefinedQuery('q'), contains('q'));
      expect(ja.aiServiceFailedToConnect('err'), contains('err'));
      expect(ja.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('Russian Extended Coverage Tests', () {
    final ru = AppLocalizationsRu();

    test('extended property coverage', () {
      expect(ru.typographyPreset, isNotEmpty);
      expect(ru.tokenUsage, isNotEmpty);
      expect(ru.libraryTitle, isNotEmpty);
      expect(ru.readerBundles, isNotEmpty);
      expect(ru.performanceSettings, isNotEmpty);
      expect(ru.edit, isNotEmpty);
      expect(ru.summary, isNotEmpty);
      expect(ru.characters, isNotEmpty);
      expect(ru.scenes, isNotEmpty);
      expect(ru.aiAssistant, isNotEmpty);
      expect(ru.deepAgentSettingsTitle, isNotEmpty);
      expect(ru.summariesLabel, isNotEmpty);
      expect(ru.synopsesLabel, isNotEmpty);
      expect(ru.locationLabel, isNotEmpty);
      expect(ru.publicLabel, isNotEmpty);
      expect(ru.privateLabel, isNotEmpty);
      expect(ru.refreshTooltip, isNotEmpty);
      expect(ru.untitled, isNotEmpty);
      expect(ru.adminMode, isNotEmpty);
      expect(ru.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(ru.removedNovel('Test'), isNotEmpty);
      expect(ru.totalRecords(100), isNotEmpty);
      expect(ru.confirmDeleteDescription('Test'), contains('Test'));
      expect(ru.languageLabel('en'), contains('en'));
      expect(ru.chaptersCount(10), isNotEmpty);
      expect(ru.avgWordsPerChapter(5000), isNotEmpty);
      expect(ru.chapterLabel(5), isNotEmpty);
      expect(ru.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(ru.aiTokenCount(1000), isNotEmpty);
      expect(ru.aiContextLoadError('err'), contains('err'));
      expect(ru.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(ru.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(ru.aiChatError('err'), contains('err'));
      expect(ru.aiChatDeepAgentError('err'), contains('err'));
      expect(ru.aiChatSearchError('err'), contains('err'));
      expect(ru.aiChatRagRefinedQuery('q'), contains('q'));
      expect(ru.aiServiceFailedToConnect('err'), contains('err'));
      expect(ru.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });

  group('Chinese Extended Coverage Tests', () {
    final zh = AppLocalizationsZh();

    test('extended property coverage', () {
      expect(zh.typographyPreset, isNotEmpty);
      expect(zh.tokenUsage, isNotEmpty);
      expect(zh.libraryTitle, isNotEmpty);
      expect(zh.readerBundles, isNotEmpty);
      expect(zh.performanceSettings, isNotEmpty);
      expect(zh.edit, isNotEmpty);
      expect(zh.summary, isNotEmpty);
      expect(zh.characters, isNotEmpty);
      expect(zh.scenes, isNotEmpty);
      expect(zh.aiAssistant, isNotEmpty);
      expect(zh.deepAgentSettingsTitle, isNotEmpty);
      expect(zh.summariesLabel, isNotEmpty);
      expect(zh.synopsesLabel, isNotEmpty);
      expect(zh.locationLabel, isNotEmpty);
      expect(zh.publicLabel, isNotEmpty);
      expect(zh.privateLabel, isNotEmpty);
      expect(zh.refreshTooltip, isNotEmpty);
      expect(zh.untitled, isNotEmpty);
      expect(zh.adminMode, isNotEmpty);
      expect(zh.reduceMotion, isNotEmpty);
    });

    test('extended parameterized coverage', () {
      expect(zh.removedNovel('Test'), isNotEmpty);
      expect(zh.totalRecords(100), isNotEmpty);
      expect(zh.confirmDeleteDescription('Test'), contains('Test'));
      expect(zh.languageLabel('en'), contains('en'));
      expect(zh.chaptersCount(10), isNotEmpty);
      expect(zh.avgWordsPerChapter(5000), isNotEmpty);
      expect(zh.chapterLabel(5), isNotEmpty);
      expect(zh.chapterWithTitle(1, 'Test'), contains('Test'));
      expect(zh.aiTokenCount(1000), isNotEmpty);
      expect(zh.aiContextLoadError('err'), contains('err'));
      expect(zh.aiChatContextTooLongCompressing(5000), isNotEmpty);
      expect(zh.aiChatContextCompressionFailedNote('err'), contains('err'));
      expect(zh.aiChatError('err'), contains('err'));
      expect(zh.aiChatDeepAgentError('err'), contains('err'));
      expect(zh.aiChatSearchError('err'), contains('err'));
      expect(zh.aiChatRagRefinedQuery('q'), contains('q'));
      expect(zh.aiServiceFailedToConnect('err'), contains('err'));
      expect(zh.aiDeepAgentStop('reason', 5), isNotEmpty);
    });
  });
}
