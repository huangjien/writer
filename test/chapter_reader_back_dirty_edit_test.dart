import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/reader/chapter_reader_screen.dart';
import 'package:writer/features/reader/logic/tts_driver.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/edit_permissions.dart';

import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/novel_providers.dart';

import 'package:mocktail/mocktail.dart';

class MockTtsDriver extends Mock implements TtsDriver {}

class MockAiChatService extends Mock implements AiChatService {}

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockNovelRepository extends Mock implements NovelRepository {}

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
    when(() => mockChapterRepository.getChapter(any())).thenAnswer((inv) async {
      final chapter = inv.positionalArguments[0] as Chapter;
      // Return a chapter with the same ID but ensure it has content
      return Chapter(
        id: chapter.id,
        novelId: chapter.novelId,
        idx: chapter.idx,
        title: chapter.title,
        content: chapter.content ?? 'Default content',
      );
    });

    // Mock NovelRepository
    when(() => mockNovelRepository.getNovel(any())).thenAnswer(
      (_) async => const Novel(
        id: 'n1',
        title: 'Test Novel',
        author: 'author1',
        languageCode: 'en',
        isPublic: true,
      ),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<Chapter> allChapters = const [
      Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'One',
        content: 'Alpha\nBeta',
      ),
    ],
    bool editPermission = true,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => ChapterReaderScreen(
            chapterId: 'c1',
            title: 'One',
            content: 'Alpha\nBeta',
            novelId: 'n1',
            allChapters: allChapters,
            currentIdx: 0,
            autoStartTts: false,
          ),
        ),
        GoRoute(
          path: '/novel/:novelId/chapters/:chapterId/edit',
          builder: (context, state) =>
              const Scaffold(body: Text('Edit Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chapterRepositoryProvider.overrideWithValue(mockChapterRepository),
          novelRepositoryProvider.overrideWithValue(mockNovelRepository),
          editRoleProvider('n1').overrideWith(
            (ref) async => editPermission ? EditRole.owner : EditRole.none,
          ),
          editPermissionsProvider.overrideWith(
            (ref, novelId) async => editPermission,
          ),
          ttsDriverProvider.overrideWith((ref) => mockTtsDriver),
          appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
          aiChatServiceProvider.overrideWith((ref) => mockAiChatService),
          isSignedInProvider.overrideWith((ref) => true),
          authStateProvider.overrideWith((ref) => 'test-session'),
          currentUserProvider.overrideWith((ref) async => null),
          chaptersProvider('n1').overrideWith((ref) async => allChapters),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  testWidgets('ChapterReaderScreen renders correctly', (tester) async {
    await pumpScreen(tester);
    await tester.pump(); // Use pump instead of pumpAndSettle to avoid timeout

    // Verify content is displayed - check for the title and any rich text containing our content
    expect(find.text('One'), findsOneWidget);

    // Check if the content is rendered in any RichText widget
    final richTexts = find.byType(RichText);
    expect(richTexts, findsWidgets);

    // Look for any widget that contains "Alpha" in its text
    bool foundAlpha = false;
    for (final widget in richTexts.evaluate()) {
      final richText = widget.widget as RichText;
      final text = richText.text.toPlainText();
      if (text.contains('Alpha')) {
        foundAlpha = true;
        break;
      }
    }
    expect(foundAlpha, isTrue, reason: 'Should find Alpha in rendered content');

    // Should see edit button
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets('Edit mode toggle works correctly', (tester) async {
    await pumpScreen(tester);
    await tester.pump();

    // Check what icons are available
    final editIcons = find.byIcon(Icons.edit);

    // Should start in reading mode with edit button available
    expect(editIcons, findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    // Enter edit mode
    await tester.tap(editIcons);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Should now be in edit mode (navigated to edit screen)
    expect(find.text('Edit Screen'), findsOneWidget);
  });
}
