import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/supabase_config.dart';

class AiChatService {
  final String baseUrl;
  final http.Client? _client;

  AiChatService(this.baseUrl, {http.Client? client}) : _client = client;

  Future<String> sendMessage(String message) async {
    try {
      final url = baseUrl.endsWith('/')
          ? '${baseUrl}agents/qa'
          : '$baseUrl/agents/qa';
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
      final response = await (_client ?? http.Client()).post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'question': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('answer')) {
          final v = data['answer'];
          return v is String ? v : 'No response from AI service';
        }
        if (data is Map && data.containsKey('reply')) {
          final v = data['reply'];
          return v is String ? v : 'No response from AI service';
        }
        if (data is Map && data.containsKey('response')) {
          final v = data['response'];
          return v is String ? v : 'No response from AI service';
        }
        return 'No response from AI service';
      }
      if (response.statusCode == 401) {
        return 'Sign in required to use AI service';
      }
      if (response.statusCode == 403) {
        return 'Feature not available for your plan';
      }
      throw Exception('Failed to get response: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to connect to AI service: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final healthUrl = baseUrl.endsWith('/')
          ? '${baseUrl}health'
          : '$baseUrl/health';
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
      final headers = {if (token != null) 'Authorization': 'Bearer $token'};
      final response = await (_client ?? http.Client()).get(
        Uri.parse(healthUrl),
        headers: headers,
      );
      if (response.statusCode != 200) return false;
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['ai'] is Map) {
          final ai = data['ai'] as Map;
          final ok = ai['access_ok'];
          if (ok is bool) return ok;
        }
      } catch (_) {}
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyUser() async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}auth/verify'
        : '$baseUrl/auth/verify';
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
    final response = await (_client ?? http.Client()).get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode != 200) return null;
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<double>?> embed(String input, {String? model}) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}vectors/embed'
        : '$baseUrl/vectors/embed';
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
    final body = {'input': input, if (model != null) 'model': model};
    final res = await (_client ?? http.Client()).post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode >= 400) return null;
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['vector'] is List) {
        final v = (data['vector'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
        return v;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  String url;
  try {
    url = ref.watch(aiServiceProvider);
  } catch (_) {
    url = 'http://localhost:5600/';
  }
  return AiChatService(url);
});
