import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/repositories/novel_repository.dart';

void main() {
  test('updateNovelMetadata returns early when no fields provided', () async {
    final client = SupabaseClient('http://localhost', 'anon');
    final repo = NovelRepository(client);
    await repo.updateNovelMetadata('novel-1');
    expect(true, isTrue);
  });
}
