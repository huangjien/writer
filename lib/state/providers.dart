import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/prompts_service.dart';
import '../services/patterns_service.dart';
import '../services/vector_service.dart';
import '../services/story_lines_service.dart';
import 'ai_service_settings.dart';
import 'admin_settings.dart';
import 'session_state.dart';
import 'supabase_config.dart';

export 'supabase_config.dart';

final isSignedInProvider = Provider<bool>((ref) {
  final sessionId = ref.watch(sessionProvider);
  return sessionId != null && sessionId.trim().isNotEmpty;
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) {
    throw StateError('Supabase is disabled');
  }
  return Supabase.instance.client;
});

final supabaseSessionProvider = Provider<Session?>((ref) {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return null;
  ref.watch(authStateProvider);
  try {
    return Supabase.instance.client.auth.currentSession;
  } catch (_) {
    return null;
  }
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return Stream<AuthState>.empty();
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return Stream<AuthState>.empty();
  }
});

final promptsServiceProvider = Provider<PromptsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return PromptsService(baseUrl: baseUrl, sessionId: sessionId);
});

final patternsServiceProvider = Provider<PatternsService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return PatternsService(baseUrl: baseUrl, sessionId: sessionId);
});

final vectorServiceProvider = Provider<VectorService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return VectorService(baseUrl: baseUrl, sessionId: sessionId);
});

final storyLinesServiceProvider = Provider<StoryLinesService>((ref) {
  String baseUrl;
  try {
    baseUrl = ref.watch(aiServiceProvider);
  } catch (_) {
    baseUrl = 'http://localhost:5600/';
  }
  final sessionId = ref.watch(sessionProvider);
  return StoryLinesService(baseUrl: baseUrl, sessionId: sessionId);
});

final isAdminProvider = Provider<bool>((ref) {
  final supabaseEnabled = ref.watch(supabaseEnabledProvider);
  if (supabaseEnabled) {
    final session = ref.watch(supabaseSessionProvider);
    final user = session?.user;
    final meta = user?.appMetadata;
    final roles = meta?['roles'];
    if (roles is List) {
      for (final r in roles) {
        if (r is String && r.toLowerCase() == 'admin') return true;
      }
    }
    final role = meta?['role'];
    if (role is String && role.toLowerCase() == 'admin') return true;
    return false;
  }
  return ref.watch(adminModeProvider);
});
