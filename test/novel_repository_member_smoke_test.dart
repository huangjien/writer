import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/repositories/novel_repository.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  test('fetchMemberNovels returns a list when enabled', () async {
    if (!supabaseEnabled) return;
    final repo = NovelRepository(Supabase.instance.client);
    final list = await repo.fetchMemberNovels(limit: 1, offset: 0);
    expect(list, isA<List>());
  }, skip: !supabaseEnabled);
}
