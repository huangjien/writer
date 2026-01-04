import '../models/api_error_response.dart';

class ApiException implements Exception {
  final int statusCode;
  final String? rawMessage;
  final ApiErrorResponse? errorResponse;

  ApiException(this.statusCode, this.rawMessage, {this.errorResponse});

  @override
  String toString() {
    if (errorResponse != null) {
      return 'ApiException($statusCode): ${errorResponse!.code}';
    }
    return 'ApiException($statusCode): $rawMessage';
  }
}
