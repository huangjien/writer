import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}
// Builder mocks are omitted due to generic type complexity with mocktail.
// class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockLocalStorageRepository mockLocalStorageRepository;
  late ChapterRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockLocalStorageRepository = MockLocalStorageRepository();

    repository = ChapterRepository(
      mockSupabaseClient,
      mockLocalStorageRepository,
    );

    registerFallbackValue(
      ChapterCache(
        chapterId: 'id',
        novelId: 'nid',
        idx: 1,
        title: 't',
        content: 'c',
        lastUpdated: DateTime.now(),
      ),
    );
  });

  group('ChapterRepository', () {
    test('getChapter returns cached chapter if available', () async {
      final chapter = Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'C1');
      final cachedChapter = ChapterCache(
        chapterId: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'C1',
        content: 'Cached Content',
        lastUpdated: DateTime.now(),
      );

      when(
        () => mockLocalStorageRepository.getChapter('c1'),
      ).thenAnswer((_) async => cachedChapter);

      final result = await repository.getChapter(chapter);

      expect(result.content, 'Cached Content');
      verify(() => mockLocalStorageRepository.getChapter('c1')).called(1);
      verifyZeroInteractions(mockSupabaseClient);
    });

    // Validating full Supabase chains with mocks is complex due to generic builders.
    // Ideally we would use a Fake Supabase client or integration tests.
  });
}
