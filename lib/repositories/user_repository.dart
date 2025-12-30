import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Abstract repository for user-related operations
///
/// This abstraction allows for easy testing by providing mock implementations.
abstract class UserRepository {
  /// Fetch user information by session ID
  ///
  /// Returns user information if session is valid, null otherwise.
  Future<User?> fetchUser(String sessionId);
}

/// Remote implementation of UserRepository that fetches user data from backend
class RemoteUserRepository implements UserRepository {
  final String baseUrl;
  final http.Client _client;

  RemoteUserRepository({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<User?> fetchUser(String sessionId) async {
    try {
      final url = baseUrl.endsWith('/')
          ? '${baseUrl}auth/verify'
          : '$baseUrl/auth/verify';

      final response = await _client.get(
        Uri.parse(url),
        headers: {'X-Session-Id': sessionId},
      );

      if (response.statusCode == 200) {
        final data = _decodeUtf8(response.bodyBytes);
        return User.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Decode UTF-8 bytes to a JSON map
  Map<String, dynamic> _decodeUtf8(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }
}
