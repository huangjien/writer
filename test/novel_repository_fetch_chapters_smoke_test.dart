import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('fetchChaptersByNovel returns a list when enabled', () async {
    if (!supabaseEnabled) return;
    final repo = NovelRepository(Supabase.instance.client);
    final list = await repo.fetchChaptersByNovel('any-novel-id');
    expect(list, isA<List>());
  }, skip: !supabaseEnabled);
}
