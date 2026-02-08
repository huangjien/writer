import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/models/chat_message.dart';

void main() {
  group('ChatMessage Tests', () {
    test('creates ChatMessage with required fields', () {
      final message = ChatMessage(
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      expect(message.content, 'Test message');
      expect(message.isUser, true);
      expect(message.timestamp, DateTime(2024, 1, 1, 12, 0));
    });

    test('creates user message correctly', () {
      final message = ChatMessage(
        content: 'User input',
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(message.isUser, true);
    });

    test('creates assistant message correctly', () {
      final message = ChatMessage(
        content: 'Assistant response',
        isUser: false,
        timestamp: DateTime.now(),
      );

      expect(message.isUser, false);
    });

    test('handles empty content', () {
      final message = ChatMessage(
        content: '',
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(message.content, '');
    });

    test('handles long content', () {
      final longContent = 'A' * 10000;
      final message = ChatMessage(
        content: longContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      expect(message.content.length, 10000);
    });

    test('handles special characters in content', () {
      final specialContent = 'Test with emoji 😊 and symbols @#\$%';
      final message = ChatMessage(
        content: specialContent,
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(message.content, specialContent);
    });

    test('handles multiline content', () {
      final multilineContent = '''Line 1
Line 2
Line 3''';
      final message = ChatMessage(
        content: multilineContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      expect(message.content, multilineContent);
      expect(message.content.split('\n').length, 3);
    });

    test('creates messages with different timestamps', () {
      final time1 = DateTime(2024, 1, 1, 10, 0);
      final time2 = DateTime(2024, 1, 1, 11, 0);

      final message1 = ChatMessage(
        content: 'First',
        isUser: true,
        timestamp: time1,
      );

      final message2 = ChatMessage(
        content: 'Second',
        isUser: true,
        timestamp: time2,
      );

      expect(message1.timestamp.isBefore(message2.timestamp), true);
    });

    test('handles unicode content', () {
      final unicodeContent = 'Hello 世界 🌍';
      final message = ChatMessage(
        content: unicodeContent,
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(message.content, unicodeContent);
    });

    test('creates message with UTC timestamp', () {
      final utcTime = DateTime.utc(2024, 1, 1, 12, 0);
      final message = ChatMessage(
        content: 'UTC message',
        isUser: false,
        timestamp: utcTime,
      );

      expect(message.timestamp, utcTime);
      expect(message.timestamp.isUtc, true);
    });

    test('serializes to JSON correctly', () {
      final message = ChatMessage(
        content: 'Test message',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      final json = message.toJson();

      expect(json['content'], 'Test message');
      expect(json['isUser'], true);
      expect(json['timestamp'], '2024-01-01T12:00:00.000');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'content': 'Test message',
        'isUser': false,
        'timestamp': '2024-01-01T12:00:00.000',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.content, 'Test message');
      expect(message.isUser, false);
      expect(message.timestamp, DateTime(2024, 1, 1, 12, 0));
    });

    test('serializes and deserializes roundtrip', () {
      final original = ChatMessage(
        content: 'Roundtrip test',
        isUser: true,
        timestamp: DateTime(2024, 1, 1, 12, 0),
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.content, original.content);
      expect(restored.isUser, original.isUser);
      expect(restored.timestamp, original.timestamp);
    });

    test('uses current time when timestamp is null', () {
      final before = DateTime.now();
      final message = ChatMessage(content: 'No timestamp', isUser: true);
      final after = DateTime.now();

      expect(
        message.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        message.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });
  });
}
