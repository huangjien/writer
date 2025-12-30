import 'dart:convert';
import 'package:http/http.dart' as http;

/// Abstract service for vector operations
///
/// This abstraction allows for easy testing by providing mock implementations.
abstract class VectorService {
  /// Get embedding for a character template
  Future<String?> getCharacterTemplateEmbedding(String templateId);

  /// Get embedding for a scene template
  Future<String?> getSceneTemplateEmbedding(String templateId);

  /// Refresh embedding for a chapter
  Future<void> refreshChapterEmbedding(String chapterId);
}

/// Remote implementation of VectorService that communicates with backend
class RemoteVectorService implements VectorService {
  final String baseUrl;
  final http.Client _client;

  RemoteVectorService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<String?> getCharacterTemplateEmbedding(String templateId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/templates/character/$templateId/embedding'),
      );
      if (response.statusCode == 200) {
        final data = _decodeUtf8(response.bodyBytes);
        return data['embedding'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getSceneTemplateEmbedding(String templateId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/templates/scene/$templateId/embedding'),
      );
      if (response.statusCode == 200) {
        final data = _decodeUtf8(response.bodyBytes);
        return data['embedding'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> refreshChapterEmbedding(String chapterId) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/chapters/$chapterId/refresh_embedding'),
      );
    } catch (_) {
      // Ignore errors
    }
  }

  /// Decode UTF-8 bytes to a JSON map
  Map<String, dynamic> _decodeUtf8(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }
}
