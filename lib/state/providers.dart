import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

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
