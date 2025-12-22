import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Toggling gestures switch updates provider state', (
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
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
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
          home: Scaffold(
            body: ListView(children: const [AppSettingsSection()]),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final tile = find.widgetWithIcon(SwitchListTile, Icons.touch_app);
    expect(tile, findsOneWidget);
    expect(container.read(motionSettingsProvider).gesturesEnabled, isTrue);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).gesturesEnabled, isFalse);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).gesturesEnabled, isTrue);
  });

  testWidgets('Swipe sensitivity slider updates provider state', (
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
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
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
          home: Scaffold(
            body: ListView(children: const [AppSettingsSection()]),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithIcon(ListTile, Icons.swipe),
      500.0,
    );
    await tester.pumpAndSettle();

    final sliderTile = find.widgetWithIcon(ListTile, Icons.swipe);
    expect(sliderTile, findsOneWidget);

    final sliderFinder = find.descendant(
      of: sliderTile,
      matching: find.byType(Slider),
    );
    expect(sliderFinder, findsOneWidget);

    final slider = tester.widget<Slider>(sliderFinder);
    expect(
      container.read(motionSettingsProvider).swipeMinVelocity,
      equals(200.0),
    );

    slider.onChanged?.call(450.0);
    await tester.pumpAndSettle();
    expect(
      container.read(motionSettingsProvider).swipeMinVelocity,
      equals(450.0),
    );
  });
}
