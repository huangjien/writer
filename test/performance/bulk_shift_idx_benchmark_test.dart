import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/services/storage_service.dart';

class _InMemoryStorageService implements StorageService {
  final Map<String, String?> _store = {};

  @override
  String? getString(String key) => _store[key];

  @override
  Set<String> getKeys() => _store.keys.toSet();

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> setString(String key, String? value) async {
    _store[key] = value;
  }
}

class _AlwaysOnlineConnectivityChecker implements ConnectivityChecker {
  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    yield const <ConnectivityResult>[ConnectivityResult.wifi];
  }
}

void main() {
  test('bulkShiftIdx uses a single reorder call', () async {
    const novelId = 'novel_1';
    const chapterCount = 100;
    int reorderCalls = 0;
    int chapterPatchCalls = 0;

    final client = MockClient((request) async {
      if (request.method == 'GET' &&
          request.url.path.endsWith('/novels/$novelId/chapters')) {
        final chapters = List.generate(chapterCount, (i) {
          final idx = i + 1;
          return {
            'id': 'c_$idx',
            'novel_id': novelId,
            'idx': idx,
            'title': 'Chapter $idx',
          };
        });
        return http.Response(jsonEncode(chapters), 200);
      }

      if (request.method == 'PATCH' &&
          request.url.path.endsWith('/novels/$novelId/chapters/reorder')) {
        reorderCalls++;
        return http.Response('{}', 200);
      }

      if (request.method == 'PATCH' &&
          request.url.path.contains('/chapters/')) {
        chapterPatchCalls++;
        return http.Response('{}', 200);
      }

      return http.Response('Not Found', 404);
    });

    final remote = RemoteRepository(
      'http://example.com/',
      client: client,
      authToken: () async => null,
    );
    final storage = LocalStorageRepository(_InMemoryStorageService());
    final repo = ChapterRepository(
      remote,
      storage,
      offlineQueue: OfflineQueueService(
        prefs: () async {
          throw StateError('Offline queue not used in this benchmark');
        },
      ),
      networkMonitor: NetworkMonitor(_AlwaysOnlineConnectivityChecker()),
    );

    await repo.bulkShiftIdx(novelId, 1, 1);

    expect(reorderCalls, 1);
    expect(chapterPatchCalls, 0);
  });
}
