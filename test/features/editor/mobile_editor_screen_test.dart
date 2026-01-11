import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/editor/mobile_editor_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/novel_providers.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

class MockChapterRepository extends Mock implements ChapterRepository {}

void main() {
  late MockNovelRepository mockNovelRepository;
  late MockChapterRepository mockChapterRepository;
  late GoRouter router;

  setUp(() {
    mockNovelRepository = MockNovelRepository();
    mockChapterRepository = MockChapterRepository();

    router = GoRouter(
      initialLocation: '/editor/novel-1',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('Settings')),
        ),
        GoRoute(
          path: '/novel/:novelId',
          builder: (context, state) =>
              Scaffold(body: Text('Novel ${state.pathParameters['novelId']}')),
        ),
        GoRoute(
          path: '/editor/:novelId',
          builder: (context, state) {
            final novelId = state.pathParameters['novelId']!;
            final chapterId = state.uri.queryParameters['chapterId'];
            return MobileEditorScreen(novelId: novelId, chapterId: chapterId);
          },
        ),
      ],
    );
  });

  testWidgets('renders editor with initial UI elements', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    // Initial loading state (if chapterId is null, it should load immediately)
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2)); // Title and Content
    expect(find.text('Editor'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
  });

  testWidgets('loads chapter content when chapterId is provided', (
    tester,
  ) async {
    final chapter = Chapter(
      id: 'chapter-1',
      novelId: 'novel-1',
      title: 'Chapter 1',
      content: 'Initial content',
      idx: 1,
    );

    when(
      () => mockChapterRepository.getChapter(chapter),
    ).thenAnswer((_) async => chapter);

    router = GoRouter(
      initialLocation: '/editor/novel-1?chapterId=chapter-1',
      routes: [
        GoRoute(
          path: '/editor/:novelId',
          builder: (context, state) {
            final novelId = state.pathParameters['novelId']!;
            final chapterId = state.uri.queryParameters['chapterId'];
            return MobileEditorScreen(novelId: novelId, chapterId: chapterId);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          chaptersProvider('novel-1').overrideWith((ref) async => [chapter]),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Initial content'), findsOneWidget);
  });

  testWidgets('shows unsaved changes badge when content changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unsaved'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Start writing...'),
      'New content',
    );
    await tester.pump();

    expect(find.text('Unsaved'), findsOneWidget);
  });

  testWidgets('saves content successfully', (tester) async {
    when(
      () => mockChapterRepository.getNextIdx('novel-1'),
    ).thenAnswer((_) async => 1);
    when(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'New content',
      ),
    ).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
      return Chapter(
        id: 'new-chapter',
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'New content',
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Chapter Title'),
      'Chapter 1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Start writing...'),
      'New content',
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pump(); // Start saving
    await tester.pump(
      const Duration(milliseconds: 50),
    ); // Advance time slightly

    expect(
      find.byType(CircularProgressIndicator),
      findsAtLeastNWidgets(1),
    ); // Saving indicator inside FAB or at bottom
    expect(find.text('Saving...'), findsOneWidget);

    await tester.pumpAndSettle(); // Finish saving

    verify(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'New content',
      ),
    ).called(1);

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('handles save error', (tester) async {
    when(
      () => mockChapterRepository.getNextIdx('novel-1'),
    ).thenAnswer((_) async => 1);
    when(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'New content',
      ),
    ).thenThrow(Exception('Save failed'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Chapter Title'),
      'Chapter 1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Start writing...'),
      'New content',
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.text('Save failed: Exception: Save failed'), findsOneWidget);
  });

  testWidgets('handles formatting actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Toggle Bold
    await tester.tap(find.byIcon(Icons.format_bold));
    await tester.pump();
    // Verify icon color change or similar visual feedback could be checked,
    // but here we ensure no crash and state update happens.

    // Toggle Italic
    await tester.tap(find.byIcon(Icons.format_italic));
    await tester.pump();

    // Toggle Underline
    await tester.tap(find.byIcon(Icons.format_underlined));
    await tester.pump();

    final contentFieldFinder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.expands,
    );

    // Insert Bullet
    await tester.tap(find.byIcon(Icons.format_list_bulleted));
    await tester.pump();
    final bulletText =
        tester.widget<TextField>(contentFieldFinder).controller?.text ?? '';
    expect(bulletText, startsWith('- '));

    // Insert Numbered List
    await tester.enterText(contentFieldFinder, '$bulletText\n');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.format_list_numbered));
    await tester.pump();
    final numberedText =
        tester.widget<TextField>(contentFieldFinder).controller?.text ?? '';
    expect(numberedText, startsWith('- '));
    expect(numberedText, contains('\n1. '));
  });

  testWidgets('shows more menu and actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Start writing...'),
      'Hello World',
    );
    await tester.pump();

    // Open More Menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Check Word Count
    await tester.tap(find.text('Word Count'));
    await tester.pumpAndSettle();
    expect(find.text('Word count: 2'), findsOneWidget);

    // Wait for snackbar to disappear
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Re-open Menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Check Character Count
    await tester.tap(find.text('Character Count'));
    await tester.pump();
    expect(find.text('Character count: 11'), findsOneWidget);
  });

  testWidgets('discard changes flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Start writing...'),
      'New content',
    );
    await tester.pump();

    // Open More Menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap Discard
    await tester.tap(find.text('Discard Changes'));
    await tester.pumpAndSettle();

    // Verify Dialog
    expect(find.text('Discard Changes?'), findsOneWidget);

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard Changes?'), findsNothing);
    expect(find.text('New content'), findsOneWidget);

    // Open Menu -> Discard again
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard Changes'));
    await tester.pumpAndSettle();

    // Confirm Discard
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    // Content should be cleared (or reverted to initial)
    expect(find.text('New content'), findsNothing);
    expect(find.text('Unsaved'), findsNothing);
  });

  testWidgets('handles load error', (tester) async {
    final chapter = Chapter(
      id: 'chapter-1',
      novelId: 'novel-1',
      title: 'Chapter 1',
      content: 'Initial content',
      idx: 1,
    );

    when(
      () => mockChapterRepository.getChapter(chapter),
    ).thenThrow(Exception('Load failed'));

    router = GoRouter(
      initialLocation: '/editor/novel-1?chapterId=chapter-1',
      routes: [
        GoRoute(
          path: '/editor/:novelId',
          builder: (context, state) {
            final novelId = state.pathParameters['novelId']!;
            final chapterId = state.uri.queryParameters['chapterId'];
            return MobileEditorScreen(novelId: novelId, chapterId: chapterId);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          chaptersProvider('novel-1').overrideWith((ref) async => [chapter]),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Failed to load chapter: Exception: Load failed'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to read mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Read tab
    await tester.tap(
      find.byIcon(Icons.book_outlined),
    ); // MobileNavTab.read icon
    await tester.pumpAndSettle();
    expect(find.text('Novel novel-1'), findsOneWidget);
  });

  testWidgets('content text field is left aligned and top aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final textFieldFinder = find.widgetWithText(TextField, 'Start writing...');
    expect(textFieldFinder, findsOneWidget);

    final TextField textField = tester.widget(textFieldFinder);
    expect(textField.textAlign, TextAlign.left);
    expect(textField.textAlignVertical, TextAlignVertical.top);
  });

  testWidgets('zen mode shows ZenModeBar and can exit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zen mode'), findsNothing);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Chapter Title'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zen mode'));
    await tester.pumpAndSettle();

    expect(find.text('Zen mode'), findsOneWidget);
    expect(find.text('Editor'), findsNothing);
    expect(find.widgetWithText(TextField, 'Chapter Title'), findsNothing);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Preview'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Exit preview'), findsOneWidget);

    await tester.tap(find.byTooltip('Exit preview'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Preview'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Exit Zen mode'));
    await tester.pumpAndSettle();

    expect(find.text('Zen mode'), findsNothing);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Chapter Title'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsOneWidget,
    );
  });

  testWidgets('focus timer action opens FocusTimerSheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Focus timer'));
    await tester.pumpAndSettle();

    expect(find.text('Focus timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('writing prompts inserts selected prompt into content', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    const prompt = 'Write a scene where a small mistake changes everything.';
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Writing prompts'));
    await tester.pumpAndSettle();

    expect(find.text('Writing prompts'), findsOneWidget);
    expect(find.text('Pick a prompt to insert'), findsOneWidget);

    await tester.tap(find.text(prompt));
    await tester.pumpAndSettle();

    final contentFieldFinder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.expands,
    );
    final inserted =
        tester.widget<TextField>(contentFieldFinder).controller?.text ?? '';
    expect(inserted, startsWith('$prompt\n\n'));
  });
}
