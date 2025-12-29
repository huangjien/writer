class RetryPolicy {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 2);
  static const Duration maxDelay = Duration(minutes: 5);

  /// Get delay for retry based on retry count
  /// Uses exponential backoff: delay = initialDelay * 2^retryCount
  static Duration getDelay(int retryCount) {
    if (retryCount <= 0) return initialDelay;

    final delay = initialDelay * (1 << retryCount); // 2^retryCount
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Check if retry is allowed
  static bool canRetry(int retryCount) {
    return retryCount < maxRetries;
  }

  /// Check if operation should be abandoned
  static bool shouldAbandon(int retryCount) {
    return retryCount >= maxRetries;
  }
}
