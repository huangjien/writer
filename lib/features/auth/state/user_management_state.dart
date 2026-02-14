import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class UserManagementState {
  final bool isLoading;
  final String? error;
  final List<dynamic> users;

  const UserManagementState({
    this.isLoading = false,
    this.error,
    this.users = const [],
  });

  UserManagementState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? users,
    bool clearError = false,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      users: users ?? this.users,
    );
  }
}

class UserManagementNotifier extends Notifier<UserManagementState> {
  @override
  UserManagementState build() => const UserManagementState();

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setUsers(List<dynamic> users) {
    state = state.copyWith(users: users);
  }

  void reset() {
    state = const UserManagementState();
  }
}

final userManagementProvider =
    NotifierProvider<UserManagementNotifier, UserManagementState>(
      UserManagementNotifier.new,
    );
