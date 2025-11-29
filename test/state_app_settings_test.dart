import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/app_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'AppSettingsNotifier initializes with default languageCode from empty prefs',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(appSettingsProvider);
      expect(state.languageCode, 'en');
    },
  );

  test('setLanguage updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(appSettingsProvider.notifier);
    await notifier.setLanguage('zh');

    final state = container.read(appSettingsProvider);
    expect(state.languageCode, 'zh');
    expect(prefs.getString('app_language'), 'zh');
  });
}
