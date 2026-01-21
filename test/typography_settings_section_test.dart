import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/state/theme_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TypographySettingsSection renders core typography controls', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeControllerProvider.overrideWith((_) => theme)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: TypographySettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Typography Preset'), findsOneWidget);
    expect(find.text('Font Pack'), findsOneWidget);
    expect(find.text('Custom Font Family'), findsOneWidget);
    expect(find.text('Reader Background Depth'), findsOneWidget);
    expect(find.text('Use separate typography for light/dark'), findsOneWidget);
  });
}
