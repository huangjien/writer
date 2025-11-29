import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefReduceMotion = 'reduce_motion_enabled';
const String _prefSwipeMinVelocity = 'reader_swipe_min_velocity';
const String _prefGesturesEnabled = 'reader_gestures_enabled';

class MotionSettings {
  final bool reduceMotion;
  final double swipeMinVelocity;
  final bool gesturesEnabled;
  const MotionSettings({
    required this.reduceMotion,
    this.swipeMinVelocity = 200.0,
    this.gesturesEnabled = true,
  });

  MotionSettings copyWith({
    bool? reduceMotion,
    double? swipeMinVelocity,
    bool? gesturesEnabled,
  }) => MotionSettings(
    reduceMotion: reduceMotion ?? this.reduceMotion,
    swipeMinVelocity: swipeMinVelocity ?? this.swipeMinVelocity,
    gesturesEnabled: gesturesEnabled ?? this.gesturesEnabled,
  );
}

class MotionSettingsNotifier extends StateNotifier<MotionSettings> {
  MotionSettingsNotifier(this._prefs)
    : super(
        MotionSettings(
          reduceMotion: _prefs?.getBool(_prefReduceMotion) ?? false,
          swipeMinVelocity: _prefs?.getDouble(_prefSwipeMinVelocity) ?? 200.0,
          gesturesEnabled: _prefs?.getBool(_prefGesturesEnabled) ?? true,
        ),
      );

  MotionSettingsNotifier.lazy()
    : _prefs = null,
      super(const MotionSettings(reduceMotion: false)) {
    _init();
  }

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final enabled = _prefs!.getBool(_prefReduceMotion) ?? false;
    final swipeMin = _prefs!.getDouble(_prefSwipeMinVelocity) ?? 200.0;
    final gestures = _prefs!.getBool(_prefGesturesEnabled) ?? true;
    state = state.copyWith(
      reduceMotion: enabled,
      swipeMinVelocity: swipeMin,
      gesturesEnabled: gestures,
    );
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_prefReduceMotion, value);
  }

  Future<void> setSwipeMinVelocity(double value) async {
    state = state.copyWith(swipeMinVelocity: value);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setDouble(_prefSwipeMinVelocity, value);
  }

  Future<void> setGesturesEnabled(bool value) async {
    state = state.copyWith(gesturesEnabled: value);
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_prefGesturesEnabled, value);
  }
}

final motionSettingsProvider =
    StateNotifierProvider<MotionSettingsNotifier, MotionSettings>((ref) {
      // Fallback to lazy initialization if not overridden.
      return MotionSettingsNotifier.lazy();
    });
