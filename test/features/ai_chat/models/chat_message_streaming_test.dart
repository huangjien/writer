import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/models/chat_message.dart';

void main() {
  group('ChatMessage Streaming Tests', () {
    test('creates message with streaming enabled', () {
      final message = ChatMessage(
        content: 'Test content',
        isUser: false,
        isStreaming: true,
      );

      expect(message.isStreaming, true);
      expect(message.content, 'Test content');
      expect(message.isUser, false);
    });

    test('creates message with streaming disabled by default', () {
      final message = ChatMessage(content: 'Test content', isUser: false);

      expect(message.isStreaming, false);
    });

    test('copyWith updates streaming state', () {
      final original = ChatMessage(
        content: 'Original',
        isUser: false,
        isStreaming: true,
      );

      final updated = original.copyWith(isStreaming: false, content: 'Updated');

      expect(updated.isStreaming, false);
      expect(updated.content, 'Updated');
      expect(original.isStreaming, true);
      expect(original.content, 'Original');
    });

    test('copyWith preserves streaming when not specified', () {
      final original = ChatMessage(
        content: 'Test',
        isUser: false,
        isStreaming: true,
      );

      final copied = original.copyWith(content: 'Updated');

      expect(copied.isStreaming, true);
      expect(copied.content, 'Updated');
    });

    test('toJson includes streaming state', () {
      final message = ChatMessage(
        content: 'Test',
        isUser: false,
        isStreaming: true,
      );

      final json = message.toJson();

      expect(json['isStreaming'], true);
      expect(json['content'], 'Test');
    });

    test('fromJson deserializes streaming state', () {
      final json = {
        'content': 'Test',
        'isUser': false,
        'timestamp': '2025-01-01T00:00:00.000Z',
        'isStreaming': true,
      };

      final message = ChatMessage.fromJson(json);

      expect(message.isStreaming, true);
    });

    test('fromJson defaults streaming to false when missing', () {
      final json = {
        'content': 'Test',
        'isUser': false,
        'timestamp': '2025-01-01T00:00:00.000Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.isStreaming, false);
    });

    test('handles streaming user messages', () {
      final userMessage = ChatMessage(
        content: 'User input',
        isUser: true,
        isStreaming: false,
      );

      expect(userMessage.isUser, true);
      expect(userMessage.isStreaming, false);
    });

    test('handles streaming AI messages', () {
      final aiMessage = ChatMessage(
        content: 'AI response',
        isUser: false,
        isStreaming: true,
      );

      expect(aiMessage.isUser, false);
      expect(aiMessage.isStreaming, true);
    });
  });

  group('ChatMessage Streaming Scenarios', () {
    test('simulates streaming message update', () {
      final chunks = ['Hello', ' world', '!'];

      var message = ChatMessage(content: '', isUser: false, isStreaming: true);

      for (final chunk in chunks) {
        message = message.copyWith(content: message.content + chunk);
      }

      expect(message.content, 'Hello world!');
      expect(message.isStreaming, true);
    });

    test('completes streaming message', () {
      final streaming = ChatMessage(
        content: 'Partial',
        isUser: false,
        isStreaming: true,
      );

      final completed = streaming.copyWith(
        content: 'Complete',
        isStreaming: false,
      );

      expect(completed.content, 'Complete');
      expect(completed.isStreaming, false);
      expect(streaming.isStreaming, true);
    });

    test('handles empty streaming message', () {
      final empty = ChatMessage(content: '', isUser: false, isStreaming: true);

      expect(empty.content, '');
      expect(empty.isStreaming, true);
    });

    test('handles whitespace in streaming message', () {
      final whitespace = ChatMessage(
        content: '   ',
        isUser: false,
        isStreaming: true,
      );

      expect(whitespace.content, '   ');
      expect(whitespace.isStreaming, true);
    });
  });

  group('ChatMessage Equality with Streaming', () {
    test('messages with different streaming states are not equal', () {
      final streaming = ChatMessage(
        content: 'Same content',
        isUser: false,
        isStreaming: true,
      );

      final completed = ChatMessage(
        content: 'Same content',
        isUser: false,
        isStreaming: false,
      );

      expect(streaming == completed, false);
    });

    test('messages with same streaming state are equal', () {
      final message1 = ChatMessage(
        content: 'Content',
        isUser: false,
        isStreaming: true,
      );

      final message2 = ChatMessage(
        content: 'Content',
        isUser: false,
        isStreaming: true,
      );

      expect(message1 == message2, true);
    });
  });
}
