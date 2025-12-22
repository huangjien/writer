import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import '../repositories/progress_port.dart';
import '../repositories/remote_repository.dart';

final progressRepositoryProvider = Provider<ProgressPort>((ref) {
  return ProgressRepository(ref.watch(remoteRepositoryProvider));
});

final lastProgressProvider = FutureProvider.family<UserProgress?, String>((
  ref,
  novelId,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return null;
  final clientRepo = ref.watch(progressRepositoryProvider);
  return clientRepo.lastProgressForNovel(novelId);
});

final latestUserProgressProvider = FutureProvider.autoDispose<UserProgress?>((
  ref,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return null;
  final repo = ref.watch(progressRepositoryProvider);
  return repo.latestProgressForUser();
});

final recentUserProgressProvider =
    FutureProvider.autoDispose<List<UserProgress>>((ref) async {
      ref.watch(authStateProvider);
      final isSignedIn = ref.watch(isSignedInProvider);
      if (!isSignedIn) return const [];
      final remote = ref.watch(remoteRepositoryProvider);
      final res = await remote.get(
        'progress/recent',
        queryParameters: {'limit': '3'},
      );
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(UserProgress.fromJson)
            .toList();
      }
      if (res is Map && res['items'] is List) {
        return (res['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(UserProgress.fromJson)
            .toList();
      }
      return const [];
    });
