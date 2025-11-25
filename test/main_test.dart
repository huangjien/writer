import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('localStorageRepositoryProvider provides LocalStorageRepository', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(localStorageRepositoryProvider);
    expect(repo, isA<LocalStorageRepository>());
  });

  test('supabaseEnabled is false in default test environment', () {
    expect(supabaseEnabled, isFalse);
  });
}
