import 'package:writer/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/supabase_config.dart';

import '../models/chapter.dart';
import '../models/chapter_cache.dart';
import 'chapter_port.dart';
import 'local_storage_repository.dart';

final chapterRepositoryProvider = Provider<ChapterPort>((ref) {
  if (!supabaseEnabled) {
    throw StateError(
      'Supabase is not enabled for this build. Configure SUPABASE_URL and SUPABASE_ANON_KEY to use ChapterRepository.',
    );
  }
  final client = Supabase.instance.client;
  final localStorage = ref.watch(localStorageRepositoryProvider);
  return ChapterRepository(client, localStorage);
});

class ChapterRepository implements ChapterPort {
  final SupabaseClient _client;
  final LocalStorageRepository _localStorage;

  ChapterRepository(this._client, this._localStorage);

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    final response = await _client
        .from('chapters')
        .select('id, novel_id, title, idx')
        .eq('novel_id', novelId)
        .order('idx', ascending: true);

    return (response as List).map((e) => Chapter.fromJson(e)).toList();
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    final cachedChapter = await _localStorage.getChapter(chapter.id);
    if (cachedChapter != null) {
      return Chapter.fromCache(cachedChapter);
    }

    final response = await _client
        .from('chapters')
        .select('content')
        .eq('id', chapter.id)
        .single();

    final newChapter = chapter.copyWith(content: response['content']);

    await _localStorage.saveChapter(
      ChapterCache(
        chapterId: newChapter.id,
        novelId: newChapter.novelId,
        idx: newChapter.idx,
        title: newChapter.title,
        content: newChapter.content!,
        lastUpdated: DateTime.now(),
      ),
    );

    return newChapter;
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    await _client
        .from('chapters')
        .update({'title': chapter.title, 'content': chapter.content})
        .eq('id', chapter.id);

    // Update local cache to keep offline in sync
    if (chapter.content != null) {
      await _localStorage.saveChapter(
        ChapterCache(
          chapterId: chapter.id,
          novelId: chapter.novelId,
          idx: chapter.idx,
          title: chapter.title,
          content: chapter.content!,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    final res = await _client
        .from('chapters')
        .select('idx')
        .eq('novel_id', novelId)
        .order('idx', ascending: false)
        .limit(1);
    final list = (res as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return 1;
    final maxIdx = (list.first['idx'] as int?) ?? 0;
    return maxIdx + 1;
  }

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    final insert = {
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'content': content ?? '',
      'language_code': 'en',
    };
    final res = await _client.from('chapters').insert(insert).select().single();
    final created = Chapter.fromJson(res);
    // Cache the empty content as a placeholder to avoid nulls downstream
    await _localStorage.saveChapter(
      ChapterCache(
        chapterId: created.id,
        novelId: created.novelId,
        idx: created.idx,
        title: created.title,
        content: created.content ?? '',
        lastUpdated: DateTime.now(),
      ),
    );
    return created;
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    await _client.from('chapters').delete().eq('id', chapterId);
    // Best-effort remove from local cache
    try {
      await _localStorage.removeChapter(chapterId);
    } catch (_) {
      // Ignore local cache deletion errors
    }
  }
}
