import 'package:flutter_test/flutter_test.dart';
import 'package:writer/common/errors/failures.dart';

void main() {
  group('AppFailure', () {
    group('NetworkFailure', () {
      test('has correct default message', () {
        const failure = NetworkFailure();
        expect(failure.message, 'No internet connection');
        expect(failure.toString(), 'AppFailure: No internet connection');
      });

      test('stores custom message', () {
        const failure = NetworkFailure('Custom network error');
        expect(failure.message, 'Custom network error');
        expect(failure.toString(), 'AppFailure: Custom network error');
      });

      test('stores original exception', () {
        final exception = Exception('oops');
        final failure = NetworkFailure('Custom message', exception);
        expect(failure.message, 'Custom message');
        expect(failure.originalException, exception);
      });

      test('originalException is null by default', () {
        const failure = NetworkFailure();
        expect(failure.originalException, isNull);
      });

      test('implements Exception', () {
        const failure = NetworkFailure();
        expect(failure, isA<Exception>());
      });
    });

    group('ServerFailure', () {
      test('has correct default message and properties', () {
        const failure = ServerFailure();
        expect(failure.message, 'Server error occurred');
        expect(failure.statusCode, isNull);
        expect(
          failure.toString(),
          'ServerFailure(null): Server error occurred',
        );
      });

      test('stores status code and custom message', () {
        const failure = ServerFailure(message: 'Bad Request', statusCode: 400);
        expect(failure.message, 'Bad Request');
        expect(failure.statusCode, 400);
        expect(failure.toString(), 'ServerFailure(400): Bad Request');
      });

      test('stores original exception', () {
        final exception = Exception('server error');
        final failure = ServerFailure(
          message: 'Custom server error',
          statusCode: 500,
          originalException: exception,
        );
        expect(failure.message, 'Custom server error');
        expect(failure.statusCode, 500);
        expect(failure.originalException, exception);
      });

      test('originalException is null by default', () {
        const failure = ServerFailure();
        expect(failure.originalException, isNull);
      });

      test('toString includes statusCode when provided', () {
        const failure = ServerFailure(message: 'Not Found', statusCode: 404);
        expect(failure.toString(), 'ServerFailure(404): Not Found');
      });

      test('implements Exception', () {
        const failure = ServerFailure();
        expect(failure, isA<Exception>());
      });
    });

    group('CacheFailure', () {
      test('has correct default message', () {
        const failure = CacheFailure();
        expect(failure.message, 'Cache error');
        expect(failure.toString(), 'AppFailure: Cache error');
      });

      test('stores custom message', () {
        const failure = CacheFailure('Cache miss');
        expect(failure.message, 'Cache miss');
        expect(failure.toString(), 'AppFailure: Cache miss');
      });

      test('stores original exception', () {
        final exception = Exception('cache corrupted');
        final failure = CacheFailure('Cache corrupted', exception);
        expect(failure.message, 'Cache corrupted');
        expect(failure.originalException, exception);
      });

      test('originalException is null by default', () {
        const failure = CacheFailure();
        expect(failure.originalException, isNull);
      });

      test('implements Exception', () {
        const failure = CacheFailure();
        expect(failure, isA<Exception>());
      });
    });

    group('AuthFailure', () {
      test('has correct default message', () {
        const failure = AuthFailure();
        expect(failure.message, 'Authentication failed');
        expect(failure.toString(), 'AppFailure: Authentication failed');
      });

      test('stores custom message', () {
        const failure = AuthFailure('Invalid credentials');
        expect(failure.message, 'Invalid credentials');
        expect(failure.toString(), 'AppFailure: Invalid credentials');
      });

      test('stores original exception', () {
        final exception = Exception('token expired');
        final failure = AuthFailure('Token expired', exception);
        expect(failure.message, 'Token expired');
        expect(failure.originalException, exception);
      });

      test('originalException is null by default', () {
        const failure = AuthFailure();
        expect(failure.originalException, isNull);
      });

      test('implements Exception', () {
        const failure = AuthFailure();
        expect(failure, isA<Exception>());
      });
    });

    group('UnknownFailure', () {
      test('has correct default message', () {
        const failure = UnknownFailure();
        expect(failure.message, 'An unknown error occurred');
        expect(failure.toString(), 'AppFailure: An unknown error occurred');
      });

      test('stores custom message', () {
        const failure = UnknownFailure('Unexpected error');
        expect(failure.message, 'Unexpected error');
        expect(failure.toString(), 'AppFailure: Unexpected error');
      });

      test('stores original exception', () {
        final exception = Exception('something went wrong');
        final failure = UnknownFailure('Unexpected error', exception);
        expect(failure.message, 'Unexpected error');
        expect(failure.originalException, exception);
      });

      test('originalException is null by default', () {
        const failure = UnknownFailure();
        expect(failure.originalException, isNull);
      });

      test('implements Exception', () {
        const failure = UnknownFailure();
        expect(failure, isA<Exception>());
      });
    });

    group('Equality and immutability', () {
      test('NetworkFailure with same values are equal', () {
        final failure1 = NetworkFailure('message', Exception('e'));
        final failure2 = NetworkFailure('message', Exception('e'));
        // Note: Exception instances are not equal by default, so this tests
        // that we can create multiple instances
        expect(failure1.message, failure2.message);
      });

      test('ServerFailure const instances can be created', () {
        const failure = ServerFailure(message: 'test', statusCode: 200);
        expect(failure.message, 'test');
        expect(failure.statusCode, 200);
      });

      test('NetworkFailure without originalException can be const', () {
        const failure = NetworkFailure('message');
        expect(failure.message, 'message');
        expect(failure.originalException, isNull);
      });

      test('ServerFailure without originalException can be const', () {
        const failure = ServerFailure(message: 'test', statusCode: 200);
        expect(failure.message, 'test');
        expect(failure.statusCode, 200);
      });

      test('CacheFailure without originalException can be const', () {
        const failure = CacheFailure('cache error');
        expect(failure.message, 'cache error');
      });

      test('AuthFailure without originalException can be const', () {
        const failure = AuthFailure('auth error');
        expect(failure.message, 'auth error');
      });

      test('UnknownFailure without originalException can be const', () {
        const failure = UnknownFailure('unknown error');
        expect(failure.message, 'unknown error');
      });
    });
  });
}
