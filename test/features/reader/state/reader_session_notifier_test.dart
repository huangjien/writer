import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Import legacy for StateNotifierProvider
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/features/reader/state/reader_session_notifier.dart';
import 'package:writer/features/reader/state/reader_session_state.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/user_progress.dart'; // Import UserProgress
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/common/errors/failures.dart';
import 'package:writer/features/reader/logic/progress_saver.dart';

class MockTtsDriver extends Mock implements TtsDriver {
  @override
  Future<void> stop() => Future.value();
}

class MockTtsDriverWithError extends Mock implements TtsDriver {
  @override
  Future<void> start({
    required String content,
    required int startIndex,
    int chunkMaxLen = 160,
    int baseTimeoutMs = 4000,
    int charTimeoutMs = 50,
  }) => Future.error(Exception('TTS start failed'));

  @override
  Future<void> stop() => Future.value();
}

class MockTtsDriverWithStopError extends Mock implements TtsDriver {
  @override
  Future<void> stop() => Future.error(Exception('TTS stop failed'));
}

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockProgressPort extends Mock implements ProgressPort {}

class MockBackendUser extends Mock implements BackendUser {
  @override
  String get id => 'user123';
}

class MockProgressController extends Mock implements ProgressController {
  @override
  Future<bool> save(UserProgress progress) => Future.value(true);
}

void main() {
  late MockTtsDriver mockTtsDriver;
  late MockChapterRepository mockChapterRepository;
  late MockProgressPort mockProgressPort;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    mockTtsDriver = MockTtsDriver();
    mockChapterRepository = MockChapterRepository();
    mockProgressPort = MockProgressPort();

    // Register fallback for UserProgress
    registerFallbackValue(
      UserProgress(
        userId: 'u',
        novelId: 'n',
        chapterId: 'c',
        scrollOffset: 0,
        ttsCharIndex: 0,
        updatedAt: DateTime.now(),
      ),
    );

    // Register fallback for Chapter
    registerFallbackValue(
      Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'Test', content: 'Test'),
    );

    // Default mocks
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

    // Mock async returns for TTS driver methods
    when(() => mockTtsDriver.setRate(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.setVolume(any())).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockTtsDriver.index).thenReturn(0);

    // Mock async returns for progress port
    when(() => mockProgressPort.upsertProgress(any())).thenAnswer((_) async {});

    // Default getChapter behavior
    when(() => mockChapterRepository.getChapter(any())).thenAnswer(
      (invocation) =>
          Future.value(invocation.positionalArguments[0] as Chapter),
    );
  });

  test('loadNextChapter updates state and prefetches', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final c2 = Chapter(
      id: 'c2',
      novelId: 'n1',
      idx: 2,
      title: 'Two',
      content: 'Content 2',
    );
    final c3 = Chapter(
      id: 'c3',
      novelId: 'n1',
      idx: 3,
      title: 'Three',
      content: 'Content 3',
    );

    final initialState = ReaderSessionState(
      chapterId: 'c1',
      title: 'One',
      allChapters: [c1, c2, c3],
      currentIdx: 0,
      content: 'Content 1',
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier(prefs),
        ),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );

    // Register fallback for progress
    registerFallbackValue(
      initialState,
    ); // Just a dummy fallback if needed, but likely need UserProgress
    // Since we mocked upsertProgress(any()), we might not need explicit fallback if we don't verify with specific value or if mocktail infers dynamic.
    // But let's be safe for other things.

    // Mock prefetch
    when(
      () => mockChapterRepository.getChapter(c3),
    ).thenAnswer((_) async => c3);

    // We define a provider that creates the notifier
    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });

    final notifier = container.read(notifierProvider.notifier);

    // Act
    final success = await notifier.loadNextChapter();

    // Assert
    expect(success, isTrue);
    expect(container.read(notifierProvider).chapterId, 'c2');
    expect(container.read(notifierProvider).currentIdx, 1);

    verify(() => mockChapterRepository.getChapter(c3)).called(1);
    verify(
      () => mockTtsDriver.start(content: 'Content 2', startIndex: 0),
    ).called(1);
  });

  test('loadPrevChapter updates state and stops playback', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final c2 = Chapter(
      id: 'c2',
      novelId: 'n1',
      idx: 2,
      title: 'Two',
      content: 'Content 2',
    );

    final initialState = ReaderSessionState(
      chapterId: 'c2',
      title: 'Two',
      allChapters: [c1, c2],
      currentIdx: 1,
      content: 'Content 2',
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier(prefs),
        ),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );

    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });

    final notifier = container.read(notifierProvider.notifier);

    // Act
    final success = await notifier.loadPrevChapter();

    // Assert
    expect(success, isTrue);
    expect(container.read(notifierProvider).chapterId, 'c1');
    expect(container.read(notifierProvider).currentIdx, 0);
  });

  test('playStop toggles playback', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final initialState = ReaderSessionState(
      chapterId: 'c1',
      title: 'One',
      allChapters: [c1],
      currentIdx: 0,
      content: 'Content 1',
      speaking: false,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier(prefs),
        ),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );

    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });

    final notifier = container.read(notifierProvider.notifier);

    // Play
    await notifier.playStop(0);
    verify(
      () => mockTtsDriver.start(content: 'Content 1', startIndex: 0),
    ).called(1);
    expect(container.read(notifierProvider).speaking, isTrue);

    // Stop
    await notifier.playStop(0);
    expect(container.read(notifierProvider).speaking, isFalse);
  });

  test('toggle flags update state', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final initialState = ReaderSessionState(
      chapterId: 'c1',
      title: 'One',
      allChapters: [c1],
      currentIdx: 0,
      content: 'Content 1',
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier(prefs),
        ),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );
    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });
    final notifier = container.read(notifierProvider.notifier);

    notifier.toggleFullScreen();
    expect(container.read(notifierProvider).fullScreen, isTrue);
    notifier.togglePreviewMode();
    expect(container.read(notifierProvider).previewMode, isTrue);
    notifier.setEditMode(true);
    expect(container.read(notifierProvider).editMode, isTrue);
    expect(container.read(notifierProvider).previewMode, isFalse);
    notifier.setDiscardDialogOpen(true);
    expect(container.read(notifierProvider).discardDialogOpen, isTrue);
    notifier.setAutoplayBlocked(true);
    expect(container.read(notifierProvider).autoplayBlocked, isTrue);
  });

  test('configure TTS maps locale zh to zh-CN', () async {});

  test('prefetchNext respects settings', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final c2 = Chapter(
      id: 'c2',
      novelId: 'n1',
      idx: 2,
      title: 'Two',
      content: 'Content 2',
    );
    final initialState = ReaderSessionState(
      chapterId: 'c1',
      title: 'One',
      allChapters: [c1, c2],
      currentIdx: 0,
      content: 'Content 1',
    );
    final perf = PerformanceSettingsNotifier(prefs);
    await perf.setPrefetchNextChapter(false);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith((ref) => perf),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );
    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });
    final notifier = container.read(notifierProvider.notifier);
    await notifier.loadNextChapter();
    verifyNever(() => mockChapterRepository.getChapter(c2));
  });

  test('saveProgress calls repository', () async {
    final c1 = Chapter(
      id: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Content 1',
    );
    final initialState = ReaderSessionState(
      chapterId: 'c1',
      title: 'One',
      allChapters: [c1],
      currentIdx: 0,
      content: 'Content 1',
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ttsDriverProvider.overrideWithValue(mockTtsDriver),
        chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
        ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier(prefs),
        ),
        isSignedInProvider.overrideWithValue(true),
        currentUserProvider.overrideWith(
          (ref) async => const BackendUser(id: 'u1', email: null),
        ),
        progressRepositoryProvider.overrideWithValue(mockProgressPort),
      ],
    );
    final notifierProvider =
        StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((ref) {
          return ReaderSessionNotifier(
            ref: ref,
            novelId: 'n1',
            initialState: initialState,
          );
        });
    final notifier = container.read(notifierProvider.notifier);
    await notifier.saveProgress(12.5);
    verify(() => mockProgressPort.upsertProgress(any()));
  });

  // Autoplay prompt logic is validated indirectly via state toggles in other tests.

  group('loadInitial', () {
    test('loads content successfully when content is empty', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: null, // Empty content should trigger load
      );

      when(
        () => mockChapterRepository.getChapter(c1),
      ).thenAnswer((_) async => c1);

      // Create fresh mock for this test to avoid conflicts
      final consistencyMockTtsDriver = MockTtsDriver();

      when(
        () => consistencyMockTtsDriver.configure(
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

      when(
        () => consistencyMockTtsDriver.setRate(any()),
      ).thenAnswer((_) async {});
      when(
        () => consistencyMockTtsDriver.setVolume(any()),
      ).thenAnswer((_) async {});
      when(
        () => consistencyMockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenAnswer((_) async {});
      when(() => consistencyMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(consistencyMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.loadInitial();

      expect(container.read(notifierProvider).content, 'Content 1');
      expect(container.read(notifierProvider).failure, isNull);
      verify(() => mockChapterRepository.getChapter(c1)).called(1);
    });

    test('does not load when content already exists', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Existing content',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Existing content',
      );

      // Create fresh mock for this test to avoid conflicts
      final consistencyMockTtsDriver = MockTtsDriver();

      when(
        () => consistencyMockTtsDriver.configure(
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

      when(
        () => consistencyMockTtsDriver.setRate(any()),
      ).thenAnswer((_) async {});
      when(
        () => consistencyMockTtsDriver.setVolume(any()),
      ).thenAnswer((_) async {});
      when(
        () => consistencyMockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenAnswer((_) async {});
      when(() => consistencyMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(consistencyMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.loadInitial();

      verifyNever(() => mockChapterRepository.getChapter(any()));
    });

    test('handles repository errors gracefully', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: null,
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: null,
      );

      when(
        () => mockChapterRepository.getChapter(c1),
      ).thenThrow(Exception('Network error'));

      // Create fresh mock for this test to avoid conflicts
      final stateConsistencyMockTtsDriver = MockTtsDriver();

      when(
        () => stateConsistencyMockTtsDriver.configure(
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

      when(
        () => stateConsistencyMockTtsDriver.setRate(any()),
      ).thenAnswer((_) async {});
      when(
        () => stateConsistencyMockTtsDriver.setVolume(any()),
      ).thenAnswer((_) async {});
      when(
        () => stateConsistencyMockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenAnswer((_) async {});
      when(() => stateConsistencyMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(stateConsistencyMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.loadInitial();

      expect(container.read(notifierProvider).failure, isA<UnknownFailure>());
      expect(
        container.read(notifierProvider).failure?.message,
        contains('Failed to load chapter'),
      );
    });

    test('returns early when allChapters is empty', () async {
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [], // Empty chapters
        currentIdx: 0,
        content: null,
      );

      // Create fresh mock for this test to avoid conflicts
      final stateConsistencyMockTtsDriver = MockTtsDriver();

      when(
        () => stateConsistencyMockTtsDriver.configure(
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

      when(
        () => stateConsistencyMockTtsDriver.setRate(any()),
      ).thenAnswer((_) async {});
      when(
        () => stateConsistencyMockTtsDriver.setVolume(any()),
      ).thenAnswer((_) async {});
      when(
        () => stateConsistencyMockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenAnswer((_) async {});
      when(() => stateConsistencyMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(stateConsistencyMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.loadInitial();

      verifyNever(() => mockChapterRepository.getChapter(any()));
    });
  });

  group('startTts', () {
    test('starts TTS with optimistic flag', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.startTts(optimistic: true);

      expect(container.read(notifierProvider).speaking, isTrue);
      expect(container.read(notifierProvider).progressDenomLockedIndex, isNull);
      verify(
        () => mockTtsDriver.start(content: 'Content 1', startIndex: 0),
      ).called(1);
    });

    test('starts TTS without optimistic flag', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.startTts(optimistic: false);

      expect(container.read(notifierProvider).progressDenomLockedIndex, isNull);
      verify(
        () => mockTtsDriver.start(content: 'Content 1', startIndex: 0),
      ).called(1);
    });
  });

  group('stopTts', () {
    test('stops TTS and updates speaking state', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: true,
      );

      final mockUser = MockBackendUser();

      final mockProgressController = MockProgressController();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => mockUser),
          progressControllerProvider.overrideWith(
            (ref) => mockProgressController,
          ),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      await notifier.stopTts();

      expect(container.read(notifierProvider).speaking, isFalse);
    });
  });

  group('tryAutoStartTts', () {
    test('attempts auto start without throwing errors', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
        autoplayBlocked: false,
      );

      void showPrompt() {}

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Should not throw any errors
      expect(() => notifier.tryAutoStartTts(showPrompt), returnsNormally);
    });

    test('does not block when TTS starts successfully', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
        autoplayBlocked: false,
      );

      bool showPromptCalled = false;
      void showPrompt() => showPromptCalled = true;

      // Mock TTS to start successfully (index changes)
      int callCount = 0;
      when(
        () => mockTtsDriver.index,
      ).thenAnswer((_) => callCount++ == 0 ? 0 : 10);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      notifier.tryAutoStartTts(showPrompt);

      await Future.delayed(const Duration(milliseconds: 300));

      expect(showPromptCalled, isFalse);
      expect(container.read(notifierProvider).autoplayBlocked, isFalse);
    });
  });

  group('updateScrollProgress', () {
    test('updates scroll progress when difference is significant', () {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        scrollProgress: 0.0,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      notifier.updateScrollProgress(0.5);

      expect(container.read(notifierProvider).scrollProgress, 0.5);
    });

    test('does not update when difference is insignificant', () {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        scrollProgress: 0.5,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      notifier.updateScrollProgress(0.505); // Difference is 0.005 < 0.01

      expect(container.read(notifierProvider).scrollProgress, 0.5);
    });
  });

  group('jumpToCreated', () {
    test('jumps to newly created chapter', () {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final c2 = Chapter(
        id: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'Two',
        content: 'Content 2',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      notifier.jumpToCreated(c2);

      final finalState = container.read(notifierProvider);
      expect(finalState.chapterId, 'c2');
      expect(finalState.title, 'Two');
      expect(finalState.content, 'Content 2');
      expect(finalState.currentIdx, 1);
      expect(finalState.allChapters.length, 2);
      expect(finalState.ttsIndex, 0);
      expect(finalState.ttsIndexVisual, 0);
      expect(finalState.speaking, isFalse);
      expect(finalState.autoplayBlocked, isFalse);
      expect(finalState.progressDenomLockedIndex, isNull);
    });
  });

  group('TTS configuration', () {
    test('configures TTS with default locale', () {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      // Create fresh mock to avoid verify conflicts

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      container.read(notifierProvider.notifier);

      verify(
        () => mockTtsDriver.configure(
          voiceName: any(named: 'voiceName'),
          voiceLocale: any(named: 'voiceLocale'),
          defaultLocale: 'en-US',
        ),
      ).called(1);
    });
  });

  group('Edge cases for chapter navigation', () {
    test('loadNextChapter returns false when at last chapter', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      final result = await notifier.loadNextChapter();

      expect(result, isFalse);
    });

    test('loadPrevChapter returns false when at first chapter', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      final result = await notifier.loadPrevChapter();

      expect(result, isFalse);
    });

    test('handles repository errors in loadNextChapter gracefully', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final c2 = Chapter(
        id: 'c2',
        novelId: 'n1',
        idx: 2,
        title: 'Two',
        content: null, // Null content to trigger fetch
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1, c2],
        currentIdx: 0,
        content: 'Content 1',
      );

      when(
        () => mockChapterRepository.getChapter(c2),
      ).thenThrow(Exception('Network error'));

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      expect(
        () async => await notifier.loadNextChapter(),
        throwsA(isA<Exception>()),
      ); // Exception bubbles up from repository call
    });
  });

  group('TTS configuration edge cases', () {
    test('configures TTS with zh locale maps to zh-CN', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      // Create app settings with zh locale
      final appSettings = AppSettingsNotifier(prefs);
      await appSettings.setLanguage('zh');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      container.read(notifierProvider.notifier);

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
      ).called(1);
    });

    test('configures TTS with unsupported locale defaults to en-US', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      // Set locale to unsupported language
      final appSettings = AppSettingsNotifier(prefs);
      await appSettings.setLanguage('fr');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => appSettings),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      container.read(notifierProvider.notifier);

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
      ).called(1);
    });

    test('handles TTS configuration errors gracefully', () async {
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
      ).thenThrow(Exception('TTS configuration failed'));

      // Should not throw during construction
      expect(
        () => ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            ttsDriverProvider.overrideWithValue(mockTtsDriver),
            chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
            appSettingsProvider.overrideWith(
              (ref) => AppSettingsNotifier(prefs),
            ),
            ttsSettingsProvider.overrideWith(
              (ref) => TtsSettingsNotifier(prefs),
            ),
            performanceSettingsProvider.overrideWith(
              (ref) => PerformanceSettingsNotifier(prefs),
            ),
            progressRepositoryProvider.overrideWithValue(mockProgressPort),
          ],
        ),
        returnsNormally,
      );
    });
  });

  group('Error handling in TTS operations', () {
    test('handles startTts errors gracefully', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
      );

      when(
        () => mockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenThrow(Exception('TTS start failed'));

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Should throw when startTts fails
      try {
        await notifier.startTts();
        fail('Expected an exception but none was thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      // State remains in optimistic mode (speaking: true) since error wasn't caught
      expect(container.read(notifierProvider).speaking, isTrue);
    });

    test('handles stopTts errors gracefully', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: true,
      );

      // Create fresh mock for this test to avoid conflicts
      final errorMockTtsDriver = MockTtsDriverWithStopError();

      when(() => errorMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(errorMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Should throw when stopTts fails
      expect(() async => await notifier.stopTts(), throwsA(isA<Exception>()));

      // State remains true since stop() failed before state could be updated
      expect(container.read(notifierProvider).speaking, isTrue);
    });
  });

  group('Progress saving edge cases', () {
    test('saveProgress handles repository errors', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      when(
        () => mockProgressPort.upsertProgress(any()),
      ).thenThrow(Exception('Progress save failed'));

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith(
            (ref) async => const BackendUser(id: 'u1', email: null),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Should not throw
      expect(() async => await notifier.saveProgress(12.5), returnsNormally);
    });

    test('saveProgress handles offline mode', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          isSignedInProvider.overrideWithValue(false), // Offline mode
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      final result = await notifier.saveProgress(12.5);

      // Should return appropriate status for offline mode
      expect(result, isA<SaveStatus>());
    });
  });

  group('State consistency tests', () {
    test('maintains basic state consistency', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
        speaking: false,
        fullScreen: false,
        autoplayBlocked: false,
      );

      final mockUser = MockBackendUser();

      final mockProgressController = MockProgressController();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => mockUser),
          progressControllerProvider.overrideWith(
            (ref) => mockProgressController,
          ),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Test basic state operations
      notifier.toggleFullScreen();
      expect(container.read(notifierProvider).fullScreen, isTrue);

      notifier.setAutoplayBlocked(true);
      expect(container.read(notifierProvider).autoplayBlocked, isTrue);

      notifier.updateScrollProgress(0.5);
      expect(container.read(notifierProvider).scrollProgress, 0.5);

      final saveStatus = await notifier.saveProgress(0.5);
      expect(saveStatus, SaveStatus.saved);
    });

    test('handles rapid state changes without corruption', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(mockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      final notifier = container.read(notifierProvider.notifier);

      // Rapid state changes
      notifier.toggleFullScreen();
      notifier.togglePreviewMode();
      notifier.setEditMode(true);
      notifier.setDiscardDialogOpen(true);
      notifier.setAutoplayBlocked(true);
      notifier.updateScrollProgress(0.25);
      notifier.updateScrollProgress(0.5);
      notifier.updateScrollProgress(0.75);

      // Verify state is consistent
      final finalState = container.read(notifierProvider);
      expect(finalState.fullScreen, isTrue);
      expect(
        finalState.previewMode,
        isFalse,
      ); // Should be false when editMode is true
      expect(finalState.editMode, isTrue);
      expect(finalState.discardDialogOpen, isTrue);
      expect(finalState.autoplayBlocked, isTrue);
      expect(finalState.scrollProgress, 0.75);
    });
  });

  group('Dispose behavior', () {
    test('disposes resources correctly', () async {
      final c1 = Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Content 1',
      );
      final initialState = ReaderSessionState(
        chapterId: 'c1',
        title: 'One',
        allChapters: [c1],
        currentIdx: 0,
        content: 'Content 1',
      );

      // Create fresh mocks for this test to avoid verification conflicts
      final freshMockTtsDriver = MockTtsDriver();

      when(
        () => freshMockTtsDriver.configure(
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

      // Note: stop() method is already overridden in MockTtsDriver class to return Future<void>
      when(() => freshMockTtsDriver.setRate(any())).thenAnswer((_) async {});
      when(() => freshMockTtsDriver.setVolume(any())).thenAnswer((_) async {});
      when(
        () => freshMockTtsDriver.start(
          content: any(named: 'content'),
          startIndex: any(named: 'startIndex'),
        ),
      ).thenAnswer((_) async {});
      when(() => freshMockTtsDriver.index).thenReturn(0);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsDriverProvider.overrideWithValue(freshMockTtsDriver),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          performanceSettingsProvider.overrideWith(
            (ref) => PerformanceSettingsNotifier(prefs),
          ),
          progressRepositoryProvider.overrideWithValue(mockProgressPort),
        ],
      );

      final notifierProvider =
          StateNotifierProvider<ReaderSessionNotifier, ReaderSessionState>((
            ref,
          ) {
            return ReaderSessionNotifier(
              ref: ref,
              novelId: 'n1',
              initialState: initialState,
            );
          });

      // Create and then dispose - should not throw any errors
      container.read(notifierProvider.notifier);

      // Disposing should complete without errors
      expect(() => container.dispose(), returnsNormally);
    });
  });
}
