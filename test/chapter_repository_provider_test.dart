import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/repositories/chapter_repository.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  test('chapterRepositoryProvider throws when Supabase disabled', () {
    if (!supabaseEnabled) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(() => container.read(chapterRepositoryProvider), throwsStateError);
    }
  });
}
