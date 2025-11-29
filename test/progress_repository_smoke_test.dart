import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/repositories/progress_repository.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('ProgressRepository constructs when Supabase enabled', () async {
    if (!supabaseEnabled) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final repo = ProgressRepository(Supabase.instance.client);
    expect(repo, isA<ProgressRepository>());
  }, skip: !supabaseEnabled);
}
