import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class VectorService {
  final String baseUrl;
  final String? sessionId;
  final String? authToken;
  final http.Client? _client;

  VectorService({
    required this.baseUrl,
    this.sessionId,
    this.authToken,
    http.Client? client,
  }) : _client = client;

  Uri _buildUri(String path) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> json) async {
    final uri = _buildUri(path);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (sessionId != null && sessionId!.trim().isNotEmpty) {
      headers['x-session-id'] = sessionId!;
    }
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    final response = await (_client ?? http.Client())
        .post(uri, headers: headers, body: jsonEncode(json))
        .timeout(kLlmTimeout);
    if (response.body.isEmpty) return {};
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<double>> embed(String input) async {
    if (input.trim().isEmpty) return [];

    final uri = _buildUri('/vectors/embed');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (sessionId != null && sessionId!.trim().isNotEmpty) {
      headers['x-session-id'] = sessionId!;
    }
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    try {
      final response = await (_client ?? http.Client())
          .post(uri, headers: headers, body: jsonEncode({'input': input}))
          .timeout(kLlmTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map && data['vector'] is List) {
          return (data['vector'] as List)
              .cast<num>()
              .map((e) => e.toDouble())
              .toList();
        }
      }
    } catch (e) {
      // Fail silently to allow save to proceed without vector
    }
    return [];
  }

  Future<void> refreshChapterEmbedding(String chapterId) async {
    if (chapterId.trim().isEmpty) return;
    try {
      await _postJson('/chapters/$chapterId/refresh_embedding', const {});
    } catch (_) {}
  }

  Future<void> refreshSceneTemplateEmbedding(String templateId) async {
    if (templateId.trim().isEmpty) return;
    try {
      await _postJson(
        '/templates/scenes/$templateId/refresh_embedding',
        const {},
      );
    } catch (_) {}
  }

  Future<void> refreshCharacterTemplateEmbedding(String templateId) async {
    if (templateId.trim().isEmpty) return;
    try {
      await _postJson(
        '/templates/characters/$templateId/refresh_embedding',
        const {},
      );
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> searchSceneTemplates({
    required String query,
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    if (query.trim().isEmpty) return const [];
    final data = await _postJson('/templates/scenes/search', {
      'query': query,
      'limit': limit,
      'offset': offset,
      if (languageCode != null) 'language_code': languageCode,
    });
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> searchCharacterTemplates({
    required String query,
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    if (query.trim().isEmpty) return const [];
    final data = await _postJson('/templates/characters/search', {
      'query': query,
      'limit': limit,
      'offset': offset,
      if (languageCode != null) 'language_code': languageCode,
    });
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }
}
