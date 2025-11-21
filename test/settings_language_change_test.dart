import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novel_reader/features/settings/settings_screen.dart';
import 'package:novel_reader/state/app_settings.dart';
import 'package:novel_reader/state/theme_controller.dart';
import 'package:novel_reader/l10n/app_localizations.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Language dropdown changes app locale to zh', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final appNotifier = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appNotifier),
          themeControllerProvider.overrideWith((_) => themeController),
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

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    expect(appNotifier.state.languageCode, 'zh');
  });
}
