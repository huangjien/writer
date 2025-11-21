import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/settings_screen.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Toggling gestures switch updates provider state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
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

    final tile = find.widgetWithText(SwitchListTile, 'Enable touch gestures');
    expect(tile, findsOneWidget);
    expect(motionNotifier.state.gesturesEnabled, isTrue);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(motionNotifier.state.gesturesEnabled, isFalse);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(motionNotifier.state.gesturesEnabled, isTrue);
  });

  testWidgets('Swipe sensitivity slider updates provider state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
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

    expect(find.text('Reader swipe sensitivity'), findsOneWidget);
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    final slider = tester.widget<Slider>(sliderFinder);
    expect(motionNotifier.state.swipeMinVelocity, equals(200.0));

    slider.onChanged?.call(450.0);
    await tester.pumpAndSettle();
    expect(motionNotifier.state.swipeMinVelocity, equals(450.0));
  });
}
