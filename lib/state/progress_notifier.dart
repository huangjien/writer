import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../repositories/progress_port.dart';
import '../repositories/progress_repository.dart';
import 'providers.dart';

class ProgressController extends StateNotifier<AsyncValue<void>> {
  ProgressController(this._repo) : super(const AsyncData(null));
  final ProgressPort _repo;

  Future<bool> save(UserProgress progress) async {
    state = const AsyncLoading();
    try {
      await _repo.upsertProgress(progress);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final progressRepositoryProvider = Provider<ProgressPort>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProgressRepository(client);
});

final progressControllerProvider =
    StateNotifierProvider<ProgressController, AsyncValue<void>>((ref) {
      final repo = ref.watch(progressRepositoryProvider);
      return ProgressController(repo);
    });
