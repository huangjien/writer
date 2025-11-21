import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  test('MotionSettingsNotifier toggles reduceMotion', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifier = MotionSettingsNotifier(prefs);
    expect(notifier.state.reduceMotion, isFalse);
    notifier.setReduceMotion(true);
    expect(notifier.state.reduceMotion, isTrue);
  });
}
