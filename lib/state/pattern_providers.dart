import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/pattern.dart';
import 'providers.dart';
import 'package:writer/services/patterns_service.dart';

final patternsServiceRefProvider = Provider<PatternsService>((ref) {
  return ref.watch(patternsServiceProvider);
});

final patternsProvider = FutureProvider<List<Pattern>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const <Pattern>[];
  final svc = ref.watch(patternsServiceRefProvider);
  return svc.fetchPatterns();
});

final patternByIdProvider = FutureProvider.family<Pattern?, String>((
  ref,
  id,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return null;
  final svc = ref.watch(patternsServiceRefProvider);
  return svc.getPattern(id);
});
