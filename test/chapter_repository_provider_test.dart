import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('chapterRepositoryProvider throws when Supabase disabled', () {
    if (!supabaseEnabled) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        () => container.read(chapterRepositoryProvider),
        throwsA(
          predicate(
            (e) =>
                e.toString().contains('Supabase is not enabled') ||
                e.toString().contains('ProviderException'),
          ),
        ),
      );
    }
  });
}
