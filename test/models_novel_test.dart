import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/novel.dart';

void main() {
  test('Novel.fromMap applies defaults', () {
    final map = {
      'id': 'n1',
      'title': 'Title',
      // language_code and is_public omitted
    };
    final n = Novel.fromMap(map);
    expect(n.id, 'n1');
    expect(n.title, 'Title');
    expect(n.languageCode, 'en');
    expect(n.isPublic, true);
  });

  test('Novel.copyWith updates fields', () {
    const base = Novel(
      id: 'n1',
      title: 'Title',
      author: 'A',
      description: 'D',
      coverUrl: 'u',
      languageCode: 'en',
      isPublic: true,
    );
    final updated = base.copyWith(title: 'New', isPublic: false);
    expect(updated.title, 'New');
    expect(updated.isPublic, false);
    expect(updated.author, 'A');
  });
}
