import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/models/chat_session.dart';
import 'package:writer/state/storage_service_provider.dart';

class ChatStorageService {
  final SharedPreferences _prefs;
  static const _key = 'ai_chat_sessions';

  ChatStorageService(this._prefs);

  List<ChatSession> loadSessions() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => ChatSession.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSessions(List<ChatSession> sessions) async {
    final jsonString = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}

final chatStorageServiceProvider = Provider<ChatStorageService>((ref) {
  return ChatStorageService(ref.watch(sharedPreferencesProvider));
});
