import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/ai_service_settings.dart';

class AiChatService {
  final String baseUrl;

  AiChatService(this.baseUrl);

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response from AI service';
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to AI service: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final healthUrl = baseUrl.endsWith('/')
          ? '${baseUrl}health'
          : '$baseUrl/health';
      final response = await http.get(Uri.parse(healthUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
