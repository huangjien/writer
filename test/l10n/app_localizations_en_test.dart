import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  group('AppLocalizationsEn', () {
    late AppLocalizationsEn l10n;

    setUp(() {
      l10n = AppLocalizationsEn();
    });

    group('Locale and basic properties', () {
      test('returns correct locale', () {
        expect(l10n.localeName, 'en');
      });

      test('has correct locale tag', () {
        expect(l10n.localeName, equals('en'));
        expect(l10n.localeName, isNotEmpty);
        expect(l10n.localeName.length, equals(2));
      });
    });

    group('Core app strings', () {
      test('specific values match expected English text', () {
        expect(l10n.appTitle, 'Writer');
        expect(l10n.settings, 'Settings');
        expect(l10n.helloWorld, 'Hello World!');
        expect(l10n.back, 'Back');
        expect(l10n.newChapter, 'New Chapter');
      });

      test('navigation strings are correct', () {
        expect(l10n.navigation, 'Navigation');
        expect(l10n.home, 'Home');
        expect(l10n.libraryTitle, 'Library');
        expect(l10n.summary, 'Summary');
        expect(l10n.characters, 'Characters');
        expect(l10n.scenes, 'Scenes');
      });
    });

    group('About page strings', () {
      test('about page strings are non-empty', () {
        expect(l10n.about, isNotEmpty);
        expect(l10n.aboutDescription, isNotEmpty);
        expect(l10n.aboutIntro, isNotEmpty);
        expect(l10n.aboutSecurity, isNotEmpty);
        expect(l10n.aboutCoach, isNotEmpty);
      });

      test('about feature strings start with bullet points', () {
        expect(l10n.aboutFeatureCreate, startsWith('•'));
        expect(l10n.aboutFeatureTemplates, startsWith('•'));
        expect(l10n.aboutFeatureTracking, startsWith('•'));
        expect(l10n.aboutFeatureCoach, startsWith('•'));
        expect(l10n.aboutFeaturePrompts, startsWith('•'));
      });

      test('about strings have reasonable length', () {
        expect(l10n.aboutDescription.length, greaterThan(100));
        expect(l10n.aboutIntro.length, greaterThan(100));
        expect(l10n.aboutUsageList.length, greaterThan(100));
      });
    });

    group('Parameterized strings - Authentication', () {
      test('signedInAs returns formatted string', () {
        expect(
          l10n.signedInAs('test@example.com'),
          'Signed in as test@example.com',
        );
        expect(l10n.signedInAs('user@test.co'), contains('user@test.co'));
      });

      test('signedInAs handles special characters in email', () {
        expect(
          l10n.signedInAs('test+user@example.com'),
          contains('test+user@example.com'),
        );
      });
    });

    group('Parameterized strings - Chapter and Novel', () {
      test('continueAtChapter formats correctly', () {
        final result = l10n.continueAtChapter('Test Chapter');
        expect(result, contains('Test Chapter'));
        expect(result, contains('•'));
      });

      test('chapterLabel formats index correctly', () {
        expect(l10n.chapterLabel(1), 'Chapter 1');
        expect(l10n.chapterLabel(100), 'Chapter 100');
      });

      test('chapterWithTitle formats correctly', () {
        final result = l10n.chapterWithTitle(5, 'Test Title');
        expect(result, contains('5'));
        expect(result, contains('Test Title'));
      });

      test('chaptersCount formats correctly', () {
        expect(l10n.chaptersCount(10), contains('10'));
        expect(l10n.chaptersCount(1), contains('1'));
      });

      test('avgWordsPerChapter formats correctly', () {
        expect(l10n.avgWordsPerChapter(2500), contains('2500'));
      });
    });

    group('Parameterized strings - Index and Range', () {
      test('indexLabel formats correctly', () {
        expect(l10n.indexLabel(5), 'Index 5');
        expect(l10n.indexLabel(0), 'Index 0');
      });

      test('indexOutOfRange formats min and max correctly', () {
        final result = l10n.indexOutOfRange(1, 100);
        expect(result, contains('1'));
        expect(result, contains('100'));
      });
    });

    group('Parameterized strings - Progress and Stats', () {
      test('novelsAndProgressSummary formats correctly', () {
        final result = l10n.novelsAndProgressSummary(5, '75%');
        expect(result, contains('5'));
        expect(result, contains('75%'));
      });

      test('totalRecords formats correctly', () {
        expect(l10n.totalRecords(42), contains('42'));
      });
    });

    group('Parameterized strings - Error and Status', () {
      test('removedNovel formats correctly', () {
        expect(l10n.removedNovel('Test Novel'), 'Removed Test Novel');
      });

      test('ttsError formats correctly', () {
        expect(l10n.ttsError('Test error'), 'TTS error: Test error');
      });

      test('confirmDeleteDescription formats title correctly', () {
        final result = l10n.confirmDeleteDescription('My Novel');
        expect(result, contains('My Novel'));
        expect(result, contains("'"));
      });
    });

    group('Parameterized strings - PDF and Export', () {
      test('byAuthor formats correctly', () {
        expect(l10n.byAuthor('Jane Doe'), 'by Jane Doe');
      });

      test('pageOfTotal formats correctly', () {
        final result = l10n.pageOfTotal(5, 100);
        expect(result, contains('5'));
        expect(result, contains('100'));
      });

      test('languageLabel formats correctly', () {
        expect(l10n.languageLabel('en'), contains('en'));
      });
    });

    group('Authentication strings', () {
      test('auth strings are non-empty', () {
        expect(l10n.email, 'Email');
        expect(l10n.password, 'Password');
        expect(l10n.signIn, 'Sign In');
        expect(l10n.signOut, 'Sign Out');
        expect(l10n.signedOut, 'Signed Out');
        expect(l10n.guest, 'Guest');
        expect(l10n.notSignedIn, 'Not signed in');
      });

      test('provider strings are non-empty', () {
        expect(l10n.signInWithGoogle, isNotEmpty);
        expect(l10n.signInWithApple, isNotEmpty);
        expect(l10n.signInWithBiometrics, isNotEmpty);
      });
    });

    group('Settings strings', () {
      test('app settings strings are non-empty', () {
        expect(l10n.appSettings, 'App Settings');
        expect(l10n.appLanguage, 'App Language');
        expect(l10n.english, 'English');
        expect(l10n.chinese, 'Chinese');
      });

      test('theme strings are correct', () {
        expect(l10n.themeMode, 'Theme Mode');
        expect(l10n.system, 'System');
        expect(l10n.light, 'Light');
        expect(l10n.dark, 'Dark');
      });
    });

    group('TTS strings', () {
      test('TTS settings are non-empty', () {
        expect(l10n.ttsSettings, 'TTS Settings');
        expect(l10n.enableTTS, 'Enable TTS');
        expect(l10n.speechRate, 'Speech Rate');
        expect(l10n.volume, 'Volume');
        expect(l10n.pitch, 'Pitch');
      });

      test('TTS voice strings are non-empty', () {
        expect(l10n.defaultTTSVoice, 'Default TTS Voice');
        expect(l10n.ttsVoice, 'TTS Voice');
        expect(l10n.ttsLanguage, 'TTS Language');
        expect(l10n.testVoice, 'Test Voice');
        expect(l10n.reloadVoices, 'Reload Voices');
      });

      test('TTS state strings are non-empty', () {
        expect(l10n.loadingVoices, 'Loading voices...');
        expect(l10n.loadingLanguages, 'Loading languages...');
        expect(l10n.stopTTS, 'Stop TTS');
        expect(l10n.speak, 'Speak');
      });
    });

    group('Biometric strings', () {
      test('biometric strings are non-empty', () {
        expect(l10n.enableBiometricLogin, isNotEmpty);
        expect(l10n.enableBiometricLoginDescription, isNotEmpty);
        expect(l10n.biometricAuthFailed, isNotEmpty);
        expect(l10n.saveCredentialsForBiometric, isNotEmpty);
        expect(l10n.biometricTokensExpired, isNotEmpty);
        expect(l10n.biometricNoTokens, isNotEmpty);
        expect(l10n.biometricTokenError, isNotEmpty);
        expect(l10n.biometricTechnicalError, isNotEmpty);
      });
    });

    group('Common action strings', () {
      test('common actions are correct', () {
        expect(l10n.save, 'Save');
        expect(l10n.cancel, 'Cancel');
        expect(l10n.delete, 'Delete');
        expect(l10n.edit, 'Edit');
        expect(l10n.close, 'Close');
        expect(l10n.copy, 'Copy');
        expect(l10n.undo, 'Undo');
        expect(l10n.remove, 'Remove');
        expect(l10n.refresh, 'Refresh');
        expect(l10n.select, 'Select');
        expect(l10n.clear, 'Clear');
        expect(l10n.create, 'Create');
      });
    });

    group('Loading and progress strings', () {
      test('loading strings contain ellipsis', () {
        expect(l10n.loadingProgress, contains('...'));
        expect(l10n.loadingNovels, contains('…'));
        expect(l10n.loadingChapter, contains('…'));
        expect(l10n.loadingVoices, 'Loading voices...');
        expect(l10n.loadingLanguages, 'Loading languages...');
      });

      test('progress state strings', () {
        expect(l10n.progressSaved, isNotEmpty);
        expect(l10n.errorSavingProgress, isNotEmpty);
        expect(l10n.currentProgress, isNotEmpty);
        expect(l10n.recentlyRead, isNotEmpty);
      });
    });

    group('Validation strings', () {
      test('validation messages are non-empty', () {
        expect(l10n.invalidUrl, isNotEmpty);
        expect(l10n.urlTooLong, isNotEmpty);
        expect(l10n.urlContainsSpaces, isNotEmpty);
        expect(l10n.urlInvalidScheme, isNotEmpty);
        expect(l10n.invalidCoverUrl, isNotEmpty);
        expect(l10n.required, 'Required');
      });
    });

    group('Error strings', () {
      test('error strings are non-empty', () {
        expect(l10n.error, 'Error');
        expect(l10n.errorLoadingProgress, isNotEmpty);
        expect(l10n.errorLoadingNovels, isNotEmpty);
        expect(l10n.errorLoadingChapters, isNotEmpty);
        expect(l10n.errorLoadingUsage, isNotEmpty);
        expect(l10n.ttsError('test'), contains('TTS error'));
      });
    });

    group('Novel and chapter strings', () {
      test('novel strings are non-empty', () {
        expect(l10n.novel, 'Novel');
        expect(l10n.novels, 'Novels');
        expect(l10n.chapter, 'Chapter');
        expect(l10n.chapters, 'Chapters');
        expect(l10n.myNovels, 'My Novels');
        expect(l10n.createNovel, 'Create Novel');
        expect(l10n.deleteNovel, 'Delete Novel');
      });

      test('chapter state strings', () {
        expect(l10n.notStarted, 'Not started');
        expect(l10n.noChaptersFound, 'No chapters found.');
        expect(l10n.noNovelsFound, 'No novels found.');
        expect(l10n.unknownNovel, 'Unknown Novel');
        expect(l10n.unknownChapter, 'Unknown chapter');
      });
    });

    group('AI strings', () {
      test('AI service strings are non-empty', () {
        expect(l10n.aiServiceUrl, isNotEmpty);
        expect(l10n.aiServiceUrlDescription, isNotEmpty);
        expect(l10n.aiAssistant, isNotEmpty);
        expect(l10n.aiChatHint, isNotEmpty);
        expect(l10n.aiChatEmpty, isNotEmpty);
        expect(l10n.aiThinking, isNotEmpty);
      });

      test('AI status strings', () {
        expect(l10n.supabaseIntegrationInitialized, isNotEmpty);
        expect(l10n.configureEnvironment, isNotEmpty);
        expect(l10n.modeSupabase, isNotEmpty);
        expect(l10n.modeMockData, isNotEmpty);
      });
    });

    group('Editor strings', () {
      test('editor strings are non-empty', () {
        expect(l10n.chapterContent, 'Chapter Content');
        expect(l10n.chapterTitle, 'Chapter Title');
        expect(l10n.edit, 'Edit');
        expect(l10n.exitEdit, 'Exit Edit');
        expect(l10n.enterEditMode, isNotEmpty);
        expect(l10n.exitEditMode, isNotEmpty);
        expect(l10n.createNextChapter, isNotEmpty);
      });

      test('editor prompts', () {
        expect(l10n.enterChapterTitle, isNotEmpty);
        expect(l10n.enterChapterContent, isNotEmpty);
        expect(l10n.discardChangesTitle, isNotEmpty);
        expect(l10n.discardChangesMessage, isNotEmpty);
        expect(l10n.keepEditing, isNotEmpty);
        expect(l10n.discardChanges, isNotEmpty);
        expect(l10n.saveAndExit, isNotEmpty);
      });
    });

    group('Accessibility strings', () {
      test('accessibility strings are non-empty', () {
        expect(l10n.reduceMotion, isNotEmpty);
        expect(l10n.reduceMotionDescription, isNotEmpty);
        expect(l10n.gesturesEnabled, isNotEmpty);
        expect(l10n.gesturesEnabledDescription, isNotEmpty);
        expect(l10n.readerSwipeSensitivity, isNotEmpty);
        expect(l10n.readerSwipeSensitivityDescription, isNotEmpty);
      });
    });

    group('Filter strings', () {
      test('filter strings are correct', () {
        expect(l10n.allFilter, 'All');
        expect(l10n.readingFilter, 'Reading');
        expect(l10n.completedFilter, 'Completed');
        expect(l10n.downloadedFilter, 'Downloaded');
      });

      test('view mode strings', () {
        expect(l10n.listView, 'List View');
        expect(l10n.gridView, 'Grid View');
      });
    });

    group('Success messages', () {
      test('success messages are non-empty', () {
        expect(l10n.saved, 'Saved');
        expect(l10n.progressSaved, isNotEmpty);
        expect(l10n.defaultVoiceUpdated, isNotEmpty);
        expect(l10n.defaultLanguageSet, isNotEmpty);
        expect(l10n.contributorAdded, isNotEmpty);
        expect(l10n.copiedToClipboard, isNotEmpty);
        expect(l10n.offlineCacheCleared, isNotEmpty);
      });
    });

    group('PDF strings', () {
      test('PDF strings are non-empty', () {
        expect(l10n.pdf, 'PDF');
        expect(l10n.generatingPdf, contains('…'));
        expect(l10n.pdfFailed, isNotEmpty);
        expect(l10n.tableOfContents, isNotEmpty);
      });
    });

    group('Token usage strings', () {
      test('token usage strings are non-empty', () {
        expect(l10n.tokenUsage, 'Token Usage');
        expect(l10n.totalThisMonth, isNotEmpty);
        expect(l10n.inputTokens, isNotEmpty);
        expect(l10n.outputTokens, isNotEmpty);
        expect(l10n.requests, isNotEmpty);
      });
    });

    group('Navigation strings', () {
      test('chapter navigation strings', () {
        expect(l10n.reachedFirstChapter, isNotEmpty);
        expect(l10n.reachedLastChapter, isNotEmpty);
        expect(l10n.previousChapter, isNotEmpty);
        expect(l10n.nextChapter, isNotEmpty);
      });

      test('beta strings', () {
        expect(l10n.betaEvaluate, isNotEmpty);
        expect(l10n.betaEvaluating, isNotEmpty);
        expect(l10n.betaEvaluationReady, isNotEmpty);
        expect(l10n.betaEvaluationFailed, isNotEmpty);
      });
    });

    group('Coverage - Additional getters', () {
      test('exercises all remaining getters for coverage', () {
        expect(l10n.continueLabel, isNotEmpty);
        expect(l10n.reload, isNotEmpty);
        expect(l10n.signInToSync, isNotEmpty);
        expect(l10n.noSupabase, isNotEmpty);
        expect(l10n.noProgress, isNotEmpty);
        expect(l10n.titleLabel, isNotEmpty);
        expect(l10n.authorLabel, isNotEmpty);
        expect(l10n.scrollOffset, isNotEmpty);
        expect(l10n.ttsIndex, isNotEmpty);
        expect(l10n.defaultVoiceUpdated, isNotEmpty);
        expect(l10n.defaultLanguageSet, isNotEmpty);
        expect(l10n.searchByTitle, isNotEmpty);
        expect(l10n.chooseLanguage, isNotEmpty);
        expect(l10n.supabaseSettings, isNotEmpty);
        expect(l10n.supabaseNotEnabled, isNotEmpty);
        expect(l10n.authDisabledInBuild, isNotEmpty);
        expect(l10n.fetchFromSupabase, isNotEmpty);
        expect(l10n.confirmFetch, isNotEmpty);
        expect(l10n.fetch, isNotEmpty);
        expect(l10n.downloadChapters, isNotEmpty);
        expect(l10n.speak, isNotEmpty);
        expect(l10n.autoplayBlocked, isNotEmpty);
        expect(l10n.colorTheme, isNotEmpty);
        expect(l10n.themeDefault, isNotEmpty);
        expect(l10n.themeHighContrast, isNotEmpty);
        expect(l10n.themeNord, isNotEmpty);
        expect(l10n.separateDarkPalette, isNotEmpty);
        expect(l10n.lightPalette, isNotEmpty);
        expect(l10n.darkPalette, isNotEmpty);
        expect(l10n.typographyPreset, isNotEmpty);
        expect(l10n.typographyComfortable, isNotEmpty);
        expect(l10n.typographyCompact, isNotEmpty);
        expect(l10n.typographySerifLike, isNotEmpty);
        expect(l10n.fontPack, isNotEmpty);
        expect(l10n.separateTypographyPresets, isNotEmpty);
        expect(l10n.typographyLight, isNotEmpty);
        expect(l10n.typographyDark, isNotEmpty);
        expect(l10n.readerBundles, isNotEmpty);
        expect(l10n.removedNovel('test'), isNotEmpty);
        expect(l10n.discover, isNotEmpty);
        expect(l10n.profile, isNotEmpty);
        expect(l10n.userManagement, isNotEmpty);
        expect(l10n.viewHistory, isNotEmpty);
        expect(l10n.noUsageThisMonth, isNotEmpty);
        expect(l10n.startUsingAiFeatures, isNotEmpty);
        expect(l10n.total, isNotEmpty);
        expect(l10n.noUsageHistory, isNotEmpty);
        expect(l10n.bundleNordCalm, isNotEmpty);
        expect(l10n.bundleSolarizedFocus, isNotEmpty);
        expect(l10n.bundleHighContrastReadability, isNotEmpty);
        expect(l10n.customFontFamily, isNotEmpty);
        expect(l10n.commonFonts, isNotEmpty);
        expect(l10n.readerFontSize, isNotEmpty);
        expect(l10n.textScale, isNotEmpty);
        expect(l10n.readerBackgroundDepth, isNotEmpty);
        expect(l10n.depthLow, isNotEmpty);
        expect(l10n.depthMedium, isNotEmpty);
        expect(l10n.depthHigh, isNotEmpty);
        expect(l10n.adminMode, isNotEmpty);
        expect(l10n.removedFromLibrary, isNotEmpty);
        expect(l10n.confirmDelete, isNotEmpty);
        expect(l10n.performanceSettings, isNotEmpty);
        expect(l10n.prefetchNextChapter, isNotEmpty);
        expect(l10n.prefetchNextChapterDescription, isNotEmpty);
        expect(l10n.clearOfflineCache, isNotEmpty);
        expect(l10n.saveAndExit, isNotEmpty);
        expect(l10n.descriptionLabel, isNotEmpty);
        expect(l10n.coverUrlLabel, isNotEmpty);
        expect(l10n.invalidCoverUrl, isNotEmpty);
        expect(l10n.send, isNotEmpty);
        expect(l10n.resetToDefault, isNotEmpty);
        expect(l10n.saved, isNotEmpty);
        expect(l10n.summariesLabel, isNotEmpty);
        expect(l10n.synopsesLabel, isNotEmpty);
        expect(l10n.locationLabel, isNotEmpty);
        expect(l10n.publicLabel, isNotEmpty);
        expect(l10n.privateLabel, isNotEmpty);
        expect(l10n.refreshTooltip, isNotEmpty);
        expect(l10n.untitled, isNotEmpty);
        expect(l10n.newLabel, isNotEmpty);
        expect(l10n.deleteSceneTitle, isNotEmpty);
        expect(l10n.deleteCharacterTitle, isNotEmpty);
        expect(l10n.deleteTemplateTitle, isNotEmpty);
        expect(l10n.confirmDeleteGeneric, isNotEmpty);
        expect(l10n.novelMetadata, isNotEmpty);
        expect(l10n.contributorEmailLabel, isNotEmpty);
        expect(l10n.contributorEmailHint, isNotEmpty);
        expect(l10n.addContributor, isNotEmpty);
        expect(l10n.indexUnchanged, isNotEmpty);
        expect(l10n.roundingBefore, isNotEmpty);
        expect(l10n.roundingAfter, isNotEmpty);
        expect(l10n.supabaseProgressNotSaved, isNotEmpty);
        expect(l10n.autoplayBlockedInline, isNotEmpty);
        expect(l10n.enterFloatIndexHint, isNotEmpty);
        expect(l10n.sentenceSummary, isNotEmpty);
        expect(l10n.paragraphSummary, isNotEmpty);
        expect(l10n.pageSummary, isNotEmpty);
        expect(l10n.expandedSummary, isNotEmpty);
        expect(l10n.format, isNotEmpty);
        expect(l10n.aiChatHint, isNotEmpty);
        expect(l10n.aiChatEmpty, isNotEmpty);
        expect(l10n.aiThinking, isNotEmpty);
      });
    });

    group('Parameterized strings - Additional coverage', () {
      test('showingCachedPublicData formats correctly', () {
        const msg = 'Network error';
        final result = l10n.showingCachedPublicData(msg);
        expect(result, contains('Network error'));
        expect(result, contains('showing cached/public data'));
      });

      test('novelMetadata is correct', () {
        expect(l10n.novelMetadata, 'Novel Metadata');
      });

      test('deleteNovelConfirmation is correct', () {
        expect(l10n.deleteNovelConfirmation, isNotEmpty);
      });
    });
  });
}
