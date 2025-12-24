import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _sessionIdKey = 'backend_session_id';

class SessionNotifier extends StateNotifier<String?> {
  SessionNotifier([this._prefs]) : super(_prefs?.getString(_sessionIdKey));

  final SharedPreferences? _prefs;

  Future<void> setSessionId(String? sessionId) async {
    if (sessionId == null || sessionId.trim().isEmpty) {
      await clear();
      return;
    }
    state = sessionId;
    await _prefs?.setString(_sessionIdKey, sessionId);
  }

  Future<void> clear() async {
    state = null;
    await _prefs?.remove(_sessionIdKey);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, String?>((ref) {
  return SessionNotifier();
});
