import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('getDelay should return initialDelay for 0 or less retries', () {
      expect(RetryPolicy.getDelay(0), RetryPolicy.initialDelay);
      expect(RetryPolicy.getDelay(-1), RetryPolicy.initialDelay);
    });

    test('getDelay should apply exponential backoff', () {
      expect(RetryPolicy.getDelay(1), RetryPolicy.initialDelay * 2);
      expect(RetryPolicy.getDelay(2), RetryPolicy.initialDelay * 4);
      expect(RetryPolicy.getDelay(3), RetryPolicy.initialDelay * 8);
    });

    test('getDelay should cap at maxDelay', () {
      // Assuming maxDelay is reached eventually
      // We can't easily test exact cap without knowing exact constants,
      // but we can test it doesn't exceed maxDelay
      final hugeDelay = RetryPolicy.getDelay(100);
      expect(hugeDelay, lessThanOrEqualTo(RetryPolicy.maxDelay));
    });

    test('canRetry should return true if count < maxRetries', () {
      expect(RetryPolicy.canRetry(0), true);
      expect(RetryPolicy.canRetry(RetryPolicy.maxRetries - 1), true);
    });

    test('canRetry should return false if count >= maxRetries', () {
      expect(RetryPolicy.canRetry(RetryPolicy.maxRetries), false);
      expect(RetryPolicy.canRetry(RetryPolicy.maxRetries + 1), false);
    });

    test('shouldAbandon should return true if count >= maxRetries', () {
      expect(RetryPolicy.shouldAbandon(RetryPolicy.maxRetries), true);
    });

    test('shouldAbandon should return false if count < maxRetries', () {
      expect(RetryPolicy.shouldAbandon(RetryPolicy.maxRetries - 1), false);
    });
  });
}
