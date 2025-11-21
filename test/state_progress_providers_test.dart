import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/progress_providers.dart' as pp;
import 'package:novel_reader/models/user_progress.dart';
import 'package:novel_reader/repositories/progress_port.dart';

class FakeProgressRepo implements ProgressPort {
  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async {
    return UserProgress(
      userId: 'u',
      novelId: 'n',
      chapterId: 'c',
      scrollOffset: 0.0,
      ttsCharIndex: 2,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> upsertProgress(UserProgress progress) async {}

  @override
  Future<UserProgress?> latestProgressForUser() async => null;
}

void main() {
  test('lastProgressProvider returns value from repo', () async {
    final container = ProviderContainer(
      overrides: [
        pp.progressRepositoryProvider.overrideWith((_) => FakeProgressRepo()),
      ],
    );
    final p = await container.read(pp.lastProgressProvider('n').future);
    expect(p?.ttsCharIndex, 2);
  });
}
