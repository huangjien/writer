import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test(
    'ChapterRepository constructs and basic calls when Supabase enabled',
    () async {
      if (!supabaseEnabled) return;
      final client = Supabase.instance.client;
      final local = LocalStorageRepository();
      final repo = ChapterRepository(client, local);

      // Basic non-throwing calls; correctness depends on backend state.
      // These are smoke checks to ensure integration wiring is valid.
      expect(await repo.getNextIdx('non-existent'), isA<int>());
    },
    skip: !supabaseEnabled,
  );
}
