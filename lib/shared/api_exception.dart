import '../models/api_error_response.dart';

class ApiException implements Exception {
  final int statusCode;
  final String? rawMessage;
  final ApiErrorResponse? errorResponse;

  ApiException(this.statusCode, this.rawMessage, {this.errorResponse});

  @override
  String toString() {
    if (errorResponse != null) {
      final rid = errorResponse!.requestId;
      return rid == null || rid.isEmpty
          ? 'ApiException($statusCode): ${errorResponse!.code}'
          : 'ApiException($statusCode): ${errorResponse!.code} (request_id=$rid)';
    }
    return 'ApiException($statusCode): $rawMessage';
  }
}
