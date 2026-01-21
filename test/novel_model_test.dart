import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/novel.dart';

void main() {
  group('Novel', () {
    test('fromMap maps fields with defaults', () {
      final map = {
        'id': 'n1',
        'title': 'Title',
        'author': null,
        'description': null,
        'cover_url': null,
      };
      final n = Novel.fromMap(map);
      expect(n.id, 'n1');
      expect(n.title, 'Title');
      expect(n.author, isNull);
      expect(n.description, isNull);
      expect(n.coverUrl, isNull);
      expect(n.languageCode, 'en');
      expect(n.isPublic, true);
    });

    test('copyWith updates provided fields', () {
      final n = const Novel(
        id: 'n1',
        title: 'A',
        author: 'B',
        description: 'D',
        coverUrl: 'C',
        languageCode: 'en',
        isPublic: true,
      );
      final u = n.copyWith(title: 'A2', isPublic: false);
      expect(u.id, 'n1');
      expect(u.title, 'A2');
      expect(u.author, 'B');
      expect(u.description, 'D');
      expect(u.coverUrl, 'C');
      expect(u.languageCode, 'en');
      expect(u.isPublic, false);
    });
  });
}
