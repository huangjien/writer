import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/app.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';

void main() {
  testWidgets('App smoke test with ProviderScope overrides mirrors main()', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((_) => appSettings),
          themeControllerProvider.overrideWith((_) => themeController),
        ],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Novel Reader'), findsWidgets);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Novel Reader');
    expect(
      materialApp.supportedLocales.map((l) => l.languageCode).toSet(),
      containsAll({'en', 'zh'}),
    );
  });
}
