import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInState {
  final bool isLoading;
  final bool isBiometricLoading;
  final bool obscurePassword;
  final String? error;

  const SignInState({
    this.isLoading = false,
    this.isBiometricLoading = false,
    this.obscurePassword = true,
    this.error,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? isBiometricLoading,
    bool? obscurePassword,
    String? error,
    bool clearError = false,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      isBiometricLoading: isBiometricLoading ?? this.isBiometricLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SignInNotifier extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setBiometricLoading(bool loading) {
    state = state.copyWith(isBiometricLoading: loading);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const SignInState();
  }
}

final signInProvider = NotifierProvider<SignInNotifier, SignInState>(
  SignInNotifier.new,
);
