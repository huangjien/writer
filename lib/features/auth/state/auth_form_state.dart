import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFormState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AuthFormState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AuthFormState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setSuccess(String? message) {
    state = state.copyWith(successMessage: message);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  void reset() {
    state = const AuthFormState();
  }
}

final authFormProvider = NotifierProvider<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);
