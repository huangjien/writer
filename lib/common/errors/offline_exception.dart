class OfflineException implements Exception {
  final String message;
  final String? operationId;

  const OfflineException(this.message, {this.operationId});

  @override
  String toString() {
    if (operationId != null) {
      return 'OfflineException: $message (operationId: $operationId)';
    }
    return 'OfflineException: $message';
  }
}

class SyncException implements Exception {
  final String message;
  final String? operationId;
  final int? statusCode;

  const SyncException(this.message, {this.operationId, this.statusCode});

  @override
  String toString() {
    if (operationId != null) {
      return 'SyncException: $message (operationId: $operationId, statusCode: $statusCode)';
    }
    return 'SyncException: $message';
  }
}
