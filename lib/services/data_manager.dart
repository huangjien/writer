import 'dart:async';
import 'dart:convert';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/chapter_cache.dart';
import '../repositories/local_storage_repository.dart';
import '../repositories/remote_repository.dart';
import '../repositories/novel_repository.dart';
import '../services/network_monitor.dart';
import '../models/cache_metadata.dart';
import '../services/storage_service.dart';

enum DataManagerState { idle, loading, syncing, error }

class DataManager {
  final LocalStorageRepository _local;
  final RemoteRepository _remote;
  final NetworkMonitor _network;
  final StorageService _storage;
  final StreamController<DataManagerState> _stateController =
      StreamController<DataManagerState>.broadcast();
  DataManagerState _currentState = DataManagerState.idle;
  String? _currentError;

  DataManager({
    required LocalStorageRepository local,
    required RemoteRepository remote,
    required NetworkMonitor network,
    required StorageService storage,
  }) : _local = local,
       _remote = remote,
       _network = network,
       _storage = storage;

  Stream<DataManagerState> get stateStream => _stateController.stream;

  DataManagerState get currentState => _currentState;

  String? get currentError => _currentError;

  void _setState(DataManagerState state, {String? error}) {
    _currentState = state;
    _currentError = error;
    _stateController.add(state);
  }

  Future<List<Novel>> getAllNovels({bool forceRefresh = false}) async {
    try {
      final cacheMeta = await _local.getCacheMetadata('novels_list');
      final isCacheValid =
          cacheMeta != null &&
          !cacheMeta.isExpired(maxAge: const Duration(hours: 24));

      if (!forceRefresh && isCacheValid) {
        final cached = await _local.getNovelsList();
        if (cached.isNotEmpty) {
          _triggerBackgroundSync().ignore();
          return cached;
        }
      }

      if (!_network.isOnline) {
        final cached = await _local.getNovelsList();
        if (cached.isNotEmpty) {
          return cached;
        }
        return [];
      }

      _setState(DataManagerState.syncing);
      final repo = NovelRepository(_remote);

      final public = await repo.fetchPublicNovels();
      final member = await repo.fetchMemberNovels();

      final byId = <String, Novel>{};
      for (final n in public) {
        byId[n.id] = n;
      }
      for (final n in member) {
        byId[n.id] = n;
      }
      final all = byId.values.toList();

      await _local.saveNovelsList(all);
      await _local.saveLibraryNovels(all);

      _setState(DataManagerState.idle);
      return all;
    } on Object catch (e) {
      _setState(DataManagerState.error, error: e.toString());
      final cached = await _local.getNovelsList();
      if (cached.isNotEmpty) return cached;
      return [];
    }
  }

  Future<Novel?> getNovel(String novelId, {bool forceRefresh = false}) async {
    try {
      final cached = await _local.getNovel(novelId);

      if (cached != null && !forceRefresh) {
        _syncNovel(novelId).ignore();
        return cached;
      }

      if (!_network.isOnline) {
        return cached;
      }

      _setState(DataManagerState.syncing);
      final repo = NovelRepository(_remote);
      final remote = await repo.getNovel(novelId);

      if (remote != null) {
        await _local.saveNovel(remote);
        await _saveCacheMetadata('novel_$novelId');
      }

      _setState(DataManagerState.idle);
      return remote;
    } on Object catch (e) {
      _setState(DataManagerState.error, error: e.toString());
      return await _local.getNovel(novelId);
    }
  }

  Future<List<Chapter>> getChapters(
    String novelId, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheMeta = await _local.getCacheMetadata('chapters_list_$novelId');
      final isCacheValid =
          cacheMeta != null &&
          !cacheMeta.isExpired(maxAge: const Duration(hours: 24));
      final cached = await _local.getChaptersList(novelId);

      if (cached.isNotEmpty && !forceRefresh && isCacheValid) {
        _syncChapters(novelId).ignore();
        return cached.map((c) => Chapter.fromCache(c)).toList();
      }

      if (!_network.isOnline) {
        if (cached.isNotEmpty) {
          return cached.map((c) => Chapter.fromCache(c)).toList();
        }
        return [];
      }

      _setState(DataManagerState.syncing);
      final repo = NovelRepository(_remote);
      final chapters = await repo.fetchChaptersByNovel(novelId);

      await _local.saveChaptersList(
        novelId,
        chapters
            .map(
              (c) => {
                'id': c.id,
                'novel_id': c.novelId,
                'idx': c.idx,
                'title': c.title,
                'content': c.content,
              },
            )
            .toList(),
      );

      _setState(DataManagerState.idle);
      return chapters;
    } catch (e) {
      _setState(DataManagerState.error, error: e.toString());
      final cached = await _local.getChaptersList(novelId);
      return cached.map((c) => Chapter.fromCache(c)).toList();
    }
  }

  Future<Chapter?> getChapter(Chapter chapter) async {
    try {
      final cached = await _local.getChapter(chapter.id);
      if (cached != null) {
        _syncChapter(chapter.id).ignore();
        return Chapter.fromCache(cached);
      }

      if (!_network.isOnline) {
        return null;
      }

      _setState(DataManagerState.syncing);
      final repo = NovelRepository(_remote);
      final remote = await repo.getChapter(chapter.id);

      if (remote != null) {
        await _local.saveChapter(
          ChapterCache(
            chapterId: remote.id,
            novelId: remote.novelId,
            idx: remote.idx,
            title: remote.title,
            content: remote.content ?? '',
            lastUpdated: DateTime.now(),
          ),
        );
      }

      _setState(DataManagerState.idle);
      return remote;
    } on Object catch (e) {
      _setState(DataManagerState.error, error: e.toString());
      final cached = await _local.getChapter(chapter.id);
      return cached != null ? Chapter.fromCache(cached) : null;
    }
  }

  Future<void> _syncNovel(String novelId) async {
    if (!_network.isOnline) return;

    try {
      final repo = NovelRepository(_remote);
      final remote = await repo.getNovel(novelId);
      if (remote != null) {
        await _local.saveNovel(remote);
        await _saveCacheMetadata('novel_$novelId');
      }
    } on Object catch (_) {}
  }

  Future<void> _syncChapters(String novelId) async {
    if (!_network.isOnline) return;

    try {
      final repo = NovelRepository(_remote);
      final chapters = await repo.fetchChaptersByNovel(novelId);

      await _local.saveChaptersList(
        novelId,
        chapters
            .map(
              (c) => {
                'id': c.id,
                'novel_id': c.novelId,
                'idx': c.idx,
                'title': c.title,
                'content': c.content,
              },
            )
            .toList(),
      );
    } on Object catch (_) {}
  }

  Future<void> _syncChapter(String chapterId) async {
    if (!_network.isOnline) return;

    try {
      final repo = NovelRepository(_remote);
      final remote = await repo.getChapter(chapterId);
      if (remote != null && remote.content != null) {
        await _local.saveChapter(
          ChapterCache(
            chapterId: remote.id,
            novelId: remote.novelId,
            idx: remote.idx,
            title: remote.title,
            content: remote.content!,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } on Object catch (_) {}
  }

  Future<void> _saveCacheMetadata(String key) async {
    final meta = CacheMetadata(
      key: key,
      lastUpdated: DateTime.now(),
      lastSynced: DateTime.now(),
    );
    final json = jsonEncode(meta.toJson());
    await _storage.setString('cache_meta_$key', json);
  }

  Future<void> _triggerBackgroundSync() async {
    if (!_network.isOnline) return;

    try {
      await getAllNovels(forceRefresh: true);
    } on Object catch (_) {}
  }

  Future<void> clearCache() async {
    await _local.clearChapterCache();
  }

  Future<void> clearNovelCache(String novelId) async {
    await _local.clearCacheByNovel(novelId);
  }

  void dispose() {
    _stateController.close();
  }
}
