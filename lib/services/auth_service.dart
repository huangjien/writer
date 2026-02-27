import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a sign-in operation
class SignInResult {
  final bool success;
  final String? sessionId;
  final String? refreshToken;
  final String? errorMessage;

  const SignInResult({
    required this.success,
    this.sessionId,
    this.refreshToken,
    this.errorMessage,
  });

  factory SignInResult.success(String sessionId, {String? refreshToken}) {
    return SignInResult(
      success: true,
      sessionId: sessionId,
      refreshToken: refreshToken,
    );
  }

  factory SignInResult.failure(String errorMessage) {
    return SignInResult(success: false, errorMessage: errorMessage);
  }
}

/// Abstract service for authentication operations
///
/// This abstraction allows for easy testing by providing mock implementations.
abstract class AuthService {
  /// Sign in with email and password
  ///
  /// Returns a SignInResult indicating success or failure.
  Future<SignInResult> signIn(String email, String password);

  /// Refresh the session using a refresh token
  ///
  /// Returns a SignInResult indicating success or failure.
  Future<SignInResult> refresh(String refreshToken);
}

/// Remote implementation of AuthService that communicates with the backend
class RemoteAuthService implements AuthService {
  final String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  RemoteAuthService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<SignInResult> signIn(String email, String password) async {
    try {
      final url = _urlJoin(baseUrl, '/auth/login');
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        String errorMessage = 'Sign in failed';
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
          if (decoded != null && decoded['detail'] != null) {
            errorMessage = decoded['detail'].toString();
          }
        } catch (_) {}
        return SignInResult.failure(errorMessage);
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final sessionId = data['session_id'];
      final refreshToken = data['refresh_token'];
      if (sessionId is String && sessionId.isNotEmpty) {
        return SignInResult.success(sessionId, refreshToken: refreshToken);
      } else {
        return SignInResult.failure('Invalid response from server');
      }
    } catch (e) {
      return SignInResult.failure(e.toString());
    }
  }

  @override
  Future<SignInResult> refresh(String refreshToken) async {
    try {
      final url = _urlJoin(baseUrl, '/auth/refresh');
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        String errorMessage = 'Refresh failed';
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
          if (decoded != null && decoded['detail'] != null) {
            errorMessage = decoded['detail'].toString();
          }
        } catch (_) {}
        return SignInResult.failure(errorMessage);
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final sessionId = data['session_id'];
      final newRefreshToken = data['refresh_token'];
      if (sessionId is String && sessionId.isNotEmpty) {
        return SignInResult.success(sessionId, refreshToken: newRefreshToken);
      } else {
        return SignInResult.failure('Invalid response from server');
      }
    } catch (e) {
      return SignInResult.failure(e.toString());
    }
  }

  /// Join base URL and path
  String _urlJoin(String baseUrl, String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return '$b$p';
  }
}
