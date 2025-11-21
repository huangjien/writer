import '../models/user_progress.dart';

abstract class ProgressPort {
  Future<void> upsertProgress(UserProgress progress);
  Future<UserProgress?> lastProgressForNovel(String novelId);
  Future<UserProgress?> latestProgressForUser();
}
