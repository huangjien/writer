import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/story_line.dart';

void main() {
  group('StoryLine', () {
    test('fromMap parses fields', () {
      final sl = StoryLine.fromMap({
        'id': 's1',
        'title': 'T',
        'description': 'D',
        'content': 'C',
        'usage_rules': {'a': 1},
        'language': 'en',
        'is_public': true,
        'locked': false,
        'owner_id': 'u1',
        'created_at': '2024-01-02T03:04:05.000Z',
      });

      expect(sl.id, 's1');
      expect(sl.title, 'T');
      expect(sl.description, 'D');
      expect(sl.content, 'C');
      expect(sl.usageRules, {'a': 1});
      expect(sl.language, 'en');
      expect(sl.isPublic, isTrue);
      expect(sl.locked, isFalse);
      expect(sl.ownerId, 'u1');
      expect(sl.createdAt, isNotNull);
      expect(
        sl.createdAt!.toUtc().toIso8601String(),
        '2024-01-02T03:04:05.000Z',
      );
    });

    test('fromMap accepts Map usage_rules', () {
      final sl = StoryLine.fromMap({
        'id': 's1',
        'title': 'T',
        'content': 'C',
        'usage_rules': {'a': 1, 'b': true},
      });
      expect(sl.usageRules, {'a': 1, 'b': true});
    });

    test('toMap serializes createdAt', () {
      final dt = DateTime.parse('2024-01-02T03:04:05.000Z');
      const sl = StoryLine(
        id: 's1',
        title: 'T',
        description: null,
        content: 'C',
        usageRules: null,
        language: 'zh',
        isPublic: false,
        locked: true,
        ownerId: 'u2',
        createdAt: null,
      );

      final map = sl.toMap();
      expect(map['id'], 's1');
      expect(map['title'], 'T');
      expect(map['content'], 'C');
      expect(map['language'], 'zh');
      expect(map['is_public'], isFalse);
      expect(map['locked'], isTrue);

      final sl2 = StoryLine(
        id: 's2',
        title: 'T2',
        content: 'C2',
        createdAt: dt,
      );
      final map2 = sl2.toMap();
      expect(map2['created_at'], '2024-01-02T03:04:05.000Z');
    });
  });
}
