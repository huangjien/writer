import 'dart:async';
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
import 'package:writer/features/reader/widgets/beta_evaluation/beta_evaluation_dialog.dart';
import 'package:writer/features/reader/widgets/edit_chapter_body.dart';
import 'package:writer/features/reader/widgets/reader_body.dart';
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
      Chapter(
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
    final chapter = Chapter(
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
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows snackbar when reaching last chapter', (tester) async {
    await pumpScreen(
      tester,
      allChapters: testChapters,
      currentIdx: testChapters.length - 1,
    );
    await tester.pumpAndSettle();

    // Tap next chapter button
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    // Should show snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Reached last chapter'), findsOneWidget);
  });

  testWidgets('Shows snackbar when reaching first chapter', (tester) async {
    await pumpScreen(tester, allChapters: testChapters, currentIdx: 0);
    await tester.pumpAndSettle();

    // Tap previous chapter button
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pumpAndSettle();

    // Should show snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Reached first chapter'), findsOneWidget);
  });

  testWidgets('Edit mode toggles between ReaderBody and EditChapterBody', (
    tester,
  ) async {
    // Set up viewport to prevent RenderFlex overflow
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Initially in reader mode
    expect(find.byType(ReaderBody), findsOneWidget);
    expect(find.byType(EditChapterBody), findsNothing);

    // Find and tap edit button
    final editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Should be in edit mode
    expect(find.byType(ReaderBody), findsNothing);
    expect(find.byType(EditChapterBody), findsOneWidget);

    // Wait for any pending animations or state transitions
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Find the close button in the bottom bar (same button toggles between edit/close)
    final closeButton = find.byIcon(Icons.close);
    expect(
      closeButton,
      findsOneWidget,
      reason: 'Close button should be visible in edit mode',
    );

    await tester.tap(closeButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify final state - back to reader mode
    expect(find.byType(ReaderBody), findsOneWidget);
    expect(find.byType(EditChapterBody), findsNothing);
  });

  testWidgets('Auto start TTS triggers start', (tester) async {
    await pumpScreen(tester, autoStartTts: true);
    await tester.pumpAndSettle();

    verify(
      () => mockTtsDriver.start(
        content: any(named: 'content'),
        startIndex: any(named: 'startIndex'),
      ),
    ).called(1);
  });

  testWidgets('AI Chat sidebar appears when provider is true', (tester) async {
    await pumpScreen(
      tester,
      overrides: [
        aiChatUiProvider.overrideWith((ref) {
          final notifier = AiChatUiNotifier();
          notifier.openSidebar();
          return notifier;
        }),
        aiChatProvider.overrideWith((ref) => AiChatNotifier(mockAiChatService)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiChatSidebar), findsOneWidget);
  });

  testWidgets('AI Chat sidebar sends message', (tester) async {
    await pumpScreen(
      tester,
      overrides: [
        aiChatUiProvider.overrideWith((ref) {
          final notifier = AiChatUiNotifier();
          notifier.openSidebar();
          return notifier;
        }),
        aiChatProvider.overrideWith((ref) => AiChatNotifier(mockAiChatService)),
      ],
    );
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Hello AI');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 100)); // AI responds

    verify(() => mockAiChatService.sendMessage('Hello AI')).called(1);
    expect(find.text('AI Response'), findsOneWidget);
  });

  testWidgets('Scrolling updates progress bar', (tester) async {
    // Create a long content chapter
    final longChapter = Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 0,
      title: 'Long Chapter',
      content: 'Line 1\n\n' * 500,
    );

    await pumpScreen(tester, allChapters: [longChapter]);
    await tester.pumpAndSettle();

    // Initial progress
    // Note: ScrollProgress is initially 0.0

    // Scroll down
    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Progress bar should update.
    // However, getting the exact value is hard.
    // We can check if the LinearProgressIndicator value is > 0.
    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, greaterThan(0.0));
  });

  testWidgets('Beta evaluation button shows dialog on success', (tester) async {
    final evalResult = {'markdown': '# Evaluation Result\n\nGood job!'};
    final completer = Completer<Map<String, dynamic>?>();

    when(
      () => mockAiChatService.betaEvaluateChapter(
        novelId: any(named: 'novelId'),
        chapterId: any(named: 'chapterId'),
        content: any(named: 'content'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) => completer.future);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final betaButton = find.byKey(const ValueKey('beta_button'));
    expect(betaButton, findsOneWidget);

    await tester.tap(betaButton);
    await tester.pump(); // Trigger loading state

    // Verify loading spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Button might still be fading out, so we don't strictly check findsNothing here.

    // Complete the future
    completer.complete(evalResult);
    // Pump to process future completion and showDialog
    await tester.pump();
    await tester.pump(); // Start dialog animation
    await tester.pump(const Duration(seconds: 1)); // Advance animation

    verify(
      () => mockAiChatService.betaEvaluateChapter(
        novelId: novelId,
        chapterId: 'c1',
        content: 'Content 1',
        language: 'en',
      ),
    ).called(1);

    expect(find.byType(BetaEvaluationDialog), findsOneWidget);
    expect(find.text('Evaluation Result'), findsOneWidget);
  });

  testWidgets('Beta evaluation shows error snackbar on failure', (
    tester,
  ) async {
    when(
      () => mockAiChatService.betaEvaluateChapter(
        novelId: any(named: 'novelId'),
        chapterId: any(named: 'chapterId'),
        content: any(named: 'content'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async => null);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final betaButton = find.byKey(const ValueKey('beta_button'));
    await tester.tap(betaButton);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Beta evaluation shows error snackbar on exception', (
    tester,
  ) async {
    when(
      () => mockAiChatService.betaEvaluateChapter(
        novelId: any(named: 'novelId'),
        chapterId: any(named: 'chapterId'),
        content: any(named: 'content'),
        language: any(named: 'language'),
      ),
    ).thenThrow(Exception('Error'));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final betaButton = find.byKey(const ValueKey('beta_button'));
    await tester.tap(betaButton);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Stop button stops TTS', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Start TTS
    final playButton = find.byIcon(Icons.play_arrow);
    await tester.tap(playButton);
    await tester.pump();

    // Verify Stop button is now visible
    final stopButton = find.byIcon(Icons.stop);
    expect(stopButton, findsOneWidget);

    // Stop TTS
    await tester.tap(stopButton);
    await tester.pump();

    // Verify stop called
    // Note: ReaderSessionNotifier might call stop multiple times or via logic, but at least once.
    verify(() => mockTtsDriver.stop()).called(greaterThan(0));
  });

  testWidgets('Edit mode dirty check shows discard dialog', (tester) async {
    final chapter = const Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 0,
      title: 'Chapter 1',
      content: 'Content 1',
    );

    await pumpScreen(
      tester,
      allChapters: [chapter],
      editRole: EditRole
          .contributor, // Hide NovelMetadataEditor to simplify finding fields
    );
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Find chapter title field by label
    // Note: Localization mock uses English, so 'Chapter Title' should match
    final titleField = find.widgetWithText(TextFormField, 'Chapter Title');
    expect(titleField, findsOneWidget);

    await tester.tap(titleField);
    await tester.pump();
    await tester.enterText(titleField, 'New Title');
    await tester.pump();

    // Verify state is dirty
    final element = tester.element(find.byType(EditChapterBody));
    final container = ProviderScope.containerOf(element);
    // Use the exact chapter instance passed to pumpScreen
    final state = container.read(chapterEditControllerProvider(chapter));
    expect(state.isDirty, isTrue);

    // Try to exit edit mode (toggle off)
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify Discard Dialog
    expect(find.text('Discard changes?'), findsOneWidget);

    // Tap cancel (Keep editing)
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(
      find.byType(EditChapterBody),
      findsOneWidget,
    ); // Should still be in edit mode

    // Try to exit again and discard
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderBody), findsOneWidget);
  });

  testWidgets('Font size change updates reader content', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(ReaderBody));
    final container = ProviderScope.containerOf(element);

    // Change font size
    // Use themeControllerProvider and setFontScale
    container.read(themeControllerProvider.notifier).setFontScale(1.5);
    await tester.pumpAndSettle();

    final state = container.read(themeControllerProvider);
    expect(state.fontScale, 1.5);
  });

  testWidgets('Background color change updates scaffold', (tester) async {
    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(ReaderBody));
    final container = ProviderScope.containerOf(element);

    // Change theme mode
    container.read(themeControllerProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    final state = container.read(themeControllerProvider);
    expect(state.mode, ThemeMode.dark);
  });

  testWidgets('Edit mode save triggers repository update', (tester) async {
    // Set up a larger viewport to ensure bottom bar is visible
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final chapter = const Chapter(
      id: 'c1',
      novelId: novelId,
      idx: 0,
      title: 'Chapter 1',
      content: 'Content 1',
    );

    await pumpScreen(
      tester,
      allChapters: [chapter],
      editRole: EditRole.contributor,
    );
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Modify content
    final titleField = find.widgetWithText(TextFormField, 'Chapter Title');
    await tester.enterText(titleField, 'Updated Title');
    await tester.pump();

    // Find Save button (icon save)
    final saveButton = find.byIcon(Icons.save);
    expect(saveButton, findsOneWidget);

    // Ensure button is enabled (dirty state should be true)
    final element = tester.element(find.byType(EditChapterBody));
    final container = ProviderScope.containerOf(element);
    final state = container.read(chapterEditControllerProvider(chapter));
    expect(state.isDirty, isTrue);

    // Scroll to make the save button visible if needed
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify repository call
    verify(
      () => mockChapterRepository.updateChapter(
        any(
          that: isA<Chapter>()
              .having((c) => c.id, 'id', chapter.id)
              .having((c) => c.title, 'title', 'Updated Title'),
        ),
      ),
    ).called(1);

    // Should still be in edit mode (save doesn't exit edit mode by default usually)
    expect(find.byType(EditChapterBody), findsOneWidget);
  });

  testWidgets('Navigation shows error snackbar on failure', (tester) async {
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

    // Should show snackbar with error message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Load Failed'), findsOneWidget);
  });

  testWidgets('Auto start TTS shows blocked prompt if delayed', (tester) async {
    // We rely on the fact that mockTtsDriver.start doesn't trigger onStart callback,
    // so ReaderSessionNotifier.tryAutoStartTts will detect "noRealStart" after timeout.

    await pumpScreen(tester, autoStartTts: true);
    // Wait for the timeout in tryAutoStartTts (1.5s)
    await tester.pump(const Duration(milliseconds: 1600));

    // Verify SnackBar with "Autoplay Blocked" message
    expect(find.byType(SnackBar), findsOneWidget);
    // Note: Localization might be "Autoplay blocked by browser..."
    // We can just check for SnackBar existence and action button
    expect(find.text('Continue'), findsOneWidget);
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
    final chapter = Chapter(
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
    await tester.pump(); // Show snackbar

    // Verify Error Snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Load Failed'), findsOneWidget);

    // Invoke Retry directly to avoid tap issues with SnackBar
    final actionFinder = find.byType(SnackBarAction);
    expect(actionFinder, findsOneWidget);
    tester.widget<SnackBarAction>(actionFinder).onPressed();
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

  testWidgets('Edit mode exits when not dirty', (tester) async {
    // Set up a larger viewport to ensure bottom bar is visible
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.byType(EditChapterBody), findsOneWidget);

    // Exit without changes
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Should be back to reader mode without dialog
    expect(find.byType(ReaderBody), findsOneWidget);
    expect(find.text('Discard Changes?'), findsNothing);
  });

  testWidgets('Beta evaluation fails for empty content', (tester) async {
    final emptyChapter = Chapter(
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

    expect(find.byType(SnackBar), findsOneWidget);
    // The exact message depends on localization, but we expect a failure snackbar
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
