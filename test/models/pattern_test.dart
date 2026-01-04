import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/pattern.dart';

void main() {
  test('Pattern.fromMap parses fields', () {
    final map = {
      'id': 'p1',
      'title': 'Title',
      'description': 'Desc',
      'content': 'Body',
      'usage_rules': {'a': 1},
      'created_at': '2024-01-01T00:00:00Z',
    };
    final p = Pattern.fromMap(map);
    expect(p.id, 'p1');
    expect(p.title, 'Title');
    expect(p.description, 'Desc');
    expect(p.content, 'Body');
    expect(p.usageRules?['a'], 1);
    expect(p.createdAt, isNotNull);
  });

  test('Pattern.toMap serializes fields correctly', () {
    final p = Pattern(
      id: 'p2',
      title: 'T',
      description: null,
      content: 'C',
      usageRules: {'x': true},
      createdAt: DateTime.parse('2024-01-02T00:00:00Z'),
    );
    final m = p.toMap();
    expect(m['id'], 'p2');
    expect(m['title'], 'T');
    expect(m['description'], isNull);
    expect(m['content'], 'C');
    expect(m['usage_rules'], isA<Map<String, dynamic>>());
    expect(m['created_at'], '2024-01-02T00:00:00.000Z');
  });
}
