import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';

class FakeProgressRepo implements ProgressPort {
  bool throwOnUpsert = false;
  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;
  Stream<List<UserProgress>> recentProgressForUser(
    String userId, {
    int limit = 3,
  }) => const Stream.empty();
  @override
  Future<void> upsertProgress(UserProgress progress) async {
    if (throwOnUpsert) throw StateError('save failed');
  }

  @override
  Future<UserProgress?> latestProgressForUser() async => null;
}

void main() {
  test('progress controller save success', () async {
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWith((_) => FakeProgressRepo()),
      ],
    );
    final ctrl = container.read(progressControllerProvider.notifier);
    final ok = await ctrl.save(
      UserProgress(
        userId: 'u',
        novelId: 'n',
        chapterId: 'c',
        scrollOffset: 0,
        ttsCharIndex: 1,
        updatedAt: DateTime.now(),
      ),
    );
    expect(ok, true);
  });

  test('progress controller save failure', () async {
    final container = ProviderContainer(
      overrides: [
        progressRepositoryProvider.overrideWith(
          (_) => FakeProgressRepo()..throwOnUpsert = true,
        ),
      ],
    );
    final ctrl = container.read(progressControllerProvider.notifier);
    final ok = await ctrl.save(
      UserProgress(
        userId: 'u',
        novelId: 'n',
        chapterId: 'c',
        scrollOffset: 0,
        ttsCharIndex: 1,
        updatedAt: DateTime.now(),
      ),
    );
    expect(ok, false);
  });
}
