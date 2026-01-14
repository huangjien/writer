import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';

import '../models/chapter.dart';
import '../models/chapter_cache.dart';
import 'chapter_port.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../repositories/local_storage_repository.dart';

import '../services/offline_queue_service.dart';
import '../services/network_monitor.dart';
import '../models/offline_operation.dart';
import '../common/errors/offline_exception.dart';
import '../state/network_monitor_provider.dart';
import '../state/providers.dart';
import '../services/connectivity_checker.dart';
import '../shared/api_exception.dart';

final chapterRepositoryProvider = Provider<ChapterPort>((ref) {
  final remote = ref.watch(remoteRepositoryProvider);
  final localStorage = ref.watch(localStorageRepositoryProvider);
  final offlineQueue = ref.watch(offlineQueueServiceProvider);
  final networkMonitor = ref.watch(networkMonitorProvider);
  return ChapterRepository(
    remote,
    localStorage,
    offlineQueue: offlineQueue,
    networkMonitor: networkMonitor,
  );
});

class ChapterRepository implements ChapterPort {
  final RemoteRepository _remote;
  final LocalStorageRepository _localStorage;
  final OfflineQueueService _offlineQueue;
  final NetworkMonitor _networkMonitor;

  ChapterRepository(
    this._remote,
    this._localStorage, {
    OfflineQueueService? offlineQueue,
    NetworkMonitor? networkMonitor,
  }) : _offlineQueue = offlineQueue ?? OfflineQueueService(),
       _networkMonitor =
           networkMonitor ?? NetworkMonitor(RealConnectivityChecker());

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
    // Check network status
    final isConnected = await _networkMonitor.isConnected;

    if (!isConnected) {
      // Offline: Queue the operation for later sync
      String? sha;
      if (chapter.content != null) {
        final bytes = utf8.encode(chapter.content!);
        sha = sha256.convert(bytes).toString();
      }

      final operation = OfflineOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: OperationType.updateChapter,
        chapterId: chapter.id,
        novelId: chapter.novelId,
        data: {
          'title': chapter.title,
          'content': chapter.content,
          if (sha != null) 'sha': sha,
        },
        baseSha: chapter.sha,
        createdAt: DateTime.now(),
      );

      await _offlineQueue.enqueue(operation);

      // Save to local cache immediately
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

      throw OfflineException(
        'No internet connection. Chapter changes queued for sync.',
        operationId: operation.id,
      );
    }

    // Online: Update immediately
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
    // Check network status
    final isConnected = await _networkMonitor.isConnected;

    if (!isConnected) {
      // Offline: Queue the index update for later sync
      // Get the cached chapter to get novelId
      String novelId = '';
      try {
        final cached = await _localStorage.getChapter(chapterId);
        if (cached != null) {
          novelId = cached.novelId;
          // Update local cache immediately
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

      final operation = OfflineOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: OperationType.updateChapterIdx,
        chapterId: chapterId,
        novelId: novelId,
        data: {'chapter_id': chapterId, 'new_idx': newIdx},
        baseSha: null,
        createdAt: DateTime.now(),
      );

      await _offlineQueue.enqueue(operation);

      throw OfflineException(
        'No internet connection. Chapter index update queued for sync.',
        operationId: operation.id,
      );
    }

    // Online: Update immediately
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
    try {
      final chapters = await getChapters(novelId);
      final toUpdate = chapters.where((c) => c.idx >= fromIdx).toList();
      if (toUpdate.isEmpty) return;

      final updates = toUpdate
          .map((c) => {'chapter_id': c.id, 'idx': c.idx + delta})
          .toList();

      try {
        await _remote.patch('novels/$novelId/chapters/reorder', {
          'updates': updates,
        });
        return;
      } on ApiException catch (e) {
        if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      }

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
    // Check network status
    final isConnected = await _networkMonitor.isConnected;

    if (!isConnected) {
      // Offline: Create a temporary chapter with a local ID
      final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final sha = sha256.convert(utf8.encode(content ?? '')).toString();

      // Queue the operation for later sync
      final operation = OfflineOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: OperationType.createChapter,
        chapterId: tempId,
        novelId: novelId,
        data: {
          'novel_id': novelId,
          'idx': idx,
          'title': title,
          'content': content,
          'sha': sha,
          'language_code': 'en',
        },
        baseSha: null,
        createdAt: DateTime.now(),
      );

      await _offlineQueue.enqueue(operation);

      // Save to local cache
      await _localStorage.saveChapter(
        ChapterCache(
          chapterId: tempId,
          novelId: novelId,
          idx: idx,
          title: title ?? 'Untitled',
          content: content ?? '',
          lastUpdated: DateTime.now(),
        ),
      );

      throw OfflineException(
        'No internet connection. Chapter creation queued for sync.',
        operationId: operation.id,
      );
    }

    // Online: Create immediately
    final body = {
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'content': content,
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
    // Check network status
    final isConnected = await _networkMonitor.isConnected;

    if (!isConnected) {
      // Offline: Queue the deletion for later sync
      final operation = OfflineOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: OperationType.deleteChapter,
        chapterId: chapterId,
        novelId: '',
        data: {'chapter_id': chapterId},
        baseSha: null,
        createdAt: DateTime.now(),
      );

      await _offlineQueue.enqueue(operation);

      // Remove from local cache immediately
      try {
        await _localStorage.removeChapter(chapterId);
      } catch (_) {}

      throw OfflineException(
        'No internet connection. Chapter deletion queued for sync.',
        operationId: operation.id,
      );
    }

    // Online: Delete immediately
    await _remote.delete('chapters/$chapterId');
    try {
      await _localStorage.removeChapter(chapterId);
    } catch (_) {}
  }
}
