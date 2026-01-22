import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  group('AppLocalizationsZh Tests', () {
    late AppLocalizationsZh zh;

    setUp(() {
      zh = AppLocalizationsZh();
    });

    group('Basic Strings', () {
      test('loads basic Chinese localizations', () {
        expect(zh.helloWorld, '你好世界！');
        expect(zh.settings, '设置');
        expect(zh.appTitle, '写手');
        expect(zh.about, '关于');
      });

      test('contains non-empty strings for all basic keys', () {
        expect(zh.helloWorld.isNotEmpty, true);
        expect(zh.settings.isNotEmpty, true);
        expect(zh.appTitle.isNotEmpty, true);
        expect(zh.about.isNotEmpty, true);
      });
    });

    group('About Section', () {
      test('about section strings are valid', () {
        expect(zh.aboutDescription.isNotEmpty, true);
        expect(zh.aboutIntro.isNotEmpty, true);
        expect(zh.aboutSecurity.isNotEmpty, true);
        expect(zh.aboutCoach.isNotEmpty, true);
        expect(zh.aboutFeatureCreate.isNotEmpty, true);
        expect(zh.aboutFeatureTemplates.isNotEmpty, true);
        expect(zh.aboutFeatureTracking.isNotEmpty, true);
        expect(zh.aboutFeatureCoach.isNotEmpty, true);
        expect(zh.aboutFeaturePrompts.isNotEmpty, true);
        expect(zh.aboutUsage.isNotEmpty, true);
        expect(zh.aboutUsageList.isNotEmpty, true);
      });
    });

    group('Language and Version', () {
      test('language and version strings are valid', () {
        expect(zh.version.isNotEmpty, true);
        expect(zh.appLanguage.isNotEmpty, true);
        expect(zh.english.isNotEmpty, true);
        expect(zh.chinese.isNotEmpty, true);
      });
    });

    group('Authentication Strings', () {
      test('authentication strings are valid', () {
        expect(zh.supabaseIntegrationInitialized.isNotEmpty, true);
        expect(zh.configureEnvironment.isNotEmpty, true);
        expect(zh.guest.isNotEmpty, true);
        expect(zh.notSignedIn.isNotEmpty, true);
        expect(zh.signIn.isNotEmpty, true);
        expect(zh.continueLabel.isNotEmpty, true);
        expect(zh.reload.isNotEmpty, true);
        expect(zh.signInToSync.isNotEmpty, true);
        expect(zh.signOut.isNotEmpty, true);
        expect(zh.signedOut.isNotEmpty, true);
        expect(zh.signInWithGoogle.isNotEmpty, true);
        expect(zh.signInWithApple.isNotEmpty, true);
        expect(zh.signInWithBiometrics.isNotEmpty, true);
        expect(zh.enableBiometricLogin.isNotEmpty, true);
        expect(zh.enableBiometricLoginDescription.isNotEmpty, true);
        expect(zh.biometricAuthFailed.isNotEmpty, true);
      });

      test('signedInAs parameterized method works', () {
        expect(zh.signedInAs('test@example.com'), '已登录为 test@example.com');
        expect(zh.signedInAs('user@test.com'), '已登录为 user@test.com');
        expect(zh.signedInAs(''), '已登录为 ');
      });
    });

    group('Progress and Loading Strings', () {
      test('progress strings are valid', () {
        expect(zh.currentProgress.isNotEmpty, true);
        expect(zh.loadingProgress.isNotEmpty, true);
        expect(zh.recentlyRead.isNotEmpty, true);
        expect(zh.noSupabase.isNotEmpty, true);
        expect(zh.errorLoadingProgress.isNotEmpty, true);
        expect(zh.noProgress.isNotEmpty, true);
        expect(zh.progressSaved.isNotEmpty, true);
        expect(zh.errorSavingProgress.isNotEmpty, true);
      });

      test('loading strings are valid', () {
        expect(zh.errorLoadingNovels.isNotEmpty, true);
        expect(zh.loadingNovels.isNotEmpty, true);
        expect(zh.errorLoadingChapters.isNotEmpty, true);
        expect(zh.loadingChapter.isNotEmpty, true);
      });
    });

    group('Novel and Chapter Strings', () {
      test('novel strings are valid', () {
        expect(zh.titleLabel.isNotEmpty, true);
        expect(zh.authorLabel.isNotEmpty, true);
        expect(zh.noNovelsFound.isNotEmpty, true);
        expect(zh.myNovels.isNotEmpty, true);
        expect(zh.createNovel.isNotEmpty, true);
        expect(zh.create.isNotEmpty, true);
        expect(zh.notStarted.isNotEmpty, true);
        expect(zh.unknownNovel.isNotEmpty, true);
        expect(zh.unknownChapter.isNotEmpty, true);
        expect(zh.chapter.isNotEmpty, true);
        expect(zh.novel.isNotEmpty, true);
        expect(zh.chapterTitle.isNotEmpty, true);
        expect(zh.chapters.isNotEmpty, true);
        expect(zh.noChaptersFound.isNotEmpty, true);
      });

      test('continueAtChapter parameterized method works', () {
        expect(zh.continueAtChapter('第一章'), '继续阅读章节 • 第一章');
        expect(zh.continueAtChapter('Chapter 1'), '继续阅读章节 • Chapter 1');
        expect(zh.continueAtChapter(''), '继续阅读章节 • ');
      });
    });

    group('Reader Strings', () {
      test('reader metadata strings are valid', () {
        expect(zh.scrollOffset.isNotEmpty, true);
        expect(zh.ttsIndex.isNotEmpty, true);
        expect(zh.speechRate.isNotEmpty, true);
        expect(zh.volume.isNotEmpty, true);
        expect(zh.defaultTTSVoice.isNotEmpty, true);
        expect(zh.defaultVoiceUpdated.isNotEmpty, true);
        expect(zh.defaultLanguageSet.isNotEmpty, true);
      });

      test('TTS strings are valid', () {
        expect(zh.ttsSettings.isNotEmpty, true);
        expect(zh.enableTTS.isNotEmpty, true);
        expect(zh.testVoice.isNotEmpty, true);
        expect(zh.reloadVoices.isNotEmpty, true);
        expect(zh.ttsVoice.isNotEmpty, true);
        expect(zh.loadingVoices.isNotEmpty, true);
        expect(zh.selectVoice.isNotEmpty, true);
        expect(zh.ttsLanguage.isNotEmpty, true);
        expect(zh.loadingLanguages.isNotEmpty, true);
        expect(zh.selectLanguage.isNotEmpty, true);
        expect(zh.ttsSpeechRate.isNotEmpty, true);
        expect(zh.ttsSpeechVolume.isNotEmpty, true);
        expect(zh.ttsSpeechPitch.isNotEmpty, true);
        expect(zh.stopTTS.isNotEmpty, true);
        expect(zh.speak.isNotEmpty, true);
      });

      test('ttsError parameterized method works', () {
        expect(zh.ttsError('Network error'), 'TTS 错误：Network error');
        expect(zh.ttsError(''), 'TTS 错误：');
        expect(zh.ttsError('测试错误'), 'TTS 错误：测试错误');
      });

      test('autoplay strings are valid', () {
        expect(zh.autoplayBlocked.isNotEmpty, true);
        expect(zh.autoplayBlockedInline.isNotEmpty, true);
        expect(zh.reachedLastChapter.isNotEmpty, true);
        expect(zh.reachedFirstChapter.isNotEmpty, true);
        expect(zh.previousChapter.isNotEmpty, true);
        expect(zh.nextChapter.isNotEmpty, true);
      });
    });

    group('Settings Strings', () {
      test('app settings strings are valid', () {
        expect(zh.appSettings.isNotEmpty, true);
        expect(zh.supabaseSettings.isNotEmpty, true);
        expect(zh.supabaseNotEnabled.isNotEmpty, true);
        expect(zh.supabaseNotEnabledDescription.isNotEmpty, true);
        expect(zh.authDisabledInBuild.isNotEmpty, true);
        expect(zh.fetchFromSupabase.isNotEmpty, true);
        expect(zh.fetchFromSupabaseDescription.isNotEmpty, true);
        expect(zh.confirmFetch.isNotEmpty, true);
        expect(zh.confirmFetchDescription.isNotEmpty, true);
        expect(zh.cancel.isNotEmpty, true);
        expect(zh.fetch.isNotEmpty, true);
        expect(zh.downloadChapters.isNotEmpty, true);
        expect(zh.modeSupabase.isNotEmpty, true);
        expect(zh.modeMockData.isNotEmpty, true);
      });

      test('theme strings are valid', () {
        expect(zh.themeMode.isNotEmpty, true);
        expect(zh.system.isNotEmpty, true);
        expect(zh.light.isNotEmpty, true);
        expect(zh.dark.isNotEmpty, true);
        expect(zh.colorTheme.isNotEmpty, true);
        expect(zh.themeLight.isNotEmpty, true);
        expect(zh.themeSepia.isNotEmpty, true);
        expect(zh.themeHighContrast.isNotEmpty, true);
        expect(zh.themeDefault.isNotEmpty, true);
        expect(zh.themeEmeraldGreen.isNotEmpty, true);
        expect(zh.themeSolarizedTan.isNotEmpty, true);
        expect(zh.themeNord.isNotEmpty, true);
        expect(zh.themeNordFrost.isNotEmpty, true);
        expect(zh.separateDarkPalette.isNotEmpty, true);
        expect(zh.lightPalette.isNotEmpty, true);
        expect(zh.darkPalette.isNotEmpty, true);
      });

      test('typography strings are valid', () {
        expect(zh.typographyPreset.isNotEmpty, true);
        expect(zh.typographyComfortable.isNotEmpty, true);
        expect(zh.typographyCompact.isNotEmpty, true);
        expect(zh.typographySerifLike.isNotEmpty, true);
        expect(zh.fontPack.isNotEmpty, true);
        expect(zh.separateTypographyPresets.isNotEmpty, true);
        expect(zh.typographyLight.isNotEmpty, true);
        expect(zh.typographyDark.isNotEmpty, true);
        expect(zh.readerBundles.isNotEmpty, true);
        expect(zh.customFontFamily.isNotEmpty, true);
        expect(zh.commonFonts.isNotEmpty, true);
        expect(zh.readerFontSize.isNotEmpty, true);
        expect(zh.textScale.isNotEmpty, true);
        expect(zh.readerBackgroundDepth.isNotEmpty, true);
        expect(zh.depthLow.isNotEmpty, true);
        expect(zh.depthMedium.isNotEmpty, true);
        expect(zh.depthHigh.isNotEmpty, true);
      });

      test('reader bundle strings are valid', () {
        expect(zh.bundleNordCalm.isNotEmpty, true);
        expect(zh.bundleSolarizedFocus.isNotEmpty, true);
        expect(zh.bundleHighContrastReadability.isNotEmpty, true);
      });

      test('performance settings strings are valid', () {
        expect(zh.performanceSettings.isNotEmpty, true);
        expect(zh.prefetchNextChapter.isNotEmpty, true);
        expect(zh.prefetchNextChapterDescription.isNotEmpty, true);
        expect(zh.clearOfflineCache.isNotEmpty, true);
        expect(zh.offlineCacheCleared.isNotEmpty, true);
        expect(zh.reduceMotion.isNotEmpty, true);
        expect(zh.reduceMotionDescription.isNotEmpty, true);
        expect(zh.gesturesEnabled.isNotEmpty, true);
        expect(zh.gesturesEnabledDescription.isNotEmpty, true);
        expect(zh.readerSwipeSensitivity.isNotEmpty, true);
        expect(zh.readerSwipeSensitivityDescription.isNotEmpty, true);
      });
    });

    group('Token Usage Strings', () {
      test('token usage strings are valid', () {
        expect(zh.tokenUsage.isNotEmpty, true);
        expect(zh.userManagement.isNotEmpty, true);
        expect(zh.totalThisMonth.isNotEmpty, true);
        expect(zh.inputTokens.isNotEmpty, true);
        expect(zh.outputTokens.isNotEmpty, true);
        expect(zh.requests.isNotEmpty, true);
        expect(zh.viewHistory.isNotEmpty, true);
        expect(zh.noUsageThisMonth.isNotEmpty, true);
        expect(zh.startUsingAiFeatures.isNotEmpty, true);
        expect(zh.errorLoadingUsage.isNotEmpty, true);
        expect(zh.refresh.isNotEmpty, true);
        expect(zh.total.isNotEmpty, true);
        expect(zh.noUsageHistory.isNotEmpty, true);
      });

      test('totalRecords parameterized method works', () {
        expect(zh.totalRecords(100), '总记录数：100');
        expect(zh.totalRecords(0), '总记录数：0');
        expect(zh.totalRecords(9999), '总记录数：9999');
      });
    });

    group('Form and Action Strings', () {
      test('form action strings are valid', () {
        expect(zh.select.isNotEmpty, true);
        expect(zh.clear.isNotEmpty, true);
        expect(zh.remove.isNotEmpty, true);
        expect(zh.removedFromLibrary.isNotEmpty, true);
        expect(zh.undo.isNotEmpty, true);
        expect(zh.confirmDelete.isNotEmpty, true);
        expect(zh.delete.isNotEmpty, true);
        expect(zh.save.isNotEmpty, true);
        expect(zh.edit.isNotEmpty, true);
        expect(zh.exitEdit.isNotEmpty, true);
        expect(zh.enterEditMode.isNotEmpty, true);
        expect(zh.exitEditMode.isNotEmpty, true);
        expect(zh.createNextChapter.isNotEmpty, true);
        expect(zh.enterChapterTitle.isNotEmpty, true);
        expect(zh.enterChapterContent.isNotEmpty, true);
        expect(zh.discardChangesTitle.isNotEmpty, true);
        expect(zh.discardChangesMessage.isNotEmpty, true);
        expect(zh.keepEditing.isNotEmpty, true);
        expect(zh.discardChanges.isNotEmpty, true);
        expect(zh.saveAndExit.isNotEmpty, true);
      });

      test('confirmDeleteDescription parameterized method works', () {
        expect(zh.confirmDeleteDescription('测试小说').contains('测试小说'), true);
        expect(zh.confirmDeleteDescription('Novel').contains('Novel'), true);
        expect(zh.confirmDeleteDescription(''), isNotNull);
      });
    });

    group('Novel Metadata Strings', () {
      test('novel metadata strings are valid', () {
        expect(zh.descriptionLabel.isNotEmpty, true);
        expect(zh.coverUrlLabel.isNotEmpty, true);
        expect(zh.invalidCoverUrl.isNotEmpty, true);
        expect(zh.novelMetadata.isNotEmpty, true);
        expect(zh.contributorEmailLabel.isNotEmpty, true);
        expect(zh.contributorEmailHint.isNotEmpty, true);
        expect(zh.addContributor.isNotEmpty, true);
        expect(zh.contributorAdded.isNotEmpty, true);
      });
    });

    group('Navigation Strings', () {
      test('navigation strings are valid', () {
        expect(zh.navigation.isNotEmpty, true);
        expect(zh.home.isNotEmpty, true);
        expect(zh.chapterIndex.isNotEmpty, true);
        expect(zh.summary.isNotEmpty, true);
        expect(zh.characters.isNotEmpty, true);
        expect(zh.scenes.isNotEmpty, true);
        expect(zh.characterTemplates.isNotEmpty, true);
        expect(zh.sceneTemplates.isNotEmpty, true);
        expect(zh.updateNovel.isNotEmpty, true);
        expect(zh.deleteNovel.isNotEmpty, true);
        expect(zh.deleteNovelConfirmation.isNotEmpty, true);
        expect(zh.format.isNotEmpty, true);
      });
    });

    group('AI Service Strings', () {
      test('AI service strings are valid', () {
        expect(zh.aiServiceUrl.isNotEmpty, true);
        expect(zh.aiServiceUrlDescription.isNotEmpty, true);
        expect(zh.aiAssistant.isNotEmpty, true);
        expect(zh.aiChatHint.isNotEmpty, true);
        expect(zh.aiChatEmpty.isNotEmpty, true);
        expect(zh.aiThinking.isNotEmpty, true);
        expect(zh.send.isNotEmpty, true);
        expect(zh.resetToDefault.isNotEmpty, true);
        expect(zh.invalidUrl.isNotEmpty, true);
        expect(zh.urlTooLong.isNotEmpty, true);
        expect(zh.urlContainsSpaces.isNotEmpty, true);
        expect(zh.urlInvalidScheme.isNotEmpty, true);
        expect(zh.saved.isNotEmpty, true);
        expect(zh.aiServiceUnavailable.isNotEmpty, true);
        expect(zh.aiConfigurations.isNotEmpty, true);
        expect(zh.modelLabel.isNotEmpty, true);
        expect(zh.temperatureLabel.isNotEmpty, true);
        expect(zh.saveFailed.isNotEmpty, true);
        expect(zh.saveMyVersion.isNotEmpty, true);
        expect(zh.resetToPublic.isNotEmpty, true);
        expect(zh.resetFailed.isNotEmpty, true);
      });

      test('aiServiceUrlHint is valid', () {
        expect(zh.aiServiceUrlHint.isNotEmpty, true);
      });
    });

    group('Summary Strings', () {
      test('summary strings are valid', () {
        expect(zh.sentenceSummary.isNotEmpty, true);
        expect(zh.paragraphSummary.isNotEmpty, true);
        expect(zh.pageSummary.isNotEmpty, true);
        expect(zh.expandedSummary.isNotEmpty, true);
        expect(zh.pitch.isNotEmpty, true);
        expect(zh.required.isNotEmpty, true);
        expect(zh.summariesLabel.isNotEmpty, true);
        expect(zh.synopsesLabel.isNotEmpty, true);
        expect(zh.locationLabel.isNotEmpty, true);
      });
    });

    group('Labels and Filters', () {
      test('label strings are valid', () {
        expect(zh.publicLabel.isNotEmpty, true);
        expect(zh.privateLabel.isNotEmpty, true);
        expect(zh.refreshTooltip.isNotEmpty, true);
        expect(zh.untitled.isNotEmpty, true);
        expect(zh.newLabel.isNotEmpty, true);
        expect(zh.required.isNotEmpty, true);
        expect(zh.metaLabel.isNotEmpty, true);
        expect(zh.templateLabel.isNotEmpty, true);
        expect(zh.menu.isNotEmpty, true);
        expect(zh.preview.isNotEmpty, true);
        expect(zh.actions.isNotEmpty, true);
        expect(zh.searchLabel.isNotEmpty, true);
        expect(zh.allLabel.isNotEmpty, true);
        expect(zh.filterByLocked.isNotEmpty, true);
        expect(zh.lockedOnly.isNotEmpty, true);
        expect(zh.unlockedOnly.isNotEmpty, true);
        expect(zh.promptKey.isNotEmpty, true);
        expect(zh.language.isNotEmpty, true);
        expect(zh.filterByKey.isNotEmpty, true);
        expect(zh.viewPublic.isNotEmpty, true);
        expect(zh.groupNone.isNotEmpty, true);
        expect(zh.groupLanguage.isNotEmpty, true);
        expect(zh.groupKey.isNotEmpty, true);
        expect(zh.content.isNotEmpty, true);
        expect(zh.invalidKey.isNotEmpty, true);
        expect(zh.invalidLanguage.isNotEmpty, true);
        expect(zh.invalidInput.isNotEmpty, true);
        expect(zh.previewLabel.isNotEmpty, true);
        expect(zh.markdownHint.isNotEmpty, true);
        expect(zh.urlLabel.isNotEmpty, true);
        expect(zh.usageRulesLabel.isNotEmpty, true);
        expect(zh.publicPatternLabel.isNotEmpty, true);
        expect(zh.publicStoryLineLabel.isNotEmpty, true);
        expect(zh.lockedLabel.isNotEmpty, true);
        expect(zh.unlockedLabel.isNotEmpty, true);
        expect(zh.aiButton.isNotEmpty, true);
      });

      test('languageLabel parameterized method works', () {
        expect(zh.languageLabel('zh'), '语言：zh');
        expect(zh.languageLabel('en'), '语言：en');
        expect(zh.languageLabel(''), '语言：');
      });

      test('chaptersCount parameterized method works', () {
        expect(zh.chaptersCount(10), '章节：10');
        expect(zh.chaptersCount(0), '章节：0');
        expect(zh.chaptersCount(100), '章节：100');
      });

      test('avgWordsPerChapter parameterized method works', () {
        expect(zh.avgWordsPerChapter(500), '平均每章字数：500');
        expect(zh.avgWordsPerChapter(0), '平均每章字数：0');
        expect(zh.avgWordsPerChapter(9999), '平均每章字数：9999');
      });

      test('charsCount parameterized method works', () {
        expect(zh.charsCount(1000), '字符数：1000');
        expect(zh.charsCount(0), '字符数：0');
        expect(zh.charsCount(50000), '字符数：50000');
      });
    });

    group('Chapter Label Methods', () {
      test('chapterLabel parameterized method works', () {
        expect(zh.chapterLabel(1), '第1章');
        expect(zh.chapterLabel(10), '第10章');
        expect(zh.chapterLabel(100), '第100章');
      });

      test('chapterWithTitle parameterized method works', () {
        expect(zh.chapterWithTitle(1, '第一章'), '第1章：第一章');
        expect(zh.chapterWithTitle(5, 'Chapter 5'), '第5章：Chapter 5');
        expect(zh.chapterWithTitle(0, 'Intro'), '第0章：Intro');
      });

      test('indexLabel parameterized method works', () {
        expect(zh.indexLabel(1), '第 1 章');
        expect(zh.indexLabel(10), '第 10 章');
        expect(zh.indexLabel(100), '第 100 章');
      });

      test('indexOutOfRange parameterized method works', () {
        expect(zh.indexOutOfRange(1, 10), '索引必须在 1-10 之间');
        expect(zh.indexOutOfRange(0, 100), '索引必须在 0-100 之间');
      });
    });

    group('Delete and Remove Strings', () {
      test('delete strings are valid', () {
        expect(zh.deleteSceneTitle.isNotEmpty, true);
        expect(zh.deleteCharacterTitle.isNotEmpty, true);
        expect(zh.deleteTemplateTitle.isNotEmpty, true);
        expect(zh.confirmDeleteGeneric.isNotEmpty, true);
        expect(zh.deleteFailed.isNotEmpty, true);
      });

      test('deletedWithTitle parameterized method works', () {
        expect(zh.deletedWithTitle('Test'), '已删除：Test');
        expect(zh.deletedWithTitle('测试'), '已删除：测试');
        expect(zh.deletedWithTitle(''), '已删除：');
      });

      test('deleteFailedWithTitle parameterized method works', () {
        expect(zh.deleteFailedWithTitle('Test'), '删除失败：Test');
        expect(zh.deleteFailedWithTitle('测试'), '删除失败：测试');
      });

      test('deleteErrorWithMessage parameterized method works', () {
        expect(
          zh.deleteErrorWithMessage('Network error'),
          '删除出错：Network error',
        );
        expect(zh.deleteErrorWithMessage(''), '删除出错：');
      });

      test('deletePromptConfirm parameterized method works', () {
        expect(zh.deletePromptConfirm('prompt1', 'zh'), '删除提示词 "prompt1"（zh）？');
        expect(zh.deletePromptConfirm('test', 'en'), '删除提示词 "test"（en）？');
      });
    });

    group('Prompts, Patterns, StoryLines', () {
      test('prompts patterns storylines strings are valid', () {
        expect(zh.prompts.isNotEmpty, true);
        expect(zh.patterns.isNotEmpty, true);
        expect(zh.storyLines.isNotEmpty, true);
        expect(zh.tools.isNotEmpty, true);
        expect(zh.newPrompt.isNotEmpty, true);
        expect(zh.newPattern.isNotEmpty, true);
        expect(zh.newStoryLine.isNotEmpty, true);
        expect(zh.editPrompt.isNotEmpty, true);
        expect(zh.editPattern.isNotEmpty, true);
        expect(zh.editStoryLine.isNotEmpty, true);
        expect(zh.makePublic.isNotEmpty, true);
        expect(zh.noPrompts.isNotEmpty, true);
        expect(zh.noPatterns.isNotEmpty, true);
        expect(zh.noStoryLines.isNotEmpty, true);
        expect(zh.editPatternTitle.isNotEmpty, true);
        expect(zh.newPatternTitle.isNotEmpty, true);
        expect(zh.editStoryLineTitle.isNotEmpty, true);
        expect(zh.newStoryLineTitle.isNotEmpty, true);
      });

      test('conversionFailed parameterized method works', () {
        expect(zh.conversionFailed('Error'), '转换失败：Error');
        expect(zh.conversionFailed(''), '转换失败：');
      });

      test('retrieveFailed parameterized method works', () {
        expect(zh.retrieveFailed('Error'), '获取失败：Error');
        expect(zh.retrieveFailed(''), '获取失败：');
      });

      test('makePublicPromptConfirm parameterized method works', () {
        expect(zh.makePublicPromptConfirm('key1', 'zh'), '将提示 "key1"（zh）设为公开？');
        expect(zh.makePublicPromptConfirm('test', 'en'), '将提示 "test"（en）设为公开？');
      });
    });

    group('AI Coach Strings', () {
      test('AI coach strings are valid', () {
        expect(zh.failedToAnalyze.isNotEmpty, true);
        expect(zh.aiCoachAnalyzing.isNotEmpty, true);
        expect(zh.retry.isNotEmpty, true);
        expect(zh.startAiCoaching.isNotEmpty, true);
        expect(zh.refinementComplete.isNotEmpty, true);
        expect(zh.coachQuestion.isNotEmpty, true);
        expect(zh.summaryLooksGood.isNotEmpty, true);
        expect(zh.howToImprove.isNotEmpty, true);
        expect(zh.suggestionsLabel.isNotEmpty, true);
        expect(zh.reviewSuggestionsHint.isNotEmpty, true);
        expect(zh.aiGenerationComplete.isNotEmpty, true);
        expect(zh.clickRegenerateForNew.isNotEmpty, true);
        expect(zh.regenerate.isNotEmpty, true);
        expect(zh.imSatisfied.isNotEmpty, true);
        expect(zh.toggleAiCoach.isNotEmpty, true);
      });
    });

    group('Template Strings', () {
      test('template strings are valid', () {
        expect(zh.exampleCharacterName.isNotEmpty, true);
        expect(zh.templateName.isNotEmpty, true);
        expect(zh.templateNameExists.isNotEmpty, true);
        expect(zh.failedToPersistTemplate.isNotEmpty, true);
      });
    });

    group('PDF Strings', () {
      test('PDF strings are valid', () {
        expect(zh.pdf.isNotEmpty, true);
        expect(zh.generatingPdf.isNotEmpty, true);
        expect(zh.pdfFailed.isNotEmpty, true);
        expect(zh.tableOfContents.isNotEmpty, true);
      });

      test('byAuthor parameterized method works', () {
        expect(zh.byAuthor('Author Name'), '作者：Author Name');
        expect(zh.byAuthor('作者名'), '作者：作者名');
        expect(zh.byAuthor(''), '作者：');
      });

      test('pageOfTotal parameterized method works', () {
        expect(zh.pageOfTotal(1, 10), '第1/10页');
        expect(zh.pageOfTotal(5, 100), '第5/100页');
        expect(zh.pageOfTotal(0, 0), '第0/0页');
      });
    });

    group('Common Action Strings', () {
      test('common action strings are valid', () {
        expect(zh.close.isNotEmpty, true);
        expect(zh.copy.isNotEmpty, true);
        expect(zh.copiedToClipboard.isNotEmpty, true);
        expect(zh.confirm.isNotEmpty, true);
      });

      test('showingCachedPublicData parameterized method works', () {
        expect(zh.showingCachedPublicData('Test'), 'Test — 显示缓存/公共数据');
        expect(zh.showingCachedPublicData(''), ' — 显示缓存/公共数据');
      });
    });

    group('Search and Filter Strings', () {
      test('search strings are valid', () {
        expect(zh.searchByTitle.isNotEmpty, true);
        expect(zh.chooseLanguage.isNotEmpty, true);
        expect(zh.searchNovels.isNotEmpty, true);
        expect(zh.allFilter.isNotEmpty, true);
        expect(zh.readingFilter.isNotEmpty, true);
        expect(zh.completedFilter.isNotEmpty, true);
        expect(zh.downloadedFilter.isNotEmpty, true);
        expect(zh.tryAdjustingSearchCreateNovel.isNotEmpty, true);
        expect(zh.smartSearch.isNotEmpty, true);
        expect(zh.listView.isNotEmpty, true);
        expect(zh.gridView.isNotEmpty, true);
      });
    });

    group('Error Strings', () {
      test('error strings are valid', () {
        expect(zh.error.isNotEmpty, true);
        expect(zh.invalidJson.isNotEmpty, true);
        expect(zh.errorUnauthorized.isNotEmpty, true);
        expect(zh.errorForbidden.isNotEmpty, true);
        expect(zh.errorSessionExpired.isNotEmpty, true);
        expect(zh.errorValidation.isNotEmpty, true);
        expect(zh.errorInvalidInput.isNotEmpty, true);
        expect(zh.errorDuplicateTitle.isNotEmpty, true);
        expect(zh.errorNotFound.isNotEmpty, true);
        expect(zh.errorServiceUnavailable.isNotEmpty, true);
        expect(zh.errorAiNotConfigured.isNotEmpty, true);
        expect(zh.errorSupabaseError.isNotEmpty, true);
        expect(zh.errorRateLimited.isNotEmpty, true);
        expect(zh.errorInternal.isNotEmpty, true);
        expect(zh.errorBadGateway.isNotEmpty, true);
        expect(zh.errorGatewayTimeout.isNotEmpty, true);
        expect(zh.loginFailed.isNotEmpty, true);
        expect(zh.invalidResponseFromServer.isNotEmpty, true);
        expect(zh.signupFailed.isNotEmpty, true);
        expect(zh.requestFailed.isNotEmpty, true);
        expect(zh.passwordsDoNotMatch.isNotEmpty, true);
        expect(zh.sessionInvalidLoginAgain.isNotEmpty, true);
        expect(zh.updateFailed.isNotEmpty, true);
        expect(zh.noActiveSessionFound.isNotEmpty, true);
        expect(zh.authenticationFailedSignInAgain.isNotEmpty, true);
        expect(zh.accessDeniedNoAdminPrivileges.isNotEmpty, true);
        expect(zh.smartSearchRequiresSignIn.isNotEmpty, true);
        expect(zh.errorLoadingUsers.isNotEmpty, true);
        expect(zh.unknownError.isNotEmpty, true);
        expect(zh.goBack.isNotEmpty, true);
        expect(zh.unableToLoadAsset.isNotEmpty, true);
        expect(zh.youDontHavePermission.isNotEmpty, true);
        expect(zh.failedToLoadConfig.isNotEmpty, true);
      });

      test('failedToLoadUsers parameterized method works', () {
        expect(
          zh.failedToLoadUsers(404, 'Not found'),
          '加载用户失败：404 - Not found',
        );
        expect(
          zh.failedToLoadUsers(500, 'Server error'),
          '加载用户失败：500 - Server error',
        );
      });

      test('userIdCreated parameterized method works', () {
        expect(
          zh.userIdCreated('123', '2024-01-01'),
          'ID：123\n创建时间：2024-01-01',
        );
        expect(
          zh.userIdCreated('abc', '2024-12-31'),
          'ID：abc\n创建时间：2024-12-31',
        );
      });
    });

    group('Auth Flow Strings', () {
      test('auth flow strings are valid', () {
        expect(zh.signUp.isNotEmpty, true);
        expect(zh.forgotPassword.isNotEmpty, true);
        expect(zh.accountCreatedCheckEmail.isNotEmpty, true);
        expect(zh.backToSignIn.isNotEmpty, true);
        expect(zh.createAccount.isNotEmpty, true);
        expect(zh.alreadyHaveAccountSignIn.isNotEmpty, true);
        expect(zh.ifAccountExistsResetLinkSent.isNotEmpty, true);
        expect(zh.enterEmailForResetLink.isNotEmpty, true);
        expect(zh.sendResetLink.isNotEmpty, true);
        expect(zh.resetPassword.isNotEmpty, true);
        expect(zh.newPassword.isNotEmpty, true);
        expect(zh.confirmPassword.isNotEmpty, true);
        expect(zh.updatePassword.isNotEmpty, true);
        expect(zh.passwordUpdatedSuccessfully.isNotEmpty, true);
      });
    });

    group('Profile Strings', () {
      test('profile strings are valid', () {
        expect(zh.profileRetrieved.isNotEmpty, true);
        expect(zh.noProfileFound.isNotEmpty, true);
        expect(zh.retrieveProfile.isNotEmpty, true);
      });
    });

    group('Font Strings', () {
      test('font strings are valid', () {
        expect(zh.systemFont.isNotEmpty, true);
        expect(zh.fontInter.isNotEmpty, true);
        expect(zh.fontMerriweather.isNotEmpty, true);
      });
    });

    group('Admin Strings', () {
      test('admin strings are valid', () {
        expect(zh.adminMode.isNotEmpty, true);
      });
    });

    group('Library Strings', () {
      test('library strings are valid', () {
        expect(zh.continueReading.isNotEmpty, true);
        expect(zh.removeFromLibrary.isNotEmpty, true);
        expect(zh.noRecentChapters.isNotEmpty, true);
        expect(zh.lastRead.isNotEmpty, true);
      });
    });

    group('Index Strings', () {
      test('index strings are valid', () {
        expect(zh.enterFloatIndexHint.isNotEmpty, true);
        expect(zh.indexUnchanged.isNotEmpty, true);
        expect(zh.roundingBefore.isNotEmpty, true);
        expect(zh.roundingAfter.isNotEmpty, true);
      });
    });

    group('Novels and Progress Summary', () {
      test('novelsAndProgressSummary parameterized method works', () {
        expect(zh.novelsAndProgressSummary(5, '50%'), '小说: 5, 进度: 50%');
        expect(zh.novelsAndProgressSummary(0, '0%'), '小说: 0, 进度: 0%');
        expect(zh.novelsAndProgressSummary(100, '100%'), '小说: 100, 进度: 100%');
      });
    });

    group('Session Strings', () {
      test('session strings are valid', () {
        expect(zh.sessionExpired.isNotEmpty, true);
      });
    });

    group('Beta Strings', () {
      test('beta strings are valid', () {
        expect(zh.betaEvaluate.isNotEmpty, true);
        expect(zh.betaEvaluating.isNotEmpty, true);
        expect(zh.betaEvaluationReady.isNotEmpty, true);
        expect(zh.betaEvaluationFailed.isNotEmpty, true);
      });
    });

    group('Supabase Progress Strings', () {
      test('supabase progress strings are valid', () {
        expect(zh.supabaseProgressNotSaved.isNotEmpty, true);
      });
    });

    group('Chapter Content Strings', () {
      test('chapter content strings are valid', () {
        expect(zh.chapterContent.isNotEmpty, true);
      });
    });
  });
}
