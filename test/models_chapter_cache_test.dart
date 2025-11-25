import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter_cache.dart';

void main() {
  test('ChapterCache toJson/fromJson roundtrip', () {
    final now = DateTime.parse('2025-01-01T12:00:00Z');
    final c = ChapterCache(
      chapterId: 'c1',
      novelId: 'n1',
      idx: 1,
      title: 'One',
      content: 'Hello',
      lastUpdated: now,
    );
    final json = c.toJson();
    final back = ChapterCache.fromJson(json);
    expect(back.chapterId, 'c1');
    expect(back.novelId, 'n1');
    expect(back.idx, 1);
    expect(back.title, 'One');
    expect(back.content, 'Hello');
    expect(back.lastUpdated.toIso8601String(), now.toIso8601String());
  });
}
