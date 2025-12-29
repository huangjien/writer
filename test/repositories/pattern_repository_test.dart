import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/repositories/pattern_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository remote;
  late PatternRepository repo;

  setUp(() {
    remote = MockRemoteRepository();
    repo = PatternRepository(remote);
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
      () => remote.get(
        'patterns',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => rows);
    final items = await repo.listPatterns();
    expect(items.length, 2);
    expect(items.first.id, 'p1');
    expect(items.last.id, 'p2');
    verify(
      () => remote.get(
        'patterns',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('getPattern returns pattern when found', () async {
    final row = {
      'id': 'p1',
      'title': 'A',
      'content': 'X',
      'created_at': '2024-01-01T00:00:00Z',
    };
    when(() => remote.get('patterns/p1')).thenAnswer((_) async => row);
    final p = await repo.getPattern('p1');
    expect(p, isNotNull);
    expect(p!.id, 'p1');
    verify(() => remote.get('patterns/p1')).called(1);
  });

  test('getPattern returns null when empty', () async {
    when(() => remote.get('patterns/pX')).thenThrow(Exception('404'));
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
    final captured = <Map<String, dynamic>>[];
    when(() => remote.post(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return created;
    });
    final p = await repo.createPattern(
      title: 'T',
      description: null,
      content: 'C',
      usageRules: {'x': true},
      embedding: const [0.1, 0.2],
    );
    expect(p.embedding, isNotNull);
    expect(p.embedding!.length, 2);
    expect(captured.single['embedding'], isNotNull);
    verify(() => remote.post('patterns', any())).called(1);
  });

  test('updatePattern only updates provided fields', () async {
    final updated = {
      'id': 'p1',
      'title': 'U',
      'description': 'D',
      'content': 'C2',
    };
    final captured = <Map<String, dynamic>>[];
    when(() => remote.patch(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return updated;
    });
    final p = await repo.updatePattern(
      id: 'p1',
      title: 'U',
      description: 'D',
      content: 'C2',
    );
    expect(p.title, 'U');
    expect(captured.single.keys.toSet(), {'title', 'description', 'content'});
    verify(() => remote.patch('patterns/p1', any())).called(1);
  });

  test('deletePattern calls delete with id filter', () async {
    when(() => remote.delete(any())).thenAnswer((_) async {});
    await repo.deletePattern('p1');
    verify(() => remote.delete('patterns/p1')).called(1);
  });

  test('listPatterns handles items response format', () async {
    final response = {
      'items': [
        {
          'id': 'p1',
          'title': 'A',
          'content': 'X',
          'created_at': '2024-01-01T00:00:00Z',
        },
      ],
    };
    when(
      () => remote.get(
        'patterns',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => response);
    final items = await repo.listPatterns();
    expect(items.length, 1);
    expect(items.first.id, 'p1');
  });

  test('listPatterns handles invalid response format', () async {
    when(
      () => remote.get(
        'patterns',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => 'invalid');
    final items = await repo.listPatterns();
    expect(items, isEmpty);
  });

  test('getPattern handles null response', () async {
    when(() => remote.get('patterns/p1')).thenAnswer((_) async => null);
    final p = await repo.getPattern('p1');
    expect(p, isNull);
  });

  test('createPattern with all optional fields', () async {
    final created = {
      'id': 'new',
      'title': 'T',
      'content': 'C',
      'description': 'D',
      'usage_rules': {'x': true},
      'embedding': [0.1, 0.2],
      'language': 'en',
      'is_public': true,
      'locked': false,
    };
    final captured = <Map<String, dynamic>>[];
    when(() => remote.post(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return created;
    });
    final p = await repo.createPattern(
      title: 'T',
      description: 'D',
      content: 'C',
      usageRules: {'x': true},
      embedding: const [0.1, 0.2],
      language: 'en',
      isPublic: true,
      locked: false,
    );
    expect(p.title, 'T');
    expect(p.description, 'D');
    expect(p.language, 'en');
    expect(captured.single.keys.toSet(), {
      'title', 'description', 'content', 'usage_rules', 
      'embedding', 'language', 'is_public', 'locked'
    });
  });

  test('updatePattern with all fields', () async {
    final updated = {
      'id': 'p1',
      'title': 'U',
      'description': 'D',
      'content': 'C2',
      'usage_rules': {'y': false},
      'embedding': [0.3, 0.4],
      'language': 'zh',
      'is_public': false,
      'locked': true,
    };
    final captured = <Map<String, dynamic>>[];
    when(() => remote.patch(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return updated;
    });
    final p = await repo.updatePattern(
      id: 'p1',
      title: 'U',
      description: 'D',
      content: 'C2',
      usageRules: {'y': false},
      embedding: const [0.3, 0.4],
      language: 'zh',
      isPublic: false,
      locked: true,
    );
    expect(p.title, 'U');
    expect(p.language, 'zh');
    expect(captured.single.keys.toSet(), {
      'title', 'description', 'content', 'usage_rules',
      'embedding', 'language', 'is_public', 'locked'
    });
  });

  test('createPattern throws exception on failure', () async {
    when(() => remote.post(any(), any())).thenAnswer((_) async => 'invalid');
    expect(
      () => repo.createPattern(title: 'T', content: 'C'),
      throwsException,
    );
  });

  test('updatePattern throws exception on failure', () async {
    when(() => remote.patch(any(), any())).thenAnswer((_) async => 'invalid');
    expect(
      () => repo.updatePattern(id: 'p1', title: 'U'),
      throwsException,
    );
  });

  test('listPatterns with custom limit', () async {
    when(
      () => remote.get(
        'patterns',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => []);
    await repo.listPatterns(limit: 100);
    verify(
      () => remote.get(
        'patterns',
        queryParameters: {'limit': '100', 'offset': '0'},
      ),
    ).called(1);
  });
}
