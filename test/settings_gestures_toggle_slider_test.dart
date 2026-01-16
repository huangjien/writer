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
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';

class MockBiometricService extends BiometricService {
  @override
  Future<bool> isBiometricAvailable() async => false;
}

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
        sharedPreferencesProvider.overrideWithValue(prefs),
        biometricServiceProvider.overrideWithValue(MockBiometricService()),
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

    final tile = find.widgetWithIcon(ListTile, Icons.touch_app);
    expect(tile, findsOneWidget);
    expect(container.read(motionSettingsProvider).gesturesEnabled, isTrue);

    final toggle = find.descendant(
      of: tile,
      matching: find.byType(NeumorphicSwitch),
    );
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).gesturesEnabled, isFalse);

    await tester.tap(toggle);
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
        sharedPreferencesProvider.overrideWithValue(prefs),
        biometricServiceProvider.overrideWithValue(MockBiometricService()),
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
      matching: find.byType(NeumorphicSlider),
    );
    expect(sliderFinder, findsOneWidget);

    final slider = tester.widget<NeumorphicSlider>(sliderFinder);
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
