import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('MotionSettingsNotifier initializes from prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = MotionSettingsNotifier(prefs);
    expect(notifier.state.reduceMotion, false);
    expect(notifier.state.swipeMinVelocity, 200.0);
    expect(notifier.state.gesturesEnabled, true);
  });

  test('setters update state and persist', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = MotionSettingsNotifier(prefs);
    notifier.setReduceMotion(true);
    notifier.setSwipeMinVelocity(300.0);
    notifier.setGesturesEnabled(false);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(prefs.getBool('reduce_motion_enabled'), true);
    expect(prefs.getDouble('reader_swipe_min_velocity'), 300.0);
    expect(prefs.getBool('reader_gestures_enabled'), false);
  });
}
