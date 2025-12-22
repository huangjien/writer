import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';

import '../models/chapter.dart';
import '../models/chapter_cache.dart';
import 'chapter_port.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../repositories/local_storage_repository.dart';
import '../main.dart';

final chapterRepositoryProvider = Provider<ChapterPort>((ref) {
  final remote = ref.watch(remoteRepositoryProvider);
  final localStorage = ref.watch(localStorageRepositoryProvider);
  return ChapterRepository(remote, localStorage);
});

class ChapterRepository implements ChapterPort {
  final RemoteRepository _remote;
  final LocalStorageRepository _localStorage;

  ChapterRepository(this._remote, this._localStorage);

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    try {
      final res = await _remote.get('novels/$novelId/chapters');
      if (res is List) {
        final list = res.cast<Map<String, dynamic>>();
        return list.map(Chapter.fromJson).toList();
      }
      return [];
    } catch (e) {
      // Fallback? Currently existing code threw errors.
      rethrow;
    }
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    // 1. Try Network First strategy with Cache Fallback
    try {
      final res = await _remote.get(
        'chapters/${chapter.id}',
      ); // Ensure endpoint returns full content
      if (res is! Map<String, dynamic>) throw Exception('Invalid response');

      final content =
          res['content'] as String?; // Assuming endpoint returns content
      final sha = res['sha'] as String?;

      final newChapter = chapter.copyWith(content: content, sha: sha);

      // Async write to cache
      if (newChapter.content != null) {
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
      }

      return newChapter;
    } catch (e) {
      // 2. Network failed, try Cache
      try {
        final cachedChapter = await _localStorage.getChapter(chapter.id);
        if (cachedChapter != null) {
          return Chapter.fromCache(cachedChapter);
        }
      } catch (_) {}

      rethrow;
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
      final body = {
        'title': chapter.title,
        'content': chapter.content,
        if (sha != null) 'sha': sha,
      };

      await _remote.patch('chapters/${chapter.id}', body);

      // Only update local cache if server update succeeded
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {
    try {
      await _remote.patch('chapters/$chapterId', {'idx': newIdx});

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
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {
    // Ideally backend should handle this. For now, fetch all and update relevant ones.
    try {
      final chapters = await getChapters(novelId);
      final toUpdate = chapters.where((c) => c.idx >= fromIdx).toList();

      // We need to update them. doing it sequentially might be slow but safe.
      for (final c in toUpdate) {
        await updateChapterIdx(c.id, c.idx + delta);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    try {
      final chapters = await getChapters(novelId);
      if (chapters.isEmpty) return 1;
      final maxIdx = chapters.map((c) => c.idx).reduce((a, b) => a > b ? a : b);
      return maxIdx + 1;
    } catch (e) {
      return 1; // Default fallback
    }
  }

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    final body = {
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'content': content,
      // 'sha' calculated by backend or we can send it? Library.py creates SHA if not present?
      // Library.py takes Sha.
      'sha': sha256.convert(utf8.encode(content ?? '')).toString(),
      'language_code': 'en',
    };

    final res = await _remote.post('chapters', body);
    if (res is Map<String, dynamic>) {
      final created = Chapter.fromJson(res);
      // Cache
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
    throw Exception('Failed to create chapter');
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    await _remote.delete('chapters/$chapterId');
    try {
      await _localStorage.removeChapter(chapterId);
    } catch (_) {}
  }
}
