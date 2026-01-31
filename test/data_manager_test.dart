import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/services/data_manager.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/chapter_cache.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:writer/services/storage_service.dart';
import 'dart:async';

class FakeConnectivityChecker implements ConnectivityChecker {
  bool _isOnline = false;

  void setOnline(bool online) {
    _isOnline = online;
  }

  @override
  Future<bool> checkConnectivity() async {
    return _isOnline;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Stream.value([]);
  }
}

class MockRemoteRepository extends RemoteRepository {
  MockRemoteRepository() : super('http://test/');

  List<Novel> novels = [];
  Map<String, List<Chapter>> chapters = {};
  Map<String, Chapter> singleChapters = {};
  bool shouldThrow = false;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    if (shouldThrow) throw Exception('Remote error');

    final cleanPath = path.startsWith('/') ? path : '/$path';

    if (cleanPath == '/novels/public') {
      return novels.where((n) => n.isPublic).map((n) => n.toMap()).toList();
    }
    if (cleanPath == '/novels/member') {
      return novels.where((n) => !n.isPublic).map((n) => n.toMap()).toList();
    }
    if (cleanPath.startsWith('/novels/') && !cleanPath.contains('/chapters')) {
      final id = cleanPath.split('/').last;
      final novel = novels.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception('Not found'),
      );
      return novel.toMap();
    }
    if (cleanPath.contains('/chapters') && !cleanPath.endsWith('/chapters')) {
      // /chapters/chapterId
      final id = cleanPath.split('/').last;
      if (singleChapters.containsKey(id)) {
        final c = singleChapters[id]!;
        return {
          'id': c.id,
          'novel_id': c.novelId,
          'idx': c.idx,
          'title': c.title,
          'content': c.content,
          'sha': c.sha,
        };
      }
      throw Exception('Chapter not found');
    }
    if (cleanPath.endsWith('/chapters')) {
      // /novels/novelId/chapters
      final parts = cleanPath.split('/');
      final novelId = parts[2];
      if (chapters.containsKey(novelId)) {
        return chapters[novelId]!
            .map(
              (c) => {
                'id': c.id,
                'novel_id': c.novelId,
                'idx': c.idx,
                'title': c.title,
                'content': c.content,
                'sha': c.sha,
              },
            )
            .toList();
      }
      return [];
    }
    return null;
  }
}

class TestStorageService implements StorageService {
  final SharedPreferences _prefs;

  TestStorageService(this._prefs);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Set<String> getKeys() => _prefs.getKeys();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataManager', () {
    late SharedPreferences prefs;
    late FakeConnectivityChecker checker;
    late NetworkMonitor monitor;
    late TestStorageService storage;
    late LocalStorageRepository local;
    late MockRemoteRepository remote;
    late DataManager dataManager;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      checker = FakeConnectivityChecker();
      monitor = NetworkMonitor(checker);
      storage = TestStorageService(prefs);
      local = LocalStorageRepository(storage);
      remote = MockRemoteRepository();
      dataManager = DataManager(
        local: local,
        remote: remote,
        network: monitor,
        storage: storage,
      );
    });

    tearDown(() {
      monitor.dispose();
      dataManager.dispose();
    });

    final testNovel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Desc',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    final testChapter = const Chapter(
      id: 'c-1',
      novelId: 'n-1',
      idx: 1,
      title: 'Chapter 1',
      content: 'Content',
    );

    test('getAllNovels returns remote data when online', () async {
      checker.setOnline(true);
      remote.novels = [testNovel];

      final result = await dataManager.getAllNovels();
      expect(result.length, 1);
      expect(result.first.id, 'n-1');
      expect(dataManager.currentState, DataManagerState.idle);
    });

    test('getAllNovels returns cached data when offline', () async {
      checker.setOnline(false);
      await local.saveNovelsList([testNovel]);

      final result = await dataManager.getAllNovels();
      expect(result.length, 1);
      expect(result.first.id, 'n-1');
    });

    test('getNovel returns remote data when online', () async {
      checker.setOnline(true);
      remote.novels = [testNovel];

      final result = await dataManager.getNovel('n-1');
      expect(result, isNotNull);
      expect(result!.title, 'Test Novel');
    });

    test('getNovel returns cached data when offline', () async {
      checker.setOnline(false);
      await local.saveNovel(testNovel);

      final result = await dataManager.getNovel('n-1');
      expect(result, isNotNull);
      expect(result!.title, 'Test Novel');
    });

    test('getChapters returns remote data when online', () async {
      checker.setOnline(true);
      remote.chapters['n-1'] = [testChapter];

      final result = await dataManager.getChapters('n-1');
      expect(result.length, 1);
      expect(result.first.title, 'Chapter 1');
    });

    test('getChapters returns cached data when offline', () async {
      checker.setOnline(false);
      await local.saveChaptersList('n-1', [
        {
          'id': testChapter.id,
          'novel_id': testChapter.novelId,
          'idx': testChapter.idx,
          'title': testChapter.title,
          'content': testChapter.content,
        },
      ]);

      final result = await dataManager.getChapters('n-1');
      expect(result.length, 1);
      expect(result.first.title, 'Chapter 1');
    });

    test('getChapter returns remote data when online', () async {
      checker.setOnline(true);
      remote.singleChapters['c-1'] = testChapter;

      final result = await dataManager.getChapter(testChapter);
      expect(result, isNotNull);
      expect(result!.content, 'Content');
    });

    test('getChapter returns cached data when offline', () async {
      checker.setOnline(false);
      await local.saveChapter(
        ChapterCache(
          chapterId: testChapter.id,
          novelId: testChapter.novelId,
          idx: testChapter.idx,
          title: testChapter.title,
          content: testChapter.content!,
          lastUpdated: DateTime.now(),
        ),
      );

      final result = await dataManager.getChapter(testChapter);
      expect(result, isNotNull);
      expect(result!.content, 'Content');
    });

    test('clearCache works', () async {
      await local.saveChapter(
        ChapterCache(
          chapterId: 'c-1',
          novelId: 'n-1',
          idx: 1,
          title: 'T',
          content: 'C',
          lastUpdated: DateTime.now(),
        ),
      );

      await dataManager.clearCache();

      final cached = await local.getChapter('c-1');
      expect(cached, isNull);
    });

    test('clearNovelCache works', () async {
      await local.saveChapter(
        ChapterCache(
          chapterId: 'c-1',
          novelId: 'n-1',
          idx: 1,
          title: 'T',
          content: 'C',
          lastUpdated: DateTime.now(),
        ),
      );

      await dataManager.clearNovelCache('n-1');

      final cached = await local.getChapter('c-1');
      expect(cached, isNull);
    });

    test('getAllNovels handles error and returns cache', () async {
      checker.setOnline(true);
      remote.shouldThrow = true;
      await local.saveNovelsList([testNovel]);

      final result = await dataManager.getAllNovels(forceRefresh: true);
      expect(result.length, 1);
      expect(dataManager.currentState, DataManagerState.error);
    });

    test('dispose closes streams', () async {
      dataManager.dispose();
      expect(dataManager.stateStream, emitsDone);
    });
  });
}
