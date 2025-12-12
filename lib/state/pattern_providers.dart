import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern.dart';
import '../repositories/pattern_repository.dart';
import 'providers.dart';

final patternRepositoryProvider = Provider<PatternRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PatternRepository(client);
});

final patternsProvider = FutureProvider<List<Pattern>>((ref) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return const <Pattern>[];
  ref.watch(authStateProvider);
  final repo = ref.watch(patternRepositoryProvider);
  return repo.listPatterns();
});

final patternByIdProvider = FutureProvider.family<Pattern?, String>((
  ref,
  id,
) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return null;
  ref.watch(authStateProvider);
  final repo = ref.watch(patternRepositoryProvider);
  return repo.getPattern(id);
});
