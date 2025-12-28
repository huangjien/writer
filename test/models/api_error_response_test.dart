import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/api_error_response.dart';

void main() {
  group('ApiErrorResponse', () {
    test('creates instance with all required fields', () {
      final error = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input provided',
      );

      expect(error.code, 'validation_error');
      expect(error.message, 'Invalid input provided');
      expect(error.userMessageKey, isNull);
      expect(error.details, isNull);
      expect(error.requestId, isNull);
    });

    test('creates instance with all fields', () {
      const details = {'field': 'email', 'error': 'invalid format'};
      final error = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input provided',
        userMessageKey: 'errorInvalidEmail',
        details: details,
        requestId: 'req_123456',
      );

      expect(error.code, 'validation_error');
      expect(error.message, 'Invalid input provided');
      expect(error.userMessageKey, 'errorInvalidEmail');
      expect(error.details, equals(details));
      expect(error.requestId, 'req_123456');
    });

    test('fromJson creates instance with all fields', () {
      final json = {
        'code': 'unauthorized',
        'message': 'Authentication failed',
        'user_message_key': 'errorUnauthorized',
        'details': {'reason': 'invalid_token'},
        'request_id': 'req_789012',
      };

      final error = ApiErrorResponse.fromJson(json);

      expect(error.code, 'unauthorized');
      expect(error.message, 'Authentication failed');
      expect(error.userMessageKey, 'errorUnauthorized');
      expect(error.details, equals({'reason': 'invalid_token'}));
      expect(error.requestId, 'req_789012');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'code': 'server_error',
        // message is missing
        'user_message_key': null,
        'details': null,
        'request_id': null,
      };

      final error = ApiErrorResponse.fromJson(json);

      expect(error.code, 'server_error');
      expect(error.message, 'An error occurred'); // default value
      expect(error.userMessageKey, isNull);
      expect(error.details, isNull);
      expect(error.requestId, isNull);
    });

    test('fromJson handles empty JSON', () {
      final json = <String, dynamic>{};

      final error = ApiErrorResponse.fromJson(json);

      expect(error.code, 'internal_error'); // default value
      expect(error.message, 'An error occurred'); // default value
      expect(error.userMessageKey, isNull);
      expect(error.details, isNull);
      expect(error.requestId, isNull);
    });

    test('toJson converts instance with all fields', () {
      const details = {'field': 'password', 'error': 'too_short'};
      final error = ApiErrorResponse(
        code: 'validation_error',
        message: 'Password is too short',
        userMessageKey: 'errorPasswordTooShort',
        details: details,
        requestId: 'req_345678',
      );

      final json = error.toJson();

      expect(
        json,
        equals({
          'code': 'validation_error',
          'message': 'Password is too short',
          'user_message_key': 'errorPasswordTooShort',
          'details': details,
          'request_id': 'req_345678',
        }),
      );
    });

    test('toJson converts instance with only required fields', () {
      final error = ApiErrorResponse(
        code: 'not_found',
        message: 'Resource not found',
      );

      final json = error.toJson();

      expect(
        json,
        equals({'code': 'not_found', 'message': 'Resource not found'}),
      );
      expect(json['user_message_key'], isNull);
      expect(json['details'], isNull);
      expect(json['request_id'], isNull);
    });

    test('toString returns readable format', () {
      final error = ApiErrorResponse(
        code: 'rate_limit_exceeded',
        message: 'Too many requests',
      );

      expect(
        error.toString(),
        'ApiErrorResponse(code: rate_limit_exceeded, message: Too many requests)',
      );
    });

    test('equality works correctly', () {
      final error1 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input',
      );

      final error2 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input',
      );

      final error3 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Different message',
      );

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
      expect(error1 == error2, isTrue);
      expect(error1 == error3, isFalse);
    });

    test('identity equality works', () {
      final error = ApiErrorResponse(
        code: 'test_error',
        message: 'Test message',
      );

      expect(error, equals(error));
      expect(error == error, isTrue);
    });

    test('hashCode is consistent', () {
      final error1 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input',
      );

      final error2 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Invalid input',
      );

      final error3 = ApiErrorResponse(
        code: 'validation_error',
        message: 'Different message',
      );

      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1.hashCode, isNot(equals(error3.hashCode)));
    });

    test('round-trip serialization preserves data', () {
      final original = ApiErrorResponse(
        code: 'payment_required',
        message: 'Payment required to access this feature',
        userMessageKey: 'errorPaymentRequired',
        details: {'feature': 'premium_templates', 'required_plan': 'pro'},
        requestId: 'req_payment_123',
      );

      final json = original.toJson();
      final restored = ApiErrorResponse.fromJson(json);

      expect(restored.code, original.code);
      expect(restored.message, original.message);
      expect(restored.userMessageKey, original.userMessageKey);
      expect(restored.details, equals(original.details));
      expect(restored.requestId, original.requestId);
    });

    group('Common Error Scenarios', () {
      test('client error (4xx) includes details', () {
        final json = {
          'code': 'bad_request',
          'message': 'Invalid request parameters',
          'user_message_key': 'errorBadRequest',
          'details': {
            'invalid_fields': ['email', 'password'],
            'errors': {'email': 'Invalid format', 'password': 'Too short'},
          },
        };

        final error = ApiErrorResponse.fromJson(json);

        expect(error.code, 'bad_request');
        expect(error.details, isNotNull);
        expect(error.details!.containsKey('invalid_fields'), isTrue);
        expect(error.details!.containsKey('errors'), isTrue);
      });

      test('server error (5xx) excludes sensitive details', () {
        final json = {
          'code': 'internal_server_error',
          'message': 'Internal server error occurred',
          'user_message_key': 'errorInternalServerError',
          // In practice, 5xx errors should not include details
        };

        final error = ApiErrorResponse.fromJson(json);

        expect(error.code, 'internal_server_error');
        expect(error.details, isNull);
      });

      test('authentication error with request tracking', () {
        final json = {
          'code': 'authentication_failed',
          'message': 'Invalid authentication credentials',
          'user_message_key': 'errorAuthenticationFailed',
          'request_id': 'auth_req_12345',
        };

        final error = ApiErrorResponse.fromJson(json);

        expect(error.code, 'authentication_failed');
        expect(error.userMessageKey, 'errorAuthenticationFailed');
        expect(error.requestId, 'auth_req_12345');
      });

      test('authorization error with permission details', () {
        final json = {
          'code': 'forbidden',
          'message': 'Insufficient permissions to access resource',
          'user_message_key': 'errorForbidden',
          'details': {
            'required_permission': 'admin',
            'user_role': 'user',
            'resource': 'novel_123',
          },
        };

        final error = ApiErrorResponse.fromJson(json);

        expect(error.code, 'forbidden');
        expect(error.details, isNotNull);
        expect(error.details!['required_permission'], 'admin');
        expect(error.details!['user_role'], 'user');
      });
    });
  });
}
