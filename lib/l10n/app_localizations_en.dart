// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newChapter => 'New Chapter';

  @override
  String get back => 'Back';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get settings => 'Settings';

  @override
  String get appTitle => 'Writer';

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'Read and manage novels, with cloud-backed storage, offline support, and Text-To-Speech playback. Use the Library to browse, search, and open chapters; sign in to sync progress; adjust settings for theme, typography, and motion.';

  @override
  String get aboutIntro =>
      'AuthorConsole helps you plan, write, and read novels across devices. It focuses on simplicity for readers and power for authors, offering a unified place to manage chapters, summaries, characters, and scenes.';

  @override
  String get aboutSecurity =>
      'With cloud-backed storage and strict access controls, your data remains protected. Authenticated users can sync progress, metadata, and templates while maintaining privacy.';

  @override
  String get aboutCoach =>
      'The built‑in AI Coach uses the Snowflake method to improve your story summary. It asks focused questions, offers suggestions, and when ready, provides a refined summary that the app applies to your document.';

  @override
  String get aboutFeatureCreate =>
      '• Create a new novel and organize chapters.';

  @override
  String get aboutFeatureTemplates =>
      '• Use character and scene templates to bootstrap ideas.';

  @override
  String get aboutFeatureTracking =>
      '• Track reading progress and resume across devices.';

  @override
  String get aboutFeatureCoach =>
      '• Refine your summary with the AI Coach and apply improvements.';

  @override
  String get aboutFeaturePrompts =>
      '• Manage prompts and experiment with AI-assisted workflows.';

  @override
  String get aboutUsage => 'Usage';

  @override
  String get aboutUsageList =>
      '• Library: search and open novels\n• Reader: navigate chapters, toggle TTS\n• Templates: manage character and scene templates\n• Settings: theme, typography, and preferences\n• Sign In: enable cloud sync';

  @override
  String get version => 'Version';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get supabaseIntegrationInitialized => 'Cloud sync initialized';

  @override
  String get configureEnvironment =>
      'Please configure your environment variables to enable cloud sync';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get guest => 'Guest';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get signIn => 'Sign In';

  @override
  String get continueLabel => 'Continue';

  @override
  String get reload => 'Reload';

  @override
  String get signInToSync => 'Sign in to sync progress across devices.';

  @override
  String get currentProgress => 'Current Progress';

  @override
  String get loadingProgress => 'Loading progress...';

  @override
  String get recentlyRead => 'Recently Read';

  @override
  String get noSupabase => 'Cloud sync is not enabled in this build.';

  @override
  String get errorLoadingProgress => 'Error loading progress';

  @override
  String get noProgress => 'No progress found';

  @override
  String get errorLoadingNovels => 'Error loading novels';

  @override
  String get loadingNovels => 'Loading novels…';

  @override
  String get titleLabel => 'Title';

  @override
  String get authorLabel => 'Author';

  @override
  String get noNovelsFound => 'No novels found.';

  @override
  String get myNovels => 'My Novels';

  @override
  String get createNovel => 'Create Novel';

  @override
  String get create => 'Create';

  @override
  String get errorLoadingChapters => 'Error loading chapters';

  @override
  String get loadingChapter => 'Loading chapter…';

  @override
  String get notStarted => 'Not started';

  @override
  String get unknownNovel => 'Unknown Novel';

  @override
  String get unknownChapter => 'Unknown chapter';

  @override
  String get chapter => 'Chapter';

  @override
  String get novel => 'Novel';

  @override
  String get chapterTitle => 'Chapter Title';

  @override
  String get scrollOffset => 'Scroll Offset';

  @override
  String get ttsIndex => 'TTS Index';

  @override
  String get speechRate => 'Speech Rate';

  @override
  String get volume => 'Volume';

  @override
  String get defaultTTSVoice => 'Default TTS Voice';

  @override
  String get defaultVoiceUpdated => 'Default voice updated';

  @override
  String get defaultLanguageSet => 'Default language set';

  @override
  String get searchByTitle => 'Search by title…';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get testVoice => 'Test Voice';

  @override
  String get reloadVoices => 'Reload Voices';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signedOut => 'Signed Out';

  @override
  String get appSettings => 'App Settings';

  @override
  String get supabaseSettings => 'Cloud Sync Settings';

  @override
  String get supabaseNotEnabled => 'Cloud sync not enabled';

  @override
  String get supabaseNotEnabledDescription =>
      'Cloud sync is not configured for this build.';

  @override
  String get authDisabledInBuild =>
      'Cloud sync is not configured. Authentication is disabled in this build.';

  @override
  String get fetchFromSupabase => 'Fetch from cloud';

  @override
  String get fetchFromSupabaseDescription =>
      'Fetch latest novels and progress from the cloud.';

  @override
  String get confirmFetch => 'Confirm Fetch';

  @override
  String get confirmFetchDescription =>
      'This will overwrite your local data. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get fetch => 'Fetch';

  @override
  String get downloadChapters => 'Download chapters';

  @override
  String get modeSupabase => 'Mode: Cloud sync';

  @override
  String get modeMockData => 'Mode: Mock data';

  @override
  String continueAtChapter(String title) {
    return 'Continue at chapter • $title';
  }

  @override
  String get error => 'Error';

  @override
  String get ttsSettings => 'TTS Settings';

  @override
  String get enableTTS => 'Enable TTS';

  @override
  String get sentenceSummary => 'Sentence Summary';

  @override
  String get paragraphSummary => 'Paragraph Summary';

  @override
  String get pageSummary => 'Page Summary';

  @override
  String get expandedSummary => 'Expanded Summary';

  @override
  String get pitch => 'Pitch';

  @override
  String get signInWithBiometrics => 'Sign in with biometrics';

  @override
  String get enableBiometricLogin => 'Enable Biometric Login';

  @override
  String get enableBiometricLoginDescription =>
      'Use fingerprint or face recognition to sign in.';

  @override
  String get biometricAuthFailed => 'Biometric authentication failed';

  @override
  String get ttsVoice => 'TTS Voice';

  @override
  String get loadingVoices => 'Loading voices...';

  @override
  String get selectVoice => 'Select a voice';

  @override
  String get ttsLanguage => 'TTS Language';

  @override
  String get loadingLanguages => 'Loading languages...';

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get ttsSpeechRate => 'Speech Rate';

  @override
  String get ttsSpeechVolume => 'Speech Volume';

  @override
  String get ttsSpeechPitch => 'Speech Pitch';

  @override
  String get novelsAndProgress => 'Novels and Progress';

  @override
  String get novels => 'Novels';

  @override
  String get progress => 'Progress';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return 'Novels: $count, Progress: $progress';
  }

  @override
  String get chapters => 'Chapters';

  @override
  String get noChaptersFound => 'No chapters found.';

  @override
  String indexLabel(int index) {
    return 'Index $index';
  }

  @override
  String get enterFloatIndexHint => 'Enter decimal index to reposition';

  @override
  String indexOutOfRange(int min, int max) {
    return 'Index must be between $min and $max';
  }

  @override
  String get indexUnchanged => 'Index unchanged';

  @override
  String get roundingBefore => 'Always before';

  @override
  String get roundingAfter => 'Always after';

  @override
  String get stopTTS => 'Stop TTS';

  @override
  String get speak => 'Speak';

  @override
  String get supabaseProgressNotSaved =>
      'Cloud sync not configured; progress not saved';

  @override
  String get progressSaved => 'Progress saved';

  @override
  String get errorSavingProgress => 'Error saving progress';

  @override
  String get autoplayBlocked => 'Auto-play blocked. Tap Continue to start.';

  @override
  String get autoplayBlockedInline =>
      'Auto-play is blocked by the browser. Tap Continue to start reading.';

  @override
  String get reachedLastChapter => 'Reached last chapter';

  @override
  String ttsError(String msg) {
    return 'TTS error: $msg';
  }

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeHighContrast => 'High Contrast';

  @override
  String get themeDefault => 'Default';

  @override
  String get themeSolarized => 'Solarized';

  @override
  String get themeSolarizedTan => 'Solarized Tan';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Frost';

  @override
  String get themeNordSnowstorm => 'Nord Snowstorm';

  @override
  String get separateDarkPalette => 'Use separate dark palette';

  @override
  String get lightPalette => 'Light Palette';

  @override
  String get darkPalette => 'Dark Palette';

  @override
  String get typographyPreset => 'Typography Preset';

  @override
  String get typographyComfortable => 'Comfortable';

  @override
  String get typographyCompact => 'Compact';

  @override
  String get typographySerifLike => 'Serif-like';

  @override
  String get fontPack => 'Font Pack';

  @override
  String get separateTypographyPresets =>
      'Use separate typography for light/dark';

  @override
  String get typographyLight => 'Light Typography';

  @override
  String get typographyDark => 'Dark Typography';

  @override
  String get readerBundles => 'Reader Theme Bundles';

  @override
  String get tokenUsage => 'Token Usage';

  @override
  String removedNovel(String title) {
    return 'Removed $title';
  }

  @override
  String get discover => 'Discover';

  @override
  String get profile => 'Profile';

  @override
  String get libraryTitle => 'Library';

  @override
  String get undo => 'Undo';

  @override
  String get allFilter => 'All';

  @override
  String get readingFilter => 'Reading';

  @override
  String get completedFilter => 'Completed';

  @override
  String get downloadedFilter => 'Downloaded';

  @override
  String get searchNovels => 'Search novels...';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get userManagement => 'User Management';

  @override
  String get totalThisMonth => 'Total This Month';

  @override
  String get inputTokens => 'Input Tokens';

  @override
  String get outputTokens => 'Output Tokens';

  @override
  String get requests => 'Requests';

  @override
  String get viewHistory => 'View history';

  @override
  String get noUsageThisMonth => 'No usage this month';

  @override
  String get startUsingAiFeatures =>
      'Start using AI features to see your token consumption';

  @override
  String get errorLoadingUsage => 'Error loading usage';

  @override
  String get refresh => 'Refresh';

  @override
  String totalRecords(int count) {
    return 'Total Records: $count';
  }

  @override
  String get total => 'Total';

  @override
  String get noUsageHistory => 'No Usage History';

  @override
  String get bundleNordCalm => 'Nord Calm';

  @override
  String get bundleSolarizedFocus => 'Solarized Focus';

  @override
  String get bundleHighContrastReadability => 'High Contrast Readability';

  @override
  String get customFontFamily => 'Custom Font Family';

  @override
  String get commonFonts => 'Common Fonts';

  @override
  String get readerFontSize => 'Reader Font Size';

  @override
  String get textScale => 'Text Scale';

  @override
  String get readerBackgroundDepth => 'Reader Background Depth';

  @override
  String get depthLow => 'Low';

  @override
  String get depthMedium => 'Medium';

  @override
  String get depthHigh => 'High';

  @override
  String get select => 'Select';

  @override
  String get clear => 'Clear';

  @override
  String get adminMode => 'Admin Mode';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionDescription =>
      'Minimize animations for motion comfort';

  @override
  String get gesturesEnabled => 'Enable touch gestures';

  @override
  String get gesturesEnabledDescription =>
      'Enable swipe and tap gestures in the reader';

  @override
  String get readerSwipeSensitivity => 'Reader swipe sensitivity';

  @override
  String get readerSwipeSensitivityDescription =>
      'Adjust minimum swipe velocity for chapter navigation';

  @override
  String get remove => 'Remove';

  @override
  String get removedFromLibrary => 'Removed from Library';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteDescription(String title) {
    return 'This will delete \'$title\' from your cloud library. Are you sure?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get reachedFirstChapter => 'Reached first chapter';

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get betaEvaluate => 'Beta';

  @override
  String get betaEvaluating => 'Sending for beta evaluation…';

  @override
  String get betaEvaluationReady => 'Beta evaluation ready';

  @override
  String get betaEvaluationFailed => 'Beta evaluation failed';

  @override
  String get performanceSettings => 'Performance Settings';

  @override
  String get prefetchNextChapter => 'Prefetch next chapter';

  @override
  String get prefetchNextChapterDescription =>
      'Preload the next chapter to reduce waiting.';

  @override
  String get clearOfflineCache => 'Clear offline cache';

  @override
  String get offlineCacheCleared => 'Offline cache cleared';

  @override
  String get edit => 'Edit';

  @override
  String get exitEdit => 'Exit Edit';

  @override
  String get enterEditMode => 'Enter Edit Mode';

  @override
  String get exitEditMode => 'Exit Edit Mode';

  @override
  String get chapterContent => 'Chapter Content';

  @override
  String get save => 'Save';

  @override
  String get createNextChapter => 'Create Next Chapter';

  @override
  String get enterChapterTitle => 'Enter chapter title';

  @override
  String get enterChapterContent => 'Enter chapter content';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get coverUrlLabel => 'Cover URL';

  @override
  String get invalidCoverUrl => 'Enter a valid http(s) URL without spaces.';

  @override
  String get navigation => 'Navigation';

  @override
  String get home => 'Home';

  @override
  String get chapterIndex => 'Chapter Index';

  @override
  String get summary => 'Summary';

  @override
  String get characters => 'Characters';

  @override
  String get scenes => 'Scenes';

  @override
  String get characterTemplates => 'Character Templates';

  @override
  String get sceneTemplates => 'Scene Templates';

  @override
  String get updateNovel => 'Update Novel';

  @override
  String get deleteNovel => 'Delete Novel';

  @override
  String get deleteNovelConfirmation =>
      'This will permanently delete the novel. Continue?';

  @override
  String get format => 'Format';

  @override
  String get aiServiceUrl => 'AI Service URL';

  @override
  String get aiServiceUrlDescription => 'Backend service URL for AI features';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiChatHint => 'Type your message...';

  @override
  String get aiChatEmpty => 'Ask me anything about this chapter or novel';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get send => 'Send';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get invalidUrl => 'Enter a valid http(s) URL without spaces.';

  @override
  String get urlTooLong => 'URL must be 2048 characters or less.';

  @override
  String get urlContainsSpaces => 'URL cannot contain spaces.';

  @override
  String get urlInvalidScheme => 'URL must start with http:// or https://.';

  @override
  String get embeddingUpdated => 'Embedding updated';

  @override
  String get embeddingFailed => 'Embedding failed';

  @override
  String get saved => 'Saved';

  @override
  String get required => 'Required';

  @override
  String get summariesLabel => 'Summaries';

  @override
  String get synopsesLabel => 'Synopses';

  @override
  String get locationLabel => 'Location';

  @override
  String languageLabel(String code) {
    return 'Language: $code';
  }

  @override
  String get publicLabel => 'Public';

  @override
  String get privateLabel => 'Private';

  @override
  String chaptersCount(int count) {
    return 'Chapters: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return 'Avg words/chapter: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return 'Chapter $idx';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return 'Chapter $idx: $title';
  }

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get untitled => 'Untitled';

  @override
  String get newLabel => 'New';

  @override
  String get deleteSceneTitle => 'Delete Scene';

  @override
  String get deleteCharacterTitle => 'Delete Character';

  @override
  String get deleteTemplateTitle => 'Delete Template';

  @override
  String get confirmDeleteGeneric =>
      'Are you sure you want to delete this item?';

  @override
  String get novelMetadata => 'Novel Metadata';

  @override
  String get contributorEmailLabel => 'Contributor Email';

  @override
  String get contributorEmailHint => 'Enter user email to add as contributor';

  @override
  String get addContributor => 'Add Contributor';

  @override
  String get contributorAdded => 'Contributor added';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'Generating PDF…';

  @override
  String get pdfFailed => 'Failed to generate PDF';

  @override
  String get tableOfContents => 'Table of Contents';

  @override
  String byAuthor(String name) {
    return 'by $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — showing cached/public data';
  }

  @override
  String get menu => 'Menu';

  @override
  String get metaLabel => 'Meta';

  @override
  String get aiServiceUnavailable => 'AI Service Unavailable';

  @override
  String get aiConfigurations => 'AI Configurations';

  @override
  String get modelLabel => 'Model';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get saveMyVersion => 'Save My Version';

  @override
  String get resetToPublic => 'Reset to public';

  @override
  String get resetFailed => 'Reset failed';

  @override
  String get prompts => 'Prompts';

  @override
  String get patterns => 'Patterns';

  @override
  String get storyLines => 'Story Lines';

  @override
  String get tools => 'Tools';

  @override
  String get preview => 'Preview';

  @override
  String get actions => 'Actions';

  @override
  String get searchLabel => 'Search';

  @override
  String get allLabel => 'All';

  @override
  String get filterByLocked => 'Filter by Locked';

  @override
  String get lockedOnly => 'Locked Only';

  @override
  String get unlockedOnly => 'Unlocked Only';

  @override
  String get promptKey => 'Prompt Key';

  @override
  String get language => 'Language';

  @override
  String get filterByKey => 'Filter by key';

  @override
  String get viewPublic => 'View public';

  @override
  String get groupNone => 'None';

  @override
  String get groupLanguage => 'Language';

  @override
  String get groupKey => 'Key';

  @override
  String get newPrompt => 'New Prompt';

  @override
  String get newPattern => 'New Pattern';

  @override
  String get newStoryLine => 'New Story Line';

  @override
  String get editPrompt => 'Edit Prompt';

  @override
  String get editPattern => 'Edit Pattern';

  @override
  String get editStoryLine => 'Edit Story Line';

  @override
  String deletedWithTitle(String title) {
    return 'Deleted: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return 'Delete failed: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return 'Delete error: $error';
  }

  @override
  String get makePublic => 'Make Public';

  @override
  String get noPrompts => 'No prompts found';

  @override
  String get noPatterns => 'No patterns';

  @override
  String get noStoryLines => 'No story lines';

  @override
  String conversionFailed(String error) {
    return 'Conversion failed: $error';
  }

  @override
  String get failedToAnalyze => 'Failed to analyze';

  @override
  String get aiCoachAnalyzing => 'AI Coach is analyzing...';

  @override
  String get retry => 'Retry';

  @override
  String get startAiCoaching => 'Start AI Coaching';

  @override
  String get refinementComplete => 'Refinement Complete!';

  @override
  String get coachQuestion => 'Coach\'s Question';

  @override
  String get summaryLooksGood => 'Great job! Your summary looks solid.';

  @override
  String get howToImprove => 'How can we improve this?';

  @override
  String get suggestionsLabel => 'Suggestions:';

  @override
  String get reviewSuggestionsHint => 'Review suggestions or type answer...';

  @override
  String get aiGenerationComplete => 'AI generation complete';

  @override
  String get clickRegenerateForNew => 'Click Regenerate for new suggestions';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get imSatisfied => 'I\'m satisfied';

  @override
  String get templateLabel => 'Template';

  @override
  String get exampleCharacterName => 'e.g. Harry Potter';

  @override
  String get aiConvert => 'AI Convert';

  @override
  String get toggleAiCoach => 'Toggle AI Coach';

  @override
  String retrieveFailed(String error) {
    return 'Retrieve failed: $error';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get lastRead => 'Last read';

  @override
  String get noRecentChapters => 'No recent chapters';

  @override
  String get failedToLoadConfig => 'Failed to load config';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return 'Make public \"$promptKey\" ($language)?';
  }

  @override
  String get content => 'Content';

  @override
  String get invalidKey => 'Invalid key';

  @override
  String get invalidLanguage => 'Invalid language';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String charsCount(int count) {
    return 'Characters: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return 'Delete prompt \"$promptKey\" ($language)?';
  }

  @override
  String get profileRetrieved => 'Profile retrieved';

  @override
  String get noProfileFound => 'No profile found';

  @override
  String get templateName => 'Template Name';

  @override
  String get retrieveProfile => 'Retrieve profile';

  @override
  String get previewLabel => 'Preview';

  @override
  String get markdownHint => 'Enter description in Markdown...';

  @override
  String get templateNameExists => 'Template name already exists';

  @override
  String get aiServiceUrlHint => 'Enter AI service URL (http/https)';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'System Font';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'Edit Pattern';

  @override
  String get newPatternTitle => 'New Pattern';

  @override
  String get editStoryLineTitle => 'Edit Story Line';

  @override
  String get newStoryLineTitle => 'New Story Line';

  @override
  String get usageRulesLabel => 'Usage Rules (JSON)';

  @override
  String get publicPatternLabel => 'Public pattern';

  @override
  String get publicStoryLineLabel => 'Public story line';

  @override
  String get lockedLabel => 'Locked';

  @override
  String get unlockedLabel => 'Unlocked';

  @override
  String get aiButton => 'AI';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get lockPattern => 'Lock pattern';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorForbidden => 'Forbidden';

  @override
  String get errorSessionExpired => 'Session expired';

  @override
  String get errorValidation => 'Validation error';

  @override
  String get errorInvalidInput => 'Invalid input';

  @override
  String get errorDuplicateTitle => 'Duplicate title';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorServiceUnavailable => 'Service unavailable';

  @override
  String get errorAiNotConfigured => 'AI service not configured';

  @override
  String get errorSupabaseError => 'Cloud service error';

  @override
  String get errorRateLimited => 'Too many requests';

  @override
  String get errorInternal => 'Internal server error';

  @override
  String get errorBadGateway => 'Bad gateway';

  @override
  String get errorGatewayTimeout => 'Gateway timeout';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get invalidResponseFromServer => 'Invalid response from server';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get accountCreatedCheckEmail =>
      'Account created! Please check your email to verify.';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccountSignIn => 'Already have an account? Sign In';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get ifAccountExistsResetLinkSent =>
      'If an account exists, a reset link has been sent to your email.';

  @override
  String get enterEmailForResetLink =>
      'Enter your email address to receive a password reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get sessionInvalidLoginAgain =>
      'Session invalid. Please login or use the reset link again.';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully!';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get noActiveSessionFound =>
      'No active session found. Please log in again.';

  @override
  String get authenticationFailedSignInAgain =>
      'Authentication failed. Please sign in again.';

  @override
  String get accessDeniedNoAdminPrivileges =>
      'Access denied. You don\'t have admin privileges.';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'Failed to load users: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn => 'Please sign in to use smart search';

  @override
  String get smartSearch => 'Smart Search';

  @override
  String get failedToPersistTemplate => 'Failed to save template';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'User $id created at $createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel =>
      'Try adjusting your search or create a new novel';

  @override
  String get sessionExpired => 'Session expired';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get goBack => 'Go Back';

  @override
  String get unableToLoadAsset => 'Unable to load asset';

  @override
  String get youDontHavePermission =>
      'You don\'t have permission to perform this action.';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get removeFromLibrary => 'Remove from Library';
}
