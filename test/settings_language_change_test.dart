import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/theme_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Language dropdown changes app locale to zh', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final langLabel = find.text('App Language');
    final langTile = find.ancestor(
      of: langLabel,
      matching: find.byType(ListTile),
    );
    final langDropdown = find.descendant(
      of: langTile,
      matching: find.byType(DropdownButton<String>),
    );
    expect(langDropdown, findsOneWidget);
    await tester.tap(langDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese').last);
    await tester.pumpAndSettle();

    expect(container.read(appSettingsProvider).languageCode, 'zh');
  });
}
