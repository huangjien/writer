import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/progress_providers.dart' as pp;
import 'package:writer/models/user_progress.dart';
import 'package:writer/repositories/progress_port.dart';
import 'package:writer/repositories/remote_repository.dart';

import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NullProgressRepo implements ProgressPort {
  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async => null;
  @override
  Future<UserProgress?> latestProgressForUser() async => null;
  @override
  Future<void> upsertProgress(UserProgress progress) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('lastProgressProvider returns null when repo has no progress', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        pp.progressRepositoryProvider.overrideWith((_) => NullProgressRepo()),
        remoteRepositoryProvider.overrideWith(
          (_) => RemoteRepository('http://localhost:5600/'),
        ),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(ref.read(storageServiceProvider)),
        ),
      ],
    );
    final p = await container.read(pp.lastProgressProvider('n').future);
    expect(p, isNull);
  });
}
