import 'package:flutter/foundation.dart';

enum SyncStatus { synced, syncing, error, offline }

@immutable
class SyncState {
  final SyncStatus status;
  final int pendingOperations;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const SyncState({
    required this.status,
    this.pendingOperations = 0,
    this.errorMessage,
    this.lastSyncTime,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? pendingOperations,
    String? errorMessage,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncState &&
        other.status == status &&
        other.pendingOperations == pendingOperations &&
        other.errorMessage == errorMessage &&
        other.lastSyncTime == lastSyncTime;
  }

  @override
  int get hashCode {
    return Object.hash(status, pendingOperations, errorMessage, lastSyncTime);
  }
}
