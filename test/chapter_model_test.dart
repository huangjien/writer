import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';

void main() {
  group('Chapter model', () {
    test('fromJson maps fields correctly', () {
      final data = {
        'id': 'chap-001',
        'novel_id': 'novel-001',
        'idx': 1,
        'title': 'Prologue',
        'content': 'Once upon a time',
      };
      final c = Chapter.fromJson(data);
      expect(c.id, 'chap-001');
      expect(c.novelId, 'novel-001');
      expect(c.idx, 1);
      expect(c.title, 'Prologue');
      expect(c.content, 'Once upon a time');
    });

    test('fromCache maps fields correctly', () {
      final cache = ChapterCache(
        chapterId: 'chap-002',
        novelId: 'novel-002',
        idx: 2,
        title: 'Chapter Two',
        content: 'More story',
        lastUpdated: DateTime.utc(2024, 1, 1),
      );
      final c = Chapter.fromCache(cache);
      expect(c.id, 'chap-002');
      expect(c.novelId, 'novel-002');
      expect(c.idx, 2);
      expect(c.title, 'Chapter Two');
      expect(c.content, 'More story');
    });

    test('copyWith overrides selected fields', () {
      const base = Chapter(
        id: 'chap-003',
        novelId: 'novel-003',
        idx: 3,
        title: 'Original',
        content: 'Text',
      );
      final updated = base.copyWith(title: 'Updated', content: 'New text');
      expect(updated.id, 'chap-003');
      expect(updated.novelId, 'novel-003');
      expect(updated.idx, 3);
      expect(updated.title, 'Updated');
      expect(updated.content, 'New text');
    });
  });
}
