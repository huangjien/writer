import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

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
  final Duration _okInterval = const Duration(minutes: 8);
  final Duration _failInterval = const Duration(minutes: 2);

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
