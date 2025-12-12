import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import '../services/prompts_service.dart';
import '../services/patterns_service.dart';
import 'ai_service_settings.dart';
import 'admin_settings.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Expose auth state changes so other providers can react (e.g., refetch data)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = Supabase.instance.client;
  return client.auth.onAuthStateChange;
});

// Current Supabase session, exposed as a provider for easier testing and DI.
final supabaseSessionProvider = Provider<Session?>((ref) {
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentSession;
});

// Test-friendly provider to expose whether Supabase is enabled.
// Allows widget tests to override gating without compile-time dart-define.
final supabaseEnabledProvider = Provider<bool>((ref) => supabaseEnabled);

final promptsServiceProvider = Provider<PromptsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  String? token;
  final enabled = ref.watch(supabaseEnabledProvider);
  if (enabled) {
    final session = ref.watch(supabaseSessionProvider);
    token = session?.accessToken;
  }
  return PromptsService(baseUrl: baseUrl, authToken: token);
});

final patternsServiceProvider = Provider<PatternsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  String? token;
  final enabled = ref.watch(supabaseEnabledProvider);
  if (enabled) {
    final session = ref.watch(supabaseSessionProvider);
    token = session?.accessToken;
  }
  return PatternsService(baseUrl: baseUrl, authToken: token);
});

final isAdminProvider = Provider<bool>((ref) {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (enabled) {
    final session = ref.watch(supabaseSessionProvider);
    final user = session?.user;
    final appMeta = user?.appMetadata is Map
        ? (user?.appMetadata as Map)
        : null;
    final userMeta = user?.userMetadata is Map
        ? (user?.userMetadata as Map)
        : null;
    bool admin = false;
    dynamic roles = appMeta != null ? appMeta['roles'] : null;
    roles ??= userMeta != null ? userMeta['roles'] : null;
    if (roles is List) {
      admin = roles.any((r) => r.toString().toLowerCase() == 'admin');
    }
    dynamic role = appMeta != null ? appMeta['role'] : null;
    role ??= userMeta != null ? userMeta['role'] : null;
    if (!admin && role is String) {
      admin = role.toLowerCase() == 'admin';
    }
    dynamic flag = appMeta != null ? appMeta['isAdmin'] : null;
    flag ??= userMeta != null ? userMeta['isAdmin'] : null;
    if (!admin && flag is bool) {
      admin = flag;
    }
    return admin;
  }
  return ref.watch(adminModeProvider);
});
