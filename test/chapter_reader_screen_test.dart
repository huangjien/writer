import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_sidebar.dart';
import 'package:writer/shared/widgets/error_view.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/common/errors/failures.dart';

class MockTtsDriver extends Mock implements TtsDriver {}

class MockAiChatService extends Mock implements AiChatService {}

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockNovelRepository extends Mock implements NovelRepository {}

class FakeChapter extends Fake implements Chapter {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Chapter(
        id: 'fallback',
        novelId: 'fallback',
        idx: 0,
        title: 'Fallback',
        content: 'Fallback',
      ),
    );
  });

  late MockTtsDriver mockTtsDriver;
  late MockAiChatService mockAiChatService;
  late MockChapterRepository mockChapterRepository;
  late MockNovelRepository mockNovelRepository;
  late SharedPreferences prefs;

  const novelId = 'novel-1';
  const chapterId = 'chapter-1';
  const chapterTitle = 'Test Chapter';
  const chapterContent = 'This is the content of the chapter.';

  final testChapters = List.generate(
    3,
    (i) => Chapter(
      id: 'chapter-${i + 1}',
      novelId: novelId,
      idx: i,
      title: 'Chapter ${i + 1}',
      content: 'Content ${i + 1}',
    ),
  );

  setUp(() async {
    mockTtsDriver = MockTtsDriver();
    mockAiChatService = MockAiChatService();
    mockChapterRepository = MockChapterRepository();
    mockNovelRepository = MockNovelRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Mock TtsDriver defaults
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
    when(() => mockTtsDriver.pause()).thenAnswer((_) async {});
    when(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).thenAnswer((_) async {});

    // Mock properties
    when(() => mockTtsDriver.speaking).thenReturn(false);
    when(() => mockTtsDriver.index).thenReturn(0);

    // Mock AiChatService
    when(() => mockAiChatService.checkHealth()).thenAnswer((_) async => true);
    when(
      () => mockAiChatService.sendMessage(any()),
    ).thenAnswer((_) async => 'AI Response');
    when(() => mockAiChatService.embed(any())).thenAnswer((_) async => []);

    // Mock ChapterRepository
    when(
      () => mockChapterRepository.updateChapter(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockChapterRepository.getChapter(any()),
    ).thenAnswer((inv) async => inv.positionalArguments[0] as Chapter);

    // Mock NovelRepository
    when(() => mockNovelRepository.getNovel(any())).thenAnswer(
      (_) async => const Novel(
        id: novelId,
        title: 'Test Novel',
        author: 'author1',
        languageCode: 'en',
        isPublic: true,
      ),
    );
    when(
      () => mockNovelRepository.updateNovelMetadata(
        any(),
        title: any(named: 'title'),
        description: any(named: 'description'),
        coverUrl: any(named: 'coverUrl'),
        languageCode: any(named: 'languageCode'),
        isPublic: any(named: 'isPublic'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {});

  Future<void> pumpScreen(
    WidgetTester tester, {
    List overrides = const [],
    List<Chapter>? allChapters,
    bool editPermission = true,
    bool autoStartTts = false,
    int currentIdx = 0,
    double initialOffset = 0.0,
    ChapterEditController Function(Ref ref, Chapter chapter)?
    editControllerBuilder,
    EditRole? editRole,
  }) async {
    final chapters =
        allChapters ??
        [
          const Chapter(
            id: 'c1',
            novelId: novelId,
            idx: 0,
            title: 'Chapter 1',
            content: 'Content 1',
          ),
        ];

    final currentChapter = chapters.isNotEmpty
        ? (currentIdx < chapters.length ? chapters[currentIdx] : chapters.first)
        : chapters.first;

    final router = GoRouter(
      initialLocation: '/reader',
      routes: [
        GoRoute(
          path: '/reader',
          builder: (context, state) => ChapterReaderScreen(
            novelId: novelId,
            chapterId: currentChapter.id,
            title: currentChapter.title ?? '',
            content: currentChapter.content,
            allChapters: chapters,
            currentIdx: currentIdx,
            autoStartTts: autoStartTts,
            initialOffset: initialOffset,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Screen Test')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          editRoleProvider(novelId).overrideWith(
            (ref) async =>
                editRole ?? (editPermission ? EditRole.owner : EditRole.none),
          ),
          ttsDriverProvider.overrideWith((ref) => mockTtsDriver),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          aiChatServiceProvider.overrideWith((ref) => mockAiChatService),
          isSignedInProvider.overrideWith((ref) => true),
          authStateProvider.overrideWith((ref) => 'test-session'),
          currentUserProvider.overrideWith((ref) async => null),
          // Ensure we have chapters
          chaptersProvider(novelId).overrideWith((ref) async => chapters),
          if (editControllerBuilder != null)
            chapterEditControllerProvider.overrideWith(editControllerBuilder),
          ...overrides,
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('ChapterReaderScreen renders title and content', (tester) async {
    final chapter = const Chapter(
      id: chapterId,
      novelId: novelId,
      idx: 0,
      title: chapterTitle,
      content: chapterContent,
    );
    await pumpScreen(
      tester,
      allChapters: [chapter],
      editControllerBuilder: (ref, c) {
        // Only return spy for our chapter
        if (c == chapter) {
          // return SpyChapterEditController(c, mockChapterRepository, mockAiChatService);
        }
        return ChapterEditController(c, mockChapterRepository);
      },
    );
    await tester.pumpAndSettle();

    expect(find.text(chapterTitle), findsOneWidget);
    expect(find.text(chapterContent), findsOneWidget);
  });

  testWidgets('Play button starts TTS', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final playButton = find.byIcon(Icons.play_arrow);
    expect(playButton, findsOneWidget);

    await tester.tap(playButton);
    await tester.pump();

    verify(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).called(1);
  });

  testWidgets('Shows bottom bar controls', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    expect(find.byIcon(Icons.speed), findsOneWidget);
    expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
  });

  testWidgets('Edit button visible when permissions allow', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Edit button hidden when permissions deny', (tester) async {
    await pumpScreen(tester, editPermission: false);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsNothing);
  });

  testWidgets('Progress bar visible in view mode', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Progress bar should be visible
    expect(
      find.byKey(const ValueKey('reader_bottom_progress_bar')),
      findsOneWidget,
    );
  });

  testWidgets('Shows toast when reaching last chapter', (tester) async {
    await pumpScreen(
      tester,
      allChapters: testChapters,
      currentIdx: testChapters.length - 1,
    );
    await tester.pumpAndSettle();

    // Tap next chapter button
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    expect(find.text('Reached last chapter'), findsOneWidget);
  });

  testWidgets('Shows toast when reaching first chapter', (tester) async {
    await pumpScreen(tester, allChapters: testChapters, currentIdx: 0);
    await tester.pumpAndSettle();

    // Tap previous chapter button
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pumpAndSettle();

    expect(find.text('Reached first chapter'), findsOneWidget);
  });

  testWidgets('Navigation shows error toast on failure', (tester) async {
    // Setup chapters where the second one needs fetching (null content)
    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: novelId,
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
      ),
      const Chapter(
        id: 'c2',
        novelId: novelId,
        idx: 1,
        title: 'Chapter 2',
        content: null, // Force fetch
      ),
    ];

    // Mock failure for next chapter fetch
    when(
      () => mockChapterRepository.getChapter(any()),
    ).thenThrow(const UnknownFailure('Load Failed'));

    await pumpScreen(tester, allChapters: chapters);
    await tester.pumpAndSettle();

    // Tap next chapter button
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump(); // Start navigation
    await tester.pump(); // Process error handling

    expect(find.text('Load Failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Auto start TTS shows blocked prompt if delayed', (tester) async {
    // We rely on the fact that mockTtsDriver.start doesn't trigger onStart callback,
    // so ReaderSessionNotifier.tryAutoStartTts will detect "noRealStart" after timeout.

    await pumpScreen(tester, autoStartTts: true);
    // Wait for the timeout in tryAutoStartTts (1.5s)
    await tester.pump(const Duration(milliseconds: 1600));

    // Verify toast action button
    expect(find.text('Continue'), findsWidgets);
  });

  testWidgets('Initial offset triggers scroll', (tester) async {
    await pumpScreen(tester, initialOffset: 100.0);
    await tester.pumpAndSettle();
    // Verify no crash and code path execution
  });

  testWidgets('Error view retry reloads', (tester) async {
    // Make repo fail so loadInitial fails and sets error state
    when(
      () => mockChapterRepository.getChapter(any()),
    ).thenThrow(const UnknownFailure('Initial Error'));

    // We pass empty content so loadInitial runs
    final chapter = const Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 0,
      title: 'Chapter 1',
      content: '', // Empty content triggers load
    );

    await pumpScreen(tester, allChapters: [chapter]);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    // We expect the message from the failure
    expect(find.text('Initial Error'), findsOneWidget);

    // Reset repo to succeed
    when(
      () => mockChapterRepository.getChapter(any()),
    ).thenAnswer((_) async => chapter.copyWith(content: 'Loaded Content'));

    // Tap retry
    final retryFinder = find.text('Retry');
    if (retryFinder.evaluate().isNotEmpty) {
      await tester.tap(retryFinder);
    } else {
      await tester.tap(find.byType(ElevatedButton));
    }
    await tester.pumpAndSettle();

    // Should show content now
    expect(find.text('Loaded Content'), findsOneWidget);
  });

  testWidgets('Navigation error retry works', (tester) async {
    // Setup chapters where the second one needs fetching
    final chapters = [
      const Chapter(
        id: 'c1',
        novelId: novelId,
        idx: 0,
        title: 'Chapter 1',
        content: 'Content 1',
      ),
      const Chapter(
        id: 'c2',
        novelId: novelId,
        idx: 1,
        title: 'Chapter 2',
        content: null, // Force fetch
      ),
    ];

    // First attempt fails
    int callCount = 0;
    when(() => mockChapterRepository.getChapter(any())).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) throw const UnknownFailure('Load Failed');
      return const Chapter(
        id: 'c2',
        novelId: novelId,
        idx: 1,
        title: 'Chapter 2',
        content: 'Content 2',
      );
    });

    await pumpScreen(tester, allChapters: chapters);
    await tester.pumpAndSettle();

    // Tap next chapter button (Fail)
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump(); // Start nav
    await tester.pump(); // Show toast
    await tester.pump(
      const Duration(milliseconds: 300),
    ); // Wait for toast animation

    // Verify Error Toast
    expect(find.text('Load Failed'), findsOneWidget);

    // Find the retry button - try both widgetWithText and direct text finder
    final retryFinder = find.text('Retry');
    expect(retryFinder, findsOneWidget);
    await tester.tap(retryFinder);
    await tester.pumpAndSettle();

    // Should now be on Chapter 2
    expect(find.text('Content 2'), findsOneWidget);
  });

  testWidgets('Method channel controls trigger actions', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    const channel = MethodChannel('com.huangjien.novel/media_control');

    // Test Play
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('play')),
      (ByteData? data) {},
    );
    await tester.pump();
    verify(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).called(1);

    // Test Pause/Stop
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('pause')),
      (ByteData? data) {},
    );
    await tester.pump();
    verify(() => mockTtsDriver.stop()).called(greaterThan(0));

    // Test Next
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('next')),
      (ByteData? data) {},
    );
    await tester.pumpAndSettle();
    // Should try to load next chapter. Since we only have 1 chapter in default pumpScreen, it shows "Reached last chapter".
    expect(find.text('Reached last chapter'), findsOneWidget);
  });

  testWidgets('Beta evaluation fails for empty content', (tester) async {
    final emptyChapter = const Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 0,
      title: 'Empty',
      content: '   ', // Empty or whitespace
    );
    await pumpScreen(tester, allChapters: [emptyChapter]);
    await tester.pumpAndSettle();

    final betaButton = find.byKey(const ValueKey('beta_button'));
    await tester.tap(betaButton);
    await tester.pumpAndSettle();

    expect(find.text('Beta evaluation failed'), findsOneWidget);
  });

  testWidgets('AI Chat sidebar closes on outside tap', (tester) async {
    // Initialize notifier with sidebar open
    final chatNotifier = AiChatUiNotifier();
    chatNotifier.openSidebar();

    await pumpScreen(
      tester,
      overrides: [
        aiChatUiProvider.overrideWith((ref) => chatNotifier),
        aiChatProvider.overrideWith((ref) => AiChatNotifier(mockAiChatService)),
      ],
    );
    await tester.pumpAndSettle();

    // Verify sidebar is present
    expect(find.byType(AiChatSidebar), findsOneWidget);

    // Tap the center of the screen (which should be the scrim)
    // The sidebar is on the right, so (100, 100) hits the scrim on the left
    await tester.tapAt(const Offset(100, 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify sidebar is gone
    expect(find.byType(AiChatSidebar), findsNothing);
    expect(chatNotifier.state, false);
  });
}
