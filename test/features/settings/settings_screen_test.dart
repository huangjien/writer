import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/features/settings/widgets/tts_settings_container.dart';
import 'package:writer/features/settings/widgets/performance_section.dart';
import 'package:writer/features/settings/widgets/reader_bundle_grid.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/theme/font_packs.dart';
import 'package:writer/theme/reader_typography.dart';
import 'package:writer/theme/themes.dart';

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

    final typography = find.byType(TypographySettingsSection);
    await tester.scrollUntilVisible(typography, 500, scrollable: scrollable);
    expect(typography, findsOneWidget);

    final bundles = find.byType(ReaderBundleGrid);
    await tester.scrollUntilVisible(bundles, 500, scrollable: scrollable);
    expect(bundles, findsOneWidget);

    final perf = find.byType(PerformanceSection);
    await tester.scrollUntilVisible(perf, 500, scrollable: scrollable);
    expect(perf, findsOneWidget);

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

    final sessionNotifier = SessionNotifier(prefs);
    await sessionNotifier.setSessionId('test-session');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith((ref) => sessionNotifier),
          currentUserProvider.overrideWith((ref) async {
            final sid = ref.watch(sessionProvider);
            if (sid == null || sid.isEmpty) return null;
            return const BackendUser(id: 'u1', email: 'a@b.com');
          }),
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

    final scrollable = find.byType(Scrollable).at(0);
    await tester.scrollUntilVisible(
      find.text('Sign Out'),
      800,
      scrollable: scrollable,
    );
    expect(find.text('Sign Out'), findsOneWidget);

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });
}
