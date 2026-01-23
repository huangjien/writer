import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/widgets/palette_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/theme/themes.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Color theme options come from theme factory', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeControllerProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PaletteSettingsSection()),
        ),
      ),
    );

    for (final def in themeFactoryThemes) {
      expect(find.text(def.label), findsWidgets);
    }

    await tester.tap(find.text('Ocean Depths').first);
    await tester.pumpAndSettle();

    expect(controller.state.family, AppThemeFamily.oceanDepths);
    expect(prefs.getString('light_theme'), 'oceanDepths');
  });
}
