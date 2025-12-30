import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/providers.dart';

void main() {
  group('editPermissionsProvider maps role to canEdit', () {
    test('owner yields canEdit=true', () async {
      final container = ProviderContainer(
        overrides: [
          editRoleProvider.overrideWith((ref, novelId) async => EditRole.owner),
          authStateProvider.overrideWithValue('test-user'),
        ],
      );
      addTearDown(container.dispose);
      final result = await container.read(
        editPermissionsProvider('novel-123').future,
      );
      expect(result, isTrue);
    });

    test('contributor yields canEdit=true', () async {
      final container = ProviderContainer(
        overrides: [
          editRoleProvider.overrideWith(
            (ref, novelId) async => EditRole.contributor,
          ),
          authStateProvider.overrideWithValue('test-user'),
        ],
      );
      addTearDown(container.dispose);
      final result = await container.read(
        editPermissionsProvider('novel-123').future,
      );
      expect(result, isTrue);
    });

    test('none yields canEdit=false', () async {
      final container = ProviderContainer(
        overrides: [
          editRoleProvider.overrideWith((ref, novelId) async => EditRole.none),
          authStateProvider.overrideWithValue('test-user'),
        ],
      );
      addTearDown(container.dispose);
      final result = await container.read(
        editPermissionsProvider('novel-123').future,
      );
      expect(result, isFalse);
    });
  });
}
