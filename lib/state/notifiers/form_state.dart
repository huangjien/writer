import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class FormState {
  final bool isLoading;
  final String? error;
  final bool isDirty;

  const FormState({this.isLoading = false, this.error, this.isDirty = false});

  FormState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isDirty,
  }) {
    return FormState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class FormStateNotifier extends Notifier<FormState> {
  @override
  FormState build() => const FormState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setDirty(bool dirty) {
    state = state.copyWith(isDirty: dirty);
  }

  void reset() {
    state = const FormState();
  }
}

final formStateProvider = NotifierProvider<FormStateNotifier, FormState>(
  FormStateNotifier.new,
);
