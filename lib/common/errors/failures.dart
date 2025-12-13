abstract class AppFailure implements Exception {
  final String message;
  final Object? originalException;

  const AppFailure(this.message, [this.originalException]);

  @override
  String toString() => 'AppFailure: $message';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'No internet connection',
    super.originalException,
  ]);
}

class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure({
    String message = 'Server error occurred',
    this.statusCode,
    Object? originalException,
  }) : super(message, originalException);

  @override
  String toString() => 'ServerFailure($statusCode): $message';
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Cache error', super.originalException]);
}

class AuthFailure extends AppFailure {
  const AuthFailure([
    super.message = 'Authentication failed',
    super.originalException,
  ]);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'An unknown error occurred',
    super.originalException,
  ]);
}
