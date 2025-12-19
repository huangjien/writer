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

class RemoteRepository {
  final String baseUrl;
  final http.Client? _client;

  RemoteRepository(this.baseUrl, {http.Client? client}) : _client = client;

  Future<String?> fetchCharacterProfile(String name) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}characters/profile'
        : '$baseUrl/characters/profile';

    String? token;
    if (supabaseEnabled) {
      final client = Supabase.instance.client;
      token = client.auth.currentSession?.accessToken;
      if (token == null && client.auth.currentUser != null) {
        try {
          await client.auth.refreshSession();
          token = client.auth.currentSession?.accessToken;
        } catch (_) {}
      }
    }

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic> &&
            data.containsKey('character_profile')) {
          return data['character_profile'] as String;
        }
      }
    } catch (_) {
      // Handle error or return null
    }
    return null;
  }

  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}agents/character-convert'
        : '$baseUrl/agents/character-convert';

    String? token;
    if (supabaseEnabled) {
      final client = Supabase.instance.client;
      token = client.auth.currentSession?.accessToken;
      if (token == null && client.auth.currentUser != null) {
        try {
          await client.auth.refreshSession();
          token = client.auth.currentSession?.accessToken;
        } catch (_) {}
      }
    }

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'template_content': templateContent,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic> && data.containsKey('result')) {
          return data['result'] as String;
        }
      }
    } catch (_) {
      // Handle error or return null
    }
    return null;
  }

  Future<String?> fetchSceneProfile(String name) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}scenes/profile'
        : '$baseUrl/scenes/profile';

    String? token;
    if (supabaseEnabled) {
      final client = Supabase.instance.client;
      token = client.auth.currentSession?.accessToken;
      if (token == null && client.auth.currentUser != null) {
        try {
          await client.auth.refreshSession();
          token = client.auth.currentSession?.accessToken;
        } catch (_) {}
      }
    }

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic> && data.containsKey('scene_profile')) {
          return data['scene_profile'] as String;
        }
      }
    } catch (_) {
      // Handle error or return null
    }
    return null;
  }

  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}scenes/convert'
        : '$baseUrl/scenes/convert';

    String? token;
    if (supabaseEnabled) {
      final client = Supabase.instance.client;
      token = client.auth.currentSession?.accessToken;
      if (token == null && client.auth.currentUser != null) {
        try {
          await client.auth.refreshSession();
          token = client.auth.currentSession?.accessToken;
        } catch (_) {}
      }
    }

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'template': templateContent,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic> && data.containsKey('result')) {
          return data['result'] as String;
        }
      }
    } catch (_) {
      // Handle error or return null
    }
    return null;
  }
}
