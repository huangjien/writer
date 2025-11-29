import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_providers.dart' as pp;
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';

class NullProgressRepo implements ProgressPort {
  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;
  @override
  Future<UserProgress?> latestProgressForUser() async => null;
  @override
  Future<void> upsertProgress(UserProgress progress) async {}
}

void main() {
  test('lastProgressProvider returns null when repo has no progress', () async {
    final container = ProviderContainer(
      overrides: [
        pp.progressRepositoryProvider.overrideWith((_) => NullProgressRepo()),
      ],
    );
    final p = await container.read(pp.lastProgressProvider('n').future);
    expect(p, isNull);
  });
}
