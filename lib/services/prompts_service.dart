import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/prompt.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class PromptsService {
  final String baseUrl;
  String? authToken;
  Duration timeout;
  bool _loading = false;
  final http.Client? _client;

  PromptsService({
    required this.baseUrl,
    this.authToken,
    Duration? timeout,
    http.Client? client,
  }) : timeout = timeout ?? const Duration(seconds: 30),
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

  Future<List<Prompt>> fetchPrompts({bool? isPublic}) async {
    final data = await _send(
      'GET',
      isPublic == true ? '/prompts/public' : '/prompts/',
    );
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : []);
    return list
        .map((e) => Prompt.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Prompt>> searchPrompts(String query, {bool? isPublic}) async {
    final q = <String, dynamic>{'q': query};
    if (isPublic != null) {
      q['is_public'] = isPublic;
    }
    final data = await _send('GET', '/prompts/search', query: q);
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : [];
    return list
        .map((e) => Prompt.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Prompt> getPrompt(String id) async {
    final data = await _send('GET', '/prompts/$id');
    return Prompt.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Prompt> createPrompt({
    required String promptKey,
    required String language,
    required String content,
    bool isPublic = false,
  }) async {
    final data = await _send(
      'POST',
      isPublic ? '/prompts/public' : '/prompts/',
      json: {'prompt_key': promptKey, 'language': language, 'content': content},
    );
    return Prompt.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Prompt> updatePrompt({
    required String id,
    required String content,
  }) async {
    final data = await _send(
      'PATCH',
      '/prompts/$id',
      json: {'content': content},
    );
    return Prompt.fromJson(Map<String, dynamic>.from(data));
  }

  Future<bool> deletePrompt(String id) async {
    final data = await _send('DELETE', '/prompts/$id');
    if (data is Map && data['deleted'] is bool) return data['deleted'] as bool;
    return false;
  }
}
