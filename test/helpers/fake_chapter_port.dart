import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/repositories/chapter_port.dart';

/// Lightweight fake ChapterPort used by widget tests to avoid Supabase.
class FakeChapterPort implements ChapterPort {
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];

  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;

  @override
  Future<void> updateChapter(Chapter chapter) async {}

  @override
  Future<int> getNextIdx(String novelId) async => 1;

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'fake-$novelId-$idx',
      novelId: novelId,
      idx: idx,
      title: title ?? 'Chapter $idx',
      content: content ?? '',
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}
}
