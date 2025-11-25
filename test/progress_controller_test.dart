import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';

class FakeProgressPort implements ProgressPort {
  bool shouldThrow = false;
  @override
  Future<void> upsertProgress(UserProgress progress) async {
    if (shouldThrow) {
      throw Exception('save failed');
    }
    // simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;

  @override
  Future<UserProgress?> latestProgressForUser() async => null;
}

void main() {
  test('ProgressController.save returns true on success', () async {
    final fakeRepo = FakeProgressPort();
    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(progressControllerProvider.notifier);
    final ok = await notifier.save(
      UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0.0,
        ttsCharIndex: 0,
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
    expect(ok, isTrue);
    expect(container.read(progressControllerProvider).isLoading, isFalse);
  });

  test('ProgressController.save returns false on failure', () async {
    final fakeRepo = FakeProgressPort()..shouldThrow = true;
    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(progressControllerProvider.notifier);
    final ok = await notifier.save(
      UserProgress(
        userId: 'u1',
        novelId: 'n1',
        chapterId: 'c1',
        scrollOffset: 0.0,
        ttsCharIndex: 0,
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
    expect(ok, isFalse);
    final state = container.read(progressControllerProvider);
    expect(state.hasError, isTrue);
  });
}
