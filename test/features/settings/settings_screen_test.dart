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
import 'package:writer/state/ui_style_controller.dart';
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
          uiStyleControllerProvider.overrideWith(
            (ref) => UiStyleController(prefs),
          ),
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

    final listFinder = find.byType(ListView);

    while (find.byType(PaletteSettingsSection).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(PaletteSettingsSection), findsOneWidget);

    while (find.byType(TypographySettingsSection).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(TypographySettingsSection), findsOneWidget);

    while (find.byType(ReaderBundleGrid).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(ReaderBundleGrid), findsOneWidget);

    while (find.byType(PerformanceSection).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(PerformanceSection), findsOneWidget);

    while (find.byType(TtsSettingsContainer).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(TtsSettingsContainer), findsOneWidget);

    expect(find.byType(TokenUsageSection), findsNothing);

    while (find.text('Sign In').evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.text('Sign In'), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
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
          uiStyleControllerProvider.overrideWith(
            (ref) => UiStyleController(prefs),
          ),
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

    final listFinder = find.byType(ListView);

    while (find.byType(TokenUsageSection).evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.byType(TokenUsageSection), findsOneWidget);

    while (find.text('Sign Out').evaluate().isEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.text('Sign Out'), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  });

  testWidgets(
    'SettingsScreen handles sign out',
    (tester) async {
      const timeout = Duration(seconds: 10);
      const shortTimeout = Duration(milliseconds: 500);

      try {
        await tester.runAsync(() async {
          SharedPreferences.setMockInitialValues({
            'backend_session_id': 'valid-session-id',
          });
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
                themeControllerProvider.overrideWith(
                  (ref) => ThemeController(prefs),
                ),
                uiStyleControllerProvider.overrideWith(
                  (ref) => UiStyleController(prefs),
                ),
                appSettingsProvider.overrideWith(
                  (ref) => AppSettingsNotifier(prefs),
                ),
                ttsSettingsProvider.overrideWith(
                  (ref) => TtsSettingsNotifier(prefs),
                ),
                performanceSettingsProvider.overrideWith(
                  (ref) => PerformanceSettingsNotifier(prefs),
                ),
                aiServiceProvider.overrideWith(
                  (ref) => AiServiceNotifier(prefs),
                ),
                adminModeProvider.overrideWith(
                  (ref) => AdminModeNotifier(prefs),
                ),
                motionSettingsProvider.overrideWith(
                  (ref) => MotionSettingsNotifier(prefs),
                ),
                sharedPreferencesProvider.overrideWithValue(prefs),
                storageServiceProvider.overrideWithValue(
                  LocalStorageService(prefs),
                ),
                sessionProvider.overrideWith(
                  (ref) => SessionNotifier(LocalStorageService(prefs)),
                ),
                currentMonthUsageProvider.overrideWith((ref) async => null),
                usageHistoryProvider.overrideWith((ref, arg) async => null),
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

          await tester.pumpAndSettle(timeout);

          final listFinder = find.byType(ListView);
          expect(
            listFinder,
            findsOneWidget,
            reason: 'ListView should be present',
          );

          final textButtonFinder = find.widgetWithText(TextButton, 'Sign Out');
          var scrollAttempts = 0;
          const maxScrollAttempts = 20;
          while (!textButtonFinder.evaluate().isNotEmpty &&
              scrollAttempts < maxScrollAttempts) {
            await tester.drag(listFinder, const Offset(0, -500));
            await tester.pumpAndSettle(shortTimeout);
            scrollAttempts++;
          }
          expect(
            textButtonFinder.evaluate().isNotEmpty,
            true,
            reason:
                'Sign Out button should be visible after scrolling (attempts: $scrollAttempts)',
          );
          expect(
            textButtonFinder,
            findsOneWidget,
            reason: 'Sign Out button should exist exactly once',
          );

          await tester.tap(textButtonFinder);
          await tester.pumpAndSettle(timeout);

          final filledButtonFinder = find.widgetWithText(
            FilledButton,
            'Sign In',
          );
          scrollAttempts = 0;
          while (!filledButtonFinder.evaluate().isNotEmpty &&
              scrollAttempts < maxScrollAttempts) {
            await tester.drag(listFinder, const Offset(0, -500));
            await tester.pumpAndSettle(shortTimeout);
            scrollAttempts++;
          }
          expect(
            filledButtonFinder.evaluate().isNotEmpty,
            true,
            reason:
                'Sign In button should be visible after sign out (attempts: $scrollAttempts)',
          );
          expect(
            filledButtonFinder,
            findsOneWidget,
            reason: 'Sign In button should exist exactly once after sign out',
          );
        });
      } finally {
        await tester.pumpAndSettle();
      }
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets('SettingsScreen shows admin link when admin', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final user = User(id: '123', email: 'admin@example.com', isAdmin: true);
    const backendUser = BackendUser(id: '123', email: 'admin@example.com');
    final mockUserRepository = MockUserRepository();
    when(
      () => mockUserRepository.fetchUser(any()),
    ).thenAnswer((_) async => user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeControllerProvider.overrideWith((ref) => ThemeController(prefs)),
          uiStyleControllerProvider.overrideWith(
            (ref) => UiStyleController(prefs),
          ),
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
          isAdminProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final listFinder = find.byType(ListView);
    final adminFinder = find.text('Admin Mode');
    while (!adminFinder.evaluate().isNotEmpty) {
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(adminFinder, findsOneWidget);

    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  });
}
