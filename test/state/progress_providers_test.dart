import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  test('latestUserProgressProvider returns null when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((_) => null),
        isSignedInProvider.overrideWith((_) => false),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(latestUserProgressProvider.future);
    expect(value, isNull);
  });

  test(
    'recentUserProgressProvider returns empty list when signed out',
    () async {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((_) => null),
          isSignedInProvider.overrideWith((_) => false),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(recentUserProgressProvider.future);
      expect(value, isEmpty);
    },
  );

  test('lastProgressProvider returns value from repository', () async {
    final fakeRepo = _FakeProgressRepo(
      UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 42.0,
        ttsCharIndex: 7,
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWith((_) => true),
        authStateProvider.overrideWith((_) => 'session'),
        progressRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final res = await container.read(lastProgressProvider('n1').future);
    expect(res, isNotNull);
    expect(res!.chapterId, 'c1');
    expect(res.novelId, 'n1');
  });

  test(
    'lastProgressProvider returns null when repository returns null',
    () async {
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWith((_) => true),
          authStateProvider.overrideWith((_) => 'session'),
          progressRepositoryProvider.overrideWithValue(_FakeProgressRepo(null)),
        ],
      );
      addTearDown(container.dispose);

      final res = await container.read(lastProgressProvider('nX').future);
      expect(res, isNull);
    },
  );

  test('latestUserProgressProvider reads repository when signed in', () async {
    final fakeRepo = _FakeProgressRepo(
      UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 1.0,
        ttsCharIndex: 0,
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWith((_) => true),
        authStateProvider.overrideWith((_) => 'session'),
        progressRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final res = await container.read(latestUserProgressProvider.future);
    expect(res, isNotNull);
    expect(res!.chapterId, 'c1');
  });

  test('recentUserProgressProvider maps remote list when signed in', () async {
    final remote = MockRemoteRepository();
    when(
      () => remote.get('progress/recent', queryParameters: {'limit': '3'}),
    ).thenAnswer(
      (_) async => [
        {
          'user_id': 'u1',
          'novel_id': 'n1',
          'chapter_id': 'c1',
          'scroll_offset': 2.0,
          'tts_char_index': 3,
          'updated_at': '2024-01-01T00:00:00Z',
        },
      ],
    );
    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWith((_) => true),
        authStateProvider.overrideWith((_) => 'session'),
        remoteRepositoryProvider.overrideWith((_) => remote),
      ],
    );
    addTearDown(container.dispose);

    final res = await container.read(recentUserProgressProvider.future);
    expect(res, hasLength(1));
    expect(res.single.novelId, 'n1');
  });
}

class _FakeProgressRepo implements ProgressPort {
  final UserProgress? value;
  _FakeProgressRepo(this.value);

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => value;

  @override
  Future<UserProgress?> latestProgressForUser() async => value;

  @override
  Future<void> upsertProgress(UserProgress progress) async {}
}
