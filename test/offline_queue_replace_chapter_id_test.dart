import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/offline_operation.dart';
import 'package:writer/services/offline_queue_service.dart';

void main() {
  test('replaceChapterId rewrites pending operations', () async {
    SharedPreferences.setMockInitialValues({});

    final queue = OfflineQueueService();
    await queue.enqueue(
      OfflineOperation(
        id: 'op_1',
        type: OperationType.updateChapter,
        chapterId: 'local_1',
        novelId: 'novel_1',
        data: {'chapter_id': 'local_1', 'title': 'T', 'content': 'C'},
        createdAt: DateTime.now(),
      ),
    );

    await queue.replaceChapterId(fromId: 'local_1', toId: 'server_1');

    final pending = await queue.getPendingOperations();
    expect(pending, hasLength(1));
    expect(pending.single.chapterId, 'server_1');
    expect(pending.single.data?['serverId'], 'server_1');
    expect(pending.single.data?['chapter_id'], 'server_1');
  });
}
