import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/motion_settings.dart';

void main() {
  test('MotionSettingsNotifier initializes from prefs', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        motionSettingsProvider.overrideWith(
          (ref) => MotionSettingsNotifier(prefs),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(motionSettingsProvider);
    expect(state.reduceMotion, false);
    expect(state.swipeMinVelocity, 200.0);
    expect(state.gesturesEnabled, true);
  });

  test('setters update state and persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        motionSettingsProvider.overrideWith(
          (ref) => MotionSettingsNotifier(prefs),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(motionSettingsProvider.notifier);
    await notifier.setReduceMotion(true);
    await notifier.setSwipeMinVelocity(300.0);
    await notifier.setGesturesEnabled(false);

    final state = container.read(motionSettingsProvider);
    expect(state.reduceMotion, true);
    expect(state.swipeMinVelocity, 300.0);
    expect(state.gesturesEnabled, false);

    expect(prefs.getBool('reduce_motion_enabled'), true);
    expect(prefs.getDouble('reader_swipe_min_velocity'), 300.0);
    expect(prefs.getBool('reader_gestures_enabled'), false);
  });
}
