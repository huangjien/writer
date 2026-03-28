import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/services/voice_input_service.dart';

@immutable
class VoiceInputState {
  final bool isInitialized;
  final bool isInitializing;
  final bool isListening;
  final bool hasPermission;
  final String currentText;
  final String? error;

  const VoiceInputState({
    this.isInitialized = false,
    this.isInitializing = false,
    this.isListening = false,
    this.hasPermission = false,
    this.currentText = '',
    this.error,
  });

  VoiceInputState copyWith({
    bool? isInitialized,
    bool? isInitializing,
    bool? isListening,
    bool? hasPermission,
    String? currentText,
    String? error,
  }) {
    return VoiceInputState(
      isInitialized: isInitialized ?? this.isInitialized,
      isInitializing: isInitializing ?? this.isInitializing,
      isListening: isListening ?? this.isListening,
      hasPermission: hasPermission ?? this.hasPermission,
      currentText: currentText ?? this.currentText,
      error: error,
    );
  }
}

final voiceInputServiceProvider = Provider<VoiceInputService>((ref) {
  final service = VoiceInputService();
  ref.onDispose(service.dispose);
  return service;
});

final voiceInputProvider =
    NotifierProvider<VoiceInputNotifier, VoiceInputState>(
      VoiceInputNotifier.new,
    );

class VoiceInputNotifier extends Notifier<VoiceInputState> {
  VoiceInputService get _service => ref.watch(voiceInputServiceProvider);

  @override
  VoiceInputState build() {
    return const VoiceInputState();
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isInitializing: true);

    try {
      final initialized = await _service.initialize();
      final hasPermission = await _service.checkPermissionStatus();

      state = state.copyWith(
        isInitialized: initialized,
        isInitializing: false,
        hasPermission: hasPermission,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        isInitializing: false,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  Future<void> startListening({
    VoidCallback? onListeningStart,
    VoidCallback? onListeningEnd,
  }) async {
    if (state.isListening) return;

    if (!state.isInitialized) {
      await initialize();
    }

    if (!state.hasPermission) {
      state = state.copyWith(error: 'Microphone permission not granted');
      return;
    }

    try {
      await _service.startListening(
        onResult: (text) {
          state = state.copyWith(currentText: text);
        },
        onListeningStart: () {
          state = state.copyWith(isListening: true, currentText: '');
          onListeningStart?.call();
        },
        onListeningEnd: () {
          state = state.copyWith(isListening: false);
          onListeningEnd?.call();
        },
      );
    } catch (e) {
      state = state.copyWith(isListening: false, error: e.toString());
    }
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;

    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> cancelListening() async {
    await _service.cancelListening();
    state = state.copyWith(isListening: false, currentText: '');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearText() {
    state = state.copyWith(currentText: '');
  }
}
