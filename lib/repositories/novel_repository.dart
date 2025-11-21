import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';
import '../models/chapter.dart';

class NovelRepository {
  final SupabaseClient client;
  NovelRepository(this.client);

  Future<List<Novel>> fetchPublicNovels() async {
    final res = await client
        .from('novels')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false);
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(Novel.fromMap).toList();
  }

  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async {
    final res = await client
        .from('chapters')
        .select()
        .eq('novel_id', novelId)
        .order('idx', ascending: true);
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(Chapter.fromJson).toList();
  }

  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    final ownerId = client.auth.currentUser?.id;
    final insert = {
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'language_code': languageCode,
      'is_public': isPublic,
      'owner_id': ownerId,
    };
    final res = await client.from('novels').insert(insert).select().single();
    return Novel.fromMap(res);
  }

  Future<Novel?> getNovel(String novelId) async {
    final res = await client.from('novels').select().eq('id', novelId).single();
    if (res.isEmpty) return null;
    return Novel.fromMap(res);
  }

  Future<Chapter?> getChapter(String chapterId) async {
    final res = await client
        .from('chapters')
        .select()
        .eq('id', chapterId)
        .single();
    if (res.isEmpty) return null;
    return Chapter.fromJson(res);
  }

  Future<void> deleteNovel(String novelId) async {
    await client.from('novels').delete().eq('id', novelId);
  }

  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {
    final update = <String, dynamic>{};
    if (title != null) update['title'] = title;
    if (description != null) update['description'] = description;
    if (coverUrl != null) update['cover_url'] = coverUrl;
    if (languageCode != null) update['language_code'] = languageCode;
    if (isPublic != null) update['is_public'] = isPublic;
    if (update.isEmpty) return; // nothing to update
    await client.from('novels').update(update).eq('id', novelId);
  }

  Future<void> addContributor({
    required String novelId,
    required String userId,
  }) async {
    await client.from('novel_contributors').insert({
      'novel_id': novelId,
      'user_id': userId,
      'role': 'contributor',
    });
  }

  /// Fetch novels where the current user is a member (owner or contributor).
  /// Uses the server-side RPC `member_novels` to ensure consistent membership logic.
  Future<List<Novel>> fetchMemberNovels({
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await client.rpc(
      'member_novels',
      params: {'p_limit': limit, 'p_offset': offset},
    );
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(Novel.fromMap).toList();
  }

  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {
    await client.rpc(
      'add_contributor_by_email',
      params: {'p_novel_id': novelId, 'p_email': email},
    );
  }
}
