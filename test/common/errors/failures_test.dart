import 'package:flutter_test/flutter_test.dart';
import 'package:writer/common/errors/failures.dart';

void main() {
  group('AppFailure', () {
    test('NetworkFailure has correct default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'No internet connection');
      expect(failure.toString(), 'AppFailure: No internet connection');
    });

    test('NetworkFailure stores original exception', () {
      final exception = Exception('oops');
      final failure = NetworkFailure('Custom message', exception);
      expect(failure.message, 'Custom message');
      expect(failure.originalException, exception);
    });

    test('ServerFailure has correct default message and properties', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error occurred');
      expect(failure.statusCode, isNull);
      expect(failure.toString(), 'ServerFailure(null): Server error occurred');
    });

    test('ServerFailure stores status code and custom message', () {
      const failure = ServerFailure(message: 'Bad Request', statusCode: 400);
      expect(failure.message, 'Bad Request');
      expect(failure.statusCode, 400);
      expect(failure.toString(), 'ServerFailure(400): Bad Request');
    });

    test('CacheFailure has correct default message', () {
      const failure = CacheFailure();
      expect(failure.message, 'Cache error');
    });

    test('AuthFailure has correct default message', () {
      const failure = AuthFailure();
      expect(failure.message, 'Authentication failed');
    });

    test('UnknownFailure has correct default message', () {
      const failure = UnknownFailure();
      expect(failure.message, 'An unknown error occurred');
    });
  });
}
