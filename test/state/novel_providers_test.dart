import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/novel.dart';

void main() {
  group('Novel', () {
    test('Novel class can be created with required fields', () {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        languageCode: 'en',
        isPublic: false,
      );

      expect(novel.id, '1');
      expect(novel.title, 'Test Novel');
    });

    test('Novel class with optional fields', () {
      final novel = const Novel(
        id: '2',
        title: 'Another Novel',
        author: 'Test Author',
        description: 'A test novel',
        languageCode: 'en',
        isPublic: true,
      );

      expect(novel.author, 'Test Author');
      expect(novel.description, 'A test novel');
      expect(novel.isPublic, isTrue);
    });

    test('Novel can be copied', () {
      final novel = const Novel(
        id: '1',
        title: 'Test Novel',
        languageCode: 'en',
        isPublic: false,
      );

      final copy = novel.copyWith(title: 'Updated Title');

      expect(copy.id, '1');
      expect(copy.title, 'Updated Title');
    });

    test('Novel has default values for optional fields', () {
      final novel = const Novel(
        id: '3',
        title: 'Minimal Novel',
        languageCode: 'en',
        isPublic: false,
      );

      expect(novel.author, isNull);
      expect(novel.description, isNull);
      expect(novel.coverUrl, isNull);
    });

    test('Novel can be converted to map', () {
      final novel = const Novel(
        id: '4',
        title: 'Mapped Novel',
        author: 'Test Author',
        languageCode: 'en',
        isPublic: true,
      );

      final map = novel.toMap();

      expect(map['id'], '4');
      expect(map['title'], 'Mapped Novel');
      expect(map['author'], 'Test Author');
      expect(map['is_public'], isTrue);
    });

    test('Novel can be created from map', () {
      final map = {
        'id': '5',
        'title': 'From Map Novel',
        'author': 'Test Author',
        'description': 'A description',
        'cover_url': 'https://example.com/cover.jpg',
        'language_code': 'en',
        'is_public': true,
      };

      final novel = Novel.fromMap(map);

      expect(novel.id, '5');
      expect(novel.title, 'From Map Novel');
      expect(novel.author, 'Test Author');
      expect(novel.description, 'A description');
      expect(novel.coverUrl, 'https://example.com/cover.jpg');
      expect(novel.languageCode, 'en');
      expect(novel.isPublic, isTrue);
    });

    test('Novel.fromMap handles missing optional fields', () {
      final map = {
        'id': '6',
        'title': 'Partial Map Novel',
        'language_code': 'en',
      };

      final novel = Novel.fromMap(map);

      expect(novel.id, '6');
      expect(novel.title, 'Partial Map Novel');
      expect(novel.author, isNull);
      expect(novel.description, isNull);
      expect(novel.coverUrl, isNull);
      expect(novel.languageCode, 'en');
      expect(novel.isPublic, true);
    });

    test('Novel.fromMap defaults languageCode to en', () {
      final map = {'id': '7', 'title': 'Default Language Novel'};

      final novel = Novel.fromMap(map);

      expect(novel.languageCode, 'en');
    });

    test('Novel.toMap converts to snake_case', () {
      final novel = const Novel(
        id: '8',
        title: 'Snake Case Novel',
        languageCode: 'en',
        isPublic: false,
      );

      final map = novel.toMap();

      expect(map.containsKey('cover_url'), isTrue);
      expect(map.containsKey('language_code'), isTrue);
      expect(map.containsKey('is_public'), isTrue);
    });

    test('Novel.copyWith can update all fields', () {
      final novel = const Novel(
        id: '9',
        title: 'Original Title',
        languageCode: 'en',
        isPublic: false,
      );

      final updated = novel.copyWith(
        id: '10',
        title: 'New Title',
        author: 'New Author',
        description: 'New Description',
        coverUrl: 'https://example.com/new.jpg',
        languageCode: 'es',
        isPublic: true,
      );

      expect(updated.id, '10');
      expect(updated.title, 'New Title');
      expect(updated.author, 'New Author');
      expect(updated.description, 'New Description');
      expect(updated.coverUrl, 'https://example.com/new.jpg');
      expect(updated.languageCode, 'es');
      expect(updated.isPublic, isTrue);
    });

    test('Novel.copyWith preserves null fields', () {
      final novel = const Novel(
        id: '11',
        title: 'Preserve Null Novel',
        author: 'Original Author',
        languageCode: 'en',
        isPublic: true,
      );

      final updated = novel.copyWith(title: 'New Title');

      expect(updated.author, 'Original Author');
      expect(updated.description, isNull);
      expect(updated.coverUrl, isNull);
    });

    test('Novel.isPublic can be toggled', () {
      final novel = const Novel(
        id: '12',
        title: 'Public Novel',
        languageCode: 'en',
        isPublic: true,
      );

      final private = novel.copyWith(isPublic: false);

      expect(private.isPublic, isFalse);
    });
  });
}
