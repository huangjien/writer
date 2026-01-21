import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/shared/constants.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const AiChatState({required this.messages, required this.isLoading});

  AiChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier(this._aiChatService)
    : super(const AiChatState(messages: [], isLoading: false));

  final AiChatService _aiChatService;

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Check for RAG command
    if (message.startsWith('/search ')) {
      await _handleRagSearch(message);
      return;
    }

    // Add user message and set loading
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(content: message, isUser: true),
      ],
      isLoading: true,
    );

    try {
      final response = await _aiChatService.sendMessage(message);

      // Add AI response and clear loading
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: response, isUser: false),
        ],
        isLoading: false,
      );
    } catch (e) {
      // Add error message and clear loading
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: 'Error: ${e.toString()}', isUser: false),
        ],
        isLoading: false,
      );
    }
  }

  Future<void> _handleRagSearch(String message) async {
    final query = message.replaceFirst('/search ', '').trim();
    if (query.isEmpty) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(content: message, isUser: true),
      ],
      isLoading: true,
    );

    try {
      final result = await _aiChatService.ragSearch(query: query);

      if (result == null) {
        throw Exception('Search failed');
      }

      final refinedQuery = result['refined_query'];
      final results = (result['results'] as List).cast<Map>();

      final sb = StringBuffer();
      sb.writeln('### RAG Search Results');
      if (refinedQuery != null) {
        sb.writeln('> Refined Query: "$refinedQuery"\n');
      }

      if (results.isEmpty) {
        sb.writeln('No results found.');
      } else {
        for (final item in results) {
          final title = item['title'] ?? 'Untitled';
          final type = item['type'] ?? 'unknown';
          final score = ((item['score'] as num) * 100).toStringAsFixed(1);
          final content = item['content'] as String? ?? '';
          final preview = content.length > 150
              ? '${content.substring(0, 150)}...'
              : content;

          sb.writeln('**$title** ($type) - $score%');
          sb.writeln(preview);
          sb.writeln('');
        }
      }

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: sb.toString(), isUser: false),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: 'Search Error: ${e.toString()}', isUser: false),
        ],
        isLoading: false,
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(messages: [], isLoading: false);
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((
  ref,
) {
  final aiChatService = ref.watch(aiChatServiceProvider);
  return AiChatNotifier(aiChatService);
});

class AiChatUiNotifier extends StateNotifier<bool> {
  AiChatUiNotifier() : super(false);

  void toggleSidebar() {
    state = !state;
  }

  void openSidebar() {
    state = true;
  }

  void closeSidebar() {
    state = false;
  }
}

final aiChatUiProvider = StateNotifierProvider<AiChatUiNotifier, bool>((ref) {
  return AiChatUiNotifier();
});

class AiServiceStatusNotifier extends StateNotifier<bool> {
  AiServiceStatusNotifier(this._aiChatService) : super(false) {
    _checkAndSchedule(initial: true);
  }

  final AiChatService _aiChatService;
  Timer? _timer;
  final Duration _okInterval = kAiHealthCheckIntervalOk;
  final Duration _failInterval = kAiHealthCheckIntervalFail;

  void _scheduleNext(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () => _checkAndSchedule());
  }

  Future<void> _checkAndSchedule({bool initial = false}) async {
    final isHealthy = await _aiChatService.checkHealth();
    if (mounted) {
      state = isHealthy;
    }
    final next = isHealthy ? _okInterval : _failInterval;
    _scheduleNext(initial ? next : next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final aiServiceStatusProvider =
    StateNotifierProvider.autoDispose<AiServiceStatusNotifier, bool>((ref) {
      final aiChatService = ref.watch(aiChatServiceProvider);
      return AiServiceStatusNotifier(aiChatService);
    });
