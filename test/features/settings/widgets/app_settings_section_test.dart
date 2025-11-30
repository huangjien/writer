import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AppSettingsSection renders correctly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
          motionSettingsProvider.overrideWith(
            (_) => MotionSettingsNotifier(prefs),
          ),
          aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AppSettingsSection()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Settings'), findsOneWidget);
    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Enable touch gestures'), findsOneWidget);
    expect(find.text('Reader swipe sensitivity'), findsOneWidget);
    expect(find.text('High Contrast'), findsOneWidget);
  });
}
