import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/repositories/novel_repository.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  test('NovelRepository constructs when Supabase enabled', () async {
    if (!supabaseEnabled) return;
    final repo = NovelRepository(Supabase.instance.client);
    expect(repo, isA<NovelRepository>());
  }, skip: !supabaseEnabled);
}
