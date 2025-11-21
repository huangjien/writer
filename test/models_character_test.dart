import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/character.dart';

void main() {
  test('Character toMap/fromMap roundtrip', () {
    const c = Character(novelId: 'n1', name: 'Alice', role: 'Hero', bio: 'Bio');
    final map = c.toMap();
    final back = Character.fromMap(map);
    expect(back.novelId, 'n1');
    expect(back.name, 'Alice');
    expect(back.role, 'Hero');
    expect(back.bio, 'Bio');
  });
}
