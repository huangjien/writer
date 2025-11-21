import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/app_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppSettingsNotifier initializes with en by default', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AppSettingsNotifier(prefs);
    expect(notifier.state.languageCode, 'en');
  });

  test('setLanguage updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = AppSettingsNotifier(prefs);
    notifier.setLanguage('zh');
    expect(notifier.state.languageCode, 'zh');
    expect(prefs.getString('app_language'), 'zh');
  });
}
