import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/features/settings/widgets/performance_section.dart';
import 'package:writer/features/settings/widgets/reader_bundle_grid.dart';
import 'package:writer/features/settings/widgets/token_usage_section.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/user.dart';
import 'package:writer/repositories/user_repository.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/session_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

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
          if (methodCall.method == 'awaitSpeakCompletion') {
            return 1;
          }
          return null;
        });
  });

  testWidgets('SettingsScreen renders without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mockUserRepository = MockUserRepository();
    when(
      () => mockUserRepository.fetchUser(any()),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(LocalStorageService(prefs)),
          ),
          currentMonthUsageProvider.overrideWith((ref) async => null),
          isSignedInProvider.overrideWithValue(false),
          currentUserProvider.overrideWith((ref) async => null),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          userProvider.overrideWith(
            (ref) => UserStateNotifier(
              ref,
              mockUserRepository,
              const AsyncValue.data(null),
            ),
          ),
          isAdminProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(AppSettingsSection), findsOneWidget);

    final scrollable = find.byType(Scrollable);

    await tester.scrollUntilVisible(
      find.byType(PaletteSettingsSection),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(PaletteSettingsSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(TypographySettingsSection),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(TypographySettingsSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(ReaderBundleGrid),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(ReaderBundleGrid), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(PerformanceSection),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(PerformanceSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(TtsSettingsContainer),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(TtsSettingsContainer), findsOneWidget);

    // User is signed out, so TokenUsageSection should not be visible
    expect(find.byType(TokenUsageSection), findsNothing);
    // Sign In button should be visible
    await tester.scrollUntilVisible(
      find.text('Sign In'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows user info when signed in', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final user = User(id: '123', email: 'test@example.com');
    const backendUser = BackendUser(id: '123', email: 'test@example.com');
    final mockUserRepository = MockUserRepository();
    when(
      () => mockUserRepository.fetchUser(any()),
    ).thenAnswer((_) async => user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(LocalStorageService(prefs)),
          ),
          currentMonthUsageProvider.overrideWith((ref) async => null),
          usageHistoryProvider.overrideWith((ref, arg) async => null),
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => backendUser),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          userProvider.overrideWith(
            (ref) => UserStateNotifier(
              ref,
              mockUserRepository,
              AsyncValue.data(user),
            ),
          ),
          isAdminProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Signed in as test@example.com'), findsOneWidget);
    final scrollable = find.byType(Scrollable);

    await tester.scrollUntilVisible(
      find.byType(TokenUsageSection),
      500,
      scrollable: scrollable,
    );
    expect(find.byType(TokenUsageSection), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sign Out'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('SettingsScreen handles sign out', (tester) async {
    SharedPreferences.setMockInitialValues({'backend_session_id': 'sess_123'});
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Prefs session: ${prefs.getString('backend_session_id')}');

    final user = User(id: '123', email: 'test@example.com');
    const backendUser = BackendUser(id: '123', email: 'test@example.com');
    final mockUserRepository = MockUserRepository();
    when(
      () => mockUserRepository.fetchUser(any()),
    ).thenAnswer((_) async => user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
          sessionProvider.overrideWith((ref) {
            return SessionNotifier(LocalStorageService(prefs));
          }),
          currentMonthUsageProvider.overrideWith((ref) async => null),
          usageHistoryProvider.overrideWith((ref, arg) async => null),
          // isSignedInProvider is NOT overridden, so it derives from sessionProvider
          currentUserProvider.overrideWith((ref) async {
            final session = ref.watch(sessionProvider);
            if (session == null) return null;
            return backendUser;
          }),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          userProvider.overrideWith(
            (ref) => UserStateNotifier(
              ref,
              mockUserRepository,
              AsyncValue.data(user),
            ),
          ),
          isAdminProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure Sign Out is in the tree (even if off-screen)
    // find.text finds widgets even if off-screen in a ListView (if cached/built)
    // But ListView lazily builds.

    // We try to scroll to it using scrollUntilVisible which is safer than dragUntilVisible
    await tester.scrollUntilVisible(
      find.text('Sign Out'),
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify Sign Out button is visible
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify session is cleared (Sign In button appears)
    expect(find.text('Sign In'), findsOneWidget);
  });
}
