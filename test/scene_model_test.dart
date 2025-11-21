import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/scene.dart';

void main() {
  group('Scene', () {
    test('toMap/fromMap round trip', () {
      const s = Scene(
        novelId: 'n1',
        title: 'Forest',
        location: 'Woods',
        summary: 'Meeting in the forest',
      );
      final map = s.toMap();
      final back = Scene.fromMap(map);
      expect(back.novelId, 'n1');
      expect(back.title, 'Forest');
      expect(back.location, 'Woods');
      expect(back.summary, 'Meeting in the forest');
    });
  });
}
