// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
      'Read and manage novels, with Supabase-backed storage, offline support, and Text-To-Speech playback. Use the Library to browse, search, and open chapters; sign in to sync progress; adjust settings for theme, typography, and motion.';

  @override
  String get aboutUsage => 'Usage';

  @override
  String get aboutUsageList =>
      '• Library: search and open novels\n• Reader: navigate chapters, toggle TTS\n• Settings: theme, typography, and preferences\n• Sign In: enable cloud sync via Supabase';

  @override
  String get version => 'Version';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get supabaseIntegrationInitialized =>
      'Supabase integration initialized';

  @override
  String get configureEnvironment =>
      'Please configure your environment variables to use Supabase';

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
  String get noSupabase => 'Supabase is not enabled in this build.';

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
  String get supabaseSettings => 'Supabase Settings';

  @override
  String get supabaseNotEnabled => 'Supabase not enabled';

  @override
  String get supabaseNotEnabledDescription =>
      'Supabase is not configured for this build.';

  @override
  String get authDisabledInBuild =>
      'Supabase is not configured. Authentication is disabled in this build.';

  @override
  String get fetchFromSupabase => 'Fetch from Supabase';

  @override
  String get fetchFromSupabaseDescription =>
      'Fetch latest novels and progress from Supabase.';

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
  String get modeSupabase => 'Mode: Supabase';

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
      'Supabase not configured; progress not saved';

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
  String get undo => 'Undo';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteDescription(String title) {
    return 'This will delete \'$title\' from Supabase. Are you sure?';
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
}
