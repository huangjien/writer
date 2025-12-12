import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern.dart';
import 'providers.dart';
import '../services/patterns_service.dart';

final patternsServiceRefProvider = Provider<PatternsService>((ref) {
  return ref.watch(patternsServiceProvider);
});

final patternsProvider = FutureProvider<List<Pattern>>((ref) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return const <Pattern>[];
  ref.watch(authStateProvider);
  final svc = ref.watch(patternsServiceRefProvider);
  return svc.fetchPatterns();
});

final patternByIdProvider = FutureProvider.family<Pattern?, String>((
  ref,
  id,
) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return null;
  ref.watch(authStateProvider);
  final svc = ref.watch(patternsServiceRefProvider);
  return svc.getPattern(id);
});
