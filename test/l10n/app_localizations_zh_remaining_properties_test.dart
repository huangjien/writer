import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - All Remaining Properties', () {
    test('TTS Voice and Language properties', () {
      expect(zh.ttsVoice, isNotEmpty);
      expect(zh.loadingVoices, isNotEmpty);
      expect(zh.selectVoice, isNotEmpty);
      expect(zh.ttsLanguage, isNotEmpty);
      expect(zh.loadingLanguages, isNotEmpty);
      expect(zh.selectLanguage, isNotEmpty);
      expect(zhTW.ttsVoice, isNotEmpty);
      expect(zhTW.loadingVoices, isNotEmpty);
      expect(zhTW.selectVoice, isNotEmpty);
    });

    test('TTS Speech properties', () {
      expect(zh.ttsSpeechRate, isNotEmpty);
      expect(zh.ttsSpeechVolume, isNotEmpty);
      expect(zh.ttsSpeechPitch, isNotEmpty);
      expect(zhTW.ttsSpeechRate, isNotEmpty);
      expect(zhTW.ttsSpeechVolume, isNotEmpty);
      expect(zhTW.ttsSpeechPitch, isNotEmpty);
    });

    test('Novels and Progress properties', () {
      expect(zh.novelsAndProgress, isNotEmpty);
      expect(zh.novels, isNotEmpty);
      expect(zh.progress, isNotEmpty);
      expect(zh.chapters, isNotEmpty);
      expect(zh.noChaptersFound, isNotEmpty);
      expect(zhTW.novelsAndProgress, isNotEmpty);
      expect(zhTW.novels, isNotEmpty);
      expect(zhTW.progress, isNotEmpty);
    });

    test('Index and Float properties', () {
      expect(zh.enterFloatIndexHint, isNotEmpty);
      expect(zh.indexUnchanged, isNotEmpty);
      expect(zh.roundingBefore, isNotEmpty);
      expect(zh.roundingAfter, isNotEmpty);
      expect(zhTW.enterFloatIndexHint, isNotEmpty);
      expect(zhTW.indexUnchanged, isNotEmpty);
    });

    test('TTS Control properties', () {
      expect(zh.stopTTS, isNotEmpty);
      expect(zh.speak, isNotEmpty);
      expect(zhTW.stopTTS, isNotEmpty);
      expect(zhTW.speak, isNotEmpty);
    });

    test('Progress Saving properties', () {
      expect(zh.supabaseProgressNotSaved, isNotEmpty);
      expect(zh.progressSaved, isNotEmpty);
      expect(zh.errorSavingProgress, isNotEmpty);
      expect(zhTW.supabaseProgressNotSaved, isNotEmpty);
      expect(zhTW.progressSaved, isNotEmpty);
      expect(zhTW.errorSavingProgress, isNotEmpty);
    });

    test('Autoplay properties', () {
      expect(zh.autoplayBlocked, isNotEmpty);
      expect(zh.autoplayBlockedInline, isNotEmpty);
      expect(zh.reachedLastChapter, isNotEmpty);
      expect(zhTW.autoplayBlocked, isNotEmpty);
      expect(zhTW.autoplayBlockedInline, isNotEmpty);
      expect(zhTW.reachedLastChapter, isNotEmpty);
    });

    test('Theme Mode properties', () {
      expect(zh.themeMode, isNotEmpty);
      expect(zh.system, isNotEmpty);
      expect(zh.light, isNotEmpty);
      expect(zh.dark, isNotEmpty);
      expect(zhTW.themeMode, isNotEmpty);
      expect(zhTW.system, isNotEmpty);
      expect(zhTW.light, isNotEmpty);
      expect(zhTW.dark, isNotEmpty);
    });

    test('Color Theme properties', () {
      expect(zh.colorTheme, isNotEmpty);
      expect(zh.themeLight, isNotEmpty);
      expect(zh.themeSepia, isNotEmpty);
      expect(zh.themeHighContrast, isNotEmpty);
      expect(zh.themeDefault, isNotEmpty);
      expect(zh.themeEmeraldGreen, isNotEmpty);
      expect(zh.themeSolarizedTan, isNotEmpty);
      expect(zh.themeNord, isNotEmpty);
      expect(zh.themeNordFrost, isNotEmpty);
      expect(zhTW.colorTheme, isNotEmpty);
      expect(zhTW.themeLight, isNotEmpty);
      expect(zhTW.themeSepia, isNotEmpty);
    });

    test('Palette properties', () {
      expect(zh.separateDarkPalette, isNotEmpty);
      expect(zh.lightPalette, isNotEmpty);
      expect(zh.darkPalette, isNotEmpty);
      expect(zhTW.separateDarkPalette, isNotEmpty);
      expect(zhTW.lightPalette, isNotEmpty);
      expect(zhTW.darkPalette, isNotEmpty);
    });

    test('Typography properties', () {
      expect(zh.typographyPreset, isNotEmpty);
      expect(zh.typographyComfortable, isNotEmpty);
      expect(zh.typographyCompact, isNotEmpty);
      expect(zh.typographySerifLike, isNotEmpty);
      expect(zh.fontPack, isNotEmpty);
      expect(zh.separateTypographyPresets, isNotEmpty);
      expect(zh.typographyLight, isNotEmpty);
      expect(zh.typographyDark, isNotEmpty);
      expect(zhTW.typographyPreset, isNotEmpty);
      expect(zhTW.typographyComfortable, isNotEmpty);
      expect(zhTW.fontPack, isNotEmpty);
    });

    test('Reader Bundles properties', () {
      expect(zh.readerBundles, isNotEmpty);
      expect(zh.tokenUsage, isNotEmpty);
      expect(zhTW.readerBundles, isNotEmpty);
      expect(zhTW.tokenUsage, isNotEmpty);
    });

    test('Navigation properties', () {
      expect(zh.discover, isNotEmpty);
      expect(zh.profile, isNotEmpty);
      expect(zh.libraryTitle, isNotEmpty);
      expect(zh.undo, isNotEmpty);
      expect(zhTW.discover, isNotEmpty);
      expect(zhTW.profile, isNotEmpty);
      expect(zhTW.libraryTitle, isNotEmpty);
      expect(zhTW.undo, isNotEmpty);
    });

    test('Filter properties', () {
      expect(zh.allFilter, isNotEmpty);
      expect(zh.readingFilter, isNotEmpty);
      expect(zh.completedFilter, isNotEmpty);
      expect(zh.downloadedFilter, isNotEmpty);
      expect(zh.searchNovels, isNotEmpty);
      expect(zhTW.allFilter, isNotEmpty);
      expect(zhTW.readingFilter, isNotEmpty);
      expect(zhTW.completedFilter, isNotEmpty);
    });

    test('View properties', () {
      expect(zh.listView, isNotEmpty);
      expect(zh.gridView, isNotEmpty);
      expect(zhTW.listView, isNotEmpty);
      expect(zhTW.gridView, isNotEmpty);
    });

    test('User Management properties', () {
      expect(zh.userManagement, isNotEmpty);
      expect(zhTW.userManagement, isNotEmpty);
    });

    test('Token Usage properties', () {
      expect(zh.totalThisMonth, isNotEmpty);
      expect(zh.inputTokens, isNotEmpty);
      expect(zh.outputTokens, isNotEmpty);
      expect(zh.requests, isNotEmpty);
      expect(zh.viewHistory, isNotEmpty);
      expect(zh.noUsageThisMonth, isNotEmpty);
      expect(zh.startUsingAiFeatures, isNotEmpty);
      expect(zh.errorLoadingUsage, isNotEmpty);
      expect(zh.refresh, isNotEmpty);
      expect(zh.total, isNotEmpty);
      expect(zh.noUsageHistory, isNotEmpty);
      expect(zhTW.totalThisMonth, isNotEmpty);
      expect(zhTW.inputTokens, isNotEmpty);
      expect(zhTW.outputTokens, isNotEmpty);
    });

    test('Reader Bundle properties', () {
      expect(zh.bundleNordCalm, isNotEmpty);
      expect(zh.bundleSolarizedFocus, isNotEmpty);
      expect(zh.bundleHighContrastReadability, isNotEmpty);
      expect(zhTW.bundleNordCalm, isNotEmpty);
      expect(zhTW.bundleSolarizedFocus, isNotEmpty);
    });

    test('Font properties', () {
      expect(zh.customFontFamily, isNotEmpty);
      expect(zh.commonFonts, isNotEmpty);
      expect(zhTW.customFontFamily, isNotEmpty);
      expect(zhTW.commonFonts, isNotEmpty);
    });

    test('Reader Settings properties', () {
      expect(zh.readerFontSize, isNotEmpty);
      expect(zh.textScale, isNotEmpty);
      expect(zh.readerBackgroundDepth, isNotEmpty);
      expect(zh.depthLow, isNotEmpty);
      expect(zh.depthMedium, isNotEmpty);
      expect(zh.depthHigh, isNotEmpty);
      expect(zhTW.readerFontSize, isNotEmpty);
      expect(zhTW.textScale, isNotEmpty);
      expect(zhTW.depthLow, isNotEmpty);
      expect(zhTW.depthMedium, isNotEmpty);
    });

    test('Action properties', () {
      expect(zh.select, isNotEmpty);
      expect(zh.clear, isNotEmpty);
      expect(zhTW.select, isNotEmpty);
      expect(zhTW.clear, isNotEmpty);
    });

    test('Settings properties', () {
      expect(zh.adminMode, isNotEmpty);
      expect(zh.reduceMotion, isNotEmpty);
      expect(zh.reduceMotionDescription, isNotEmpty);
      expect(zh.gesturesEnabled, isNotEmpty);
      expect(zhTW.adminMode, isNotEmpty);
      expect(zhTW.reduceMotion, isNotEmpty);
      expect(zhTW.gesturesEnabled, isNotEmpty);
    });

    test('Parameterized methods - novelsAndProgressSummary', () {
      expect(zh.novelsAndProgressSummary(5, '50%'), contains('5'));
      expect(zh.novelsAndProgressSummary(10, '100%'), contains('10'));
      expect(zh.novelsAndProgressSummary(1, '0%'), contains('1'));
      expect(zhTW.novelsAndProgressSummary(5, '50%'), contains('5'));
      expect(zhTW.novelsAndProgressSummary(10, '80%'), contains('10'));
    });

    test('Parameterized methods - removedNovel', () {
      expect(zh.removedNovel('Novel Title'), contains('Novel Title'));
      expect(zh.removedNovel('小说'), contains('小说'));
      expect(zhTW.removedNovel('Test'), contains('Test'));
    });

    test('Parameterized methods - totalRecords', () {
      expect(zh.totalRecords(100), contains('100'));
      expect(zh.totalRecords(1000), contains('1000'));
      expect(zh.totalRecords(0), contains('0'));
      expect(zhTW.totalRecords(100), contains('100'));
      expect(zhTW.totalRecords(500), contains('500'));
    });

    test('Parameterized methods - indexLabel', () {
      expect(zh.indexLabel(0), contains('0'));
      expect(zh.indexLabel(1), contains('1'));
      expect(zh.indexLabel(99), contains('99'));
      expect(zhTW.indexLabel(0), contains('0'));
      expect(zhTW.indexLabel(50), contains('50'));
    });

    test('Parameterized methods - indexOutOfRange', () {
      expect(zh.indexOutOfRange(0, 10), contains('0'));
      expect(zh.indexOutOfRange(5, 10), contains('5'));
      expect(zh.indexOutOfRange(10, 100), contains('10'));
      expect(zhTW.indexOutOfRange(0, 10), contains('0'));
      expect(zhTW.indexOutOfRange(9, 10), contains('9'));
    });

    test('Parameterized methods - ttsError', () {
      expect(zh.ttsError('Error loading'), contains('Error loading'));
      expect(zh.ttsError('Network failed'), contains('Network failed'));
      expect(zh.ttsError('超时'), contains('超时'));
      expect(zhTW.ttsError('Error'), contains('Error'));
      expect(zhTW.ttsError('Failed'), contains('Failed'));
    });
  });
}
