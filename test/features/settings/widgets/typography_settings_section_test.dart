import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/settings/widgets/typography_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TypographySettingsSection renders correctly', (
    WidgetTester tester,
  ) async {
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
          home: Scaffold(body: TypographySettingsSection()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(l10n.typographyPreset), findsOneWidget);
    expect(find.text(l10n.fontPack), findsOneWidget);
    expect(find.text(l10n.customFontFamily), findsOneWidget);
    expect(find.text(l10n.textScale), findsOneWidget);
    expect(find.text(l10n.readerBackgroundDepth), findsOneWidget);
    expect(find.text(l10n.separateTypographyPresets), findsOneWidget);
  });
}
