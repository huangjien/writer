import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter_cache.dart';

void main() {
  group('ChapterCache', () {
    test('toJson/fromJson round trip', () {
      final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
      final c = ChapterCache(
        chapterId: 'chap-001',
        novelId: 'novel-001',
        idx: 1,
        title: 'Prologue',
        content: 'Once upon a time',
        lastUpdated: now,
      );
      final json = c.toJson();
      final back = ChapterCache.fromJson(json);
      expect(back.chapterId, 'chap-001');
      expect(back.novelId, 'novel-001');
      expect(back.idx, 1);
      expect(back.title, 'Prologue');
      expect(back.content, 'Once upon a time');
      expect(back.lastUpdated.toIso8601String(), now.toIso8601String());
    });
  });
}
