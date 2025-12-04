import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/supabase_config.dart';

class AgentsConfigService {
  final String baseUrl;
  AgentsConfigService(this.baseUrl);

  Future<Map<String, dynamic>?> getEffective(String agentType) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}configs/agents/$agentType/effective'
        : '$baseUrl/configs/agents/$agentType/effective';
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
    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode >= 400) return null;
    try {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> list(String agentType) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}configs/agents/$agentType'
        : '$baseUrl/configs/agents/$agentType';
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
    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode >= 400) return [];
    try {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> saveMyVersion(
    String agentType,
    Map<String, dynamic> payload,
  ) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}configs/agents/$agentType'
        : '$baseUrl/configs/agents/$agentType';
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
    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 400) return null;
    try {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMyVersion(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}configs/agents/$id'
        : '$baseUrl/configs/agents/$id';
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
    final res = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 400) return null;
    try {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> resetToPublic(String id) async {
    final url = baseUrl.endsWith('/')
        ? '${baseUrl}configs/agents/$id'
        : '$baseUrl/configs/agents/$id';
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
    final res = await http.delete(Uri.parse(url), headers: headers);
    return res.statusCode < 400;
  }
}

final agentsConfigServiceProvider = Provider<AgentsConfigService>((ref) {
  String url;
  try {
    url = ref.watch(aiServiceProvider);
  } catch (_) {
    url = 'http://localhost:5600/';
  }
  return AgentsConfigService(url);
});
