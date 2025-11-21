import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/repositories/chapter_port.dart';
import 'package:novel_reader/models/chapter.dart';

class _FakeChapterPort implements ChapterPort {
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'c',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}

  @override
  Future<Chapter> getChapter(Chapter chapter) async => chapter;

  @override
  Future<List<Chapter>> getChapters(String novelId) async => [];

  @override
  Future<int> getNextIdx(String novelId) async => 1;

  @override
  Future<void> updateChapter(Chapter chapter) async {}
}

void main() {
  test('ChapterPort interface can be implemented', () async {
    final port = _FakeChapterPort();
    final created = await port.createChapter(novelId: 'n', idx: 2, title: 'T');
    expect(created.idx, 2);
    expect(await port.getNextIdx('n'), 1);
  });
}
