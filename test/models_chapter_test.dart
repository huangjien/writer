import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/models/chapter_cache.dart';

void main() {
  test('Chapter.fromJson decodes fields', () {
    final json = {
      'id': 'c1',
      'novel_id': 'n1',
      'idx': 2,
      'title': 'Two',
      'content': 'Body',
    };
    final c = Chapter.fromJson(json);
    expect(c.id, 'c1');
    expect(c.novelId, 'n1');
    expect(c.idx, 2);
    expect(c.title, 'Two');
    expect(c.content, 'Body');
  });

  test('Chapter.fromCache builds from cache', () {
    final cache = ChapterCache(
      chapterId: 'c2',
      novelId: 'n1',
      idx: 3,
      title: 'Three',
      content: 'Cached',
      lastUpdated: DateTime.now(),
    );
    final c = Chapter.fromCache(cache);
    expect(c.id, 'c2');
    expect(c.novelId, 'n1');
    expect(c.idx, 3);
    expect(c.title, 'Three');
    expect(c.content, 'Cached');
  });

  test('Chapter.copyWith updates selective fields', () {
    const base = Chapter(
      id: 'c',
      novelId: 'n',
      idx: 1,
      title: 'T',
      content: 'C',
    );
    final updated = base.copyWith(title: 'New');
    expect(updated.title, 'New');
    expect(updated.id, 'c');
    expect(updated.idx, 1);
  });
}
