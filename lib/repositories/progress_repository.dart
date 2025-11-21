import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress.dart';
import 'progress_port.dart';

class ProgressRepository implements ProgressPort {
  final SupabaseClient client;
  ProgressRepository(this.client);

  @override
  Future<void> upsertProgress(UserProgress progress) async {
    final insert = progress.toMap();
    await client.from('user_progress').upsert(insert);
  }

  @override
  Future<UserProgress?> lastProgressForNovel(String novelId) async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res = await client
        .from('user_progress')
        .select(
          'user_id, novel_id, chapter_id, scroll_offset, tts_char_index, updated_at',
        )
        .eq('user_id', user.id)
        .eq('novel_id', novelId)
        .order('updated_at', ascending: false)
        .limit(1);
    final list = (res as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return null;
    final m = list.first;
    return UserProgress.fromJson(m);
  }

  @override
  Future<UserProgress?> latestProgressForUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res = await client
        .from('user_progress')
        .select(
          'user_id, novel_id, chapter_id, scroll_offset, tts_char_index, updated_at',
        )
        .eq('user_id', user.id)
        .order('updated_at', ascending: false)
        .limit(1);
    final list = (res as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return null;
    final m = list.first;
    return UserProgress.fromJson(m);
  }
}
