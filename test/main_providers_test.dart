import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/main.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('localStorageRepositoryProvider returns LocalStorageRepository', () {
    final container = ProviderContainer();
    final repo = container.read(localStorageRepositoryProvider);
    expect(repo, isA<LocalStorageRepository>());
  });

  test(
    'chapterRepositoryProvider throws when Supabase disabled',
    () {
      if (supabaseEnabled) return;
      final container = ProviderContainer();
      expect(
        () => container.read(chapterRepositoryProvider),
        throwsA(
          predicate((e) => e.toString().contains('Supabase is not enabled')),
        ),
      );
    },
    skip: supabaseEnabled,
  );
}
