import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/common/errors/failures.dart';
import 'dart:io';

import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

void main() {
  late MockSupabaseClient client;
  late MockSupabaseQueryBuilder qb;
  late MockGoTrueClient auth;
  late MockUser user;
  late NovelRepository repo;

  setUp(() {
    client = MockSupabaseClient();
    qb = MockSupabaseQueryBuilder();
    auth = MockGoTrueClient();
    user = MockUser();
    repo = NovelRepository(client);
    when(() => client.from(any())).thenAnswer((_) => qb);
    when(() => client.auth).thenReturn(auth);
  });

  test('updateNovelMetadata only updates provided fields', () async {
    final captured = <Map<String, dynamic>>[];
    when(() => qb.update(any())).thenAnswer((inv) {
      captured.add(inv.positionalArguments.first as Map<String, dynamic>);
      return FakePostgrestFilterBuilder(null);
    });
    await repo.updateNovelMetadata('n1', title: 'T', languageCode: 'zh');

    expect(captured.single.keys.toSet(), {'title', 'language_code'});
    verify(() => qb.update(any())).called(1);
  });

  test('addContributorByEmail calls rpc with parameters', () async {
    when(
      () => client.rpc(any(), params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
    await repo.addContributorByEmail(novelId: 'n1', email: 'user@example.com');
    verify(
      () => client.rpc(
        'add_contributor_by_email',
        params: {'p_novel_id': 'n1', 'p_email': 'user@example.com'},
      ),
    ).called(1);
  });

  test('fetchMemberNovels maps list result', () async {
    final rows = [
      {
        'id': 'n1',
        'title': 'A',
        'author': 'X',
        'description': null,
        'cover_url': null,
        'language_code': 'en',
        'is_public': true,
      },
      {
        'id': 'n2',
        'title': 'B',
        'author': null,
        'description': null,
        'cover_url': null,
        'language_code': 'en',
        'is_public': true,
      },
    ];
    when(
      () => client.rpc(any(), params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(rows));
    final list = await repo.fetchMemberNovels(limit: 10, offset: 0);
    expect(list.map((n) => n.id).toList(), ['n1', 'n2']);
    verify(
      () => client.rpc('member_novels', params: {'p_limit': 10, 'p_offset': 0}),
    ).called(1);
  });

  test('getNovel returns mapped object and null on empty', () async {
    when(() => qb.select()).thenAnswer(
      (_) => FakePostgrestFilterBuilder([
        {
          'id': 'n3',
          'title': 'T',
          'author': 'A',
          'description': null,
          'cover_url': null,
          'language_code': 'en',
          'is_public': true,
        },
      ]),
    );
    final n = await repo.getNovel('n3');
    expect(n!.id, 'n3');

    when(
      () => qb.select(),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(<Map<String, dynamic>>[]));
    final none = await repo.getNovel('nX');
    expect(none, isNull);
  });

  test('fetchPublicNovels and fetchChaptersByNovel use select chain', () async {
    when(() => client.from('novels')).thenAnswer((_) => qb);
    when(() => qb.select()).thenAnswer(
      (_) => FakePostgrestFilterBuilder([
        {
          'id': 'n1',
          'title': 'A',
          'author': null,
          'description': null,
          'cover_url': null,
          'language_code': 'en',
          'is_public': true,
        },
      ]),
    );
    final novels = await repo.fetchPublicNovels();
    expect(novels.length, 1);

    final chaptersRows = [
      {'id': 'c1', 'novel_id': 'n1', 'title': 'T', 'idx': 1},
      {'id': 'c2', 'novel_id': 'n1', 'title': null, 'idx': 2},
    ];
    when(() => client.from('chapters')).thenAnswer((_) => qb);
    when(
      () => qb.select(),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(chaptersRows));
    final chapters = await repo.fetchChaptersByNovel('n1');
    expect(chapters.map((c) => c.id).toList(), ['c1', 'c2']);
  });

  test('createNovel builds insert payload and returns mapped novel', () async {
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.id).thenReturn('owner1');
    final singleMap = {
      'id': 'n9',
      'title': 'New',
      'author': null,
      'description': null,
      'cover_url': null,
      'language_code': 'en',
      'is_public': true,
    };
    when(
      () => qb.insert(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([singleMap]));
    when(
      () => qb.select(),
    ).thenAnswer((_) => FakePostgrestFilterBuilder([singleMap]));
    final created = await repo.createNovel(title: 'New');
    expect(created.id, 'n9');
    verify(() => qb.insert(any())).called(1);
  });

  test('deleteNovel and addContributor issue correct operations', () async {
    when(() => client.from('novel_contributors')).thenAnswer((_) => qb);
    when(
      () => qb.insert(any()),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(null));
    await repo.addContributor(novelId: 'n1', userId: 'u1');
    verify(
      () =>
          qb.insert({'novel_id': 'n1', 'user_id': 'u1', 'role': 'contributor'}),
    ).called(1);

    when(() => client.from('novels')).thenAnswer((_) => qb);
    when(() => qb.delete()).thenAnswer((_) => FakePostgrestFilterBuilder(null));
    await repo.deleteNovel('n1');
    verify(() => qb.delete()).called(1);
  });

  group('NovelRepository Failures', () {
    test(
      'fetchPublicNovels throws ServerFailure on PostgrestException',
      () async {
        when(() => qb.select()).thenThrow(
          const PostgrestException(message: 'Server Error', code: '500'),
        );
        expect(
          () => repo.fetchPublicNovels(),
          throwsA(
            isA<ServerFailure>()
                .having((f) => f.message, 'message', 'Server Error')
                .having((f) => f.statusCode, 'statusCode', 500),
          ),
        );
      },
    );

    test(
      'fetchPublicNovels throws NetworkFailure on SocketException',
      () async {
        when(() => qb.select()).thenThrow(const SocketException('No internet'));
        expect(() => repo.fetchPublicNovels(), throwsA(isA<NetworkFailure>()));
      },
    );

    test('fetchPublicNovels throws UnknownFailure on other errors', () async {
      when(() => qb.select()).thenThrow(Exception('Unknown'));
      expect(() => repo.fetchPublicNovels(), throwsA(isA<UnknownFailure>()));
    });

    test('createNovel throws ServerFailure on PostgrestException', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('owner1');
      when(
        () => qb.insert(any()),
      ).thenThrow(const PostgrestException(message: 'DB Error'));
      expect(
        () => repo.createNovel(title: 'Fail'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('getNovel returns null on PGRST116', () async {
      final filterBuilder = MockPostgrestFilterBuilder();
      when(() => qb.select()).thenAnswer((_) => filterBuilder);
      when(
        () => filterBuilder.eq(any(), any()),
      ).thenAnswer((_) => filterBuilder);
      when(() => filterBuilder.single()).thenThrow(
        const PostgrestException(message: 'Row not found', code: 'PGRST116'),
      );

      final result = await repo.getNovel('missing');
      expect(result, isNull);
    });

    test('getNovel throws ServerFailure on other PostgrestException', () async {
      final filterBuilder = MockPostgrestFilterBuilder();
      when(() => qb.select()).thenAnswer((_) => filterBuilder);
      when(
        () => filterBuilder.eq(any(), any()),
      ).thenAnswer((_) => filterBuilder);
      when(
        () => filterBuilder.single(),
      ).thenThrow(const PostgrestException(message: 'DB Error', code: '500'));

      expect(() => repo.getNovel('error'), throwsA(isA<ServerFailure>()));
    });

    test('getChapter returns null on PGRST116', () async {
      final filterBuilder = MockPostgrestFilterBuilder();
      when(() => qb.select()).thenAnswer((_) => filterBuilder);
      when(
        () => filterBuilder.eq(any(), any()),
      ).thenAnswer((_) => filterBuilder);
      when(() => filterBuilder.single()).thenThrow(
        const PostgrestException(message: 'Row not found', code: 'PGRST116'),
      );

      final result = await repo.getChapter('missing');
      expect(result, isNull);
    });

    test('updateNovelMetadata does nothing if no fields provided', () async {
      // No calls to update should happen
      await repo.updateNovelMetadata('n1');
      verifyNever(() => qb.update(any()));
    });

    test('fetchChaptersByNovel throws ServerFailure', () async {
      when(
        () => qb.select(),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(
        () => repo.fetchChaptersByNovel('n1'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('deleteNovel throws ServerFailure', () async {
      when(
        () => qb.delete(),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(() => repo.deleteNovel('n1'), throwsA(isA<ServerFailure>()));
    });

    test('updateNovelMetadata throws ServerFailure', () async {
      when(
        () => qb.update(any()),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(
        () => repo.updateNovelMetadata('n1', title: 'T'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('addContributor throws ServerFailure', () async {
      when(
        () => qb.insert(any()),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(
        () => repo.addContributor(novelId: 'n1', userId: 'u1'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('fetchMemberNovels throws ServerFailure', () async {
      when(
        () => client.rpc(any(), params: any(named: 'params')),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(() => repo.fetchMemberNovels(), throwsA(isA<ServerFailure>()));
    });

    test('addContributorByEmail throws ServerFailure', () async {
      when(
        () => client.rpc(any(), params: any(named: 'params')),
      ).thenThrow(const PostgrestException(message: 'Error'));
      expect(
        () => repo.addContributorByEmail(novelId: 'n1', email: 'e'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
