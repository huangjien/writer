import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/session_state.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  late MockRemoteRepository remote;

  setUp(() {
    remote = MockRemoteRepository();
  });

  test('editRoleProvider returns none when signed out', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('editRoleProvider returns owner for backend role owner', () async {
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => SessionNotifier()..state = 's'),
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
      final container = ProviderContainer(
        overrides: [
          sessionProvider.overrideWith((ref) => SessionNotifier()..state = 's'),
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
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => SessionNotifier()..state = 's'),
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
