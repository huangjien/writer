import 'package:uuid/uuid.dart';
import 'package:writer/models/mobile_sync.dart';

class MobileSyncService {
  final Uuid _uuid = Uuid();
  final List<SyncableEntity> _pendingChanges = [];
  final List<SyncConflict> _conflicts = [];

  Future<SyncStatus> getSyncStatus(String deviceId) async {
    return SyncStatus(
      id: _uuid.v4(),
      deviceId: deviceId,
      state: SyncState.idle,
      lastSyncTime: DateTime.now().subtract(const Duration(hours: 1)),
      pendingChanges: _pendingChanges.length,
    );
  }

  Future<SyncStatus> startSync(String deviceId) async {
    final status = await getSyncStatus(deviceId);
    final syncingStatus = status.copyWith(state: SyncState.syncing);

    try {
      await _uploadPendingChanges();
      await _downloadRemoteChanges();
      await _detectAndResolveConflicts();

      return syncingStatus.copyWith(
        state: SyncState.success,
        lastSyncTime: DateTime.now(),
        pendingChanges: _pendingChanges.length,
      );
    } catch (e) {
      return syncingStatus.copyWith(
        state: SyncState.failed,
        error: e.toString(),
      );
    }
  }

  Future<void> _uploadPendingChanges() async {
    // print('Uploading ${_pendingChanges.length} pending changes...');
    await Future.delayed(const Duration(milliseconds: 100));
    _pendingChanges.clear();
  }

  Future<void> _downloadRemoteChanges() async {
    // print('Downloading remote changes...');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _detectAndResolveConflicts() async {
    for (final conflict in _conflicts) {
      if (!conflict.isResolved) {
        await _autoResolveConflict(conflict);
      }
    }
  }

  Future<void> _autoResolveConflict(SyncConflict conflict) async {
    if (conflict.localIsNewer) {
      await resolveConflict(conflict.id, ConflictResolution.keepLocal);
    } else {
      await resolveConflict(conflict.id, ConflictResolution.keepRemote);
    }
  }

  Future<void> queueChange(SyncableEntity entity) async {
    _pendingChanges.add(entity);
    // print('Queued change for ${entity.type}: ${entity.id}');
  }

  Future<SyncConflict> createConflict({
    required String documentId,
    required String entityType,
    required String localVersion,
    required String remoteVersion,
    required DateTime localModifiedAt,
    required DateTime remoteModifiedAt,
  }) async {
    final conflict = SyncConflict(
      id: _uuid.v4(),
      documentId: documentId,
      entityType: entityType,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      localModifiedAt: localModifiedAt,
      remoteModifiedAt: remoteModifiedAt,
      createdAt: DateTime.now(),
    );

    _conflicts.add(conflict);
    return conflict;
  }

  Future<void> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  ) async {
    final index = _conflicts.indexWhere((c) => c.id == conflictId);
    if (index != -1) {
      _conflicts[index] = _conflicts[index].copyWith(resolution: resolution);
      print(
        'Resolved conflict $conflictId with resolution: ${resolution.name}',
      );
    }
  }

  Future<List<SyncConflict>> getUnresolvedConflicts() async {
    return _conflicts.where((c) => !c.isResolved).toList();
  }

  Future<SyncableEntity> markEntitySynced(String entityId) async {
    final index = _pendingChanges.indexWhere((e) => e.id == entityId);
    if (index != -1) {
      final entity = _pendingChanges[index];
      _pendingChanges.removeAt(index);
      return entity.copyWith(
        version: entity.version + 1,
        lastModified: DateTime.now(),
      );
    }

    return SyncableEntity(
      id: entityId,
      type: 'unknown',
      documentId: 'unknown',
      lastModified: DateTime.now(),
      version: 1,
    );
  }

  Future<Device> registerDevice({
    required String name,
    required String platform,
    String? appVersion,
    Map<String, dynamic>? capabilities,
  }) async {
    return Device(
      id: _uuid.v4(),
      name: name,
      platform: platform,
      appVersion: appVersion,
      lastSeen: DateTime.now(),
      isCurrentDevice: true,
      capabilities: capabilities,
    );
  }

  Future<List<Device>> getDevices() async {
    return [
      Device(
        id: 'device1',
        name: 'iPhone 14',
        platform: 'ios',
        appVersion: '1.0.0',
        lastSeen: DateTime.now(),
        isCurrentDevice: true,
      ),
      Device(
        id: 'device2',
        name: 'MacBook Pro',
        platform: 'web',
        appVersion: '1.0.0',
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        isCurrentDevice: false,
      ),
    ];
  }

  Future<SyncSettings> getSyncSettings() async {
    return SyncSettings(
      autoSyncEnabled: true,
      frequency: SyncFrequency.automatic,
      syncOnWifiOnly: false,
      syncOnCellular: true,
      syncInBackground: true,
      syncDeletedItems: true,
    );
  }

  Future<void> updateSyncSettings(SyncSettings settings) async {
    // print('Updating sync settings: ${settings.toMap()}');
  }

  Future<bool> isNetworkAvailable() async {
    return true;
  }

  Future<bool> isWifiConnected() async {
    return true;
  }

  Future<SyncableEntity> createSyncableEntity({
    required String id,
    required String type,
    required String documentId,
    Map<String, dynamic>? data,
  }) async {
    return SyncableEntity(
      id: id,
      type: type,
      documentId: documentId,
      lastModified: DateTime.now(),
      data: data,
    );
  }

  Future<void> deleteEntity(String entityId) async {
    final entity = await createSyncableEntity(
      id: entityId,
      type: 'deleted',
      documentId: 'deleted',
      data: {'deleted': true},
    );

    await queueChange(entity.copyWith(isDeleted: true));
  }

  Future<Map<String, dynamic>> getSyncStatistics() async {
    return {
      'total_devices': 2,
      'pending_changes': _pendingChanges.length,
      'unresolved_conflicts': _conflicts.where((c) => !c.isResolved).length,
      'last_sync': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      'total_synced': 150,
    };
  }

  Future<String> exportSyncData() async {
    final data = {
      'devices': await getDevices(),
      'pending_changes': _pendingChanges,
      'conflicts': _conflicts,
      'exported_at': DateTime.now().toIso8601String(),
    };

    return data.toString();
  }

  Future<void> importSyncData(String data) async {
    // print('Importing sync data: $data');
  }

  Future<void> clearSyncHistory() async {
    _pendingChanges.clear();
    _conflicts.clear();
    // print('Cleared sync history');
  }

  Future<void> forceFullSync(String deviceId) async {
    // print('Forcing full sync for device: $deviceId');
    await startSync(deviceId);
  }

  Future<void> pauseSync() async {
    // print('Pausing sync');
  }

  Future<void> resumeSync() async {
    // print('Resuming sync');
    await startSync('current_device');
  }

  bool shouldSync(SyncSettings settings) {
    if (!settings.autoSyncEnabled) return false;
    return true;
  }

  Future<bool> shouldSyncAsync(SyncSettings settings) async {
    if (!settings.autoSyncEnabled) return false;
    if (settings.syncOnWifiOnly) {
      final isWifi = await isWifiConnected();
      if (!isWifi) return false;
    }
    return true;
  }

  Duration getNextSyncInterval(SyncSettings settings) {
    switch (settings.frequency) {
      case SyncFrequency.every15Minutes:
        return const Duration(minutes: 15);
      case SyncFrequency.every30Minutes:
        return const Duration(minutes: 30);
      case SyncFrequency.everyHour:
        return const Duration(hours: 1);
      case SyncFrequency.everyDay:
        return const Duration(days: 1);
      case SyncFrequency.automatic:
        return const Duration(minutes: 5);
      case SyncFrequency.manual:
        return const Duration(days: 365);
    }
  }

  Future<void> cleanupOldConflicts(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    _conflicts.removeWhere((c) => c.createdAt.isBefore(cutoffDate));
    // print('Cleaned up conflicts older than $daysOld days');
  }

  Future<void> optimizeSyncData() async {
    final entitiesByDocument = <String, List<SyncableEntity>>{};

    for (final entity in _pendingChanges) {
      entitiesByDocument.putIfAbsent(entity.documentId, () => []);
      entitiesByDocument[entity.documentId]!.add(entity);
    }

    for (final entry in entitiesByDocument.entries) {
      if (entry.value.length > 10) {
        print(
          'Optimizing ${entry.value.length} entities for document ${entry.key}',
        );
      }
    }
  }

  Future<String> generateSyncReport() async {
    final stats = await getSyncStatistics();
    final conflicts = await getUnresolvedConflicts();

    final buffer = StringBuffer();
    buffer.writeln('=== Sync Report ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Last Sync: ${stats['last_sync']}');
    buffer.writeln('Total Devices: ${stats['total_devices']}');
    buffer.writeln('Pending Changes: ${stats['pending_changes']}');
    buffer.writeln('Unresolved Conflicts: ${stats['unresolved_conflicts']}');
    buffer.writeln('Total Synced: ${stats['total_synced']}');

    if (conflicts.isNotEmpty) {
      buffer.writeln('\n=== Unresolved Conflicts ===');
      for (final conflict in conflicts) {
        buffer.writeln('${conflict.entityType}: ${conflict.documentId}');
        buffer.writeln(
          '  Local: ${conflict.localVersion} (${conflict.localAge})',
        );
        buffer.writeln(
          '  Remote: ${conflict.remoteVersion} (${conflict.remoteAge})',
        );
      }
    }

    return buffer.toString();
  }
}
