import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final remoteRepositoryProvider = Provider<RemoteRepository>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  return RemoteRepository(baseUrl);
});

typedef AuthTokenGetter = Future<String?> Function();

class RemoteRepository {
  final String baseUrl;
  final http.Client _client;
  final AuthTokenGetter _authToken;

  RemoteRepository(
    this.baseUrl, {
    http.Client? client,
    AuthTokenGetter? authToken,
  }) : _client = client ?? http.Client(),
       _authToken = authToken ?? _defaultAuthToken;

  static Future<String?> _defaultAuthToken() async {
    if (!supabaseEnabled) return null;
    final client = Supabase.instance.client;
    var token = client.auth.currentSession?.accessToken;
    if (token == null && client.auth.currentUser != null) {
      try {
        await client.auth.refreshSession();
        token = client.auth.currentSession?.accessToken;
      } catch (_) {}
    }
    return token;
  }

  String _url(String path) {
    if (baseUrl.endsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  Future<Map<String, dynamic>?> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    String? token;
    try {
      token = await _authToken();
    } catch (_) {
      token = null;
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.post(
        Uri.parse(_url(path)),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _postStringField(
    String path,
    Map<String, dynamic> payload,
    String field,
  ) async {
    final data = await _postJson(path, payload);
    final v = data?[field];
    if (v is String) return v;
    return null;
  }

  Future<String?> fetchCharacterProfile(String name) async {
    return _postStringField('characters/profile', {
      'name': name,
    }, 'character_profile');
  }

  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return _postStringField('agents/character-convert', {
      'name': name,
      'template_content': templateContent,
      'language': language,
    }, 'result');
  }

  Future<String?> fetchSceneProfile(String name) async {
    return _postStringField('scenes/profile', {'name': name}, 'scene_profile');
  }

  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    return _postStringField('scenes/convert', {
      'name': name,
      'template': templateContent,
      'language': language,
    }, 'result');
  }
}
