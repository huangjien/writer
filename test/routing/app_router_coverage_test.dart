import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/about/about_screen.dart';
import 'package:writer/features/admin/admin_logs_screen.dart';
import 'package:writer/features/auth/screens/forgot_password_screen.dart';
import 'package:writer/features/auth/screens/reset_password_screen.dart';
import 'package:writer/features/auth/screens/sign_in_screen.dart';
import 'package:writer/features/auth/screens/sign_up_screen.dart';
import 'package:writer/features/auth/screens/user_management_screen.dart';
import 'package:writer/features/library/screens/create_novel_screen.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/features/library/screens/my_novels_screen.dart';
import 'package:writer/features/editor/screens/mobile_editor_screen.dart';
import 'package:writer/features/reader/novel_metadata_editor.dart';
import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/features/settings/screens/settings_screen.dart';
import 'package:writer/features/settings/screens/token_usage_history_screen.dart';
import 'package:writer/features/summary/screens/characters/character_templates_list_screen.dart';
import 'package:writer/features/summary/screens/characters/character_templates_screen.dart';
import 'package:writer/features/summary/screens/characters/characters_list_screen.dart';
import 'package:writer/features/summary/screens/characters/characters_screen.dart';
import 'package:writer/features/summary/screens/scenes/scene_templates_list_screen.dart';
import 'package:writer/features/summary/screens/scenes/scene_templates_screen.dart';
import 'package:writer/features/summary/screens/scenes/scenes_list_screen.dart';
import 'package:writer/features/summary/screens/scenes/scenes_screen.dart';
import 'package:writer/features/summary/screens/summary_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/character_note.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/pattern.dart';
import 'package:writer/models/prompt.dart';
import 'package:writer/models/scene_note.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/models/user.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/user_repository.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/screens/pattern_form_screen.dart';
import 'package:writer/screens/patterns_list_screen.dart';
import 'package:writer/screens/prompt_form_screen.dart';
import 'package:writer/screens/prompts_list_screen.dart';
import 'package:writer/screens/story_line_form_screen.dart';
import 'package:writer/screens/story_lines_list_screen.dart';
import 'package:writer/services/patterns_service.dart';
import 'package:writer/services/prompts_service.dart';
import 'package:writer/services/story_lines_service.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/navigator_key_provider.dart';
import 'package:writer/state/novel_providers_v2.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/state/ui_style_controller.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/state/sync_service_provider.dart';
import 'package:writer/models/sync_state.dart';
import 'package:flutter/services.dart';

// Fakes
class FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<User?> fetchUser(String sessionId) async => null;
}

class FakeRemoteRepository extends Fake implements RemoteRepository {}

class FakeNovelRepository extends Fake implements NovelRepository {
  @override
  Future<List<Summary>> fetchSummaries(String novelId) async => [];

  @override
  Future<Novel?> getNovel(String novelId) async => Novel(
    id: novelId,
    title: 'Test Novel',
    isPublic: false,
    languageCode: 'en',
  );

  @override
  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async => [];

  @override
  Future<Chapter?> getChapter(String chapterId) async =>
      Chapter(id: chapterId, novelId: '123', idx: 1, title: 'Test Chapter');
}

class FakeNotesRepository extends Fake implements NotesRepository {
  @override
  Future<List<CharacterNote>> listCharacterNotes(String novelId) async => [];

  @override
  Future<List<SceneNote>> listSceneNotes(String novelId) async => [];
}

class FakeChapterRepository extends Fake implements ChapterPort {
  @override
  Future<int> getNextIdx(String novelId) async => 1;

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    // Simulate failure to keep the screen visible
    throw Exception('Simulated creation failure for testing');
  }
}

class FakePromptsService extends PromptsService {
  FakePromptsService() : super(baseUrl: 'http://mock');

  @override
  Future<List<Prompt>> fetchPrompts({bool? isPublic}) async {
    return [];
  }

  @override
  Future<List<Prompt>> searchPrompts(String query, {bool? isPublic}) async =>
      [];
}

class FakePatternsService extends PatternsService {
  FakePatternsService() : super(baseUrl: 'http://mock');

  @override
  Future<List<Pattern>> fetchPatterns() async => [];

  @override
  Future<List<Pattern>> searchPatterns(String query) async => [];
}

class FakeStoryLinesService extends StoryLinesService {
  FakeStoryLinesService() : super(baseUrl: 'http://mock');

  @override
  Future<List<StoryLine>> fetchStoryLines() async => [];

  @override
  Future<List<StoryLine>> searchStoryLines(String query) async => [];
}

class FakeSyncService extends Fake implements SyncService {
  @override
  SyncState get currentSyncState => const SyncState(
    status: SyncStatus.synced,
    pendingOperations: 0,
    errorMessage: null,
    lastSyncTime: null,
  );
}

List getOverrides(SharedPreferences prefs) {
  return [
    globalNavigatorKeyProvider.overrideWith(
      (ref) => GlobalKey<NavigatorState>(),
    ),
    sharedPreferencesProvider.overrideWithValue(prefs),
    localStorageRepositoryProvider.overrideWithValue(
      LocalStorageRepository(LocalStorageService(prefs)),
    ),
    sessionProvider.overrideWith(
      (ref) => SessionNotifier(LocalStorageService(prefs)),
    ),
    libraryNovelsProviderV2.overrideWith((ref) async => []),
    downloadedNovelIdsProvider.overrideWith((ref) async => {}),
    recentUserProgressProvider.overrideWith((ref) async => []),
    latestUserProgressProvider.overrideWith((ref) async => null),
    currentUserProvider.overrideWith((ref) async => null),
    userRepositoryProvider.overrideWithValue(FakeUserRepository()),
    themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
    appSettingsProvider.overrideWith((ref) => AppSettingsNotifier(prefs)),
    ttsSettingsProvider.overrideWith((ref) => TtsSettingsNotifier(prefs)),
    performanceSettingsProvider.overrideWith(
      (ref) => PerformanceSettingsNotifier(prefs),
    ),
    aiServiceProvider.overrideWith((ref) => AiServiceNotifier(prefs)),
    adminModeProvider.overrideWith((ref) => AdminModeNotifier(prefs)),
    motionSettingsProvider.overrideWith((ref) => MotionSettingsNotifier(prefs)),
    currentMonthUsageProvider.overrideWith((ref) async => null),
    usageHistoryProvider.overrideWith((ref, arg) async => null),
    isAdminProvider.overrideWith((ref) => false),

    // New overrides for coverage
    novelRepositoryProvider.overrideWithValue(FakeNovelRepository()),
    notesRepositoryProvider.overrideWithValue(FakeNotesRepository()),
    promptsServiceProvider.overrideWithValue(FakePromptsService()),
    patternsServiceProvider.overrideWithValue(FakePatternsService()),
    storyLinesServiceProvider.overrideWithValue(FakeStoryLinesService()),
    remoteRepositoryProvider.overrideWithValue(FakeRemoteRepository()),
    chapterRepositoryProvider.overrideWithValue(FakeChapterRepository()),
    uiStyleControllerProvider.overrideWith((ref) => UiStyleController(prefs)),
    syncServiceProvider.overrideWithValue(FakeSyncService()),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'getVoices') {
            return [];
          }
          if (methodCall.method == 'getLanguages') {
            return [];
          }
          return null;
        });
  });

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpRouterApp(
    WidgetTester tester, {
    required ProviderContainer container,
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('navigates to Auth screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = ['/auth', '/signup', '/forgot-password', '/reset-password'];
    final types = [
      SignInScreen,
      SignUpScreen,
      ForgotPasswordScreen,
      ResetPasswordScreen,
    ];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to simple screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = ['/about', '/my-novels', '/create-novel'];
    final types = [AboutScreen, MyNovelsScreen, CreateNovelScreen];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to list and form screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = [
      '/prompts',
      '/patterns',
      '/story_lines',
      '/prompt_form',
      '/pattern_form',
      '/story_line_form',
    ];
    final types = [
      PromptsListScreen,
      PatternsListScreen,
      StoryLinesListScreen,
      PromptFormScreen,
      PatternFormScreen,
      StoryLineFormScreen,
    ];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to admin screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = ['/admin/users', '/admin/logs'];
    final types = [UserManagementScreen, AdminLogsScreen];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to settings screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = ['/settings', '/settings/token-usage-history'];
    final types = [SettingsScreen, TokenUsageHistoryScreen];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to standalone template screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = ['/character-templates', '/scene-templates'];
    final types = [CharacterTemplatesListScreen, SceneTemplatesListScreen];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      expect(find.byType(types[i]), findsOneWidget);
    }
  });

  testWidgets('navigates to nested novel screens', (tester) async {
    final container = ProviderContainer(overrides: [...getOverrides(prefs)]);
    addTearDown(container.dispose);

    await pumpRouterApp(tester, container: container);
    final router = container.read(appRouterProvider);
    await tester.pumpAndSettle();

    final routes = [
      '/novel/123',
      '/novel/123/chapters/new',
      '/novel/123/summary',
      '/novel/123/characters',
      '/novel/123/characters/new',
      '/novel/123/scenes',
      '/novel/123/scenes/new',
      '/novel/123/character-templates',
      '/novel/123/character-templates/new',
      '/novel/123/scene-templates',
      '/novel/123/scene-templates/new',
      '/novel/123/edit',
    ];
    final types = [
      ReaderScreen,
      MobileEditorScreen,
      SummaryScreen,
      CharactersListScreen,
      CharactersScreen,
      ScenesListScreen,
      ScenesScreen,
      CharacterTemplatesListScreen,
      CharacterTemplatesScreen,
      SceneTemplatesListScreen,
      SceneTemplatesScreen,
      NovelMetadataEditor,
    ];

    for (int i = 0; i < routes.length; i++) {
      router.go(routes[i]);
      await tester.pumpAndSettle();
      if (types[i] == NovelMetadataEditor) {
        expect(find.byType(NovelMetadataEditor), findsOneWidget);
      } else {
        expect(find.byType(types[i]), findsOneWidget);
      }
    }
  });
}
