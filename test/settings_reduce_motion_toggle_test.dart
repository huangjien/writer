import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/motion_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Toggling Reduce Motion switch updates provider state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs); // defaults to en
    final themeController = ThemeController(prefs);
    final motionNotifier = MotionSettingsNotifier(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
          motionSettingsProvider.overrideWith((_) => motionNotifier),
        ],
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
    expect(motionNotifier.state.reduceMotion, isFalse);

    // Tap to enable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(motionNotifier.state.reduceMotion, isTrue);

    // Tap again to disable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(motionNotifier.state.reduceMotion, isFalse);
  });
}
