class SyncStatus {
  final String id;
  final String deviceId;
  final SyncState state;
  final DateTime? lastSyncTime;
  final DateTime? nextSyncTime;
  final int pendingChanges;
  final String? error;
  final Map<String, dynamic>? metadata;

  SyncStatus({
    required this.id,
    required this.deviceId,
    required this.state,
    this.lastSyncTime,
    this.nextSyncTime,
    this.pendingChanges = 0,
    this.error,
    this.metadata,
  });

  bool get isSyncing => state == SyncState.syncing;
  bool get hasError => error != null;
  bool get hasPendingChanges => pendingChanges > 0;

  Duration? get timeSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().difference(lastSyncTime!);
  }

  SyncStatus copyWith({
    String? id,
    String? deviceId,
    SyncState? state,
    DateTime? lastSyncTime,
    DateTime? nextSyncTime,
    int? pendingChanges,
    String? error,
    Map<String, dynamic>? metadata,
  }) {
    return SyncStatus(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      state: state ?? this.state,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      nextSyncTime: nextSyncTime ?? this.nextSyncTime,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'state': state.name,
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'next_sync_time': nextSyncTime?.toIso8601String(),
      'pending_changes': pendingChanges,
      'error': error,
      'metadata': metadata,
    };
  }

  factory SyncStatus.fromMap(Map<String, dynamic> map) {
    return SyncStatus(
      id: map['id'] as String,
      deviceId: map['device_id'] as String,
      state: SyncState.values.firstWhere(
        (e) => e.name == map['state'],
        orElse: () => SyncState.idle,
      ),
      lastSyncTime: map['last_sync_time'] != null
          ? DateTime.parse(map['last_sync_time'] as String)
          : null,
      nextSyncTime: map['next_sync_time'] != null
          ? DateTime.parse(map['next_sync_time'] as String)
          : null,
      pendingChanges: map['pending_changes'] as int? ?? 0,
      error: map['error'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

enum SyncState { idle, syncing, success, failed, offline }

class SyncConflict {
  final String id;
  final String documentId;
  final String entityType;
  final String localVersion;
  final String remoteVersion;
  final DateTime localModifiedAt;
  final DateTime remoteModifiedAt;
  final ConflictResolution? resolution;
  final DateTime createdAt;

  SyncConflict({
    required this.id,
    required this.documentId,
    required this.entityType,
    required this.localVersion,
    required this.remoteVersion,
    required this.localModifiedAt,
    required this.remoteModifiedAt,
    this.resolution,
    required this.createdAt,
  });

  bool get isResolved => resolution != null;

  Duration get localAge => DateTime.now().difference(localModifiedAt);
  Duration get remoteAge => DateTime.now().difference(remoteModifiedAt);

  bool get localIsNewer => localModifiedAt.isAfter(remoteModifiedAt);

  SyncConflict copyWith({
    String? id,
    String? documentId,
    String? entityType,
    String? localVersion,
    String? remoteVersion,
    DateTime? localModifiedAt,
    DateTime? remoteModifiedAt,
    ConflictResolution? resolution,
    DateTime? createdAt,
  }) {
    return SyncConflict(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      entityType: entityType ?? this.entityType,
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      localModifiedAt: localModifiedAt ?? this.localModifiedAt,
      remoteModifiedAt: remoteModifiedAt ?? this.remoteModifiedAt,
      resolution: resolution ?? this.resolution,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'entity_type': entityType,
      'local_version': localVersion,
      'remote_version': remoteVersion,
      'local_modified_at': localModifiedAt.toIso8601String(),
      'remote_modified_at': remoteModifiedAt.toIso8601String(),
      'resolution': resolution?.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SyncConflict.fromMap(Map<String, dynamic> map) {
    return SyncConflict(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      entityType: map['entity_type'] as String,
      localVersion: map['local_version'] as String,
      remoteVersion: map['remote_version'] as String,
      localModifiedAt: DateTime.parse(map['local_modified_at'] as String),
      remoteModifiedAt: DateTime.parse(map['remote_modified_at'] as String),
      resolution: map['resolution'] != null
          ? ConflictResolution.values.firstWhere(
              (e) => e.name == map['resolution'],
              orElse: () => ConflictResolution.manual,
            )
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

enum ConflictResolution { keepLocal, keepRemote, merge, manual }

class SyncableEntity {
  final String id;
  final String type;
  final String documentId;
  final DateTime lastModified;
  final int version;
  final bool isDeleted;
  final Map<String, dynamic>? data;

  SyncableEntity({
    required this.id,
    required this.type,
    required this.documentId,
    required this.lastModified,
    this.version = 1,
    this.isDeleted = false,
    this.data,
  });

  bool get needsSync => version > 1 || isDeleted;

  SyncableEntity copyWith({
    String? id,
    String? type,
    String? documentId,
    DateTime? lastModified,
    int? version,
    bool? isDeleted,
    Map<String, dynamic>? data,
  }) {
    return SyncableEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      documentId: documentId ?? this.documentId,
      lastModified: lastModified ?? this.lastModified,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'document_id': documentId,
      'last_modified': lastModified.toIso8601String(),
      'version': version,
      'is_deleted': isDeleted,
      'data': data,
    };
  }

  factory SyncableEntity.fromMap(Map<String, dynamic> map) {
    return SyncableEntity(
      id: map['id'] as String,
      type: map['type'] as String,
      documentId: map['document_id'] as String,
      lastModified: DateTime.parse(map['last_modified'] as String),
      version: map['version'] as int? ?? 1,
      isDeleted: map['is_deleted'] as bool? ?? false,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}

class Device {
  final String id;
  final String name;
  final String platform;
  final String? appVersion;
  final DateTime lastSeen;
  final bool isCurrentDevice;
  final Map<String, dynamic>? capabilities;

  Device({
    required this.id,
    required this.name,
    required this.platform,
    this.appVersion,
    required this.lastSeen,
    this.isCurrentDevice = false,
    this.capabilities,
  });

  bool get isAndroid => platform == 'android';
  bool get isIOS => platform == 'ios';
  bool get isWeb => platform == 'web';

  Duration get timeSinceLastSeen => DateTime.now().difference(lastSeen);

  bool get isOnline => timeSinceLastSeen.inMinutes < 5;

  Device copyWith({
    String? id,
    String? name,
    String? platform,
    String? appVersion,
    DateTime? lastSeen,
    bool? isCurrentDevice,
    Map<String, dynamic>? capabilities,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      lastSeen: lastSeen ?? this.lastSeen,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'app_version': appVersion,
      'last_seen': lastSeen.toIso8601String(),
      'is_current_device': isCurrentDevice,
      'capabilities': capabilities,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as String,
      name: map['name'] as String,
      platform: map['platform'] as String,
      appVersion: map['app_version'] as String?,
      lastSeen: DateTime.parse(map['last_seen'] as String),
      isCurrentDevice: map['is_current_device'] as bool? ?? false,
      capabilities: map['capabilities'] as Map<String, dynamic>?,
    );
  }
}

class SyncSettings {
  final bool autoSyncEnabled;
  final SyncFrequency frequency;
  final bool syncOnWifiOnly;
  final bool syncOnCellular;
  final bool syncInBackground;
  final bool syncDeletedItems;
  final Duration? customInterval;
  final List<String>? excludedDocumentIds;

  SyncSettings({
    this.autoSyncEnabled = true,
    this.frequency = SyncFrequency.automatic,
    this.syncOnWifiOnly = false,
    this.syncOnCellular = true,
    this.syncInBackground = true,
    this.syncDeletedItems = true,
    this.customInterval,
    this.excludedDocumentIds,
  });

  SyncSettings copyWith({
    bool? autoSyncEnabled,
    SyncFrequency? frequency,
    bool? syncOnWifiOnly,
    bool? syncOnCellular,
    bool? syncInBackground,
    bool? syncDeletedItems,
    Duration? customInterval,
    List<String>? excludedDocumentIds,
  }) {
    return SyncSettings(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      frequency: frequency ?? this.frequency,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      syncOnCellular: syncOnCellular ?? this.syncOnCellular,
      syncInBackground: syncInBackground ?? this.syncInBackground,
      syncDeletedItems: syncDeletedItems ?? this.syncDeletedItems,
      customInterval: customInterval ?? this.customInterval,
      excludedDocumentIds: excludedDocumentIds ?? this.excludedDocumentIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auto_sync_enabled': autoSyncEnabled,
      'frequency': frequency.name,
      'sync_on_wifi_only': syncOnWifiOnly,
      'sync_on_cellular': syncOnCellular,
      'sync_in_background': syncInBackground,
      'sync_deleted_items': syncDeletedItems,
      'custom_interval': customInterval?.inMinutes,
      'excluded_document_ids': excludedDocumentIds,
    };
  }

  factory SyncSettings.fromMap(Map<String, dynamic> map) {
    return SyncSettings(
      autoSyncEnabled: map['auto_sync_enabled'] as bool? ?? true,
      frequency: SyncFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => SyncFrequency.automatic,
      ),
      syncOnWifiOnly: map['sync_on_wifi_only'] as bool? ?? false,
      syncOnCellular: map['sync_on_cellular'] as bool? ?? true,
      syncInBackground: map['sync_in_background'] as bool? ?? true,
      syncDeletedItems: map['sync_deleted_items'] as bool? ?? true,
      customInterval: map['custom_interval'] != null
          ? Duration(minutes: map['custom_interval'] as int)
          : null,
      excludedDocumentIds: map['excluded_document_ids'] != null
          ? List<String>.from(map['excluded_document_ids'])
          : null,
    );
  }
}

enum SyncFrequency {
  automatic,
  manual,
  every15Minutes,
  every30Minutes,
  everyHour,
  everyDay,
}
