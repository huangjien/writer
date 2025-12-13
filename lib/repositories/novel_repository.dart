import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../common/errors/failures.dart';
import 'dart:io';

class NovelRepository {
  final SupabaseClient client;
  NovelRepository(this.client);

  Future<List<Novel>> fetchPublicNovels() async {
    try {
      final res = await client
          .from('novels')
          .select()
          .eq('is_public', true)
          .order('created_at', ascending: false);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map(Novel.fromMap).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection', e);
    } catch (e) {
      throw UnknownFailure('Failed to fetch novels', e);
    }
  }

  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async {
    try {
      final res = await client
          .from('chapters')
          .select()
          .eq('novel_id', novelId)
          .order('idx', ascending: true);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map(Chapter.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection', e);
    } catch (e) {
      throw UnknownFailure('Failed to fetch chapters', e);
    }
  }

  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    try {
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
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to create novel', e);
    } catch (e) {
      throw UnknownFailure('Failed to create novel', e);
    }
  }

  Future<Novel?> getNovel(String novelId) async {
    try {
      final res = await client
          .from('novels')
          .select()
          .eq('id', novelId)
          .single();
      if (res.isEmpty) return null;
      return Novel.fromMap(res);
    } on PostgrestException catch (e) {
      // Single returning no rows is sometimes treated as error by supabase client depending on configuration
      // But typically .single() throws if 0 or >1 rows.
      if (e.code == 'PGRST116') {
        return null; // JSON object requested, multiple (or no) results returned
      }
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection', e);
    } catch (e) {
      // Supabase flutter might throw if `.single()` finds nothing
      // Check if it's that case or real error
      throw UnknownFailure('Failed to load novel', e);
    }
  }

  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final res = await client
          .from('chapters')
          .select()
          .eq('id', chapterId)
          .single();
      if (res.isEmpty) return null;
      return Chapter.fromJson(res);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return null;
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection', e);
    } catch (e) {
      throw UnknownFailure('Failed to load chapter', e);
    }
  }

  Future<void> deleteNovel(String novelId) async {
    try {
      await client.from('novels').delete().eq('id', novelId);
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to delete novel', e);
    } catch (e) {
      throw UnknownFailure('Failed to delete novel', e);
    }
  }

  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {
    try {
      final update = <String, dynamic>{};
      if (title != null) update['title'] = title;
      if (description != null) update['description'] = description;
      if (coverUrl != null) update['cover_url'] = coverUrl;
      if (languageCode != null) update['language_code'] = languageCode;
      if (isPublic != null) update['is_public'] = isPublic;
      if (update.isEmpty) return; // nothing to update
      await client.from('novels').update(update).eq('id', novelId);
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to update novel', e);
    } catch (e) {
      throw UnknownFailure('Failed to update novel', e);
    }
  }

  Future<void> addContributor({
    required String novelId,
    required String userId,
  }) async {
    try {
      await client.from('novel_contributors').insert({
        'novel_id': novelId,
        'user_id': userId,
        'role': 'contributor',
      });
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to add contributor', e);
    } catch (e) {
      throw UnknownFailure('Failed to add contributor', e);
    }
  }

  /// Fetch novels where the current user is a member (owner or contributor).
  /// Uses the server-side RPC `member_novels` to ensure consistent membership logic.
  Future<List<Novel>> fetchMemberNovels({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final res = await client.rpc(
        'member_novels',
        params: {'p_limit': limit, 'p_offset': offset},
      );
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map(Novel.fromMap).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('No internet connection', e);
    } catch (e) {
      throw UnknownFailure('Failed to fetch my novels', e);
    }
  }

  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {
    try {
      await client.rpc(
        'add_contributor_by_email',
        params: {'p_novel_id': novelId, 'p_email': email},
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to add contributor', e);
    } catch (e) {
      throw UnknownFailure('Failed to add contributor', e);
    }
  }
}
