import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/supabase_config.dart';
import '../../models/snowflake.dart';

class SnowflakeService {
  final String baseUrl;
  final http.Client? _client;

  SnowflakeService(this.baseUrl, {http.Client? client}) : _client = client;

  Future<SnowflakeRefinementOutput?> refineSummary(
    SnowflakeRefinementInput input,
  ) async {
    try {
      final url = baseUrl.endsWith('/')
          ? '${baseUrl}snowflake/refine'
          : '$baseUrl/snowflake/refine';
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
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return SnowflakeRefinementOutput.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final snowflakeServiceProvider = Provider<SnowflakeService>((ref) {
  String url;
  try {
    url = ref.watch(aiServiceProvider);
  } catch (_) {
    url = 'http://localhost:5600/';
  }
  return SnowflakeService(url);
});
