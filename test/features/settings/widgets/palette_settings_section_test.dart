import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PaletteSettingsSection renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PaletteSettingsSection(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Use separate dark palette'), findsOneWidget);
    expect(find.text('Color Theme'), findsOneWidget);
  });
}
