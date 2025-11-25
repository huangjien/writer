import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/app.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  testWidgets('App boots to Library with localized title', (tester) async {
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
    expect(find.text(AppLocalizationsEn().appTitle), findsOneWidget);
  });
}
