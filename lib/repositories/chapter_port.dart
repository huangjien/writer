import '../models/chapter.dart';

/// Lightweight repository interface for chapter operations.
/// Mirrors the style of `ProgressPort` to keep layers clean.
abstract class ChapterPort {
  Future<List<Chapter>> getChapters(String novelId);
  Future<Chapter> getChapter(Chapter chapter);
  Future<void> updateChapter(Chapter chapter);
  Future<int> getNextIdx(String novelId);
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  });
  Future<void> deleteChapter(String chapterId);
}
