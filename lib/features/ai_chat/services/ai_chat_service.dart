import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'package:writer/state/ai_agent_settings.dart';

class AiChatService {
  final RemoteRepository remote;

  AiChatService(this.remote);

  String? _extractTextAnswer(dynamic res) {
    if (res is! Map) return null;
    final answer = res['answer'];
    if (answer is String) return answer;
    final reply = res['reply'];
    if (reply is String) return reply;
    final response = res['response'];
    if (response is String) return response;
    return null;
  }

  String _formatError(Object e) {
    if (e.toString().contains('401')) {
      return 'Sign in required to use AI service';
    }
    if (e.toString().contains('403')) {
      return 'Feature not available for your plan';
    }
    return 'Failed to connect to AI service: $e';
  }

  String _formatDeepAgentResponse(dynamic res, {required bool includeDetails}) {
    final answer = _extractTextAnswer(res) ?? 'No response from AI service';
    if (!includeDetails || res is! Map) return answer;

    final sb = StringBuffer();
    sb.writeln(answer);

    final plan = res['plan'];
    final toolEvents = res['tool_events'];
    final stopReason = res['stop_reason'];
    final rounds = res['rounds'];

    sb.writeln('');
    sb.writeln('---');
    sb.writeln('Deep Agent');
    if (stopReason != null || rounds != null) {
      sb.writeln('Stop: ${stopReason ?? '-'} (rounds: ${rounds ?? '-'})');
    }

    if (plan is Map) {
      final steps = plan['steps'];
      if (steps is List) {
        final stepStrings = steps.whereType<String>().toList();
        if (stepStrings.isNotEmpty) {
          sb.writeln('');
          sb.writeln('Plan:');
          for (final step in stepStrings) {
            sb.writeln('- $step');
          }
        }
      }
    }

    if (toolEvents is List) {
      final eventMaps = toolEvents.whereType<Map>().toList();
      if (eventMaps.isNotEmpty) {
        sb.writeln('');
        sb.writeln('Tools:');
        for (final e in eventMaps) {
          final round = e['round'];
          final tool = e['tool'];
          final args = e['args'];
          sb.writeln('- [${round ?? '-'}] ${tool ?? '-'} ${args ?? {}}');
        }
      }
    }

    return sb.toString().trimRight();
  }

  Future<String> _sendQa(String message) async {
    final res = await remote.post('agents/qa', {'question': message});
    final answer = _extractTextAnswer(res);
    return answer ?? 'No response from AI service';
  }

  Future<String> sendMessage(
    String message, {
    AiAgentSettings? settings,
  }) async {
    try {
      final preferDeepAgent = settings?.preferDeepAgent ?? true;
      if (!preferDeepAgent) {
        return await _sendQa(message);
      }

      final fallbackToQa = settings?.deepAgentFallbackToQa ?? true;
      final reflectionMode =
          (settings?.deepAgentReflectionMode ?? DeepAgentReflectionMode.off)
              .wireValue;
      final includeDetails = settings?.deepAgentShowDetails ?? false;
      final maxPlanSteps = settings?.deepAgentMaxPlanSteps;
      final maxToolRounds = settings?.deepAgentMaxToolRounds;

      try {
        final res = await remote.post('agents/deep-agent', {
          'question': message,
          if (maxPlanSteps != null) 'max_plan_steps': maxPlanSteps,
          if (maxToolRounds != null) 'max_tool_rounds': maxToolRounds,
          'reflection_mode': reflectionMode,
        });
        return _formatDeepAgentResponse(res, includeDetails: includeDetails);
      } catch (e) {
        if (fallbackToQa &&
            e is ApiException &&
            (e.statusCode == 404 || e.statusCode == 501)) {
          return await _sendQa(message);
        }
        rethrow;
      }
    } catch (e) {
      return _formatError(e);
    }
  }

  Future<String> sendMessageDeepAgent(
    String message, {
    String? context,
    int? maxPlanSteps,
    int? maxToolRounds,
    String reflectionMode = 'off',
    bool includeDetails = false,
  }) async {
    try {
      final body = <String, dynamic>{
        'question': message,
        if (context != null) 'context': context,
        if (maxPlanSteps != null) 'max_plan_steps': maxPlanSteps,
        if (maxToolRounds != null) 'max_tool_rounds': maxToolRounds,
        'reflection_mode': reflectionMode,
      };

      final res = await remote.post('agents/deep-agent', body);
      return _formatDeepAgentResponse(res, includeDetails: includeDetails);
    } catch (e) {
      return _formatError(e);
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

  Future<String> compressContext(String context) async {
    try {
      final body = <String, dynamic>{
        'question':
            'Please summarize and compress the following context into a concise version that preserves the most important information. Use bullet points where appropriate.',
        'context': context,
        'max_plan_steps': 3,
        'max_tool_rounds': 3,
        'reflection_mode': 'off',
      };

      final res = await remote.post('agents/deep-agent', body);
      return _formatDeepAgentResponse(res, includeDetails: false);
    } catch (e) {
      return _formatError(e);
    }
  }

  Future<Map<String, dynamic>?> ragSearch({
    required String query,
    String? category,
    int initialTopK = 10,
    int finalTopK = 5,
    bool refinementEnabled = true,
  }) async {
    try {
      final body = {
        'query': query,
        if (category != null) 'category': category,
        'initial_top_k': initialTopK,
        'final_top_k': finalTopK,
        'refinement_enabled': refinementEnabled,
      };
      final res = await remote.post('rag/search', body);
      if (res is Map) {
        return res.cast<String, dynamic>();
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
