import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/user_progress.dart';

void main() {
  group('UserProgress', () {
    test('fromJson maps fields', () {
      final now = DateTime.utc(2024, 2, 2, 2, 2, 2).toIso8601String();
      final json = {
        'user_id': 'u1',
        'novel_id': 'n1',
        'chapter_id': 'c1',
        'scroll_offset': 12.5,
        'tts_char_index': 42,
        'updated_at': now,
      };
      final p = UserProgress.fromJson(json);
      expect(p.userId, 'u1');
      expect(p.novelId, 'n1');
      expect(p.chapterId, 'c1');
      expect(p.scrollOffset, 12.5);
      expect(p.ttsCharIndex, 42);
      expect(p.updatedAt.toIso8601String(), now);
    });

    test('toMap produces serializable structure', () {
      final when = DateTime.utc(2024, 3, 3, 3, 3, 3);
      final p = UserProgress(
        userId: 'u2',
        novelId: 'n2',
        chapterId: 'c2',
        scrollOffset: 1,
        ttsCharIndex: 0,
        updatedAt: when,
      );
      final map = p.toMap();
      expect(map['user_id'], 'u2');
      expect(map['novel_id'], 'n2');
      expect(map['chapter_id'], 'c2');
      expect(map['scroll_offset'], 1);
      expect(map['tts_char_index'], 0);
      expect(map['updated_at'], when.toIso8601String());
    });
  });
}
