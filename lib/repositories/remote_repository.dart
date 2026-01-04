import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/services/auth_redirect_service.dart';

final remoteRepositoryProvider = Provider<RemoteRepository>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return RemoteRepository(
    baseUrl,
    authToken: () async => sessionId,
    onUnauthorized: () async {
      await ref.read(sessionProvider.notifier).clear();
      final authRedirectService = ref.read(authRedirectServiceProvider);
      await authRedirectService.redirectToLogin(ref);
    },
  );
});

typedef AuthTokenGetter = Future<String?> Function();

class RemoteRepository {
  final String baseUrl;
  final http.Client _client;
  final AuthTokenGetter _authToken;
  final Future<void> Function()? _onUnauthorized;

  RemoteRepository(
    this.baseUrl, {
    http.Client? client,
    AuthTokenGetter? authToken,
    Future<void> Function()? onUnauthorized,
  }) : _client = client ?? http.Client(),
       _authToken = authToken ?? (() async => null),
       _onUnauthorized = onUnauthorized;

  String _url(String path) {
    if (baseUrl.endsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    String? token;
    if (withAuth) {
      try {
        token = await _authToken();
      } catch (_) {
        token = null;
      }
    }
    final trimmed = token?.trim();
    return {
      'Content-Type': 'application/json',
      if (trimmed != null && trimmed.isNotEmpty) 'X-Session-Id': trimmed,
    };
  }

  Future<http.Response> _getWithRetry(
    Uri uri, {
    required bool retryUnauthorized,
  }) async {
    var headers = await _headers(withAuth: true);
    var response = await _client.get(uri, headers: headers);
    if (response.statusCode == 401) {
      final hadAuth = headers.containsKey('X-Session-Id');
      try {
        await _onUnauthorized?.call();
      } catch (_) {}
      if (retryUnauthorized && hadAuth) {
        headers = await _headers(withAuth: false);
        response = await _client.get(uri, headers: headers);
      }
    }
    return response;
  }

  Future<http.Response> _deleteWithRetry(
    Uri uri, {
    required bool retryUnauthorized,
  }) async {
    var headers = await _headers(withAuth: true);
    var response = await _client.delete(uri, headers: headers);
    if (response.statusCode == 401) {
      final hadAuth = headers.containsKey('X-Session-Id');
      try {
        await _onUnauthorized?.call();
      } catch (_) {}
      if (retryUnauthorized && hadAuth) {
        headers = await _headers(withAuth: false);
        response = await _client.delete(uri, headers: headers);
      }
    }
    return response;
  }

  Future<http.Response> _postWithRetry(
    Uri uri,
    Map<String, dynamic> body, {
    required bool retryUnauthorized,
  }) async {
    var headers = await _headers(withAuth: true);
    var response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final hadAuth = headers.containsKey('X-Session-Id');
      try {
        await _onUnauthorized?.call();
      } catch (_) {}
      if (retryUnauthorized && hadAuth) {
        headers = await _headers(withAuth: false);
        response = await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  Future<http.Response> _patchWithRetry(
    Uri uri,
    Map<String, dynamic> body, {
    required bool retryUnauthorized,
  }) async {
    var headers = await _headers(withAuth: true);
    var response = await _client.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final hadAuth = headers.containsKey('X-Session-Id');
      try {
        await _onUnauthorized?.call();
      } catch (_) {}
      if (retryUnauthorized && hadAuth) {
        headers = await _headers(withAuth: false);
        response = await _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    try {
      final uri = Uri.parse(
        _url(path),
      ).replace(queryParameters: queryParameters);
      final response = await _getWithRetry(
        uri,
        retryUnauthorized: retryUnauthorized,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Request failed: ${response.statusCode} ${response.body}',
        );
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    try {
      final response = await _postWithRetry(
        Uri.parse(_url(path)),
        body,
        retryUnauthorized: retryUnauthorized,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Request failed: ${response.statusCode} ${response.body}',
        );
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    try {
      final response = await _patchWithRetry(
        Uri.parse(_url(path)),
        body,
        retryUnauthorized: retryUnauthorized,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Request failed: ${response.statusCode} ${response.body}',
        );
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = false,
  }) async {
    try {
      final uri = Uri.parse(
        _url(path),
      ).replace(queryParameters: queryParameters);
      final response = await _deleteWithRetry(
        uri,
        retryUnauthorized: retryUnauthorized,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Request failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deprecated usage mapping to new methods
  Future<Map<String, dynamic>?> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await post(path, payload);
      if (res is Map<String, dynamic>) return res;
      return null;
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

  Future<TokenUsage?> getCurrentMonthUsage() async {
    final data = await get('token-usage/current-month');
    if (data == null) return null;
    return TokenUsage.fromJson(data);
  }

  Future<TokenUsageHistory?> getUsageHistory({
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    final data = await get('token-usage/history', queryParameters: queryParams);
    if (data == null) return null;
    return TokenUsageHistory.fromJson(data);
  }

  Future<String?> getAdminLogs({int lines = 1000}) async {
    final data = await get(
      'admin/logs',
      queryParameters: {'lines': lines.toString()},
    );
    if (data is Map<String, dynamic>) {
      return data['logs'] as String?;
    }
    return null;
  }
}
