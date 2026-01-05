import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository remote;
  late NovelRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    remote = MockRemoteRepository();
    repo = NovelRepository(remote);
  });

  test('updateNovelMetadata only updates provided fields', () async {
    final captured = <Map<String, dynamic>>[];
    when(() => remote.patch(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return {};
    });

    await repo.updateNovelMetadata('n1', title: 'T', languageCode: 'zh');

    expect(captured.single.keys.toSet(), {'title', 'language_code'});
    verify(() => remote.patch('novels/n1', any())).called(1);
  });

  test('updateNovelMetadata does nothing if no fields provided', () async {
    await repo.updateNovelMetadata('n1');
    verifyNever(() => remote.patch(any(), any()));
  });

  test('fetchPublicNovels maps list result', () async {
    when(() => remote.get('novels/public')).thenAnswer((_) async {
      return [
        {
          'id': 'n1',
          'title': 'A',
          'author': null,
          'description': null,
          'cover_url': null,
          'language_code': 'en',
          'is_public': true,
        },
      ];
    });

    final novels = await repo.fetchPublicNovels();
    expect(novels.single.id, 'n1');
    verify(() => remote.get('novels/public')).called(1);
  });

  test('fetchMemberNovels maps list result', () async {
    when(
      () => remote.get(
        'novels/member',
        queryParameters: any(named: 'queryParameters'),
        retryUnauthorized: any(named: 'retryUnauthorized'),
      ),
    ).thenAnswer((_) async {
      return [
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
    });

    final list = await repo.fetchMemberNovels(limit: 10, offset: 0);
    expect(list.map((n) => n.id).toList(), ['n1', 'n2']);
    verify(
      () => remote.get(
        'novels/member',
        queryParameters: any(named: 'queryParameters'),
        retryUnauthorized: any(named: 'retryUnauthorized'),
      ),
    ).called(1);
  });

  test('fetchChaptersByNovel maps list result', () async {
    when(() => remote.get('novels/n1/chapters')).thenAnswer((_) async {
      return [
        {'id': 'c1', 'novel_id': 'n1', 'title': 'T', 'idx': 1},
        {'id': 'c2', 'novel_id': 'n1', 'title': null, 'idx': 2},
      ];
    });

    final chapters = await repo.fetchChaptersByNovel('n1');
    expect(chapters.map((c) => c.id).toList(), ['c1', 'c2']);
    verify(() => remote.get('novels/n1/chapters')).called(1);
  });

  test('createNovel posts fields and returns mapped novel', () async {
    final captured = <Map<String, dynamic>>[];
    when(() => remote.post(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return {
        'id': 'n9',
        'title': 'New',
        'author': null,
        'description': null,
        'cover_url': null,
        'language_code': 'en',
        'is_public': true,
      };
    });

    final created = await repo.createNovel(title: 'New');
    expect(created.id, 'n9');
    expect(captured.single['title'], 'New');
    verify(() => remote.post('novels', any())).called(1);
  });

  test('getNovel returns mapped object and null on error', () async {
    when(() => remote.get('novels/n3')).thenAnswer((_) async {
      return {
        'id': 'n3',
        'title': 'T',
        'author': 'A',
        'description': null,
        'cover_url': null,
        'language_code': 'en',
        'is_public': true,
      };
    });
    final n = await repo.getNovel('n3');
    expect(n!.id, 'n3');

    when(() => remote.get('novels/nX')).thenThrow(Exception('404'));
    final none = await repo.getNovel('nX');
    expect(none, isNull);
  });

  test('getChapter returns mapped object and null on error', () async {
    when(() => remote.get('chapters/c1')).thenAnswer((_) async {
      return {'id': 'c1', 'novel_id': 'n1', 'title': 'T', 'idx': 1};
    });
    final chapter = await repo.getChapter('c1');
    expect(chapter!.id, 'c1');

    when(() => remote.get('chapters/missing')).thenThrow(Exception('404'));
    final none = await repo.getChapter('missing');
    expect(none, isNull);
  });

  test('deleteNovel calls delete', () async {
    when(() => remote.delete(any())).thenAnswer((_) async {});
    await repo.deleteNovel('n1');
    verify(() => remote.delete('novels/n1')).called(1);
  });

  test('addContributor throws UnimplementedError', () async {
    expect(
      () => repo.addContributor(novelId: 'n1', userId: 'u1'),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('addContributorByEmail calls post', () async {
    when(() => remote.post(any(), any())).thenAnswer((_) async => {});
    await repo.addContributorByEmail(novelId: 'n1', email: 'e');
    verify(
      () => remote.post('novels/n1/contributors', {'email': 'e'}),
    ).called(1);
  });

  test('fetchSummaries maps list result', () async {
    when(() => remote.get('summaries/novel/n1')).thenAnswer((_) async {
      return [
        {
          'id': 's1',
          'novel_id': 'n1',
          'idx': 1,
          'title': 'Summary 1',
          'sentence_summary': 'Content 1',
          'language_code': 'en',
        },
        {
          'id': 's2',
          'novel_id': 'n1',
          'idx': 2,
          'title': 'Summary 2',
          'sentence_summary': 'Content 2',
          'language_code': 'en',
        },
      ];
    });

    final summaries = await repo.fetchSummaries('n1');
    expect(summaries.length, 2);
    expect(summaries.first.id, 's1');
    expect(summaries.last.id, 's2');
    verify(() => remote.get('summaries/novel/n1')).called(1);
  });

  test('fetchSummaries handles invalid response', () async {
    when(
      () => remote.get('summaries/novel/n1'),
    ).thenAnswer((_) async => 'invalid');
    final summaries = await repo.fetchSummaries('n1');
    expect(summaries, isEmpty);
  });

  test('createSummary posts summary and returns mapped result', () async {
    final summary = Summary(
      id: 's1',
      novelId: 'n1',
      idx: 1,
      title: 'Test Summary',
      sentenceSummary: 'Test content',
    );

    final captured = <Map<String, dynamic>>[];
    when(() => remote.post(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return {
        'id': 's2',
        'novel_id': 'n1',
        'idx': 1,
        'title': 'Test Summary',
        'sentence_summary': 'Test content',
        'language_code': 'en',
      };
    });

    final created = await repo.createSummary(summary);
    expect(created.id, 's2');
    expect(captured.single.keys, isNot(contains('id')));
    verify(() => remote.post('summaries', any())).called(1);
  });

  test('createSummary throws exception on failure', () async {
    final summary = Summary(
      id: 's1',
      novelId: 'n1',
      idx: 1,
      title: 'Test Summary',
      sentenceSummary: 'Test content',
    );

    when(() => remote.post(any(), any())).thenAnswer((_) async => 'invalid');
    expect(() => repo.createSummary(summary), throwsException);
  });

  test('updateSummary patches summary and returns mapped result', () async {
    final summary = Summary(
      id: 's1',
      novelId: 'n1',
      idx: 1,
      title: 'Updated Summary',
      sentenceSummary: 'Updated content',
    );

    when(() => remote.patch(any(), any())).thenAnswer((_) async {
      return {
        'id': 's1',
        'novel_id': 'n1',
        'idx': 1,
        'title': 'Updated Summary',
        'sentence_summary': 'Updated content',
        'language_code': 'en',
      };
    });

    final updated = await repo.updateSummary(summary);
    expect(updated.id, 's1');
    expect(updated.title, 'Updated Summary');
    verify(() => remote.patch('summaries/s1', any())).called(1);
  });

  test('updateSummary throws exception on failure', () async {
    final summary = Summary(
      id: 's1',
      novelId: 'n1',
      idx: 1,
      title: 'Test Summary',
      sentenceSummary: 'Test content',
    );

    when(() => remote.patch(any(), any())).thenAnswer((_) async => 'invalid');
    expect(() => repo.updateSummary(summary), throwsException);
  });

  test('createNovel with all fields', () async {
    final captured = <Map<String, dynamic>>[];
    when(() => remote.post(any(), any())).thenAnswer((inv) async {
      captured.add(inv.positionalArguments[1] as Map<String, dynamic>);
      return {
        'id': 'n9',
        'title': 'New Novel',
        'author': 'Author Name',
        'description': 'Description',
        'cover_url': 'https://example.com/cover.jpg',
        'language_code': 'zh',
        'is_public': false,
      };
    });

    final created = await repo.createNovel(
      title: 'New Novel',
      author: 'Author Name',
      description: 'Description',
      coverUrl: 'https://example.com/cover.jpg',
      languageCode: 'zh',
      isPublic: false,
    );
    expect(created.id, 'n9');
    expect(captured.single.keys.toSet(), {
      'title',
      'author',
      'description',
      'cover_url',
      'language_code',
      'is_public',
    });
  });

  test('createNovel throws exception on failure', () async {
    when(() => remote.post(any(), any())).thenAnswer((_) async => 'invalid');
    expect(() => repo.createNovel(title: 'Test'), throwsException);
  });

  test('fetchPublicNovels handles invalid response', () async {
    when(() => remote.get('novels/public')).thenAnswer((_) async => 'invalid');
    final novels = await repo.fetchPublicNovels();
    expect(novels, isEmpty);
  });

  test('fetchChaptersByNovel handles invalid response', () async {
    when(
      () => remote.get('novels/n1/chapters'),
    ).thenAnswer((_) async => 'invalid');
    final chapters = await repo.fetchChaptersByNovel('n1');
    expect(chapters, isEmpty);
  });

  test('getNovel handles null response', () async {
    when(() => remote.get('novels/n1')).thenAnswer((_) async => null);
    final novel = await repo.getNovel('n1');
    expect(novel, isNull);
  });

  test('getChapter handles null response', () async {
    when(() => remote.get('chapters/c1')).thenAnswer((_) async => null);
    final chapter = await repo.getChapter('c1');
    expect(chapter, isNull);
  });

  test('fetchMemberNovels with default parameters', () async {
    when(
      () => remote.get(
        'novels/member',
        queryParameters: any(named: 'queryParameters'),
        retryUnauthorized: any(named: 'retryUnauthorized'),
      ),
    ).thenAnswer((_) async => []);

    await repo.fetchMemberNovels();

    verify(
      () => remote.get(
        'novels/member',
        queryParameters: {'limit': '50', 'offset': '0'},
        retryUnauthorized: false,
      ),
    ).called(1);
  });

  test('fetchMemberNovels handles invalid response', () async {
    when(
      () => remote.get(
        'novels/member',
        queryParameters: any(named: 'queryParameters'),
        retryUnauthorized: any(named: 'retryUnauthorized'),
      ),
    ).thenAnswer((_) async => 'invalid');

    final novels = await repo.fetchMemberNovels();
    expect(novels, isEmpty);
  });
}
