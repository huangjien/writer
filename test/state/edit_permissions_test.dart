import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository remote;

  setUp(() {
    remote = MockRemoteRepository();
  });

  test('editRoleProvider returns none when signed out', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('editRoleProvider returns owner for backend role owner', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('s');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((_) => session),
        remoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    when(
      () => remote.get('permissions/novels/n1'),
    ).thenAnswer((_) async => {'role': 'owner'});
    expect(await container.read(editRoleProvider('n1').future), EditRole.owner);
  });

  test(
    'editRoleProvider returns contributor for backend role contributor',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      final session = SessionNotifier(storageService);
      await session.setSessionId('s');
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith((_) => session),
          remoteRepositoryProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);

      when(
        () => remote.get('permissions/novels/n1'),
      ).thenAnswer((_) async => {'role': 'contributor'});
      expect(
        await container.read(editRoleProvider('n1').future),
        EditRole.contributor,
      );
    },
  );

  test('editRoleProvider returns none for backend role unknown', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final session = SessionNotifier(storageService);
    await session.setSessionId('s');
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((_) => session),
        remoteRepositoryProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);

    when(
      () => remote.get('permissions/novels/n1'),
    ).thenAnswer((_) async => {'role': 'something-else'});
    expect(await container.read(editRoleProvider('n1').future), EditRole.none);
  });
}
