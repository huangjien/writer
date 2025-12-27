/// API Error Response Model
///
/// This model represents the standardized error response format
/// returned by the backend API. It includes the error code,
/// message, user-facing message key, and optional details.
library;

class ApiErrorResponse {
  /// The error code for client-side handling and localization
  final String code;

  /// Developer-friendly error message (always in English)
  final String message;

  /// Key for frontend localization
  /// Matches ErrorCode value for easy mapping to localized strings
  final String? userMessageKey;

  /// Additional context for debugging
  /// Only included for non-5xx errors to avoid exposing internal details
  final Map<String, dynamic>? details;

  /// Unique identifier for request
  /// Useful for tracing and debugging in production
  final String? requestId;

  ApiErrorResponse({
    required this.code,
    required this.message,
    this.userMessageKey,
    this.details,
    this.requestId,
  });

  /// Create an ApiErrorResponse from JSON data
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      code: json['code'] as String? ?? 'internal_error',
      message: json['message'] as String? ?? 'An error occurred',
      userMessageKey: json['user_message_key'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      requestId: json['request_id'] as String?,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (userMessageKey != null) 'user_message_key': userMessageKey,
      if (details != null) 'details': details,
      if (requestId != null) 'request_id': requestId,
    };
  }

  @override
  String toString() {
    return 'ApiErrorResponse(code: $code, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiErrorResponse &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}
