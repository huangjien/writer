import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('fetchPublicNovels returns a list when enabled', () async {
    if (!supabaseEnabled) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final repo = NovelRepository(Supabase.instance.client);
    final list = await repo.fetchPublicNovels();
    expect(list, isA<List>());
  }, skip: true);
}
