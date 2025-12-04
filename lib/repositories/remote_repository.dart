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

  Future<Map<String, dynamic>?> fetchCharacterProfile(String name) async {
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
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> &&
            data.containsKey('character_profile')) {
          return data['character_profile'] as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Handle error or return null
    }
    return null;
  }
}
