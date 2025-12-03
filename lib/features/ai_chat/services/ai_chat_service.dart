import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/supabase_config.dart';

class AiChatService {
  final String baseUrl;

  AiChatService(this.baseUrl);

  Future<String> sendMessage(String message) async {
    try {
      final url = baseUrl.endsWith('/')
          ? '${baseUrl}agents/qa'
          : '$baseUrl/agents/qa';
      final headers = {
        'Content-Type': 'application/json',
        if (supabaseEnabled)
          if (Supabase.instance.client.auth.currentSession?.accessToken != null)
            'Authorization':
                'Bearer ${Supabase.instance.client.auth.currentSession!.accessToken}',
      };
      final response = await http.post(
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
      final headers = {
        if (supabaseEnabled)
          if (Supabase.instance.client.auth.currentSession?.accessToken != null)
            'Authorization':
                'Bearer ${Supabase.instance.client.auth.currentSession!.accessToken}',
      };
      final response = await http.get(Uri.parse(healthUrl), headers: headers);
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
    final headers = {
      'Content-Type': 'application/json',
      if (supabaseEnabled)
        if (Supabase.instance.client.auth.currentSession?.accessToken != null)
          'Authorization':
              'Bearer ${Supabase.instance.client.auth.currentSession!.accessToken}',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) return null;
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : null;
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
