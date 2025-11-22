import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:novel_reader/main.dart';
import 'package:novel_reader/repositories/local_storage_repository.dart';
import 'package:novel_reader/state/supabase_config.dart';

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
