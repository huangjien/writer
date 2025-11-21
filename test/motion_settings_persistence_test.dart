import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novel_reader/state/motion_settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('gesturesEnabled persists across notifier instances', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = MotionSettingsNotifier.lazy();
    expect(first.state.gesturesEnabled, isTrue);
    first.setGesturesEnabled(false);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final second = MotionSettingsNotifier(prefs);
    expect(second.state.gesturesEnabled, isFalse);

    first.setGesturesEnabled(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final third = MotionSettingsNotifier(prefs);
    expect(third.state.gesturesEnabled, isTrue);
  });

  test('swipeMinVelocity persists across notifier instances', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = MotionSettingsNotifier.lazy();
    expect(first.state.swipeMinVelocity, equals(200.0));
    first.setSwipeMinVelocity(350.0);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final second = MotionSettingsNotifier(prefs);
    expect(second.state.swipeMinVelocity, equals(350.0));

    first.setSwipeMinVelocity(500.0);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final third = MotionSettingsNotifier(prefs);
    expect(third.state.swipeMinVelocity, equals(500.0));
  });
}
