import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/editor/mobile_editor_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/shared/widgets/rich_text_toolbar.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

class MockChapterRepository extends Mock implements ChapterRepository {}

class InMemoryStorageService implements StorageService {
  InMemoryStorageService([Map<String, String>? initial])
    : _data = {...?initial};

  final Map<String, String> _data;
  final List<MapEntry<String, String?>> setCalls = [];

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String? value) async {
    setCalls.add(MapEntry(key, value));
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

void main() {
  late MockNovelRepository mockNovelRepository;
  late MockChapterRepository mockChapterRepository;
  late InMemoryStorageService storage;
  late GoRouter router;

  setUp(() {
    mockNovelRepository = MockNovelRepository();
    mockChapterRepository = MockChapterRepository();
    storage = InMemoryStorageService();

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
          path: '/tools',
          name: 'tools',
          builder: (context, state) => const Scaffold(body: Text('Tools')),
        ),
        GoRoute(
          path: '/editor/:novelId',
          builder: (context, state) {
            final novelId = state.pathParameters['novelId']!;
            final chapterId = state.uri.queryParameters['chapterId'];
            return Focus(
              autofocus: true,
              child: MobileEditorScreen(novelId: novelId, chapterId: chapterId),
            );
          },
        ),
      ],
    );
  });

  String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  testWidgets('renders editor with initial UI elements', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
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
            return Focus(
              autofocus: true,
              child: MobileEditorScreen(novelId: novelId, chapterId: chapterId),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
            return Focus(
              autofocus: true,
              child: MobileEditorScreen(novelId: novelId, chapterId: chapterId),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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
          storageServiceProvider.overrideWithValue(storage),
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

  testWidgets('loads writing streak when last write is today', (tester) async {
    final today = dateOnly(DateTime.now());
    storage = InMemoryStorageService({
      'writer.editor.last_write_date': formatDate(today),
      'writer.editor.streak_days': '5',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('5d'), findsOneWidget);
  });

  testWidgets('stale writing streak is not shown', (tester) async {
    final stale = dateOnly(DateTime.now()).subtract(const Duration(days: 3));
    storage = InMemoryStorageService({
      'writer.editor.last_write_date': formatDate(stale),
      'writer.editor.streak_days': '5',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Streak'), findsNothing);
  });

  testWidgets('save records a writing session for non-empty content', (
    tester,
  ) async {
    when(
      () => mockChapterRepository.getNextIdx('novel-1'),
    ).thenAnswer((_) async => 1);
    when(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Hello world',
      ),
    ).thenAnswer(
      (_) async => Chapter(
        id: 'new-chapter',
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Hello world',
      ),
    );

    storage = InMemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
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
      'Hello world',
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    final todayKey = formatDate(dateOnly(DateTime.now()));
    expect(storage.getString('writer.editor.last_write_date'), todayKey);
    expect(storage.getString('writer.editor.streak_days'), '1');
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('1d'), findsOneWidget);
  });

  testWidgets('Ctrl+/ opens keyboard shortcuts sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final contentFieldFinder = find.widgetWithText(
      TextField,
      'Start writing...',
    );
    await tester.tap(contentFieldFinder);
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Ctrl/⌘ + S'), findsOneWidget);
    expect(find.text('Ctrl/⌘ + P'), findsOneWidget);
  });

  testWidgets('Ctrl+S triggers save action', (tester) async {
    when(
      () => mockChapterRepository.getNextIdx('novel-1'),
    ).thenAnswer((_) async => 1);
    when(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Hello world',
      ),
    ).thenAnswer(
      (_) async => Chapter(
        id: 'new-chapter',
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Hello world',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
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
      'Hello world',
    );
    await tester.pump();

    final contentFieldFinder = find.widgetWithText(
      TextField,
      'Start writing...',
    );
    await tester.tap(contentFieldFinder);
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    verify(
      () => mockChapterRepository.createChapter(
        novelId: 'novel-1',
        idx: 1,
        title: 'Chapter 1',
        content: 'Hello world',
      ),
    ).called(1);
  });

  testWidgets('Escape exits preview mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          storageServiceProvider.overrideWithValue(storage),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toolbar = find.byType(RichTextToolbar);
    expect(toolbar, findsOneWidget);
    await tester.tap(
      find.descendant(of: toolbar, matching: find.byIcon(Icons.visibility)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(TextField, 'Chapter Title'));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownBody), findsNothing);
    expect(
      find.byWidgetPredicate((w) => w is TextField && w.expands),
      findsOneWidget,
    );
  });
}
