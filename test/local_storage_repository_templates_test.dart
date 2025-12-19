import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/local_storage_repository.dart';
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
  });
}
