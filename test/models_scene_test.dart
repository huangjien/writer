import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/scene.dart';

void main() {
  test('Scene toMap/fromMap roundtrip', () {
    const s = Scene(
      novelId: 'n1',
      title: 'Opening',
      location: 'Forest',
      summary: 'Intro',
    );
    final map = s.toMap();
    final back = Scene.fromMap(map);
    expect(back.novelId, 'n1');
    expect(back.title, 'Opening');
    expect(back.location, 'Forest');
    expect(back.summary, 'Intro');
  });
}
