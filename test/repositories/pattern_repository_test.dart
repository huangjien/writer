import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/pattern_repository.dart';

import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient client;
  late MockSupabaseQueryBuilder qb;
  late PatternRepository repo;

  setUp(() {
    client = MockSupabaseClient();
    qb = MockSupabaseQueryBuilder();
    repo = PatternRepository(client);
    when(() => client.from('writing_patterns')).thenAnswer((_) => qb);
  });

  test('listPatterns returns mapped list', () async {
    final rows = [
      {
        'id': 'p1',
        'title': 'A',
        'content': 'X',
        'created_at': '2024-01-01T00:00:00Z',
      },
      {
        'id': 'p2',
        'title': 'B',
        'content': 'Y',
        'created_at': '2024-01-02T00:00:00Z',
      },
    ];
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));
    // order + limit handled by Fake transformers
    final items = await repo.listPatterns();
    expect(items.length, 2);
    expect(items.first.id, 'p1');
    expect(items.last.id, 'p2');
    verify(() => client.from('writing_patterns')).called(1);
  });

  test('getPattern returns pattern when found', () async {
    final row = {
      'id': 'p1',
      'title': 'A',
      'content': 'X',
      'created_at': '2024-01-01T00:00:00Z',
    };
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([row]));
    final p = await repo.getPattern('p1');
    expect(p, isNotNull);
    expect(p!.id, 'p1');
    verify(() => client.from('writing_patterns')).called(1);
  });

  test('getPattern returns null when empty', () async {
    when(
      () => qb.select(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
    final p = await repo.getPattern('pX');
    expect(p, isNull);
  });

  test('createPattern includes embedding when provided', () async {
    final created = {
      'id': 'new',
      'title': 'T',
      'content': 'C',
      'embedding': [0.1, 0.2],
    };
    when(
      () => qb.insert(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([created]));
    final p = await repo.createPattern(
      title: 'T',
      description: null,
      content: 'C',
      usageRules: {'x': true},
      embedding: const [0.1, 0.2],
    );
    expect(p.embedding, isNotNull);
    expect(p.embedding!.length, 2);
    verify(() => client.from('writing_patterns')).called(1);
  });

  test('updatePattern only updates provided fields', () async {
    final updated = {
      'id': 'p1',
      'title': 'U',
      'description': 'D',
      'content': 'C2',
    };
    final captured = <Map<String, dynamic>>[];
    when(() => qb.update(any())).thenAnswer((inv) {
      captured.add(inv.positionalArguments.first as Map<String, dynamic>);
      return FakePostgrestFilterBuilder([updated]);
    });
    final p = await repo.updatePattern(
      id: 'p1',
      title: 'U',
      description: 'D',
      content: 'C2',
    );
    expect(p.title, 'U');
    expect(captured.single.keys.toSet(), {'title', 'description', 'content'});
    verify(() => client.from('writing_patterns')).called(1);
  });

  test('deletePattern calls delete with id filter', () async {
    when(() => qb.delete()).thenAnswer((_) => FakePostgrestFilterBuilder(null));
    await repo.deletePattern('p1');
    verify(() => client.from('writing_patterns')).called(1);
    verify(() => qb.delete()).called(1);
  });
}
