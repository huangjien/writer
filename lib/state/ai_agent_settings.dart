import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service_provider.dart';

const String _preferDeepAgentKey = 'ai_prefer_deep_agent';
const String _deepAgentFallbackToQaKey = 'ai_deep_agent_fallback_to_qa';
const String _deepAgentReflectionModeKey = 'ai_deep_agent_reflection_mode';
const String _deepAgentShowDetailsKey = 'ai_deep_agent_show_details';
const String _deepAgentMaxPlanStepsKey = 'ai_deep_agent_max_plan_steps';
const String _deepAgentMaxToolRoundsKey = 'ai_deep_agent_max_tool_rounds';

enum DeepAgentReflectionMode { off, onFailure, always }

extension DeepAgentReflectionModeCodec on DeepAgentReflectionMode {
  String get wireValue {
    switch (this) {
      case DeepAgentReflectionMode.off:
        return 'off';
      case DeepAgentReflectionMode.onFailure:
        return 'on_failure';
      case DeepAgentReflectionMode.always:
        return 'always';
    }
  }

  static DeepAgentReflectionMode fromWireValue(String? value) {
    switch (value) {
      case 'on_failure':
        return DeepAgentReflectionMode.onFailure;
      case 'always':
        return DeepAgentReflectionMode.always;
      case 'off':
      default:
        return DeepAgentReflectionMode.off;
    }
  }
}

class AiAgentSettings {
  final bool preferDeepAgent;
  final bool deepAgentFallbackToQa;
  final DeepAgentReflectionMode deepAgentReflectionMode;
  final bool deepAgentShowDetails;
  final int deepAgentMaxPlanSteps;
  final int deepAgentMaxToolRounds;

  const AiAgentSettings({
    required this.preferDeepAgent,
    required this.deepAgentFallbackToQa,
    required this.deepAgentReflectionMode,
    required this.deepAgentShowDetails,
    required this.deepAgentMaxPlanSteps,
    required this.deepAgentMaxToolRounds,
  });

  AiAgentSettings copyWith({
    bool? preferDeepAgent,
    bool? deepAgentFallbackToQa,
    DeepAgentReflectionMode? deepAgentReflectionMode,
    bool? deepAgentShowDetails,
    int? deepAgentMaxPlanSteps,
    int? deepAgentMaxToolRounds,
  }) {
    return AiAgentSettings(
      preferDeepAgent: preferDeepAgent ?? this.preferDeepAgent,
      deepAgentFallbackToQa:
          deepAgentFallbackToQa ?? this.deepAgentFallbackToQa,
      deepAgentReflectionMode:
          deepAgentReflectionMode ?? this.deepAgentReflectionMode,
      deepAgentShowDetails: deepAgentShowDetails ?? this.deepAgentShowDetails,
      deepAgentMaxPlanSteps:
          deepAgentMaxPlanSteps ?? this.deepAgentMaxPlanSteps,
      deepAgentMaxToolRounds:
          deepAgentMaxToolRounds ?? this.deepAgentMaxToolRounds,
    );
  }
}

class AiAgentSettingsNotifier extends StateNotifier<AiAgentSettings> {
  AiAgentSettingsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static AiAgentSettings _load(SharedPreferences prefs) {
    final preferDeepAgent = prefs.getBool(_preferDeepAgentKey) ?? true;
    final fallbackToQa = prefs.getBool(_deepAgentFallbackToQaKey) ?? true;
    final reflectionMode = DeepAgentReflectionModeCodec.fromWireValue(
      prefs.getString(_deepAgentReflectionModeKey),
    );
    final showDetails = prefs.getBool(_deepAgentShowDetailsKey) ?? false;
    final maxPlanSteps = _clampInt(
      prefs.getInt(_deepAgentMaxPlanStepsKey),
      6,
      1,
      12,
    );
    final maxToolRounds = _clampInt(
      prefs.getInt(_deepAgentMaxToolRoundsKey),
      8,
      1,
      20,
    );

    return AiAgentSettings(
      preferDeepAgent: preferDeepAgent,
      deepAgentFallbackToQa: fallbackToQa,
      deepAgentReflectionMode: reflectionMode,
      deepAgentShowDetails: showDetails,
      deepAgentMaxPlanSteps: maxPlanSteps,
      deepAgentMaxToolRounds: maxToolRounds,
    );
  }

  static int _clampInt(int? value, int fallback, int min, int max) {
    if (value == null) return fallback;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Future<void> setPreferDeepAgent(bool value) async {
    await _prefs.setBool(_preferDeepAgentKey, value);
    state = state.copyWith(preferDeepAgent: value);
  }

  Future<void> setDeepAgentFallbackToQa(bool value) async {
    await _prefs.setBool(_deepAgentFallbackToQaKey, value);
    state = state.copyWith(deepAgentFallbackToQa: value);
  }

  Future<void> setDeepAgentReflectionMode(DeepAgentReflectionMode mode) async {
    await _prefs.setString(_deepAgentReflectionModeKey, mode.wireValue);
    state = state.copyWith(deepAgentReflectionMode: mode);
  }

  Future<void> setDeepAgentShowDetails(bool value) async {
    await _prefs.setBool(_deepAgentShowDetailsKey, value);
    state = state.copyWith(deepAgentShowDetails: value);
  }

  Future<void> setDeepAgentMaxPlanSteps(int value) async {
    final v = _clampInt(value, 6, 1, 12);
    await _prefs.setInt(_deepAgentMaxPlanStepsKey, v);
    state = state.copyWith(deepAgentMaxPlanSteps: v);
  }

  Future<void> setDeepAgentMaxToolRounds(int value) async {
    final v = _clampInt(value, 8, 1, 20);
    await _prefs.setInt(_deepAgentMaxToolRoundsKey, v);
    state = state.copyWith(deepAgentMaxToolRounds: v);
  }
}

final aiAgentSettingsProvider =
    StateNotifierProvider<AiAgentSettingsNotifier, AiAgentSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AiAgentSettingsNotifier(prefs);
    });
