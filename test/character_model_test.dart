import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/character.dart';

void main() {
  group('Character', () {
    test('toMap/fromMap round trip', () {
      const c = Character(
        novelId: 'n1',
        name: 'Alice',
        role: 'Hero',
        bio: 'Brave adventurer',
      );
      final map = c.toMap();
      final back = Character.fromMap(map);
      expect(back.novelId, 'n1');
      expect(back.name, 'Alice');
      expect(back.role, 'Hero');
      expect(back.bio, 'Brave adventurer');
    });
  });
}
