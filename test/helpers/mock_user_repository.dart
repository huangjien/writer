import 'package:writer/models/user.dart';
import 'package:writer/repositories/user_repository.dart';

/// Mock implementation of UserRepository for testing
class MockUserRepository implements UserRepository {
  @override
  Future<User?> fetchUser(String sessionId) async {
    // Return a mock user for testing
    return User(
      id: 'test-user-id',
      email: 'test@example.com',
      isApproved: true,
      isAdmin: false,
    );
  }
}
