import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/api_exception.dart';

class AiChatService {
  final RemoteRepository remote;

  AiChatService(this.remote);

  Future<String> sendMessage(String message) async {
    try {
      final res = await remote.post('agents/qa', {'question': message});

      if (res is Map) {
        final answer = res['answer'];
        if (answer is String) return answer;
        final reply = res['reply'];
        if (reply is String) return reply;
        final response = res['response'];
        if (response is String) return response;
      }
      return 'No response from AI service';
    } catch (e) {
      if (e.toString().contains('401')) {
        return 'Sign in required to use AI service';
      }
      if (e.toString().contains('403')) {
        return 'Feature not available for your plan';
      }
      return 'Failed to connect to AI service: $e';
    }
  }

  Future<bool> checkHealth() async {
    try {
      final res = await remote.get('health');
      if (res is Map && res['ai'] is Map) {
        final ai = res['ai'] as Map;
        final ok = ai['access_ok'];
        if (ok is bool) return ok;
      }
      return true;
    } catch (e) {
      if (e is FormatException) return true;
      if (e is ApiException &&
          e.rawMessage != null &&
          e.rawMessage!.contains('FormatException')) {
        return true;
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyUser() async {
    try {
      final res = await remote.get('auth/verify');
      return res is Map<String, dynamic> ? res : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<double>?> embed(String input, {String? model}) async {
    try {
      final body = {'input': input, if (model != null) 'model': model};
      final res = await remote.post('vectors/embed', body);
      if (res is Map && res['vector'] is List) {
        return (res['vector'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    try {
      final body = {
        'novel_id': novelId,
        'chapter_id': chapterId,
        'content': content,
        'language': language,
      };
      final res = await remote.post('beta/evaluate', body);
      if (res is Map && res['evaluation'] is Map) {
        return (res['evaluation'] as Map).cast<String, dynamic>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService(ref.watch(remoteRepositoryProvider));
});
