import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/token_usage.dart';

void main() {
  group('TokenUsage', () {
    test('fromJson creates correct instance', () {
      final json = {
        'user_id': 'user-123',
        'year': 2024,
        'month': 12,
        'input_tokens': 100,
        'output_tokens': 200,
        'total_tokens': 300,
        'request_count': 5,
      };

      final usage = TokenUsage.fromJson(json);

      expect(usage.userId, 'user-123');
      expect(usage.year, 2024);
      expect(usage.month, 12);
      expect(usage.inputTokens, 100);
      expect(usage.outputTokens, 200);
      expect(usage.totalTokens, 300);
      expect(usage.requestCount, 5);
    });

    test('constructor properties are set correctly', () {
      final usage = TokenUsage(
        userId: 'user-123',
        year: 2024,
        month: 12,
        inputTokens: 100,
        outputTokens: 200,
        totalTokens: 300,
        requestCount: 5,
      );

      expect(usage.userId, 'user-123');
      expect(usage.year, 2024);
      expect(usage.month, 12);
      expect(usage.inputTokens, 100);
      expect(usage.outputTokens, 200);
      expect(usage.totalTokens, 300);
      expect(usage.requestCount, 5);
    });
  });
}
