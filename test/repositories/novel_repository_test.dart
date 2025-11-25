import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late NovelRepository repository;

  setUpAll(() {
    registerFallbackValue((List<Map<String, dynamic>> _) {});
    registerFallbackValue((Map<String, dynamic> _) {});
    registerFallbackValue((dynamic _) {});
    registerFallbackValue((Object error, StackTrace stackTrace) {});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    repository = NovelRepository(mockClient);

    // Default setups
    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
  });

  group('NovelRepository', () {
    test('fetchPublicNovels returns list of novels', () async {
      final novelsData = [
        {
          'id': '1',
          'title': 'Test Novel',
          'author': 'Author',
          'description': 'Desc',
          'cover_url': null,
          'language_code': 'en',
          'is_public': true,
          'owner_id': 'owner1',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(novelsData));

      final result = await repository.fetchPublicNovels();

      expect(result, isA<List<Novel>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Test Novel');
    });

    test('getNovel returns novel when found', () async {
      final novelData = {
        'id': '1',
        'title': 'Test Novel',
        'author': 'Author',
        'description': 'Desc',
        'cover_url': null,
        'language_code': 'en',
        'is_public': true,
        'owner_id': 'owner1',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // select() returns a list of maps usually, then single() extracts one
      // If the query returns a list containing one item:
      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => FakePostgrestFilterBuilder([novelData]));

      final result = await repository.getNovel('1');

      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.title, 'Test Novel');
    });

    test('deleteNovel calls delete', () async {
      when(
        () => mockQueryBuilder.delete(),
      ).thenAnswer((_) => FakePostgrestFilterBuilder(null));

      await repository.deleteNovel('1');

      verify(() => mockClient.from('novels')).called(1);
      verify(() => mockQueryBuilder.delete()).called(1);
    });
  });
}
