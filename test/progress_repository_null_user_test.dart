import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:novel_reader/repositories/progress_repository.dart';

void main() {
  test('lastProgressForNovel returns null when no user', () async {
    final client = SupabaseClient('http://localhost', 'anon');
    final repo = ProgressRepository(client);
    final res = await repo.lastProgressForNovel('novel-1');
    expect(res, isNull);
  });

  test('latestProgressForUser returns null when no user', () async {
    final client = SupabaseClient('http://localhost', 'anon');
    final repo = ProgressRepository(client);
    final res = await repo.latestProgressForUser();
    expect(res, isNull);
  });
}
