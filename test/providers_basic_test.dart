import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/repositories/local_storage_repository.dart';

void main() {
  test('isSignedInProvider is false by default', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);

    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((_) => session),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(storageService),
        ),
      ],
    );
    expect(container.read(isSignedInProvider), isFalse);
  });
}
