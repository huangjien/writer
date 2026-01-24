import 'package:writer/services/auth_service.dart';

/// Mock implementation of AuthService for testing
class MockAuthService implements AuthService {
  final String? _forceResult;
  final String? _forceError;

  MockAuthService({String? forceResult, String? forceError})
    : _forceResult = forceResult,
      _forceError = forceError;

  @override
  Future<SignInResult> signIn(String email, String password) async {
    // Return forced result if set, otherwise return success
    if (_forceError != null) {
      return SignInResult.failure(_forceError);
    }
    if (_forceResult != null) {
      return SignInResult.success(_forceResult);
    }
    return SignInResult.success('mock-session-id');
  }

  @override
  Future<SignInResult> refresh(String refreshToken) async {
    // Return forced result if set, otherwise return success
    if (_forceError != null) {
      return SignInResult.failure(_forceError);
    }
    if (_forceResult != null) {
      return SignInResult.success(_forceResult);
    }
    return SignInResult.success('mock-refreshed-session-id');
  }
}
