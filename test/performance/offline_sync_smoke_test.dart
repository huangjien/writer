import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/offline_operation.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/connectivity_checker.dart';
import 'package:writer/services/network_monitor.dart';
import 'package:writer/services/offline_queue_service.dart';
import 'package:writer/services/sync_service.dart';

class _AlwaysOnlineConnectivityChecker implements ConnectivityChecker {
  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    yield const <ConnectivityResult>[ConnectivityResult.wifi];
  }
}

void main() {
  test('offline create op is synced', () async {
    SharedPreferences.setMockInitialValues({});

    const novelId = 'novel_1';
    final offlineQueue = OfflineQueueService();

    await offlineQueue.enqueue(
      OfflineOperation(
        id: 'op_1',
        type: OperationType.createChapter,
        chapterId: 'local_1',
        novelId: novelId,
        data: {
          'novel_id': novelId,
          'idx': 1,
          'title': 'Chapter 1',
          'content': 'hello',
          'sha': 'x',
          'language_code': 'en',
        },
        createdAt: DateTime.now(),
      ),
    );

    final remote = RemoteRepository(
      'http://example.com/',
      client: MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/chapters')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (body['novel_id'] is! String ||
              (body['novel_id'] as String).isEmpty) {
            return http.Response(
              jsonEncode({
                'code': 'validation_error',
                'message': 'novel_id missing',
              }),
              422,
            );
          }
          return http.Response(
            jsonEncode({
              'id': 'server_1',
              'novel_id': novelId,
              'idx': 1,
              'title': 'Chapter 1',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      }),
      authToken: () async => null,
    );

    final sync = SyncService(
      offlineQueue: offlineQueue,
      remote: remote,
      networkMonitor: NetworkMonitor(_AlwaysOnlineConnectivityChecker()),
      delay: (_) async {},
    );

    await sync.syncPendingOperations();

    final pending = await offlineQueue.getPendingOperations();
    expect(pending, isEmpty);
  });
}
