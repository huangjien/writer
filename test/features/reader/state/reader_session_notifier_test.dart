import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/state/reader_session_notifier.dart';
import 'package:writer/features/reader/state/reader_session_state.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/chapter_repository.dart';

class MockTtsDriver extends Mock implements TtsDriver {}

class MockChapterRepository extends Mock implements ChapterRepository {}

// Use real notifiers backed by SharedPreferences mock storage.

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Chapter(id: 'f', novelId: 'n', idx: 0, title: '', content: ''),
    );
  });
  late MockTtsDriver mockTtsDriver;
  late MockChapterRepository mockRepo;
  late SharedPreferences prefs;

  setUp(() async {
    mockTtsDriver = MockTtsDriver();
    mockRepo = MockChapterRepository();
    SharedPreferences.setMockInitialValues({
      'tts_voice_name': 'en-US-Wavenet-D',
      'tts_voice_locale': 'en-US',
      'tts_rate': 1.0,
      'tts_volume': 1.0,
      'app_language': 'en',
      'prefetch_next_chapter_enabled': false,
    });
    prefs = await SharedPreferences.getInstance();

    // Mock TtsDriver methods
    when(
      () => mockTtsDriver.configure(
        voiceName: any(named: 'voiceName'),
        voiceLocale: any(named: 'voiceLocale'),
        defaultLocale: any(named: 'defaultLocale'),
        onProgress: any(named: 'onProgress'),
        onStart: any(named: 'onStart'),
        onCancel: any(named: 'onCancel'),
        onError: any(named: 'onError'),
        onAllComplete: any(named: 'onAllComplete'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockTtsDriver.setRate(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.setVolume(any())).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockTtsDriver.stop()).thenAnswer((_) async {});
  });

  test('ReaderSessionNotifier initializes correctly', () {
    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(false),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: const ReaderSessionState(
              chapterId: 'c1',
              title: 'Chapter 1',
              currentIdx: 0,
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);
    expect(notifier.state.chapterId, 'c1');
    expect(notifier.state.editMode, false);

    container.dispose();
  });

  test('toggleFullScreen updates state', () {
    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(false),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: const ReaderSessionState(
              chapterId: 'c1',
              title: 'Chapter 1',
              currentIdx: 0,
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);

    notifier.toggleFullScreen();
    expect(notifier.state.fullScreen, true);

    notifier.toggleFullScreen();
    expect(notifier.state.fullScreen, false);
    container.dispose();
  });

  test('loadNextChapter updates state and starts TTS', () async {
    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'C1',
        content: 'Content 1',
      ),
      const Chapter(
        id: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'C2',
        content: 'Content 2',
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(false),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: ReaderSessionState(
              chapterId: 'c1',
              title: 'C1',
              currentIdx: 0,
              allChapters: chapters,
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);

    final success = await notifier.loadNextChapter();

    expect(success, true);
    expect(notifier.state.chapterId, 'c2');
    expect(notifier.state.currentIdx, 1);
    expect(notifier.state.speaking, true);

    verify(
      () => mockTtsDriver.start(content: 'Content 2', startIndex: 0),
    ).called(1);

    container.dispose();
  });

  test('configureTts maps locale changes to driver', () async {
    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(false),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: const ReaderSessionState(
              chapterId: 'c1',
              title: 'C1',
              currentIdx: 0,
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);
    await notifier.startTts(optimistic: false);
    verify(
      () => mockTtsDriver.configure(
        voiceName: any(named: 'voiceName'),
        voiceLocale: any(named: 'voiceLocale'),
        defaultLocale: 'en-US',
        onProgress: any(named: 'onProgress'),
        onStart: any(named: 'onStart'),
        onCancel: any(named: 'onCancel'),
        onError: any(named: 'onError'),
        onAllComplete: any(named: 'onAllComplete'),
      ),
    ).called(greaterThanOrEqualTo(1));

    final app = container.read(appSettingsProvider.notifier);
    await app.setLanguage('zh');
    await notifier.startTts(optimistic: false);
    verify(
      () => mockTtsDriver.configure(
        voiceName: any(named: 'voiceName'),
        voiceLocale: any(named: 'voiceLocale'),
        defaultLocale: 'zh-CN',
        onProgress: any(named: 'onProgress'),
        onStart: any(named: 'onStart'),
        onCancel: any(named: 'onCancel'),
        onError: any(named: 'onError'),
        onAllComplete: any(named: 'onAllComplete'),
      ),
    ).called(greaterThanOrEqualTo(1));

    container.dispose();
  });

  test('playStop toggles speaking and calls stop when speaking', () async {
    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(false),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: const ReaderSessionState(
              chapterId: 'c1',
              title: 'C1',
              currentIdx: 0,
              content: 'Hello world',
              speaking: true,
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);
    await notifier.playStop(0.0);
    expect(notifier.state.speaking, false);
    verify(() => mockTtsDriver.stop()).called(1);

    await notifier.playStop(0.0);
    expect(notifier.state.speaking, true);

    container.dispose();
  });

  test('loadNextChapter prefetches when enabled', () async {
    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'C1',
        content: 'Content 1',
      ),
      const Chapter(
        id: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'C2',
        content: 'Content 2',
      ),
      const Chapter(
        id: 'c3',
        novelId: 'n1',
        idx: 3,
        title: 'C3',
        content: 'Content 3',
      ),
    ];

    when(() => mockRepo.getChapter(any())).thenAnswer((invocation) async {
      final ch = invocation.positionalArguments.first as Chapter;
      return ch;
    });

    final container = ProviderContainer(
      overrides: [
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        supabaseEnabledProvider.overrideWithValue(true),
        chapterRepositoryProvider.overrideWithValue(mockRepo),
        readerSessionProvider.overrideWith(
          (ref) => ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: ReaderSessionState(
              chapterId: 'c1',
              title: 'C1',
              currentIdx: 0,
              allChapters: chapters,
              content: 'Content 1',
            ),
          ),
        ),
      ],
    );

    final notifier = container.read(readerSessionProvider.notifier);
    await notifier.loadNextChapter();

    verify(() => mockRepo.getChapter(chapters[2])).called(1);

    container.dispose();
  });
}
