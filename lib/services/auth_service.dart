import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a sign-in operation
class SignInResult {
  final bool success;
  final String? sessionId;
  final String? errorMessage;

  const SignInResult({
    required this.success,
    this.sessionId,
    this.errorMessage,
  });

  factory SignInResult.success(String sessionId) {
    return SignInResult(success: true, sessionId: sessionId);
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
          final decoded = jsonDecode(response.body);
          if (decoded['detail'] != null) {
            errorMessage = decoded['detail'].toString();
          }
        } catch (_) {}
        return SignInResult.failure(errorMessage);
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final sessionId = data['session_id'];
      if (sessionId is String && sessionId.isNotEmpty) {
        return SignInResult.success(sessionId);
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
