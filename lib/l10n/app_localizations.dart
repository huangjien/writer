import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Novel Reader'**
  String get appTitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Read and manage novels, with Supabase-backed storage, offline support, and Text-To-Speech playback. Use the Library to browse, search, and open chapters; sign in to sync progress; adjust settings for theme, typography, and motion.'**
  String get aboutDescription;

  /// No description provided for @aboutUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get aboutUsage;

  /// No description provided for @aboutUsageList.
  ///
  /// In en, this message translates to:
  /// **'• Library: search and open novels\n• Reader: navigate chapters, toggle TTS\n• Settings: theme, typography, and preferences\n• Sign In: enable cloud sync via Supabase'**
  String get aboutUsageList;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @supabaseIntegrationInitialized.
  ///
  /// In en, this message translates to:
  /// **'Supabase integration initialized'**
  String get supabaseIntegrationInitialized;

  /// No description provided for @configureEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Please configure your environment variables to use Supabase'**
  String get configureEnvironment;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @signInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync progress across devices.'**
  String get signInToSync;

  /// No description provided for @currentProgress.
  ///
  /// In en, this message translates to:
  /// **'Current Progress'**
  String get currentProgress;

  /// No description provided for @loadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading progress...'**
  String get loadingProgress;

  /// No description provided for @recentlyRead.
  ///
  /// In en, this message translates to:
  /// **'Recently Read'**
  String get recentlyRead;

  /// No description provided for @noSupabase.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not enabled in this build.'**
  String get noSupabase;

  /// No description provided for @errorLoadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Error loading progress'**
  String get errorLoadingProgress;

  /// No description provided for @noProgress.
  ///
  /// In en, this message translates to:
  /// **'No progress found'**
  String get noProgress;

  /// No description provided for @errorLoadingNovels.
  ///
  /// In en, this message translates to:
  /// **'Error loading novels'**
  String get errorLoadingNovels;

  /// No description provided for @loadingNovels.
  ///
  /// In en, this message translates to:
  /// **'Loading novels…'**
  String get loadingNovels;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @noNovelsFound.
  ///
  /// In en, this message translates to:
  /// **'No novels found.'**
  String get noNovelsFound;

  /// No description provided for @myNovels.
  ///
  /// In en, this message translates to:
  /// **'My Novels'**
  String get myNovels;

  /// No description provided for @createNovel.
  ///
  /// In en, this message translates to:
  /// **'Create Novel'**
  String get createNovel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @errorLoadingChapters.
  ///
  /// In en, this message translates to:
  /// **'Error loading chapters'**
  String get errorLoadingChapters;

  /// No description provided for @loadingChapter.
  ///
  /// In en, this message translates to:
  /// **'Loading chapter…'**
  String get loadingChapter;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @unknownNovel.
  ///
  /// In en, this message translates to:
  /// **'Unknown Novel'**
  String get unknownNovel;

  /// No description provided for @unknownChapter.
  ///
  /// In en, this message translates to:
  /// **'Unknown chapter'**
  String get unknownChapter;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @novel.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get novel;

  /// No description provided for @chapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter Title'**
  String get chapterTitle;

  /// No description provided for @scrollOffset.
  ///
  /// In en, this message translates to:
  /// **'Scroll Offset'**
  String get scrollOffset;

  /// No description provided for @ttsIndex.
  ///
  /// In en, this message translates to:
  /// **'TTS Index'**
  String get ttsIndex;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get speechRate;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @defaultTTSVoice.
  ///
  /// In en, this message translates to:
  /// **'Default TTS Voice'**
  String get defaultTTSVoice;

  /// No description provided for @defaultVoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default voice updated'**
  String get defaultVoiceUpdated;

  /// No description provided for @defaultLanguageSet.
  ///
  /// In en, this message translates to:
  /// **'Default language set'**
  String get defaultLanguageSet;

  /// No description provided for @searchByTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title…'**
  String get searchByTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get testVoice;

  /// No description provided for @reloadVoices.
  ///
  /// In en, this message translates to:
  /// **'Reload Voices'**
  String get reloadVoices;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed Out'**
  String get signedOut;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @supabaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Supabase Settings'**
  String get supabaseSettings;

  /// No description provided for @supabaseNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Supabase not enabled'**
  String get supabaseNotEnabled;

  /// No description provided for @supabaseNotEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured for this build.'**
  String get supabaseNotEnabledDescription;

  /// No description provided for @authDisabledInBuild.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured. Authentication is disabled in this build.'**
  String get authDisabledInBuild;

  /// No description provided for @fetchFromSupabase.
  ///
  /// In en, this message translates to:
  /// **'Fetch from Supabase'**
  String get fetchFromSupabase;

  /// No description provided for @fetchFromSupabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Fetch latest novels and progress from Supabase.'**
  String get fetchFromSupabaseDescription;

  /// No description provided for @confirmFetch.
  ///
  /// In en, this message translates to:
  /// **'Confirm Fetch'**
  String get confirmFetch;

  /// No description provided for @confirmFetchDescription.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your local data. Are you sure?'**
  String get confirmFetchDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetch;

  /// No description provided for @downloadChapters.
  ///
  /// In en, this message translates to:
  /// **'Download chapters'**
  String get downloadChapters;

  /// No description provided for @modeSupabase.
  ///
  /// In en, this message translates to:
  /// **'Mode: Supabase'**
  String get modeSupabase;

  /// No description provided for @modeMockData.
  ///
  /// In en, this message translates to:
  /// **'Mode: Mock data'**
  String get modeMockData;

  /// No description provided for @continueAtChapter.
  ///
  /// In en, this message translates to:
  /// **'Continue at chapter • {title}'**
  String continueAtChapter(String title);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ttsSettings.
  ///
  /// In en, this message translates to:
  /// **'TTS Settings'**
  String get ttsSettings;

  /// No description provided for @enableTTS.
  ///
  /// In en, this message translates to:
  /// **'Enable TTS'**
  String get enableTTS;

  /// No description provided for @ttsVoice.
  ///
  /// In en, this message translates to:
  /// **'TTS Voice'**
  String get ttsVoice;

  /// No description provided for @loadingVoices.
  ///
  /// In en, this message translates to:
  /// **'Loading voices...'**
  String get loadingVoices;

  /// No description provided for @selectVoice.
  ///
  /// In en, this message translates to:
  /// **'Select a voice'**
  String get selectVoice;

  /// No description provided for @ttsLanguage.
  ///
  /// In en, this message translates to:
  /// **'TTS Language'**
  String get ttsLanguage;

  /// No description provided for @loadingLanguages.
  ///
  /// In en, this message translates to:
  /// **'Loading languages...'**
  String get loadingLanguages;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get selectLanguage;

  /// No description provided for @ttsSpeechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get ttsSpeechRate;

  /// No description provided for @ttsSpeechVolume.
  ///
  /// In en, this message translates to:
  /// **'Speech Volume'**
  String get ttsSpeechVolume;

  /// No description provided for @ttsSpeechPitch.
  ///
  /// In en, this message translates to:
  /// **'Speech Pitch'**
  String get ttsSpeechPitch;

  /// No description provided for @novelsAndProgress.
  ///
  /// In en, this message translates to:
  /// **'Novels and Progress'**
  String get novelsAndProgress;

  /// No description provided for @novels.
  ///
  /// In en, this message translates to:
  /// **'Novels'**
  String get novels;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @novelsAndProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'Novels: {count}, Progress: {progress}'**
  String novelsAndProgressSummary(int count, String progress);

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @noChaptersFound.
  ///
  /// In en, this message translates to:
  /// **'No chapters found.'**
  String get noChaptersFound;

  /// No description provided for @indexLabel.
  ///
  /// In en, this message translates to:
  /// **'Index {index}'**
  String indexLabel(int index);

  /// No description provided for @stopTTS.
  ///
  /// In en, this message translates to:
  /// **'Stop TTS'**
  String get stopTTS;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @supabaseProgressNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Supabase not configured; progress not saved'**
  String get supabaseProgressNotSaved;

  /// No description provided for @progressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get progressSaved;

  /// No description provided for @errorSavingProgress.
  ///
  /// In en, this message translates to:
  /// **'Error saving progress'**
  String get errorSavingProgress;

  /// No description provided for @autoplayBlocked.
  ///
  /// In en, this message translates to:
  /// **'Auto-play blocked. Tap Continue to start.'**
  String get autoplayBlocked;

  /// No description provided for @autoplayBlockedInline.
  ///
  /// In en, this message translates to:
  /// **'Auto-play is blocked by the browser. Tap Continue to start reading.'**
  String get autoplayBlockedInline;

  /// No description provided for @reachedLastChapter.
  ///
  /// In en, this message translates to:
  /// **'Reached last chapter'**
  String get reachedLastChapter;

  /// No description provided for @ttsError.
  ///
  /// In en, this message translates to:
  /// **'TTS error: {msg}'**
  String ttsError(String msg);

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @themeHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get themeHighContrast;

  /// No description provided for @themeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeDefault;

  /// No description provided for @themeSolarized.
  ///
  /// In en, this message translates to:
  /// **'Solarized'**
  String get themeSolarized;

  /// No description provided for @themeSolarizedTan.
  ///
  /// In en, this message translates to:
  /// **'Solarized Tan'**
  String get themeSolarizedTan;

  /// No description provided for @themeNord.
  ///
  /// In en, this message translates to:
  /// **'Nord'**
  String get themeNord;

  /// No description provided for @themeNordFrost.
  ///
  /// In en, this message translates to:
  /// **'Nord Frost'**
  String get themeNordFrost;

  /// No description provided for @themeNordSnowstorm.
  ///
  /// In en, this message translates to:
  /// **'Nord Snowstorm'**
  String get themeNordSnowstorm;

  /// No description provided for @separateDarkPalette.
  ///
  /// In en, this message translates to:
  /// **'Use separate dark palette'**
  String get separateDarkPalette;

  /// No description provided for @lightPalette.
  ///
  /// In en, this message translates to:
  /// **'Light Palette'**
  String get lightPalette;

  /// No description provided for @darkPalette.
  ///
  /// In en, this message translates to:
  /// **'Dark Palette'**
  String get darkPalette;

  /// No description provided for @typographyPreset.
  ///
  /// In en, this message translates to:
  /// **'Typography Preset'**
  String get typographyPreset;

  /// No description provided for @typographyComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get typographyComfortable;

  /// No description provided for @typographyCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get typographyCompact;

  /// No description provided for @typographySerifLike.
  ///
  /// In en, this message translates to:
  /// **'Serif-like'**
  String get typographySerifLike;

  /// No description provided for @fontPack.
  ///
  /// In en, this message translates to:
  /// **'Font Pack'**
  String get fontPack;

  /// No description provided for @separateTypographyPresets.
  ///
  /// In en, this message translates to:
  /// **'Use separate typography for light/dark'**
  String get separateTypographyPresets;

  /// No description provided for @typographyLight.
  ///
  /// In en, this message translates to:
  /// **'Light Typography'**
  String get typographyLight;

  /// No description provided for @typographyDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Typography'**
  String get typographyDark;

  /// No description provided for @readerBundles.
  ///
  /// In en, this message translates to:
  /// **'Reader Theme Bundles'**
  String get readerBundles;

  /// No description provided for @bundleNordCalm.
  ///
  /// In en, this message translates to:
  /// **'Nord Calm'**
  String get bundleNordCalm;

  /// No description provided for @bundleSolarizedFocus.
  ///
  /// In en, this message translates to:
  /// **'Solarized Focus'**
  String get bundleSolarizedFocus;

  /// No description provided for @bundleHighContrastReadability.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Readability'**
  String get bundleHighContrastReadability;

  /// No description provided for @customFontFamily.
  ///
  /// In en, this message translates to:
  /// **'Custom Font Family'**
  String get customFontFamily;

  /// No description provided for @commonFonts.
  ///
  /// In en, this message translates to:
  /// **'Common Fonts'**
  String get commonFonts;

  /// No description provided for @readerFontSize.
  ///
  /// In en, this message translates to:
  /// **'Reader Font Size'**
  String get readerFontSize;

  /// No description provided for @textScale.
  ///
  /// In en, this message translates to:
  /// **'Text Scale'**
  String get textScale;

  /// No description provided for @readerBackgroundDepth.
  ///
  /// In en, this message translates to:
  /// **'Reader Background Depth'**
  String get readerBackgroundDepth;

  /// No description provided for @depthLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get depthLow;

  /// No description provided for @depthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get depthMedium;

  /// No description provided for @depthHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get depthHigh;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimize animations for motion comfort'**
  String get reduceMotionDescription;

  /// No description provided for @gesturesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable touch gestures'**
  String get gesturesEnabled;

  /// No description provided for @gesturesEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable swipe and tap gestures in the reader'**
  String get gesturesEnabledDescription;

  /// No description provided for @readerSwipeSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Reader swipe sensitivity'**
  String get readerSwipeSensitivity;

  /// No description provided for @readerSwipeSensitivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust minimum swipe velocity for chapter navigation'**
  String get readerSwipeSensitivityDescription;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removedFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Removed from Library'**
  String get removedFromLibrary;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'This will delete \'{title}\' from Supabase. Are you sure?'**
  String confirmDeleteDescription(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reachedFirstChapter.
  ///
  /// In en, this message translates to:
  /// **'Reached first chapter'**
  String get reachedFirstChapter;

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @performanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Performance Settings'**
  String get performanceSettings;

  /// No description provided for @prefetchNextChapter.
  ///
  /// In en, this message translates to:
  /// **'Prefetch next chapter'**
  String get prefetchNextChapter;

  /// No description provided for @prefetchNextChapterDescription.
  ///
  /// In en, this message translates to:
  /// **'Preload the next chapter to reduce waiting.'**
  String get prefetchNextChapterDescription;

  /// No description provided for @clearOfflineCache.
  ///
  /// In en, this message translates to:
  /// **'Clear offline cache'**
  String get clearOfflineCache;

  /// No description provided for @offlineCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Offline cache cleared'**
  String get offlineCacheCleared;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @exitEdit.
  ///
  /// In en, this message translates to:
  /// **'Exit Edit'**
  String get exitEdit;

  /// No description provided for @enterEditMode.
  ///
  /// In en, this message translates to:
  /// **'Enter Edit Mode'**
  String get enterEditMode;

  /// No description provided for @exitEditMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Edit Mode'**
  String get exitEditMode;

  /// No description provided for @chapterContent.
  ///
  /// In en, this message translates to:
  /// **'Chapter Content'**
  String get chapterContent;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @createNextChapter.
  ///
  /// In en, this message translates to:
  /// **'Create Next Chapter'**
  String get createNextChapter;

  /// No description provided for @enterChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter chapter title'**
  String get enterChapterTitle;

  /// No description provided for @enterChapterContent.
  ///
  /// In en, this message translates to:
  /// **'Enter chapter content'**
  String get enterChapterContent;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them?'**
  String get discardChangesMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @saveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @coverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover URL'**
  String get coverUrlLabel;

  /// No description provided for @invalidCoverUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) URL without spaces.'**
  String get invalidCoverUrl;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @chapterIndex.
  ///
  /// In en, this message translates to:
  /// **'Chapter Index'**
  String get chapterIndex;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @scenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get scenes;

  /// No description provided for @characterTemplates.
  ///
  /// In en, this message translates to:
  /// **'Character Templates'**
  String get characterTemplates;

  /// No description provided for @sceneTemplates.
  ///
  /// In en, this message translates to:
  /// **'Scene Templates'**
  String get sceneTemplates;

  /// No description provided for @updateNovel.
  ///
  /// In en, this message translates to:
  /// **'Update Novel'**
  String get updateNovel;

  /// No description provided for @deleteNovel.
  ///
  /// In en, this message translates to:
  /// **'Delete Novel'**
  String get deleteNovel;

  /// No description provided for @deleteNovelConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the novel. Continue?'**
  String get deleteNovelConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
