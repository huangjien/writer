import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/supabase_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/themes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen shows all sections', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Use the first scrollable (vertical list)
    final scrollable = find.byType(Scrollable).at(0);

    // App Settings (visible at top)
    expect(find.byType(AppSettingsSection), findsOneWidget);

    // Palette
    final palette = find.byType(PaletteSettingsSection);
    await tester.scrollUntilVisible(palette, 500, scrollable: scrollable);
    expect(palette, findsOneWidget);

    // AI Configurations section removed; ensure other sections still render

    // Supabase
    final supabase = find.byType(SupabaseSection);
    await tester.scrollUntilVisible(supabase, 500, scrollable: scrollable);
    expect(supabase, findsOneWidget);

    // TTS
    final tts = find.byType(TtsSettingsContainer);
    await tester.scrollUntilVisible(tts, 500, scrollable: scrollable);
    expect(tts, findsOneWidget);
  });

  testWidgets('SettingsScreen home button navigates to /', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('SettingsScreen applies reader bundle preset', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_separate_dark_palette', true);

    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).at(0);
    await tester.scrollUntilVisible(
      find.text('Nord Calm'),
      600,
      scrollable: scrollable,
    );

    await tester.tap(find.text('Nord Calm'));
    await tester.pumpAndSettle();

    final state = container.read(themeControllerProvider);
    expect(state.hasSeparateDark, isFalse);
    expect(state.family, AppThemeFamily.nord);
    expect(state.fontPack, ReaderFontPack.inter);
    expect(state.preset, ReaderTypographyPreset.comfortable);
  });

  testWidgets('SettingsScreen shows Signed in as and signs out', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final themeController = ThemeController(prefs);

    final mockClient = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    final mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('a@b.com');
    when(() => mockAuth.signOut()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEnabledProvider.overrideWith((ref) => true),
          supabaseClientProvider.overrideWithValue(mockClient),
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => themeController),
          ttsSettingsProvider.overrideWith((_) => TtsSettingsNotifier(prefs)),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Signed in as a@b.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    final scrollable = find.byType(Scrollable).at(0);
    await tester.scrollUntilVisible(
      find.text('Sign Out'),
      800,
      scrollable: scrollable,
    );

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    verify(() => mockAuth.signOut()).called(1);
  });
}
