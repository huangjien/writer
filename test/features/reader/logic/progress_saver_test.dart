import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/reader/logic/progress_saver.dart' as saver;
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/state/providers.dart';

void main() {
  test('saveReaderProgress returns notEnabled when signed out', () async {
    final container = ProviderContainer(
      overrides: [isSignedInProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);
    final refProvider = Provider((ref) => ref);
    final status = await saver.saveReaderProgress(
      ref: container.read(refProvider),
      novelId: 'n1',
      chapterId: 'c1',
      scrollOffset: 12.3,
      ttsIndex: 5,
    );
    expect(status, saver.SaveStatus.notEnabled);
  });

  test(
    'saveReaderProgress returns noUser when signed in but user null',
    () async {
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);
      final refProvider = Provider((ref) => ref);
      final status = await saver.saveReaderProgress(
        ref: container.read(refProvider),
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 1.0,
        ttsIndex: 0,
      );
      expect(status, saver.SaveStatus.noUser);
    },
  );

  test(
    'saveReaderProgress returns error when repository save throws',
    () async {
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith(
            (ref) async => const BackendUser(id: 'u1', email: null),
          ),
          progressRepositoryProvider.overrideWithValue(
            FakeProgressPort(shouldThrowOnSave: true),
          ),
        ],
      );
      addTearDown(container.dispose);
      final refProvider = Provider((ref) => ref);
      final status = await saver.saveReaderProgress(
        ref: container.read(refProvider),
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0.0,
        ttsIndex: 0,
      );
      expect(status, saver.SaveStatus.error);
    },
  );

  test(
    'saveReaderProgress returns saved when repository save succeeds',
    () async {
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          currentUserProvider.overrideWith(
            (ref) async => const BackendUser(id: 'u1', email: null),
          ),
          progressRepositoryProvider.overrideWithValue(
            FakeProgressPort(shouldThrowOnSave: false),
          ),
        ],
      );
      addTearDown(container.dispose);
      final refProvider = Provider((ref) => ref);
      final status = await saver.saveReaderProgress(
        ref: container.read(refProvider),
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0.0,
        ttsIndex: 0,
      );
      expect(status, saver.SaveStatus.saved);
    },
  );
}

class FakeProgressPort implements ProgressPort {
  final bool shouldThrowOnSave;
  FakeProgressPort({required this.shouldThrowOnSave});

  @override
  Future<void> upsertProgress(UserProgress progress) async {
    if (shouldThrowOnSave) throw Exception('boom');
  }

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;

  @override
  Future<UserProgress?> latestProgressForUser() async => null;
}
