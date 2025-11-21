import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/user_progress.dart';

void main() {
  test('UserProgress.fromJson parses types correctly', () {
    final json = {
      'user_id': 'u',
      'novel_id': 'n',
      'chapter_id': 'c',
      'scroll_offset': 12.5,
      'tts_char_index': 42,
      'updated_at': '2025-02-02T03:04:05Z',
    };
    final p = UserProgress.fromJson(json);
    expect(p.userId, 'u');
    expect(p.novelId, 'n');
    expect(p.chapterId, 'c');
    expect(p.scrollOffset, 12.5);
    expect(p.ttsCharIndex, 42);
    expect(p.updatedAt.toIso8601String(), '2025-02-02T03:04:05.000Z');
  });

  test('UserProgress.toMap emits iso strings', () {
    final now = DateTime.parse('2025-02-02T03:04:05Z');
    final p = UserProgress(
      userId: 'u',
      novelId: 'n',
      chapterId: 'c',
      scrollOffset: 0.0,
      ttsCharIndex: 0,
      updatedAt: now,
    );
    final map = p.toMap();
    expect(map['updated_at'], now.toIso8601String());
    expect(map['user_id'], 'u');
    expect(map['novel_id'], 'n');
    expect(map['chapter_id'], 'c');
  });
}
