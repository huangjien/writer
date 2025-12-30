import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'session_state.dart';
import 'ai_service_settings.dart';

class User {
  final String id;
  final String? email;
  final bool isApproved;
  final bool isAdmin;

  User({
    required this.id,
    this.email,
    this.isApproved = false,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      isApproved: json['is_approved'] ?? false,
      isAdmin: json['is_admin'] ?? false,
    );
  }
}

class UserStateNotifier extends StateNotifier<AsyncValue<User?>> {
  UserStateNotifier(this.ref, [AsyncValue<User?>? initialState])
    : super(initialState ?? const AsyncValue.data(null)) {
    init();
  }

  final Ref ref;

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

      String baseUrl;
      try {
        baseUrl = ref.read(aiServiceProvider);
      } catch (_) {
        baseUrl = 'http://localhost:5600/';
      }

      final url = baseUrl.endsWith('/')
          ? '${baseUrl}auth/verify'
          : '$baseUrl/auth/verify';

      final res = await http.get(
        Uri.parse(url),
        headers: {'X-Session-Id': sessionId},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        state = AsyncValue.data(User.fromJson(data));
      } else {
        state = AsyncValue.error(
          'Failed to verify session',
          StackTrace.current,
        );
        if (res.statusCode == 401) {
          ref.read(sessionProvider.notifier).clear();
          // Note: Cannot redirect here as we don't have access to navigator from user state
          // The RemoteRepository will handle the redirect when it receives 401
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProvider =
    StateNotifierProvider<UserStateNotifier, AsyncValue<User?>>((ref) {
      return UserStateNotifier(ref);
    });
