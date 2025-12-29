import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/token_usage.dart';

void main() {
  group('TokenUsageRecord', () {
    test('creates TokenUsageRecord with required fields', () {
      final record = TokenUsageRecord(
        operationType: 'completion',
        modelName: 'gpt-4',
        inputTokens: 100,
        outputTokens: 50,
      );

      expect(record.operationType, 'completion');
      expect(record.modelName, 'gpt-4');
      expect(record.inputTokens, 100);
      expect(record.outputTokens, 50);
      expect(record.requestId, null);
      expect(record.metadata, null);
      expect(record.createdAt, null);
      expect(record.totalTokens, 150);
    });

    test('creates TokenUsageRecord with all fields', () {
      final createdAt = DateTime.parse('2024-01-15T10:30:00Z');
      final metadata = {'prompt_length': 200, 'temperature': 0.7};

      final record = TokenUsageRecord(
        operationType: 'chat',
        modelName: 'gpt-3.5-turbo',
        inputTokens: 200,
        outputTokens: 75,
        requestId: 'req-123',
        metadata: metadata,
        createdAt: createdAt,
      );

      expect(record.operationType, 'chat');
      expect(record.modelName, 'gpt-3.5-turbo');
      expect(record.inputTokens, 200);
      expect(record.outputTokens, 75);
      expect(record.requestId, 'req-123');
      expect(record.metadata, metadata);
      expect(record.createdAt, createdAt);
      expect(record.totalTokens, 275);
    });

    test('fromJson creates TokenUsageRecord correctly', () {
      final json = {
        'operation_type': 'completion',
        'model_name': 'gpt-4',
        'input_tokens': 150,
        'output_tokens': 75,
        'request_id': 'req-456',
        'metadata': {'type': 'text_completion'},
        'created_at': '2024-01-20T14:45:30Z',
      };

      final record = TokenUsageRecord.fromJson(json);

      expect(record.operationType, 'completion');
      expect(record.modelName, 'gpt-4');
      expect(record.inputTokens, 150);
      expect(record.outputTokens, 75);
      expect(record.requestId, 'req-456');
      expect(record.metadata, {'type': 'text_completion'});
      expect(record.createdAt, DateTime.parse('2024-01-20T14:45:30Z'));
      expect(record.totalTokens, 225);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'operation_type': 'embedding',
        'model_name': 'text-embedding-ada-002',
        'input_tokens': 500,
        'output_tokens': 0,
      };

      final record = TokenUsageRecord.fromJson(json);

      expect(record.operationType, 'embedding');
      expect(record.modelName, 'text-embedding-ada-002');
      expect(record.inputTokens, 500);
      expect(record.outputTokens, 0);
      expect(record.requestId, null);
      expect(record.metadata, null);
      expect(record.createdAt, null);
      expect(record.totalTokens, 500);
    });

    test('totalTokens calculates sum correctly', () {
      final record = TokenUsageRecord(
        operationType: 'completion',
        modelName: 'gpt-4',
        inputTokens: 0,
        outputTokens: 0,
      );

      expect(record.totalTokens, 0);

      // Test with different values
      final record2 = TokenUsageRecord(
        operationType: 'completion',
        modelName: 'gpt-4',
        inputTokens: 1000,
        outputTokens: 2000,
      );

      expect(record2.totalTokens, 3000);
    });
  });

  group('TokenUsage', () {
    test('creates TokenUsage with required fields', () {
      final usage = TokenUsage(
        userId: 'user-123',
        year: 2024,
        month: 1,
        inputTokens: 1000,
        outputTokens: 500,
        totalTokens: 1500,
        requestCount: 25,
      );

      expect(usage.userId, 'user-123');
      expect(usage.year, 2024);
      expect(usage.month, 1);
      expect(usage.inputTokens, 1000);
      expect(usage.outputTokens, 500);
      expect(usage.totalTokens, 1500);
      expect(usage.requestCount, 25);
    });

    test('fromJson creates TokenUsage correctly', () {
      final json = {
        'user_id': 'user-456',
        'year': 2024,
        'month': 2,
        'input_tokens': 2000,
        'output_tokens': 1000,
        'total_tokens': 3000,
        'request_count': 50,
      };

      final usage = TokenUsage.fromJson(json);

      expect(usage.userId, 'user-456');
      expect(usage.year, 2024);
      expect(usage.month, 2);
      expect(usage.inputTokens, 2000);
      expect(usage.outputTokens, 1000);
      expect(usage.totalTokens, 3000);
      expect(usage.requestCount, 50);
    });

    test('fromJson handles zero values', () {
      final json = {
        'user_id': 'user-789',
        'year': 2024,
        'month': 3,
        'input_tokens': 0,
        'output_tokens': 0,
        'total_tokens': 0,
        'request_count': 0,
      };

      final usage = TokenUsage.fromJson(json);

      expect(usage.userId, 'user-789');
      expect(usage.year, 2024);
      expect(usage.month, 3);
      expect(usage.inputTokens, 0);
      expect(usage.outputTokens, 0);
      expect(usage.totalTokens, 0);
      expect(usage.requestCount, 0);
    });
  });

  group('TokenUsageHistory', () {
    test('creates TokenUsageHistory with records and count', () {
      final records = [
        TokenUsageRecord(
          operationType: 'completion',
          modelName: 'gpt-4',
          inputTokens: 100,
          outputTokens: 50,
        ),
        TokenUsageRecord(
          operationType: 'chat',
          modelName: 'gpt-3.5-turbo',
          inputTokens: 200,
          outputTokens: 75,
        ),
      ];

      final history = TokenUsageHistory(records: records, totalCount: 150);

      expect(history.records.length, 2);
      expect(history.totalCount, 150);
      expect(history.records[0].modelName, 'gpt-4');
      expect(history.records[1].modelName, 'gpt-3.5-turbo');
    });

    test('fromJson creates TokenUsageHistory correctly', () {
      final json = {
        'records': [
          {
            'operation_type': 'completion',
            'model_name': 'gpt-4',
            'input_tokens': 150,
            'output_tokens': 75,
            'created_at': '2024-01-20T10:00:00Z',
          },
          {
            'operation_type': 'chat',
            'model_name': 'gpt-3.5-turbo',
            'input_tokens': 200,
            'output_tokens': 100,
            'metadata': {'conversation_id': 'conv-123'},
          },
        ],
        'total_count': 500,
      };

      final history = TokenUsageHistory.fromJson(json);

      expect(history.records.length, 2);
      expect(history.totalCount, 500);

      final firstRecord = history.records[0];
      expect(firstRecord.operationType, 'completion');
      expect(firstRecord.modelName, 'gpt-4');
      expect(firstRecord.inputTokens, 150);
      expect(firstRecord.outputTokens, 75);
      expect(firstRecord.createdAt, DateTime.parse('2024-01-20T10:00:00Z'));

      final secondRecord = history.records[1];
      expect(secondRecord.operationType, 'chat');
      expect(secondRecord.modelName, 'gpt-3.5-turbo');
      expect(secondRecord.inputTokens, 200);
      expect(secondRecord.outputTokens, 100);
      expect(secondRecord.metadata, {'conversation_id': 'conv-123'});
    });

    test('fromJson handles empty records list', () {
      final json = {'records': [], 'total_count': 0};

      final history = TokenUsageHistory.fromJson(json);

      expect(history.records.isEmpty, true);
      expect(history.totalCount, 0);
    });

    test('fromJson handles missing optional fields in records', () {
      final json = {
        'records': [
          {
            'operation_type': 'embedding',
            'model_name': 'text-embedding-ada-002',
            'input_tokens': 500,
            'output_tokens': 0,
          },
        ],
        'total_count': 100,
      };

      final history = TokenUsageHistory.fromJson(json);

      expect(history.records.length, 1);
      expect(history.totalCount, 100);

      final record = history.records[0];
      expect(record.operationType, 'embedding');
      expect(record.modelName, 'text-embedding-ada-002');
      expect(record.inputTokens, 500);
      expect(record.outputTokens, 0);
      expect(record.requestId, null);
      expect(record.metadata, null);
      expect(record.createdAt, null);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('TokenUsageRecord.fromJson throws on invalid date format', () {
      final json = {
        'operation_type': 'completion',
        'model_name': 'gpt-4',
        'input_tokens': 100,
        'output_tokens': 50,
        'created_at': 'invalid-date',
      };

      expect(
        () => TokenUsageRecord.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('TokenUsage.fromJson handles type casting', () {
      final json = {
        'user_id': 'user-123',
        'year': '2024', // String instead of int
        'month': '1', // String instead of int
        'input_tokens': '1000', // String instead of int
        'output_tokens': '500', // String instead of int
        'total_tokens': '1500', // String instead of int
        'request_count': '25', // String instead of int
      };

      expect(() => TokenUsage.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('TokenUsageHistory.fromJson handles missing records field', () {
      final json = {'total_count': 50};

      expect(() => TokenUsageHistory.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
