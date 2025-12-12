import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/pattern.dart';

void main() {
  test('Pattern.fromMap parses fields and embedding numbers', () {
    final map = {
      'id': 'p1',
      'title': 'Title',
      'description': 'Desc',
      'content': 'Body',
      'usage_rules': {'a': 1},
      'embedding': [1, 2.5, '3.0'],
      'created_at': '2024-01-01T00:00:00Z',
    };
    final p = Pattern.fromMap(map);
    expect(p.id, 'p1');
    expect(p.title, 'Title');
    expect(p.description, 'Desc');
    expect(p.content, 'Body');
    expect(p.usageRules?['a'], 1);
    expect(p.embedding, isNotNull);
    expect(p.embedding!.length, 3);
    expect(p.embedding![0], 1.0);
    expect(p.embedding![1], 2.5);
    expect(p.embedding![2], 3.0);
    expect(p.createdAt, isNotNull);
  });

  test('Pattern.toMap serializes fields correctly', () {
    final p = Pattern(
      id: 'p2',
      title: 'T',
      description: null,
      content: 'C',
      usageRules: {'x': true},
      embedding: [0.1, 0.2],
      createdAt: DateTime.parse('2024-01-02T00:00:00Z'),
    );
    final m = p.toMap();
    expect(m['id'], 'p2');
    expect(m['title'], 'T');
    expect(m['description'], isNull);
    expect(m['content'], 'C');
    expect(m['usage_rules'], isA<Map<String, dynamic>>());
    expect((m['embedding'] as List).length, 2);
    expect(m['created_at'], '2024-01-02T00:00:00.000Z');
  });
}
