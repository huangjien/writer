import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers.dart';

import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import '../repositories/progress_port.dart';

final progressRepositoryProvider = Provider<ProgressPort>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProgressRepository(client);
});

final lastProgressProvider = FutureProvider.family<UserProgress?, String>((
  ref,
  novelId,
) async {
  final clientRepo = ref.watch(progressRepositoryProvider);
  return clientRepo.lastProgressForNovel(novelId);
});

final latestUserProgressProvider = StreamProvider.autoDispose<UserProgress?>((
  ref,
) {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return Stream.value(null);
  return client
      .from('user_progress')
      .stream(primaryKey: ['user_id', 'chapter_id'])
      .eq('user_id', userId)
      .order('updated_at', ascending: false)
      .limit(1)
      .map((list) => list.isEmpty ? null : UserProgress.fromJson(list.first));
});

final recentUserProgressProvider =
    StreamProvider.autoDispose<List<UserProgress>>((ref) {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return Stream.value([]);
      return client
          .from('user_progress')
          .stream(primaryKey: ['user_id', 'chapter_id'])
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(3)
          .map(
            (list) => list.map((item) => UserProgress.fromJson(item)).toList(),
          );
    });
