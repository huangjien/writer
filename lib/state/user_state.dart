import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../repositories/user_repository.dart';
import 'session_state.dart';
import 'ai_service_settings.dart';
import '../models/user.dart';

class UserStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;
  final UserRepository _userRepository;

  UserStateNotifier(
    this.ref,
    this._userRepository, [
    AsyncValue<User?>? initialState,
  ]) : super(initialState ?? const AsyncValue.data(null)) {
    init();
  }

  void init() {
    ref.listen<String?>(sessionProvider, (previous, next) {
      if (next != null) {
        fetchUser();
      } else {
        state = const AsyncValue.data(null);
      }
    });
    // Initial check
    if (ref.read(sessionProvider) != null) {
      fetchUser();
    }
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final sessionId = ref.read(sessionProvider);
      if (sessionId == null) return;

      final user = await _userRepository.fetchUser(sessionId);
      if (user != null) {
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.error(
          'Failed to verify session',
          StackTrace.empty,
        );
        // Clear session on failure
        ref.read(sessionProvider.notifier).clear();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.read(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  return RemoteUserRepository(baseUrl: baseUrl);
});

final userProvider =
    StateNotifierProvider<UserStateNotifier, AsyncValue<User?>>((ref) {
      return UserStateNotifier(ref, ref.read(userRepositoryProvider));
    });
