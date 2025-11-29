import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (supabaseEnabled) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    }
  });

  testWidgets('Toggling Reduce Motion switch updates provider state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        motionSettingsProvider.overrideWith(
          (_) => MotionSettingsNotifier(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure the tile is visible
    final tileFinder = find.widgetWithText(SwitchListTile, 'Reduce motion');
    expect(tileFinder, findsOneWidget);

    // Initial state should be false
    expect(container.read(motionSettingsProvider).reduceMotion, isFalse);

    // Tap to enable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isTrue);

    // Tap again to disable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isFalse);
  });
}
