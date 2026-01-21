import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/auth/sign_in_screen.dart';
import 'package:writer/features/library/library_screen.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/features/library/library_providers.dart';
import 'package:writer/routing/app_router.dart';
import 'package:writer/state/navigator_key_provider.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/user_repository.dart';
import 'package:writer/models/user.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:flutter/services.dart';

import 'package:writer/features/reader/reader_screen.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/edit_permissions.dart';

class FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<User?> fetchUser(String sessionId) async => null;
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
    required GoRouter router,
    List overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          sharedPreferencesProvider.overrideWithValue(prefs),
          localStorageRepositoryProvider.overrideWithValue(
            LocalStorageRepository(LocalStorageService(prefs)),
          ),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(LocalStorageService(prefs)),
          ),
          // Mock data providers to prevent loading actual data
          libraryNovelsProvider.overrideWith((ref) async => []),
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
          motionSettingsProvider.overrideWith(
            (ref) => MotionSettingsNotifier(prefs),
          ),
          currentMonthUsageProvider.overrideWith((ref) async => null),
          usageHistoryProvider.overrideWith((ref, arg) async => null),
          isAdminProvider.overrideWith((ref) => false),
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

  testWidgets('initial route is LibraryScreen', (tester) async {
    final container = ProviderContainer(
      overrides: [
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
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await pumpRouterApp(tester, router: router);
    await tester.pumpAndSettle();

    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('navigates to Auth screen', (tester) async {
    final container = ProviderContainer(
      overrides: [
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
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await pumpRouterApp(tester, router: router);
    await tester.pumpAndSettle();

    router.go('/auth');
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('navigates to Settings screen', (tester) async {
    final container = ProviderContainer(
      overrides: [
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
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await pumpRouterApp(tester, router: router);
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('navigates to Reader screen for novel/:id', (tester) async {
    final container = ProviderContainer(
      overrides: [
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
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await pumpRouterApp(
      tester,
      router: router,
      overrides: [
        chaptersProvider('123').overrideWith((ref) => []),
        editPermissionsProvider('123').overrideWith((ref) async => false),
      ],
    );
    await tester.pumpAndSettle();

    router.go('/novel/123');
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
  });

  testWidgets(
    'navigates to Chapter Reader screen for novel/:id/chapters/:chapterId',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
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
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      final chapter = const Chapter(
        id: 'c1',
        title: 'Chapter 1',
        content: 'Content',
        idx: 1,
        novelId: '123',
      );

      await pumpRouterApp(
        tester,
        router: router,
        overrides: [
          chaptersProvider('123').overrideWith((ref) => [chapter]),
          editPermissionsProvider('123').overrideWith((ref) async => false),
        ],
      );
      await tester.pumpAndSettle();

      router.go('/novel/123/chapters/c1');
      await tester.pumpAndSettle();

      expect(find.byType(ReaderScreen), findsOneWidget);
      // ReaderScreen wraps ChapterReaderScreen, so we check if ReaderScreen is there
      // and if it displays content from the chapter.
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    },
  );

  testWidgets('navigates to nested route settings/token-usage-history', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
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
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await pumpRouterApp(tester, router: router);
    await tester.pumpAndSettle();

    router.go('/settings/token-usage-history');
    await tester.pumpAndSettle();

    // Check for the screen title from localization
    expect(find.text('View history'), findsOneWidget);
  });
}
