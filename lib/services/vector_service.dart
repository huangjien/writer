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
        final data = jsonDecode(response.body);
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
}
