import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  test('edit role is none when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((_) => null),
        isSignedInProvider.overrideWith((_) => false),
      ],
    );
    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('edit permissions false when signed out', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((_) => null),
        isSignedInProvider.overrideWith((_) => false),
      ],
    );
    final ok = await container.read(editPermissionsProvider('n1').future);
    expect(ok, false);
  });

  test('edit role reads backend permissions when signed in', () async {
    final remote = MockRemoteRepository();
    when(
      () => remote.get('permissions/novels/n1'),
    ).thenAnswer((_) async => {'role': 'owner'});
    final container = ProviderContainer(
      overrides: [
        isSignedInProvider.overrideWith((_) => true),
        authStateProvider.overrideWith((_) => 'session'),
        remoteRepositoryProvider.overrideWith((_) => remote),
      ],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.owner);
    final ok = await container.read(editPermissionsProvider('n1').future);
    expect(ok, true);
  });
}
