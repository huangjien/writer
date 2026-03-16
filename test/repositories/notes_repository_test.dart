import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/repositories/notes_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('NotesRepository (characters)', () {
    late MockRemoteRepository remote;
    late NotesRepository repo;

    setUp(() {
      remote = MockRemoteRepository();
      repo = NotesRepository(remote);
    });

    test('listCharacterNotes maps list response', () async {
      when(
        () => remote.get(
          'characters',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            'id': 'cn1',
            'novel_id': 'n1',
            'idx': 1,
            'title': 'A',
            'character_summaries': 'S',
            'character_synopses': 'Y',
            'language_code': 'en',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.listCharacterNotes('n1');
      expect(items.single.id, 'cn1');
      verify(
        () => remote.get('characters', queryParameters: {'novel_id': 'n1'}),
      ).called(1);
    });

    test('listCharacterNotes maps items response', () async {
      when(
        () => remote.get(
          'characters',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return {
          'items': [
            {
              'id': 'cn2',
              'novel_id': 'n1',
              'idx': 2,
              'title': null,
              'character_summaries': null,
              'character_synopses': null,
              'language_code': 'en',
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
          ],
        };
      });

      final items = await repo.listCharacterNotes('n1');
      expect(items.single.id, 'cn2');
      verify(
        () => remote.get('characters', queryParameters: {'novel_id': 'n1'}),
      ).called(1);
    });

    test('listCharacterNotes returns empty list on error', () async {
      when(
        () => remote.get(
          'characters',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('x'));

      final items = await repo.listCharacterNotes('n1');
      expect(items, isEmpty);
    });

    test('listCharacterNotes returns empty list on unknown format', () async {
      when(
        () => remote.get(
          'characters',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => {'foo': 'bar'}); // Not list, no items

      final items = await repo.listCharacterNotes('n1');
      expect(items, isEmpty);
    });

    test('upsertCharacterNote posts mapped body', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => remote.post(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return {};
      });

      await repo.upsertCharacterNote(
        novelId: 'n1',
        idx: 3,
        title: 'T',
        summaries: 'S',
        synopses: 'Y',
      );

      verify(() => remote.post('characters', any())).called(1);
      expect(captured.single['novel_id'], 'n1');
      expect(captured.single['idx'], 3);
      expect(captured.single['title'], 'T');
      expect(captured.single['character_summaries'], 'S');
      expect(captured.single['character_synopses'], 'Y');
      expect(captured.single['language_code'], 'en');
    });

    test('deleteCharacterNoteById calls delete', () async {
      when(() => remote.delete(any())).thenAnswer((_) async {});
      await repo.deleteCharacterNoteById('cn9');
      verify(() => remote.delete('characters/cn9')).called(1);
    });

    test(
      'deleteCharacterNoteByIdx calls delete with query parameters',
      () async {
        when(
          () => remote.delete(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async {});

        await repo.deleteCharacterNoteByIdx('n1', 7);
        verify(
          () => remote.delete(
            'characters',
            queryParameters: {'novel_id': 'n1', 'idx': '7'},
          ),
        ).called(1);
      },
    );
  });

  group('NotesRepository (scenes)', () {
    late MockRemoteRepository remote;
    late NotesRepository repo;

    setUp(() {
      remote = MockRemoteRepository();
      repo = NotesRepository(remote);
    });

    test('listSceneNotes maps list response', () async {
      when(
        () => remote.get(
          'scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return [
          {
            'id': 'sn1',
            'novel_id': 'n1',
            'idx': 1,
            'title': 'A',
            'scene_summaries': 'S',
            'scene_synopses': 'Y',
            'language_code': 'en',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];
      });

      final items = await repo.listSceneNotes('n1');
      expect(items.single.id, 'sn1');
      verify(
        () => remote.get('scenes', queryParameters: {'novel_id': 'n1'}),
      ).called(1);
    });

    test('listSceneNotes maps items response', () async {
      when(
        () => remote.get(
          'scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {
        return {
          'items': [
            {
              'id': 'sn2',
              'novel_id': 'n1',
              'idx': 2,
              'title': null,
              'scene_summaries': null,
              'scene_synopses': null,
              'language_code': 'en',
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
          ],
        };
      });

      final items = await repo.listSceneNotes('n1');
      expect(items.single.id, 'sn2');
    });

    test('listSceneNotes returns empty list on unknown format', () async {
      when(
        () => remote.get(
          'scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => {'foo': 'bar'});

      final items = await repo.listSceneNotes('n1');
      expect(items, isEmpty);
    });

    test('listSceneNotes returns empty list on error', () async {
      when(
        () => remote.get(
          'scenes',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('x'));

      final items = await repo.listSceneNotes('n1');
      expect(items, isEmpty);
    });

    test('upsertSceneNote posts mapped body', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => remote.post(any(), any())).thenAnswer((inv) async {
        captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
        return {};
      });

      await repo.upsertSceneNote(
        novelId: 'n1',
        idx: 3,
        title: 'T',
        summaries: 'S',
        synopses: 'Y',
        languageCode: 'zh',
      );

      verify(() => remote.post('scenes', any())).called(1);
      expect(captured.single['novel_id'], 'n1');
      expect(captured.single['idx'], 3);
      expect(captured.single['title'], 'T');
      expect(captured.single['scene_summaries'], 'S');
      expect(captured.single['scene_synopses'], 'Y');
      expect(captured.single['language_code'], 'zh');
    });

    test('deleteSceneNoteById calls delete', () async {
      when(() => remote.delete(any())).thenAnswer((_) async {});
      await repo.deleteSceneNoteById('sn9');
      verify(() => remote.delete('scenes/sn9')).called(1);
    });

    test('deleteSceneNoteByIdx calls delete with query parameters', () async {
      when(
        () => remote.delete(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async {});

      await repo.deleteSceneNoteByIdx('n1', 7);
      verify(
        () => remote.delete(
          'scenes',
          queryParameters: {'novel_id': 'n1', 'idx': '7'},
        ),
      ).called(1);
    });
  });
}
