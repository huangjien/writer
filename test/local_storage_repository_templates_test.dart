import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/models/template.dart';

import 'shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Character templates offline', () {
    test('save/get character template form via local storage', () async {
      final repo = LocalStorageRepository();
      final item = TemplateItem(
        novelId: 'n1',
        name: 'Hero',
        description: 'Brave',
      );
      await repo.saveCharacterTemplateForm('n1', item);
      final got = await repo.getCharacterTemplateForm('n1');
      expect(got, isNotNull);
      expect(got!.name, 'Hero');
      expect(got.description, 'Brave');
    });

    test('list/get/update/delete no-op when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final list = await repo.listCharacterTemplates();
      expect(list, isEmpty);
      final byId = await repo.getCharacterTemplateById('id');
      expect(byId, isNull);
      await repo.updateCharacterTemplate('id', title: 'X');
      await repo.deleteCharacterTemplate('id');
    });
  });

  group('Character templates supabase', () {
    late MockSupabaseClient client;
    late MockGoTrueClient auth;
    late MockUser user;
    late MockSupabaseQueryBuilder qb;
    late LocalStorageRepository repo;

    setUp(() {
      client = MockSupabaseClient();
      auth = MockGoTrueClient();
      user = MockUser();
      qb = MockSupabaseQueryBuilder();

      when(() => client.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      when(() => client.from('character_templates')).thenAnswer((_) => qb);

      repo = LocalStorageRepository(supabaseEnabled: true, client: client);
    });

    test('saveCharacterTemplateForm throws on duplicate title', () async {
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder([
            {'id': 'dup'},
          ]);
        }
        return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
      });
      when(
        () => qb.insert(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      Object? caught;
      await runZonedGuarded(
        () async {
          try {
            await repo.saveCharacterTemplateForm(
              'n1',
              const TemplateItem(novelId: 'n1', name: 'Hero', description: 'D'),
            );
          } catch (e) {
            caught = e;
          }
        },
        (e, _) {
          caught ??= e;
        },
      );
      expect(caught, isA<Exception>());
      verifyNever(() => qb.insert(any()));
    });

    test('saveCharacterTemplateForm inserts when no duplicate', () async {
      final inserted = <Map<String, dynamic>>[];
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
      when(() => qb.insert(any())).thenAnswer((inv) {
        inserted.add(
          Map<String, dynamic>.from(inv.positionalArguments.first as Map),
        );
        return FakePostgrestFilterBuilder(null);
      });

      await repo.saveCharacterTemplateForm(
        'n1',
        const TemplateItem(novelId: 'n1', name: 'Hero', description: 'Brave'),
      );
      expect(inserted, hasLength(1));
      expect(inserted.single['title'], 'Hero');
      expect(inserted.single['character_summaries'], 'Brave');
      expect(inserted.single['created_by'], 'u1');
    });

    test(
      'getCharacterTemplateForm prefers remote and falls back to local',
      () async {
        when(() => qb.select(any())).thenAnswer(
          (_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );
        when(
          () => qb.insert(any()),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

        await repo.saveCharacterTemplateForm(
          'n1',
          const TemplateItem(novelId: 'n1', name: 'Local', description: 'LD'),
        );

        when(() => qb.select()).thenAnswer((_) {
          return FakePostgrestFilterBuilder([
            {'title': 'Remote', 'character_summaries': 'RD'},
          ]);
        });

        final got = await repo.getCharacterTemplateForm('n1');
        expect(got, isNotNull);
        expect(got!.name, 'Remote');
        expect(got.description, 'RD');
      },
    );

    test('listCharacterTemplates maps rows', () async {
      final rows = [
        {
          'id': 't1',
          'idx': 1,
          'title': 'Hero',
          'character_summaries': 'S',
          'character_synopses': 'Y',
          'language_code': 'en',
          'created_by': 'u1',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
        },
        {
          'id': 't2',
          'idx': 2,
          'title': 'Villain',
          'character_summaries': null,
          'character_synopses': null,
          'language_code': 'zh',
          'created_by': 'u1',
          'created_at': '2024-01-03T00:00:00Z',
          'updated_at': '2024-01-04T00:00:00Z',
        },
      ];
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));

      final res = await repo.listCharacterTemplates();
      expect(res.length, 2);
      expect(res.first.id, 't1');
      expect(res.first.title, 'Hero');
      expect(res.last.languageCode, 'zh');
    });

    test('getCharacterTemplateById maps row', () async {
      final row = {
        'id': 't1',
        'idx': 1,
        'title': 'Hero',
        'character_summaries': 'S',
        'character_synopses': 'Y',
        'language_code': 'en',
        'created_by': 'u1',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
      };
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([row]));

      final res = await repo.getCharacterTemplateById('t1');
      expect(res, isNotNull);
      expect(res!.id, 't1');
      expect(res.title, 'Hero');
    });

    test('deleteCharacterTemplate calls delete', () async {
      when(
        () => qb.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repo.deleteCharacterTemplate('t1');
      verify(() => client.from('character_templates')).called(1);
      verify(() => qb.delete()).called(1);
    });

    test('updateCharacterTemplate throws on duplicate title', () async {
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder([
            {'id': 'existing'},
          ]);
        }
        return FakePostgrestFilterBuilder([]);
      });
      when(
        () => qb.update(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      Object? caught;
      await runZonedGuarded(
        () async {
          try {
            await repo.updateCharacterTemplate('t1', title: 'Hero');
          } catch (e) {
            caught = e;
          }
        },
        (e, _) {
          caught ??= e;
        },
      );
      expect(caught, isA<Exception>());
    });

    test('updateCharacterTemplate updates fields when no duplicate', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
        }
        return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
      });
      when(() => qb.update(any())).thenAnswer((inv) {
        captured.add(
          Map<String, dynamic>.from(inv.positionalArguments.first as Map),
        );
        return FakePostgrestFilterBuilder(null);
      });

      await repo.updateCharacterTemplate(
        't1',
        title: 'New',
        summaries: 'S2',
        synopses: 'Y2',
        languageCode: 'zh',
      );

      expect(captured, hasLength(1));
      expect(captured.single, {
        'title': 'New',
        'character_summaries': 'S2',
        'character_synopses': 'Y2',
        'language_code': 'zh',
      });
    });
  });

  group('Scene templates offline', () {
    test('save/get scene template form via local storage', () async {
      final repo = LocalStorageRepository();
      final item = TemplateItem(
        novelId: 'n1',
        name: 'Battle',
        description: 'Epic',
      );
      await repo.saveSceneTemplateForm('n1', item);
      final got = await repo.getSceneTemplateForm('n1');
      expect(got, isNotNull);
      expect(got!.name, 'Battle');
      expect(got.description, 'Epic');
    });

    test('list/get/update/delete no-op when supabase disabled', () async {
      final repo = LocalStorageRepository();
      final list = await repo.listSceneTemplates();
      expect(list, isEmpty);
      final byId = await repo.getSceneTemplateById('id');
      expect(byId, isNull);
      await repo.updateSceneTemplate('id', title: 'Y');
      await repo.deleteSceneTemplate('id');
    });

    test('search/upsert no-op when supabase disabled', () async {
      final client = MockSupabaseClient();
      final repo = LocalStorageRepository(
        supabaseEnabled: false,
        client: client,
      );

      final res = await repo.searchSceneTemplatesByVector(const [0.1, 0.2]);
      expect(res, isEmpty);

      await repo.upsertSceneTemplateEmbedding('t1', const [0.1, 0.2]);
      verifyNever(() => client.rpc(any(), params: any(named: 'params')));
    });
  });

  group('Scene templates supabase', () {
    late MockSupabaseClient client;
    late MockGoTrueClient auth;
    late MockUser user;
    late MockSupabaseQueryBuilder qb;
    late LocalStorageRepository repo;

    setUp(() {
      client = MockSupabaseClient();
      auth = MockGoTrueClient();
      user = MockUser();
      qb = MockSupabaseQueryBuilder();

      when(() => client.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      when(() => client.from('scene_templates')).thenAnswer((_) => qb);

      repo = LocalStorageRepository(supabaseEnabled: true, client: client);
    });

    test('saveSceneTemplateForm returns inserted id', () async {
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
        }
        return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
      });
      when(() => qb.insert(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder(<String, dynamic>{'id': 'new-id'}),
      );

      final id = await repo.saveSceneTemplateForm(
        'n1',
        const TemplateItem(novelId: 'n1', name: 'Battle', description: 'Epic'),
        languageCode: 'en',
      );
      expect(id, 'new-id');
    });

    test('saveSceneTemplateForm throws on duplicate title', () async {
      when(() => qb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {'id': 'dup'},
        ]),
      );
      when(() => qb.insert(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder(<String, dynamic>{'id': 'new-id'}),
      );

      Object? caught;
      await runZonedGuarded(
        () async {
          try {
            await repo.saveSceneTemplateForm(
              'n1',
              const TemplateItem(
                novelId: 'n1',
                name: 'Battle',
                description: 'Epic',
              ),
              languageCode: 'en',
            );
          } catch (e) {
            caught = e;
          }
        },
        (e, _) {
          caught ??= e;
        },
      );
      expect(caught, isA<Exception>());
    });

    test('listSceneTemplates maps rows', () async {
      final rows = [
        {
          'id': 'a',
          'idx': 1,
          'title': 'A',
          'scene_summaries': 'S',
          'scene_synopses': 'Y',
          'language_code': 'en',
          'created_by': 'u1',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
        },
        {
          'id': 'b',
          'idx': 2,
          'title': 'B',
          'scene_summaries': null,
          'scene_synopses': null,
          'language_code': 'zh',
          'created_by': 'u1',
          'created_at': '2024-01-03T00:00:00Z',
          'updated_at': '2024-01-04T00:00:00Z',
        },
      ];
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));

      final res = await repo.listSceneTemplates();
      expect(res.length, 2);
      expect(res.first.id, 'a');
      expect(res.first.title, 'A');
      expect(res.last.languageCode, 'zh');
    });

    test('getSceneTemplateById maps row', () async {
      final row = {
        'id': 't1',
        'idx': 1,
        'title': 'Battle',
        'scene_summaries': 'S',
        'scene_synopses': 'Y',
        'language_code': 'en',
        'created_by': 'u1',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
      };
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([row]));

      final res = await repo.getSceneTemplateById('t1');
      expect(res, isNotNull);
      expect(res!.id, 't1');
      expect(res.title, 'Battle');
    });

    test('deleteSceneTemplate calls delete', () async {
      when(
        () => qb.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repo.deleteSceneTemplate('t1');
      verify(() => client.from('scene_templates')).called(1);
      verify(() => qb.delete()).called(1);
    });

    test('updateSceneTemplate throws on duplicate title', () async {
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder([
            {'id': 'existing'},
          ]);
        }
        return FakePostgrestFilterBuilder([]);
      });
      when(
        () => qb.update(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      Object? caught;
      await runZonedGuarded(
        () async {
          try {
            await repo.updateSceneTemplate('t1', title: 'Battle');
          } catch (e) {
            caught = e;
          }
        },
        (e, _) {
          caught ??= e;
        },
      );
      expect(caught, isA<Exception>());
    });

    test('updateSceneTemplate updates fields when no duplicate', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => qb.select(any())).thenAnswer((inv) {
        final cols = inv.positionalArguments.first as String;
        if (cols == 'id') {
          return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
        }
        return FakePostgrestFilterBuilder(<Map<String, dynamic>>[]);
      });
      when(() => qb.update(any())).thenAnswer((inv) {
        captured.add(
          Map<String, dynamic>.from(inv.positionalArguments.first as Map),
        );
        return FakePostgrestFilterBuilder(null);
      });

      await repo.updateSceneTemplate(
        't1',
        title: 'New',
        summaries: 'S2',
        synopses: 'Y2',
        languageCode: 'zh',
      );

      expect(captured, hasLength(1));
      expect(captured.single, {
        'title': 'New',
        'scene_summaries': 'S2',
        'scene_synopses': 'Y2',
        'language_code': 'zh',
      });
    });

    test('searchSceneTemplatesByVector returns rows in hit order', () async {
      when(() => client.rpc(any(), params: any(named: 'params'))).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {'id': 'b'},
          {'id': 'a'},
        ]),
      );
      final rows = [
        {
          'id': 'a',
          'idx': 1,
          'title': 'A',
          'scene_summaries': 'S',
          'scene_synopses': 'Y',
          'language_code': 'en',
          'created_by': 'u1',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
        },
        {
          'id': 'b',
          'idx': 2,
          'title': 'B',
          'scene_summaries': 'S2',
          'scene_synopses': 'Y2',
          'language_code': 'en',
          'created_by': 'u1',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
        },
      ];
      when(
        () => qb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));

      final res = await repo.searchSceneTemplatesByVector(
        const [0.1, 0.2],
        limit: 10,
        offset: 0,
        languageCode: 'en',
      );
      expect(res.map((e) => e.id).toList(), ['b', 'a']);
    });

    test(
      'searchSceneTemplatesByVector returns empty when hits empty',
      () async {
        when(() => client.rpc(any(), params: any(named: 'params'))).thenAnswer(
          (_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        final res = await repo.searchSceneTemplatesByVector(
          const [0.1, 0.2],
          limit: 10,
          offset: 0,
        );
        expect(res, isEmpty);
        verifyNever(() => client.from('scene_templates'));
      },
    );

    test(
      'searchSceneTemplatesByVector uses no language filter when null',
      () async {
        when(() => client.rpc(any(), params: any(named: 'params'))).thenAnswer(
          (_) => FakePostgrestFilterBuilder([
            {'id': 'a'},
          ]),
        );
        final rows = [
          {
            'id': 'a',
            'idx': 1,
            'title': 'A',
            'scene_summaries': 'S',
            'scene_synopses': 'Y',
            'language_code': 'en',
            'created_by': 'u1',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-02T00:00:00Z',
          },
        ];
        when(
          () => qb.select(any()),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));

        final res = await repo.searchSceneTemplatesByVector(
          const [0.1, 0.2],
          limit: 10,
          offset: 0,
        );
        expect(res.map((e) => e.id).toList(), ['a']);
      },
    );

    test(
      'upsertSceneTemplateEmbedding calls rpc when embedding non-empty',
      () async {
        when(
          () => client.rpc(any(), params: any(named: 'params')),
        ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

        await repo.upsertSceneTemplateEmbedding('t1', const [0.1, 0.2]);
        verify(
          () => client.rpc(
            'upsert_scene_template_embedding',
            params: {
              'p_template_id': 't1',
              'p_embedding': [0.1, 0.2],
            },
          ),
        ).called(1);
      },
    );

    test('upsertSceneTemplateEmbedding no-ops on empty embedding', () async {
      await repo.upsertSceneTemplateEmbedding('t1', const []);
      verifyNever(() => client.rpc(any(), params: any(named: 'params')));
    });
  });

  group('Characters and scenes supabase', () {
    late MockSupabaseClient client;
    late MockGoTrueClient auth;
    late MockUser user;
    late MockSupabaseQueryBuilder charactersQb;
    late MockSupabaseQueryBuilder scenesQb;
    late LocalStorageRepository repo;

    setUp(() {
      client = MockSupabaseClient();
      auth = MockGoTrueClient();
      user = MockUser();
      charactersQb = MockSupabaseQueryBuilder();
      scenesQb = MockSupabaseQueryBuilder();

      when(() => client.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('u1');
      when(() => client.from('characters')).thenAnswer((_) => charactersQb);
      when(() => client.from('scenes')).thenAnswer((_) => scenesQb);

      repo = LocalStorageRepository(supabaseEnabled: true, client: client);
    });

    test('saveCharacterForm upserts when supabase enabled', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => charactersQb.upsert(any())).thenAnswer((inv) {
        captured.add(
          Map<String, dynamic>.from(inv.positionalArguments.first as Map),
        );
        return FakePostgrestFilterBuilder(null);
      });
      final c = Character(novelId: 'n1', name: 'Alice', role: 'R', bio: 'B');
      await repo.saveCharacterForm('n1', c, idx: 2);
      expect(captured, hasLength(1));
      expect(captured.single['novel_id'], 'n1');
      expect(captured.single['idx'], 2);
      expect(captured.single['title'], 'Alice');
      expect(captured.single['character_summaries'], 'R');
      expect(captured.single['character_synopses'], 'B');
    });

    test('getCharacterForm returns remote row when present', () async {
      when(() => charactersQb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {
            'title': 'Remote',
            'character_summaries': 'RS',
            'character_synopses': 'RB',
          },
        ]),
      );
      final got = await repo.getCharacterForm('n1', idx: 1);
      expect(got, isNotNull);
      expect(got!.name, 'Remote');
      expect(got.role, 'RS');
      expect(got.bio, 'RB');
    });

    test('listCharacterNotes maps rows when supabase enabled', () async {
      when(() => charactersQb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {
            'id': 'c1',
            'novel_id': 'n1',
            'idx': 1,
            'title': 'A',
            'character_summaries': 'S',
            'character_synopses': 'Y',
            'language_code': 'en',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-02T00:00:00Z',
          },
        ]),
      );
      final notes = await repo.listCharacterNotes('n1');
      expect(notes.length, 1);
      expect(notes.first.id, 'c1');
      expect(notes.first.title, 'A');
    });

    test('nextCharacterIdx returns max+1 when supabase enabled', () async {
      when(() => charactersQb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {'idx': 3},
        ]),
      );
      final next = await repo.nextCharacterIdx('n1');
      expect(next, 4);
    });

    test('deleteCharacterNoteByIdx calls delete with filters', () async {
      when(
        () => charactersQb.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));
      await repo.deleteCharacterNoteByIdx('n1', 2);
      verify(() => charactersQb.delete()).called(1);
    });

    test('saveSceneForm upserts when supabase enabled', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => scenesQb.upsert(any())).thenAnswer((inv) {
        captured.add(
          Map<String, dynamic>.from(inv.positionalArguments.first as Map),
        );
        return FakePostgrestFilterBuilder(null);
      });
      final s = Scene(
        novelId: 'n1',
        title: 'Opening',
        location: 'Forest',
        summary: 'Intro',
      );
      await repo.saveSceneForm('n1', s, idx: 5);
      expect(captured, hasLength(1));
      expect(captured.single['novel_id'], 'n1');
      expect(captured.single['idx'], 5);
      expect(captured.single['title'], 'Opening');
      expect(captured.single['scene_summaries'], 'Intro');
      expect(captured.single['scene_synopses'], 'Forest');
    });

    test('listSceneNotes maps rows when supabase enabled', () async {
      when(() => scenesQb.select(any())).thenAnswer(
        (_) => FakePostgrestFilterBuilder([
          {
            'id': 's1',
            'novel_id': 'n1',
            'idx': 1,
            'title': 'T',
            'scene_summaries': 'S',
            'scene_synopses': 'L',
            'language_code': 'en',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-02T00:00:00Z',
          },
        ]),
      );
      final notes = await repo.listSceneNotes('n1');
      expect(notes.length, 1);
      expect(notes.first.id, 's1');
      expect(notes.first.title, 'T');
    });

    test('nextSceneIdx returns 1 when no rows', () async {
      when(
        () => scenesQb.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
      final next = await repo.nextSceneIdx('n1');
      expect(next, 1);
    });

    test('deleteSceneNoteById calls delete', () async {
      when(
        () => scenesQb.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));
      await repo.deleteSceneNoteById('s1');
      verify(() => scenesQb.delete()).called(1);
    });
  });
}
