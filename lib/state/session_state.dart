import 'package:flutter_riverpod/legacy.dart';
import '../services/storage_service.dart';
import 'storage_service_provider.dart';

const String _sessionIdKey = 'backend_session_id';

class SessionNotifier extends StateNotifier<String?> {
  final StorageService _storage;

  SessionNotifier(this._storage, [String? initialState])
    : super(initialState ?? _storage.getString(_sessionIdKey));

  Future<void> setSessionId(String? sessionId) async {
    if (sessionId == null || sessionId.trim().isEmpty) {
      await clear();
      return;
    }
    state = sessionId;
    await _storage.setString(_sessionIdKey, sessionId);
  }

  Future<void> clear() async {
    state = null;
    await _storage.remove(_sessionIdKey);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, String?>((ref) {
  return SessionNotifier(ref.read(storageServiceProvider));
});
