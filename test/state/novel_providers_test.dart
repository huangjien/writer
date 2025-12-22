import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/main.dart'; // Import main.dart to access localStorageRepositoryProvider

// Mocks
class MockNovelRepository extends Mock implements NovelRepository {}

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late MockNovelRepository mockRepo;
  late MockLocalStorageRepository mockLocalRepo;

  setUp(() {
    mockRepo = MockNovelRepository();
    mockLocalRepo = MockLocalStorageRepository();
  });

  group('Novel Providers', () {
    test('novelsProvider fetches public novels', () async {
      final novels = [
        const Novel(
          id: '1',
          title: 'Test',
          author: 'A',
          languageCode: 'en',
          isPublic: true,
        ),
      ];
      when(() => mockRepo.fetchPublicNovels()).thenAnswer((_) async => novels);

      final container = ProviderContainer(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockRepo),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(novelsProvider.future);
      expect(result, novels);
      verify(() => mockRepo.fetchPublicNovels()).called(1);
    });

    test('memberNovelsProvider fetches member novels', () async {
      final novels = [
        const Novel(
          id: '2',
          title: 'Member',
          author: 'Me',
          languageCode: 'en',
          isPublic: false,
        ),
      ];
      when(() => mockRepo.fetchMemberNovels()).thenAnswer((_) async => novels);

      final container = ProviderContainer(
        overrides: [
          novelRepositoryProvider.overrideWithValue(mockRepo),
          isSignedInProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(memberNovelsProvider.future);
      expect(result, novels);
      verify(() => mockRepo.fetchMemberNovels()).called(1);
    });

    test('libraryNovelsProvider merges public and member novels', () async {
      final public = [
        const Novel(
          id: '1',
          title: 'Public',
          author: 'A',
          languageCode: 'en',
          isPublic: true,
        ),
      ];
      final member = [
        const Novel(
          id: '2',
          title: 'Member',
          author: 'Me',
          languageCode: 'en',
          isPublic: false,
        ),
      ];

      when(
        () => mockLocalRepo.saveLibraryNovels(any()),
      ).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(mockLocalRepo),
          // Override fetching providers to return static data immediately
          novelsProvider.overrideWith((ref) async => public),
          memberNovelsProvider.overrideWith((ref) async => member),
        ],
      );

      try {
        final result = await container.read(libraryNovelsProvider.future);
        expect(result.length, 2);
        expect(result.any((n) => n.id == '1'), true);
        expect(result.any((n) => n.id == '2'), true);
        verify(() => mockLocalRepo.saveLibraryNovels(any())).called(1);
      } finally {
        container.dispose();
      }
    }, skip: true);

    test('libraryNovelsProvider falls back to local cache on error', () async {
      final public = [
        const Novel(
          id: '1',
          title: 'Public',
          author: 'A',
          languageCode: 'en',
          isPublic: true,
        ),
      ];
      final cached = [
        const Novel(
          id: '3',
          title: 'Cached',
          author: 'C',
          languageCode: 'en',
          isPublic: true,
        ),
      ];

      when(
        () => mockLocalRepo.getLibraryNovels(),
      ).thenAnswer((_) async => cached);

      final container = ProviderContainer(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(mockLocalRepo),
          novelsProvider.overrideWith((ref) async => public),
          // Mock memberNovelsProvider to complete with error
          memberNovelsProvider.overrideWith(
            (ref) => Future<List<Novel>>.error(Exception('Network error')),
          ),
        ],
      );

      try {
        final sub = container.listen(memberNovelsProvider, (prev, _) {});
        final _ = await container.read(novelsProvider.future);
        try {
          await container.read(memberNovelsProvider.future);
        } catch (_) {}
        final result = await container.read(libraryNovelsProvider.future);
        expect(result.length, 2); // Public + Cached
        expect(result.any((n) => n.id == '1'), true);
        expect(result.any((n) => n.id == '3'), true);
        sub.close();
      } finally {
        container.dispose();
      }
    }, skip: true);

    test(
      'recentProgressDetailsProvider combines progress with novel/chapter',
      () async {
        final progress = [
          UserProgress(
            userId: 'u1',
            novelId: 'n1',
            chapterId: 'c1',
            updatedAt: DateTime.now(),
            scrollOffset: 0,
            ttsCharIndex: 0,
          ),
        ];
        final novel = const Novel(
          id: 'n1',
          title: 'N1',
          languageCode: 'en',
          isPublic: true,
        );
        final chapter = const Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 'C1',
          content: '',
        );

        when(() => mockRepo.getNovel('n1')).thenAnswer((_) async => novel);
        when(() => mockRepo.getChapter('c1')).thenAnswer((_) async => chapter);

        final container = ProviderContainer(
          overrides: [
            novelRepositoryProvider.overrideWithValue(mockRepo),
            recentUserProgressProvider.overrideWith((ref) async => progress),
          ],
        );

        try {
          final result = await container.read(
            recentProgressDetailsProvider.future,
          );
          expect(result, hasLength(1));
          expect(result.first.novel.id, 'n1');
          expect(result.first.chapter.id, 'c1');
        } finally {
          container.dispose();
        }
      },
    );
  });
}
