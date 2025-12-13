import 'package:writer/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/supabase_config.dart';

import '../models/chapter.dart';
import '../models/chapter_cache.dart';
import 'chapter_port.dart';
import 'local_storage_repository.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../common/errors/failures.dart';
import 'dart:io';

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
    try {
      final response = await _client
          .from('chapters')
          .select('id, novel_id, title, idx, sha')
          .eq('novel_id', novelId)
          .order('idx', ascending: true);

      return (response as List).map((e) => Chapter.fromJson(e)).toList();
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

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    // 1. Try Network First strategy with Cache Fallback
    try {
      final response = await _client
          .from('chapters')
          .select('content, sha')
          .eq('id', chapter.id)
          .single();

      final newChapter = chapter.copyWith(
        content: response['content'],
        sha: response['sha'],
      );

      // Async write to cache, don't await blocking the UI return
      _localStorage
          .saveChapter(
            ChapterCache(
              chapterId: newChapter.id,
              novelId: newChapter.novelId,
              idx: newChapter.idx,
              title: newChapter.title,
              content: newChapter.content!,
              lastUpdated: DateTime.now(),
            ),
          )
          .ignore();

      return newChapter;
    } on Exception catch (e) {
      // 2. Network failed, try Cache
      try {
        final cachedChapter = await _localStorage.getChapter(chapter.id);
        if (cachedChapter != null) {
          return Chapter.fromCache(cachedChapter);
        }
      } catch (_) {
        // Cache read failed too, proceed to throw original network error
      }

      if (e is PostgrestException) {
        throw ServerFailure(
          message: e.message,
          statusCode: int.tryParse(e.code ?? ''),
          originalException: e,
        );
      } else if (e is SocketException) {
        throw NetworkFailure('No internet connection', e);
      } else {
        throw UnknownFailure('Failed to load chapter', e);
      }
    }
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    try {
      String? sha;
      if (chapter.content != null) {
        final bytes = utf8.encode(chapter.content!);
        sha = sha256.convert(bytes).toString();
      }
      await _client
          .from('chapters')
          .update({
            'title': chapter.title,
            'content': chapter.content,
            if (sha != null) 'sha': sha,
          })
          .eq('id', chapter.id);

      // Only update local cache if server update succeeded to maintain consistency
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
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to save changes', e);
    } catch (e) {
      throw UnknownFailure('Failed to update chapter', e);
    }
  }

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {
    try {
      await _client
          .from('chapters')
          .update({'idx': newIdx})
          .eq('id', chapterId);

      // Update local cache
      try {
        final cached = await _localStorage.getChapter(chapterId);
        if (cached != null) {
          await _localStorage.saveChapter(
            ChapterCache(
              chapterId: cached.chapterId,
              novelId: cached.novelId,
              idx: newIdx,
              title: cached.title,
              content: cached.content,
              lastUpdated: DateTime.now(),
            ),
          );
        }
      } catch (e) {
        // Cache update failed, but server succeeded. Log locally or ignore.
        // We consider this a success from user perspective.
      }
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to reorder chapter', e);
    } catch (e) {
      throw UnknownFailure('Failed to reorder chapter', e);
    }
  }

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {
    try {
      final rows =
          await _client
                  .from('chapters')
                  .select('id, idx')
                  .eq('novel_id', novelId)
                  .gte('idx', fromIdx)
                  .order('idx', ascending: true)
              as List<dynamic>;

      for (final row in rows) {
        final id = (row as Map<String, dynamic>)['id'] as String;
        final idx = (row)['idx'] as int;
        final newIdx = idx + delta;
        await updateChapterIdx(id, newIdx);
      }
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to reorder chapters', e);
    } catch (e) {
      throw UnknownFailure('Failed to reorder chapters', e);
    }
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    try {
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
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Connection error', e);
    } catch (e) {
      throw UnknownFailure('Unknown error', e);
    }
  }

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    try {
      final insert = {
        'novel_id': novelId,
        'idx': idx,
        'title': title,
        'content': content ?? '',
        'sha': sha256.convert(utf8.encode(content ?? '')).toString(),
        'language_code': 'en',
      };
      final res = await _client
          .from('chapters')
          .insert(insert)
          .select()
          .single();
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
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to create chapter', e);
    } catch (e) {
      throw UnknownFailure('Failed to create chapter', e);
    }
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    try {
      await _client.from('chapters').delete().eq('id', chapterId);
      // Best-effort remove from local cache
      try {
        await _localStorage.removeChapter(chapterId);
      } catch (_) {
        // Ignore local cache deletion errors
      }
    } on PostgrestException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } on SocketException catch (e) {
      throw NetworkFailure('Failed to delete chapter', e);
    } catch (e) {
      throw UnknownFailure('Failed to delete chapter', e);
    }
  }
}
