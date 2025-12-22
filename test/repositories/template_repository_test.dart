import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('TemplateRepository (characters)', () {
    late MockRemoteRepository remote;
    late TemplateRepository repo;

    setUp(() {
      remote = MockRemoteRepository();
      repo = TemplateRepository(remote);
    });

    test('listCharacterTemplates maps list response', () async {
      when(() => remote.get('templates/characters')).thenAnswer((_) async {
        return [
          {
            'id': 'c1',
            'idx': 1,
            'title': 'A',
            'character_summaries': 'S',
            'character_synopses': 'Y',
            'language_code': 'en',
            'created_by': null,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.listCharacterTemplates();
      expect(items.length, 1);
      expect(items.single.id, 'c1');
      verify(() => remote.get('templates/characters')).called(1);
    });

    test('listCharacterTemplates maps items response', () async {
      when(() => remote.get('templates/characters')).thenAnswer((_) async {
        return {
          'items': [
            {
              'id': 'c2',
              'idx': 2,
              'title': 'B',
              'character_summaries': null,
              'character_synopses': null,
              'language_code': 'en',
              'created_by': null,
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
          ],
        };
      });

      final items = await repo.listCharacterTemplates();
      expect(items.length, 1);
      expect(items.single.id, 'c2');
      verify(() => remote.get('templates/characters')).called(1);
    });

    test('listCharacterTemplates returns empty list on error', () async {
      when(() => remote.get('templates/characters')).thenThrow(Exception('x'));
      final items = await repo.listCharacterTemplates();
      expect(items, isEmpty);
    });

    test('getCharacterTemplateById maps row', () async {
      when(() => remote.get('templates/characters/c1')).thenAnswer((_) async {
        return {
          'id': 'c1',
          'idx': 1,
          'title': 'A',
          'character_summaries': 'S',
          'character_synopses': 'Y',
          'language_code': 'en',
          'created_by': null,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        };
      });

      final row = await repo.getCharacterTemplateById('c1');
      expect(row, isNotNull);
      expect(row!.id, 'c1');
      verify(() => remote.get('templates/characters/c1')).called(1);
    });

    test('getCharacterTemplateById returns null on error', () async {
      when(() => remote.get(any())).thenThrow(Exception('x'));
      final row = await repo.getCharacterTemplateById('c1');
      expect(row, isNull);
    });

    test('upsertCharacterTemplate patches when id provided', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => remote.patch(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return {};
      });

      await repo.upsertCharacterTemplate(
        id: 'c1',
        title: 'T',
        languageCode: 'zh',
      );

      verify(() => remote.patch('templates/characters/c1', any())).called(1);
      expect(captured.single.keys.toSet(), {'title', 'language_code'});
    });

    test('upsertCharacterTemplate posts when no id provided', () async {
      when(() => remote.post(any(), any())).thenAnswer((_) async => {});
      await repo.upsertCharacterTemplate(title: 'T');
      verify(() => remote.post('templates/characters', any())).called(1);
    });

    test('deleteCharacterTemplate calls delete', () async {
      when(() => remote.delete(any())).thenAnswer((_) async {});
      await repo.deleteCharacterTemplate('c9');
      verify(() => remote.delete('templates/characters/c9')).called(1);
    });

    test('searchCharacterTemplates posts body and maps list', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => remote.post(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return [
          {
            'id': 'c1',
            'idx': 1,
            'title': 'A',
            'character_summaries': null,
            'character_synopses': null,
            'language_code': 'en',
            'created_by': null,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.searchCharacterTemplates(
        'q',
        limit: 2,
        offset: 3,
        languageCode: 'en',
      );

      expect(items.single.id, 'c1');
      expect(captured.single, {
        'query': 'q',
        'limit': 2,
        'offset': 3,
        'language_code': 'en',
      });
      verify(() => remote.post('templates/characters/search', any())).called(1);
    });

    test('refreshCharacterTemplateEmbedding posts refresh endpoint', () async {
      when(() => remote.post(any(), any())).thenAnswer((_) async => {});
      await repo.refreshCharacterTemplateEmbedding('c1');
      verify(
        () => remote.post('templates/characters/c1/refresh_embedding', any()),
      ).called(1);
    });
  });

  group('TemplateRepository (scenes)', () {
    late MockRemoteRepository remote;
    late TemplateRepository repo;

    setUp(() {
      remote = MockRemoteRepository();
      repo = TemplateRepository(remote);
    });

    test('listSceneTemplates maps list response', () async {
      when(
        () => remote.get(
          'templates/scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            'id': 's1',
            'idx': 1,
            'title': 'A',
            'scene_summaries': 'S',
            'scene_synopses': 'Y',
            'language_code': 'en',
            'created_by': null,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.listSceneTemplates(limit: 10);
      expect(items.single.id, 's1');
      verify(
        () => remote.get('templates/scenes', queryParameters: {'limit': '10'}),
      ).called(1);
    });

    test('listSceneTemplates maps items response', () async {
      when(
        () => remote.get(
          'templates/scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return {
          'items': [
            {
              'id': 's2',
              'idx': 2,
              'title': 'B',
              'scene_summaries': null,
              'scene_synopses': null,
              'language_code': 'en',
              'created_by': null,
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
          ],
        };
      });

      final items = await repo.listSceneTemplates(limit: 10);
      expect(items.single.id, 's2');
      verify(
        () => remote.get('templates/scenes', queryParameters: {'limit': '10'}),
      ).called(1);
    });

    test('getSceneTemplateById maps row', () async {
      when(() => remote.get('templates/scenes/s1')).thenAnswer((_) async {
        return {
          'id': 's1',
          'idx': 1,
          'title': 'A',
          'scene_summaries': 'S',
          'scene_synopses': 'Y',
          'language_code': 'en',
          'created_by': null,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        };
      });

      final row = await repo.getSceneTemplateById('s1');
      expect(row, isNotNull);
      expect(row!.id, 's1');
      verify(() => remote.get('templates/scenes/s1')).called(1);
    });

    test('upsertSceneTemplate returns id from response', () async {
      when(() => remote.post(any(), any())).thenAnswer((_) async {
        return {'id': 'new'};
      });

      final id = await repo.upsertSceneTemplate(title: 'T');
      expect(id, 'new');
      verify(() => remote.post('templates/scenes', any())).called(1);
    });

    test('upsertSceneTemplate falls back to provided id', () async {
      when(() => remote.patch(any(), any())).thenAnswer((_) async => null);
      final id = await repo.upsertSceneTemplate(id: 's9', title: 'T');
      expect(id, 's9');
      verify(() => remote.patch('templates/scenes/s9', any())).called(1);
    });

    test('deleteSceneTemplate calls delete', () async {
      when(() => remote.delete(any())).thenAnswer((_) async {});
      await repo.deleteSceneTemplate('s9');
      verify(() => remote.delete('templates/scenes/s9')).called(1);
    });

    test('searchSceneTemplates posts body and maps list', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => remote.post(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return [
          {
            'id': 's1',
            'idx': 1,
            'title': 'A',
            'scene_summaries': null,
            'scene_synopses': null,
            'language_code': 'en',
            'created_by': null,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.searchSceneTemplates(
        'q',
        limit: 2,
        offset: 3,
        languageCode: 'en',
      );

      expect(items.single.id, 's1');
      expect(captured.single, {
        'query': 'q',
        'limit': 2,
        'offset': 3,
        'language_code': 'en',
      });
      verify(() => remote.post('templates/scenes/search', any())).called(1);
    });

    test('refreshSceneTemplateEmbedding posts refresh endpoint', () async {
      when(() => remote.post(any(), any())).thenAnswer((_) async => {});
      await repo.refreshSceneTemplateEmbedding('s1');
      verify(
        () => remote.post('templates/scenes/s1/refresh_embedding', any()),
      ).called(1);
    });
  });
}
