import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/storage_service_provider.dart';

const String _sessionIdKey = 'backend_session_id';
const String _refreshTokenKey = 'backend_refresh_token';

class SessionNotifier extends StateNotifier<String?> {
  final StorageService _storage;

  SessionNotifier(this._storage, [String? initialState])
    : super(initialState ?? _storage.getString(_sessionIdKey));

  Future<void> setSessionId(String? sessionId) async {
    if (sessionId == null || sessionId.trim().isEmpty) {
      await clear();
      return;
    }
    // Update state synchronously first to ensure immediate UI update
    state = sessionId;
    // Then persist to storage asynchronously
    try {
      await _storage.setString(_sessionIdKey, sessionId);
      // Verify the state is still set after storage operation
      // This handles edge cases where provider might be rebuilt during async operation
      if (state != sessionId) {
        state = sessionId;
      }
    } catch (e) {
      // If storage fails, still keep the in-memory state
      // This allows login to work even if persistence fails
    }
  }

  Future<void> setRefreshToken(String? refreshToken) async {
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await _storage.remove(_refreshTokenKey);
      return;
    }
    await _storage.setString(_refreshTokenKey, refreshToken);
  }

  String? getRefreshToken() {
    return _storage.getString(_refreshTokenKey);
  }

  Future<void> clear() async {
    state = null;
    await _storage.remove(_sessionIdKey);
    await _storage.remove(_refreshTokenKey);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, String?>((ref) {
  final storage = ref.read(storageServiceProvider);
  return SessionNotifier(storage);
});
