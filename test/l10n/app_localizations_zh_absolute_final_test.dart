import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_zh.dart';

void main() {
  late AppLocalizationsZh zh;
  late AppLocalizationsZhTw zhTW;

  setUp(() {
    zh = AppLocalizationsZh();
    zhTW = AppLocalizationsZhTw();
  });

  group('AppLocalizationsZh - Absolute Final Coverage', () {
    test('all version and language strings work', () {
      expect(zh.version, isNotEmpty);
      expect(zh.appLanguage, isNotEmpty);
      expect(zh.english, isNotEmpty);
      expect(zh.chinese, isNotEmpty);
      expect(zh.supabaseIntegrationInitialized, isNotEmpty);
      expect(zh.configureEnvironment, isNotEmpty);
    });

    test('all error and loading strings work', () {
      expect(zh.errorLoadingChapters, isNotEmpty);
      expect(zh.loadingChapter, isNotEmpty);
      expect(zh.notStarted, isNotEmpty);
      expect(zh.unknownNovel, isNotEmpty);
      expect(zh.unknownChapter, isNotEmpty);
      expect(zh.chapterTitle, isNotEmpty);
      expect(zh.scrollOffset, isNotEmpty);
      expect(zh.ttsIndex, isNotEmpty);
      expect(zh.defaultVoiceUpdated, isNotEmpty);
      expect(zh.defaultLanguageSet, isNotEmpty);
      expect(zh.searchByTitle, isNotEmpty);
      expect(zh.chooseLanguage, isNotEmpty);
    });

    test('all Supabase strings work', () {
      expect(zh.supabaseNotEnabledDescription, isNotEmpty);
      expect(zh.fetchFromSupabase, isNotEmpty);
      expect(zh.fetchFromSupabaseDescription, isNotEmpty);
      expect(zh.confirmFetch, isNotEmpty);
      expect(zh.confirmFetchDescription, isNotEmpty);
      expect(zh.fetch, isNotEmpty);
      expect(zh.downloadChapters, isNotEmpty);
      expect(zh.modeSupabase, isNotEmpty);
      expect(zh.modeMockData, isNotEmpty);
    });

    test('all remaining TTS strings work', () {
      expect(zh.reloadVoices, isNotEmpty);
    });

    test('all misc strings work', () {
      expect(zh.noSupabase, isNotEmpty);
      expect(zh.noProgress, isNotEmpty);
    });
  });

  group('AppLocalizationsZhTw - Absolute Final Coverage', () {
    test('all version and language strings work', () {
      expect(zhTW.version, isNotEmpty);
      expect(zhTW.appLanguage, isNotEmpty);
      expect(zhTW.english, isNotEmpty);
      expect(zhTW.chinese, isNotEmpty);
      expect(zhTW.supabaseIntegrationInitialized, isNotEmpty);
      expect(zhTW.configureEnvironment, isNotEmpty);
    });

    test('all error and loading strings work', () {
      expect(zhTW.errorLoadingChapters, isNotEmpty);
      expect(zhTW.loadingChapter, isNotEmpty);
      expect(zhTW.notStarted, isNotEmpty);
      expect(zhTW.unknownNovel, isNotEmpty);
      expect(zhTW.unknownChapter, isNotEmpty);
      expect(zhTW.chapterTitle, isNotEmpty);
      expect(zhTW.scrollOffset, isNotEmpty);
      expect(zhTW.ttsIndex, isNotEmpty);
      expect(zhTW.defaultVoiceUpdated, isNotEmpty);
      expect(zhTW.defaultLanguageSet, isNotEmpty);
      expect(zhTW.searchByTitle, isNotEmpty);
      expect(zhTW.chooseLanguage, isNotEmpty);
    });

    test('all Supabase strings work', () {
      expect(zhTW.supabaseNotEnabledDescription, isNotEmpty);
      expect(zhTW.fetchFromSupabase, isNotEmpty);
      expect(zhTW.fetchFromSupabaseDescription, isNotEmpty);
      expect(zhTW.confirmFetch, isNotEmpty);
      expect(zhTW.confirmFetchDescription, isNotEmpty);
      expect(zhTW.fetch, isNotEmpty);
      expect(zhTW.downloadChapters, isNotEmpty);
      expect(zhTW.modeSupabase, isNotEmpty);
      expect(zhTW.modeMockData, isNotEmpty);
    });

    test('all remaining TTS strings work', () {
      expect(zhTW.reloadVoices, isNotEmpty);
    });

    test('all misc strings work', () {
      expect(zhTW.noSupabase, isNotEmpty);
      expect(zhTW.noProgress, isNotEmpty);
    });
  });
}
