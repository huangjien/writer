import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/template.dart';

void main() {
  test('TemplateItem toMap/fromMap roundtrip', () {
    const t = TemplateItem(
      novelId: 'n1',
      name: 'Battle',
      description: 'High tension',
    );
    final map = t.toMap();
    final back = TemplateItem.fromMap(map);
    expect(back.novelId, 'n1');
    expect(back.name, 'Battle');
    expect(back.description, 'High tension');
  });
}
