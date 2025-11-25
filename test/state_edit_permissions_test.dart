import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/providers.dart';

void main() {
  test('edit role is none when Supabase disabled', () async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
    );
    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('edit permissions false when Supabase disabled', () async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
    );
    final ok = await container.read(editPermissionsProvider('n1').future);
    expect(ok, false);
  });
}
