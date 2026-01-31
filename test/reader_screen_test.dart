import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/mock_providers.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

void main() {
  const novelId = 'novel-001';
  final mockChapters = [
    const Chapter(
      id: 'chap-1',
      novelId: novelId,
      idx: 1,
      title: 'First Chapter',
      content: 'Content 1',
    ),
    const Chapter(
      id: 'chap-2',
      novelId: novelId,
      idx: 2,
      title: 'Second Chapter',
      content: 'Content 2',
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  List<dynamic> createCommonProviderOverrides(SharedPreferences prefs) {
    final appSettings = AppSettingsNotifier(prefs);
    final ttsSettings = TtsSettingsNotifier(prefs);
    final motion = MotionSettingsNotifier(prefs);
    final storageService = LocalStorageService(prefs);

    return [
      sharedPreferencesProvider.overrideWithValue(prefs),
      localStorageRepositoryProvider.overrideWithValue(
        LocalStorageRepository(storageService),
      ),
      sessionProvider.overrideWith((ref) => SessionNotifier(storageService)),
      appSettingsProvider.overrideWith((ref) => appSettings),
      ttsSettingsProvider.overrideWith((ref) => ttsSettings),
      motionSettingsProvider.overrideWith((ref) => motion),
      remoteRepositoryProvider.overrideWith(
        (ref) => RemoteRepository('http://localhost:5600/'),
      ),
      aiChatServiceProvider.overrideWith(
        (ref) => AiChatService(ref.read(remoteRepositoryProvider)),
      ),
    ];
  }

  Future<void> pumpReaderScreen(
    WidgetTester tester, {
    required List<Chapter> chapters,
    bool isLoading = false,
    Object? error,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          if (isLoading)
            mockChaptersProvider(
              novelId,
            ).overrideWith((ref) => Future.any([])), // Never completes
          if (isLoading)
            chaptersProviderV2(novelId).overrideWith((ref) => Future.any([])),
          if (error != null)
            mockChaptersProvider(
              novelId,
            ).overrideWith((ref) => Future.error(error)),
          if (error != null)
            chaptersProviderV2(
              novelId,
            ).overrideWith((ref) => Future.error(error)),
          if (!isLoading && error == null)
            mockChaptersProvider(
              novelId,
            ).overrideWith((ref) => Future.value(chapters)),
          if (!isLoading && error == null)
            chaptersProviderV2(
              novelId,
            ).overrideWith((ref) => Future.value(chapters)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId),
        ),
      ),
    );
  }

  testWidgets('ReaderScreen shows loading indicator initially', (tester) async {
    // We can't easily simulate "loading then done" with FutureProvider overrides in one pump
    // without using a Completer or just simulating "stuck in loading".
    // Or we can just rely on the fact that FutureProvider is async.

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...createCommonProviderOverrides(prefs),
          mockChaptersProvider(novelId).overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return mockChapters;
          }),
          chaptersProviderV2(novelId).overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return mockChapters;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReaderScreen(novelId: novelId),
        ),
      ),
    );

    // Should be loading initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish loading
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Title is split into "Chapter 1" and "First Chapter" widgets
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('First Chapter'), findsOneWidget);
  });

  testWidgets('ReaderScreen shows list of chapters', (tester) async {
    await pumpReaderScreen(tester, chapters: mockChapters);
    await tester.pumpAndSettle();

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('First Chapter'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('Second Chapter'), findsOneWidget);
  });

  testWidgets('ReaderScreen shows empty state when no chapters', (
    tester,
  ) async {
    await pumpReaderScreen(tester, chapters: []);
    await tester.pumpAndSettle();

    // The code says: if (chapters.isEmpty) return Center(child: Text(l10n.noChaptersFound));
    // l10n.noChaptersFound is "No chapters found." (with period)
    expect(find.text('No chapters found.'), findsOneWidget);
  });

  testWidgets('ReaderScreen shows error message', (tester) async {
    await pumpReaderScreen(tester, chapters: [], error: 'Network Error');
    await tester.pumpAndSettle();

    // Code: Text('${l10n.error}: $e')
    // English l10n.error is "Error".
    expect(find.text('Error: Network Error'), findsOneWidget);
  });

  testWidgets('Tapping a chapter navigates to ChapterReaderScreen', (
    tester,
  ) async {
    await pumpReaderScreen(tester, chapters: mockChapters);
    await tester.pumpAndSettle();

    // Tap the first chapter's title text
    await tester.tap(find.text('First Chapter'));
    await tester.pumpAndSettle();

    // Should fallback to MaterialPageRoute push and show ChapterReaderScreen
    // ChapterReaderScreen title is usually the chapter title.
    // In the code: title: c.title ?? '${l10n.chapter} ${c.idx}'
    // For first chapter: "First Chapter"

    // We look for the title in the AppBar or body of ChapterReaderScreen.
    // Note: ChapterReaderScreen also uses a Scaffold/AppBar likely.
    expect(find.text('First Chapter'), findsOneWidget);

    // Also verify content is present to be sure
    expect(find.text('Content 1'), findsOneWidget);
  });

  testWidgets(
    'ReaderScreen with chapterId renders ChapterReaderScreen directly',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...createCommonProviderOverrides(prefs),
            mockChaptersProvider(
              novelId,
            ).overrideWith((ref) => Future.value(mockChapters)),
            chaptersProviderV2(
              novelId,
            ).overrideWith((ref) => Future.value(mockChapters)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Pass chapterId to render ChapterReaderScreen directly
            home: ReaderScreen(novelId: novelId, chapterId: 'chap-2'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show second chapter directly
      expect(find.text('Second Chapter'), findsOneWidget);
      expect(find.text('Content 2'), findsOneWidget);
    },
  );
}
