import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/services/data_manager.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/models/novel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:writer/services/storage_service.dart';

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

class FailingRemoteRepository extends RemoteRepository {
  FailingRemoteRepository() : super('http://test/');

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    throw Exception('offline');
  }

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic>? body, {
    bool retryUnauthorized = true,
  }) async {
    throw Exception('offline');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('DataManager returns cached novels when offline', () async {
    final prefs = await SharedPreferences.getInstance();
    final checker = FakeConnectivityChecker()..setOnline(false);
    final monitor = NetworkMonitor(checker);
    final storage = TestStorageService(prefs);
    final local = LocalStorageRepository(storage);
    final remote = FailingRemoteRepository();

    final dataManager = DataManager(
      local: local,
      remote: remote,
      network: monitor,
      storage: storage,
    );

    final novels = [
      const Novel(
        id: 'n-1',
        title: 'Test Novel 1',
        author: 'Author',
        description: 'Description',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
      const Novel(
        id: 'n-2',
        title: 'Test Novel 2',
        author: 'Author',
        description: 'Description',
        coverUrl: null,
        languageCode: 'en',
        isPublic: true,
      ),
    ];

    await local.saveNovelsList(novels);

    final result = await dataManager.getAllNovels();

    expect(result.length, 2);
    expect(result.first.id, 'n-1');
    expect(result.last.id, 'n-2');

    monitor.dispose();
    dataManager.dispose();
  });

  test('DataManager returns cached novel when offline', () async {
    final prefs = await SharedPreferences.getInstance();
    final checker = FakeConnectivityChecker()..setOnline(false);
    final monitor = NetworkMonitor(checker);
    final storage = TestStorageService(prefs);
    final local = LocalStorageRepository(storage);
    final remote = FailingRemoteRepository();

    final dataManager = DataManager(
      local: local,
      remote: remote,
      network: monitor,
      storage: storage,
    );

    final novel = const Novel(
      id: 'n-1',
      title: 'Test Novel',
      author: 'Author',
      description: 'Description',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );

    await local.saveNovel(novel);

    final result = await dataManager.getNovel('n-1');

    expect(result, isNotNull);
    final resultNovel = result!;
    expect(resultNovel.id, 'n-1');
    expect(resultNovel.title, 'Test Novel');

    monitor.dispose();
    dataManager.dispose();
  });

  test('DataManager returns empty list when offline and no cache', () async {
    final prefs = await SharedPreferences.getInstance();
    final checker = FakeConnectivityChecker()..setOnline(false);
    final monitor = NetworkMonitor(checker);
    final storage = TestStorageService(prefs);
    final local = LocalStorageRepository(storage);
    final remote = FailingRemoteRepository();

    final dataManager = DataManager(
      local: local,
      remote: remote,
      network: monitor,
      storage: storage,
    );

    final result = await dataManager.getAllNovels();

    expect(result, isEmpty);

    monitor.dispose();
    dataManager.dispose();
  });
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
