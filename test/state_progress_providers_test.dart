import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_providers.dart' as pp;
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('lastProgressProvider returns value from repo', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        pp.progressRepositoryProvider.overrideWith((_) => FakeProgressRepo()),
        isSignedInProvider.overrideWith((_) => true),
      ],
    );
    final p = await container.read(pp.lastProgressProvider('n').future);
    expect(p?.ttsCharIndex, 2);
  });
}
