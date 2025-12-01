import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _aiServiceUrlKey = 'ai_service_url';
const String _defaultAiServiceUrl = String.fromEnvironment(
  'AI_SERVICE_URL',
  defaultValue: 'http://localhost:5600/',
);

class AiServiceNotifier extends StateNotifier<String> {
  AiServiceNotifier(this._prefs)
    : super(_prefs.getString(_aiServiceUrlKey) ?? _defaultAiServiceUrl);

  final SharedPreferences _prefs;

  Future<void> setAiServiceUrl(String url) async {
    await _prefs.setString(_aiServiceUrlKey, url);
    state = url;
  }

  Future<void> resetToDefault() async {
    await _prefs.setString(_aiServiceUrlKey, _defaultAiServiceUrl);
    state = _defaultAiServiceUrl;
  }
}

final aiServiceProvider = StateNotifierProvider<AiServiceNotifier, String>((
  ref,
) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});
