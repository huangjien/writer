import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/app.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  testWidgets('App smoke test with ProviderScope overrides mirrors main()', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appSettings = AppSettingsNotifier(prefs);
    final themeController = ThemeController(prefs);
    final motionSettings = MotionSettingsNotifier(prefs);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appSettingsProvider.overrideWith((_) => appSettings),
          themeControllerProvider.overrideWith((_) => themeController),
          motionSettingsProvider.overrideWith((_) => motionSettings),
          appRouterProvider.overrideWithValue(router),
        ],
        child: const App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Writer');
    expect(
      materialApp.supportedLocales.map((l) => l.languageCode).toSet(),
      containsAll({'en', 'zh'}),
    );
  });
}
