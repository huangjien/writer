import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/l10n/app_localizations.dart';
import 'package:novel_reader/features/settings/widgets/app_settings_section.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AppSettingsSection renders core controls', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final app = AppSettingsNotifier(prefs);
    final theme = ThemeController(prefs);
    final motion = MotionSettingsNotifier(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => app),
          themeControllerProvider.overrideWith((_) => theme),
          motionSettingsProvider.overrideWith((_) => motion),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: AppSettingsSection()),
          ),
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
