import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/template.dart';

void main() {
  group('TemplateItem', () {
    test('toMap/fromMap round trip', () {
      const t = TemplateItem(
        novelId: 'n1',
        name: 'Character Base',
        description: 'Default traits',
      );
      final map = t.toMap();
      final back = TemplateItem.fromMap(map);
      expect(back.novelId, 'n1');
      expect(back.name, 'Character Base');
      expect(back.description, 'Default traits');
    });
  });
}
