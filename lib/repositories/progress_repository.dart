import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/user_progress.dart';
import 'progress_port.dart';
import 'remote_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(remoteRepositoryProvider));
});

class ProgressRepository implements ProgressPort {
  final RemoteRepository remote;

  ProgressRepository(this.remote);

  @override
  Future<void> upsertProgress(UserProgress progress) async {
    final body = {
      'novel_id': progress.novelId,
      'chapter_id': progress.chapterId,
      'scroll_offset': progress.scrollOffset,
      'tts_char_index': progress.ttsCharIndex,
    };
    await remote.post('progress', body);
  }

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async {
    try {
      final res = await remote.get('progress/novels/$novelId/last');
      if (res is Map<String, dynamic>) {
        return UserProgress.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProgress?> latestProgressForUser() async {
    try {
      final res = await remote.get('progress/latest');
      if (res is Map<String, dynamic>) {
        return UserProgress.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
