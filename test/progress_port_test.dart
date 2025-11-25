import 'package:flutter_test/flutter_test.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/models/user_progress.dart';

class _FakeProgressPort implements ProgressPort {
  UserProgress? last;

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => last;

  @override
  Future<UserProgress?> latestProgressForUser() async => last;

  @override
  Future<void> upsertProgress(UserProgress progress) async {
    last = progress;
  }
}

void main() {
  test('ProgressPort interface can be implemented', () async {
    final port = _FakeProgressPort();
    final p = UserProgress(
      userId: 'u',
      novelId: 'n',
      chapterId: 'c',
      scrollOffset: 0,
      ttsCharIndex: 0,
      updatedAt: DateTime.utc(2024, 1, 1),
    );
    await port.upsertProgress(p);
    expect(await port.latestProgressForUser(), isNotNull);
    expect((await port.lastProgressForNovel('n'))?.novelId, 'n');
  });
}
