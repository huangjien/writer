import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/motion_settings.dart';

void main() {
  group('MotionSettingsNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    group('Reduce Motion toggle', () {
      test('should initialize with reduceMotion disabled by default', () {
        final notifier = MotionSettingsNotifier(prefs);

        expect(
          notifier.state.reduceMotion,
          isFalse,
          reason: 'Reduce motion should be disabled by default',
        );
      });

      test(
        'should initialize with reduceMotion enabled from SharedPreferences',
        () async {
          SharedPreferences.setMockInitialValues({
            'reduce_motion_enabled': true,
          });
          final prefs = await SharedPreferences.getInstance();

          final notifier = MotionSettingsNotifier(prefs);

          expect(
            notifier.state.reduceMotion,
            isTrue,
            reason: 'Should load saved reduceMotion state',
          );
        },
      );

      test('should toggle reduceMotion from false to true', () async {
        final notifier = MotionSettingsNotifier(prefs);
        expect(notifier.state.reduceMotion, isFalse);

        await notifier.setReduceMotion(true);

        expect(
          notifier.state.reduceMotion,
          isTrue,
          reason: 'Reduce motion should be enabled',
        );
        expect(
          prefs.getBool('reduce_motion_enabled'),
          isTrue,
          reason: 'Should persist to SharedPreferences',
        );
      });

      test('should toggle reduceMotion from true to false', () async {
        SharedPreferences.setMockInitialValues({'reduce_motion_enabled': true});
        final prefs = await SharedPreferences.getInstance();
        final notifier = MotionSettingsNotifier(prefs);
        expect(notifier.state.reduceMotion, isTrue);

        await notifier.setReduceMotion(false);

        expect(
          notifier.state.reduceMotion,
          isFalse,
          reason: 'Reduce motion should be disabled',
        );
        expect(
          prefs.getBool('reduce_motion_enabled'),
          isFalse,
          reason: 'Should persist to SharedPreferences',
        );
      });

      test('should persist reduceMotion changes across instances', () async {
        final notifier1 = MotionSettingsNotifier(prefs);
        await notifier1.setReduceMotion(true);

        final notifier2 = MotionSettingsNotifier(prefs);
        expect(
          notifier2.state.reduceMotion,
          isTrue,
          reason: 'Should load persisted state from SharedPreferences',
        );
      });
    });

    group('State management', () {
      test('should notify listeners when reduceMotion changes', () async {
        final notifier = MotionSettingsNotifier(prefs);
        final states = <MotionSettings>[];
        final subscription = notifier.stream.listen(states.add);

        await notifier.setReduceMotion(true);

        expect(
          states.last.reduceMotion,
          isTrue,
          reason: 'Should emit new state when reduceMotion changes',
        );

        await subscription.cancel();
      });

      test('should update state synchronously after setReduceMotion', () async {
        final notifier = MotionSettingsNotifier(prefs);

        await notifier.setReduceMotion(true);
        expect(notifier.state.reduceMotion, isTrue);

        await notifier.setReduceMotion(false);
        expect(notifier.state.reduceMotion, isFalse);
      });

      test(
        'should not affect other settings when changing reduceMotion',
        () async {
          SharedPreferences.setMockInitialValues({
            'reader_swipe_min_velocity': 300.0,
            'reader_gestures_enabled': false,
          });
          final prefs = await SharedPreferences.getInstance();
          final notifier = MotionSettingsNotifier(prefs);

          expect(notifier.state.swipeMinVelocity, 300.0);
          expect(notifier.state.gesturesEnabled, isFalse);

          await notifier.setReduceMotion(true);

          expect(notifier.state.reduceMotion, isTrue);
          expect(
            notifier.state.swipeMinVelocity,
            300.0,
            reason: 'Swipe min velocity should not change',
          );
          expect(
            notifier.state.gesturesEnabled,
            isFalse,
            reason: 'Gestures enabled should not change',
          );
        },
      );
    });

    group('Swipe Min Velocity', () {
      test('should initialize with default swipeMinVelocity', () {
        final notifier = MotionSettingsNotifier(prefs);

        expect(
          notifier.state.swipeMinVelocity,
          200.0,
          reason: 'Default swipe min velocity should be 200.0',
        );
      });

      test('should update swipeMinVelocity', () async {
        final notifier = MotionSettingsNotifier(prefs);
        const newValue = 250.0;

        await notifier.setSwipeMinVelocity(newValue);

        expect(notifier.state.swipeMinVelocity, newValue);
        expect(prefs.getDouble('reader_swipe_min_velocity'), newValue);
      });

      test('should persist swipeMinVelocity changes', () async {
        final notifier1 = MotionSettingsNotifier(prefs);
        await notifier1.setSwipeMinVelocity(150.0);

        final notifier2 = MotionSettingsNotifier(prefs);
        expect(notifier2.state.swipeMinVelocity, 150.0);
      });
    });

    group('Gestures Enabled', () {
      test('should initialize with gesturesEnabled by default', () {
        final notifier = MotionSettingsNotifier(prefs);

        expect(
          notifier.state.gesturesEnabled,
          isTrue,
          reason: 'Gestures should be enabled by default',
        );
      });

      test('should update gesturesEnabled', () async {
        final notifier = MotionSettingsNotifier(prefs);

        await notifier.setGesturesEnabled(false);

        expect(notifier.state.gesturesEnabled, isFalse);
        expect(prefs.getBool('reader_gestures_enabled'), isFalse);
      });

      test('should persist gesturesEnabled changes', () async {
        final notifier1 = MotionSettingsNotifier(prefs);
        await notifier1.setGesturesEnabled(false);

        final notifier2 = MotionSettingsNotifier(prefs);
        expect(notifier2.state.gesturesEnabled, isFalse);
      });
    });

    group('Lazy initialization', () {
      test(
        'should initialize with defaults when using lazy constructor',
        () async {
          SharedPreferences.setMockInitialValues({});
          final notifier = MotionSettingsNotifier.lazy();

          await Future.delayed(const Duration(milliseconds: 100));

          expect(notifier.state.reduceMotion, isFalse);
          expect(notifier.state.swipeMinVelocity, 200.0);
          expect(notifier.state.gesturesEnabled, isTrue);
        },
      );

      test('should load saved values after async initialization', () async {
        SharedPreferences.setMockInitialValues({
          'reduce_motion_enabled': true,
          'reader_swipe_min_velocity': 300.0,
          'reader_gestures_enabled': false,
        });

        final notifier = MotionSettingsNotifier.lazy();

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.reduceMotion, isTrue);
        expect(notifier.state.swipeMinVelocity, 300.0);
        expect(notifier.state.gesturesEnabled, isFalse);
      });
    });

    group('copyWith', () {
      test('should create copy with only reduceMotion changed', () {
        const original = MotionSettings(
          reduceMotion: false,
          swipeMinVelocity: 200.0,
          gesturesEnabled: true,
        );

        final copy = original.copyWith(reduceMotion: true);

        expect(copy.reduceMotion, isTrue);
        expect(copy.swipeMinVelocity, 200.0);
        expect(copy.gesturesEnabled, true);
      });

      test('should create copy with all fields changed', () {
        const original = MotionSettings(
          reduceMotion: false,
          swipeMinVelocity: 200.0,
          gesturesEnabled: true,
        );

        final copy = original.copyWith(
          reduceMotion: true,
          swipeMinVelocity: 250.0,
          gesturesEnabled: false,
        );

        expect(copy.reduceMotion, isTrue);
        expect(copy.swipeMinVelocity, 250.0);
        expect(copy.gesturesEnabled, false);
      });
    });

    group('Integration scenarios', () {
      test('should handle multiple rapid toggles of reduceMotion', () async {
        final notifier = MotionSettingsNotifier(prefs);

        await notifier.setReduceMotion(true);
        await notifier.setReduceMotion(false);
        await notifier.setReduceMotion(true);
        await notifier.setReduceMotion(false);

        expect(notifier.state.reduceMotion, isFalse);
        expect(prefs.getBool('reduce_motion_enabled'), isFalse);
      });

      test(
        'should handle settings changes before lazy initialization completes',
        () async {
          SharedPreferences.setMockInitialValues({});
          final notifier = MotionSettingsNotifier.lazy();

          await notifier.setReduceMotion(true);
          await notifier.setSwipeMinVelocity(300.0);

          await Future.delayed(const Duration(milliseconds: 100));

          expect(notifier.state.reduceMotion, isTrue);
          expect(notifier.state.swipeMinVelocity, 300.0);
        },
      );
    });
  });
}
