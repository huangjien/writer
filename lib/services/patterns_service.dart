import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pattern.dart';
import '../shared/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class PatternsService {
  final String baseUrl;
  final String? sessionId;
  String? authToken;
  Duration timeout;
  bool _loading = false;
  final http.Client? _client;

  PatternsService({
    required this.baseUrl,
    this.sessionId,
    this.authToken,
    Duration? timeout,
    http.Client? client,
  }) : timeout = timeout ?? kLlmTimeout,
       _client = client;

  bool get isLoading => _loading;
  void setAuthToken(String? token) => authToken = token;

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$p');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? json,
  }) async {
    _loading = true;
    try {
      final uri = _buildUri(path, query);
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (sessionId != null && sessionId!.trim().isNotEmpty) {
        headers['x-session-id'] = sessionId!;
      }
      if (authToken != null && authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      final client = _client ?? http.Client();
      http.Response res;
      switch (method.toUpperCase()) {
        case 'GET':
          res = await client.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          res = await client
              .post(uri, headers: headers, body: jsonEncode(json))
              .timeout(timeout);
          break;
        case 'PATCH':
          res = await client
              .patch(uri, headers: headers, body: jsonEncode(json))
              .timeout(timeout);
          break;
        case 'DELETE':
          res = await client.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw ApiException(0, 'Unsupported method');
      }
      final status = res.statusCode;
      final body = res.body;
      if (status >= 400) {
        throw ApiException(status, body.isEmpty ? 'Request failed' : body);
      }
      if (body.isEmpty) return {};
      final data = jsonDecode(body);
      return data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, e.toString());
    } finally {
      _loading = false;
    }
  }

  Future<List<Pattern>> fetchPatterns() async {
    final data = await _send('GET', '/patterns/');
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : []);
    return list
        .map((e) => Pattern.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Pattern> getPattern(String id) async {
    final data = await _send('GET', '/patterns/$id');
    return Pattern.fromMap(Map<String, dynamic>.from(data));
  }

  Future<Pattern> createPattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
    bool? isPublic,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
    };
    if (language != null) payload['language'] = language;
    if (isPublic != null) payload['is_public'] = isPublic;
    final data = await _send('POST', '/patterns/', json: payload);
    return Pattern.fromMap(Map<String, dynamic>.from(data));
  }

  Future<Pattern> updatePattern({
    required String id,
    String? title,
    String? description,
    String? content,
    Map<String, dynamic>? usageRules,
    String? language,
    bool? isPublic,
    bool? locked,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (content != null) payload['content'] = content;
    if (usageRules != null) payload['usage_rules'] = usageRules;
    if (language != null) payload['language'] = language;
    if (isPublic != null) payload['is_public'] = isPublic;
    if (locked != null) payload['locked'] = locked;
    final data = await _send('PATCH', '/patterns/$id', json: payload);
    return Pattern.fromMap(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>> improvePattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    String? language,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
    };
    if (language != null) payload['language'] = language;
    final data = await _send('POST', '/patterns/improve', json: payload);
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(0, 'Invalid improvePattern response');
  }

  Future<bool> deletePattern(String id) async {
    final data = await _send('DELETE', '/patterns/$id');
    if (data is Map && data['deleted'] is bool) return data['deleted'] as bool;
    return false;
  }

  Future<List<Pattern>> searchPatterns(String query) async {
    final data = await _send('GET', '/patterns/search', query: {'q': query});
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : []);
    return list
        .map((e) => Pattern.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Pattern>> smartSearchPatterns(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    final data = await _send(
      'POST',
      '/patterns/search_vector',
      json: {'query': query, 'limit': limit, 'offset': offset},
    );
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : []);
    return list
        .map((e) => Pattern.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
