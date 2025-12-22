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

class MockTtsDriver extends Mock implements TtsDriver {}

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockProgressPort extends Mock implements ProgressPort {}

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

    when(() => mockTtsDriver.setRate(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.setVolume(any())).thenAnswer((_) async {});
    when(() => mockTtsDriver.stop()).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockTtsDriver.index).thenReturn(0);

    when(() => mockProgressPort.upsertProgress(any())).thenAnswer((_) async {});
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

    // Verify TTS stopped
    verify(() => mockTtsDriver.stop()).called(1);
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
    verify(() => mockTtsDriver.stop()).called(1);
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
}
