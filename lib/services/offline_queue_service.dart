import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/offline_operation.dart';

const String _queueKey = 'offline_ops_queue';
const String _opPrefix = 'offline_op_';

class OfflineQueueService {
  final Future<SharedPreferences> Function() _prefs;

  OfflineQueueService({Future<SharedPreferences> Function()? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance;

  /// Enqueue a new offline operation
  Future<void> enqueue(OfflineOperation operation) async {
    final prefs = await _prefs();

    // Add to queue list
    final queue = await _getQueueList();
    queue.add(operation.id);
    await prefs.setString(_queueKey, jsonEncode(queue));

    // Store operation data
    await prefs.setString(
      '$_opPrefix${operation.id}',
      jsonEncode(operation.toJson()),
    );
  }

  /// Get all pending operations
  Future<List<OfflineOperation>> getPendingOperations() async {
    final queue = await _getQueueList();
    final operations = <OfflineOperation>[];

    for (final opId in queue) {
      final prefs = await _prefs();
      final opJson = prefs.getString('$_opPrefix$opId');
      if (opJson != null) {
        try {
          final opMap = jsonDecode(opJson) as Map<String, dynamic>;
          if (opMap['isPending'] == true) {
            operations.add(OfflineOperation.fromJson(opMap));
          }
        } catch (_) {
          // Skip invalid operations
        }
      }
    }

    // Sort by creation time (oldest first)
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return operations;
  }

  /// Mark an operation as completed
  Future<void> markCompleted(String operationId) async {
    final prefs = await _prefs();

    // Update operation status
    final opJson = prefs.getString('$_opPrefix$operationId');
    if (opJson == null) return;

    try {
      final opMap = jsonDecode(opJson) as Map<String, dynamic>;
      final updatedOp = OfflineOperation.fromJson(
        opMap,
      ).copyWith(isPending: false);
      await prefs.setString(
        '$_opPrefix$operationId',
        jsonEncode(updatedOp.toJson()),
      );
    } catch (_) {
      // Ignore errors
    }
  }

  /// Mark an operation as failed
  Future<void> markFailed(String operationId, String error) async {
    final prefs = await _prefs();

    // Update operation status
    final opJson = prefs.getString('$_opPrefix$operationId');
    if (opJson == null) return;

    try {
      final opMap = jsonDecode(opJson) as Map<String, dynamic>;
      final updatedOp = OfflineOperation.fromJson(
        opMap,
      ).copyWith(isPending: true, lastError: error);
      await prefs.setString(
        '$_opPrefix$operationId',
        jsonEncode(updatedOp.toJson()),
      );
    } catch (_) {
      // Ignore errors
    }
  }

  /// Increment retry count for an operation
  Future<void> incrementRetry(String operationId) async {
    final prefs = await _prefs();

    final opJson = prefs.getString('$_opPrefix$operationId');
    if (opJson == null) return;

    try {
      final opMap = jsonDecode(opJson) as Map<String, dynamic>;
      final op = OfflineOperation.fromJson(opMap);
      final updatedOp = op.copyWith(retryCount: op.retryCount + 1);
      await prefs.setString(
        '$_opPrefix$operationId',
        jsonEncode(updatedOp.toJson()),
      );
    } catch (_) {
      // Ignore errors
    }
  }

  /// Clear completed operations from queue
  Future<void> clearCompleted() async {
    final prefs = await _prefs();
    final queue = await _getQueueList();

    // Remove completed operations from queue
    final activeQueue = <String>[];
    for (final opId in queue) {
      final opJson = prefs.getString('$_opPrefix$opId');
      if (opJson == null) continue;

      try {
        final opMap = jsonDecode(opJson) as Map<String, dynamic>;
        if (opMap['isPending'] == true) {
          activeQueue.add(opId);
        }
      } catch (_) {
        // Skip invalid operations, keep in queue
        activeQueue.add(opId);
      }
    }

    await prefs.setString(_queueKey, jsonEncode(activeQueue));
  }

  /// Get list of operation IDs from queue
  Future<List<String>> _getQueueList() async {
    final prefs = await _prefs();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) return <String>[];

    try {
      return (jsonDecode(queueJson) as List<dynamic>).cast<String>();
    } catch (_) {
      return <String>[];
    }
  }

  /// Get pending operations count
  Future<int> getPendingCount() async {
    final operations = await getPendingOperations();
    return operations.length;
  }

  /// Remove a specific operation from queue
  Future<void> removeOperation(String operationId) async {
    final prefs = await _prefs();

    // Remove from queue list
    final queue = await _getQueueList();
    queue.remove(operationId);
    await prefs.setString(_queueKey, jsonEncode(queue));

    // Remove operation data
    await prefs.remove('$_opPrefix$operationId');
  }

  Future<void> replaceChapterId({
    required String fromId,
    required String toId,
  }) async {
    if (fromId.trim().isEmpty || toId.trim().isEmpty) return;
    final prefs = await _prefs();
    final queue = await _getQueueList();

    for (final opId in queue) {
      final opJson = prefs.getString('$_opPrefix$opId');
      if (opJson == null) continue;

      try {
        final opMap = jsonDecode(opJson) as Map<String, dynamic>;
        final op = OfflineOperation.fromJson(opMap);
        if (op.chapterId != fromId) continue;

        final updatedData = Map<String, dynamic>.from(op.data ?? {});
        final embeddedChapterId = updatedData['chapter_id'];
        if (embeddedChapterId == fromId) {
          updatedData['chapter_id'] = toId;
        }
        updatedData['serverId'] = toId;

        final updatedOp = op.copyWith(chapterId: toId, data: updatedData);
        await prefs.setString(
          '$_opPrefix$opId',
          jsonEncode(updatedOp.toJson()),
        );
      } catch (_) {}
    }
  }
}
