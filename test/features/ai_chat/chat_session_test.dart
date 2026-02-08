import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/models/chat_session.dart';
import 'package:writer/features/ai_chat/models/chat_message.dart';

void main() {
  group('ChatSession Tests', () {
    test('creates ChatSession with required fields', () {
      final session = ChatSession(
        id: 'test-id',
        title: 'Test Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Preview text',
      );

      expect(session.id, 'test-id');
      expect(session.title, 'Test Session');
      expect(session.preview, 'Preview text');
      expect(session.messages, isEmpty);
    });

    test('creates session with messages', () {
      final messages = [
        ChatMessage(
          content: 'Hello',
          isUser: true,
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
        ChatMessage(
          content: 'Hi there',
          isUser: false,
          timestamp: DateTime(2024, 1, 1, 10, 1),
        ),
      ];

      final session = ChatSession(
        id: 'session-1',
        title: 'Chat',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: messages,
        preview: 'Hello',
      );

      expect(session.messages.length, 2);
      expect(session.messages.first.content, 'Hello');
      expect(session.messages.last.content, 'Hi there');
    });

    test('handles empty messages list', () {
      final session = ChatSession(
        id: 'empty-session',
        title: 'Empty',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: '',
      );

      expect(session.messages, isEmpty);
    });

    test('handles long title', () {
      final longTitle = 'A' * 200;
      final session = ChatSession(
        id: 'test-id',
        title: longTitle,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: 'Preview',
      );

      expect(session.title.length, 200);
    });

    test('handles long preview', () {
      final longPreview = 'B' * 500;
      final session = ChatSession(
        id: 'test-id',
        title: 'Session',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: longPreview,
      );

      expect(session.preview.length, 500);
    });

    test('handles empty preview', () {
      final session = ChatSession(
        id: 'test-id',
        title: 'Session',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: '',
      );

      expect(session.preview, '');
    });

    test('handles special characters in title', () {
      final specialTitle = 'Chat: "Test" & Review 😊';
      final session = ChatSession(
        id: 'test-id',
        title: specialTitle,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: 'Preview',
      );

      expect(session.title, specialTitle);
    });

    test('handles special characters in preview', () {
      final specialPreview = 'User said: "Hello @user #tag" 🎉';
      final session = ChatSession(
        id: 'test-id',
        title: 'Session',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: specialPreview,
      );

      expect(session.preview, specialPreview);
    });

    test('creates session with UUID as id', () {
      final uuid = '123e4567-e89b-12d3-a456-426614174000';
      final session = ChatSession(
        id: uuid,
        title: 'UUID Session',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: 'Preview',
      );

      expect(session.id, uuid);
    });

    test('handles session with many messages', () {
      final messages = List.generate(
        100,
        (index) => ChatMessage(
          content: 'Message $index',
          isUser: index % 2 == 0,
          timestamp: DateTime(2024, 1, 1, 0, 0).add(Duration(minutes: index)),
        ),
      );

      final session = ChatSession(
        id: 'busy-session',
        title: 'Busy Chat',
        createdAt: DateTime(2024, 1, 1, 0, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 1, 40),
        messages: messages,
        preview: 'Message 0',
      );

      expect(session.messages.length, 100);
      expect(session.messages.first.content, 'Message 0');
      expect(session.messages.last.content, 'Message 99');
    });

    test('handles timestamps correctly', () {
      final created = DateTime(2024, 1, 1, 10, 0);
      final updated = DateTime(2024, 1, 1, 11, 30);

      final session = ChatSession(
        id: 'time-session',
        title: 'Time Test',
        createdAt: created,
        lastUpdatedAt: updated,
        messages: [],
        preview: 'Preview',
      );

      expect(session.createdAt, created);
      expect(session.lastUpdatedAt, updated);
      expect(session.lastUpdatedAt.isAfter(session.createdAt), true);
    });

    test('handles session with same created and updated time', () {
      final time = DateTime(2024, 1, 1, 10, 0);
      final session = ChatSession(
        id: 'new-session',
        title: 'New Session',
        createdAt: time,
        lastUpdatedAt: time,
        messages: [],
        preview: 'Preview',
      );

      expect(session.createdAt, session.lastUpdatedAt);
    });

    test('handles unicode in title and preview', () {
      final session = ChatSession(
        id: 'unicode-session',
        title: '对话标题 🌍',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: '用户说: 你好世界 👋',
      );

      expect(session.title, '对话标题 🌍');
      expect(session.preview, '用户说: 你好世界 👋');
    });

    test('handles multiline preview', () {
      final multilinePreview = '''First line
Second line
Third line''';
      final session = ChatSession(
        id: 'multiline-session',
        title: 'Multiline',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: multilinePreview,
      );

      expect(session.preview, multilinePreview);
      expect(session.preview.split('\n').length, 3);
    });

    test('creates sessions with different ids', () {
      final session1 = ChatSession(
        id: 'id-1',
        title: 'Session 1',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: 'Preview 1',
      );

      final session2 = ChatSession(
        id: 'id-2',
        title: 'Session 2',
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messages: [],
        preview: 'Preview 2',
      );

      expect(session1.id, isNot(session2.id));
    });

    test('serializes to JSON correctly', () {
      final messages = [
        ChatMessage(
          content: 'Hello',
          isUser: true,
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
        ChatMessage(
          content: 'Hi there',
          isUser: false,
          timestamp: DateTime(2024, 1, 1, 10, 1),
        ),
      ];

      final session = ChatSession(
        id: 'session-id',
        title: 'Test Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 30),
        messages: messages,
        preview: 'Preview text',
      );

      final json = session.toJson();

      expect(json['id'], 'session-id');
      expect(json['title'], 'Test Session');
      expect(json['createdAt'], '2024-01-01T10:00:00.000');
      expect(json['lastUpdatedAt'], '2024-01-01T11:30:00.000');
      expect(json['preview'], 'Preview text');
      expect(json['messages'], isList);
      expect(json['messages'].length, 2);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'session-id',
        'title': 'Test Session',
        'createdAt': '2024-01-01T10:00:00.000',
        'lastUpdatedAt': '2024-01-01T11:30:00.000',
        'messages': [
          {
            'content': 'Hello',
            'isUser': true,
            'timestamp': '2024-01-01T10:00:00.000',
          },
          {
            'content': 'Hi there',
            'isUser': false,
            'timestamp': '2024-01-01T10:01:00.000',
          },
        ],
        'preview': 'Preview text',
      };

      final session = ChatSession.fromJson(json);

      expect(session.id, 'session-id');
      expect(session.title, 'Test Session');
      expect(session.preview, 'Preview text');
      expect(session.messages.length, 2);
      expect(session.messages.first.content, 'Hello');
      expect(session.messages.last.content, 'Hi there');
    });

    test('serializes and deserializes roundtrip', () {
      final original = ChatSession(
        id: 'session-id',
        title: 'Roundtrip Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 30),
        messages: [
          ChatMessage(
            content: 'Test',
            isUser: true,
            timestamp: DateTime(2024, 1, 1, 10, 0),
          ),
        ],
        preview: 'Preview',
      );

      final json = original.toJson();
      final restored = ChatSession.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.preview, original.preview);
      expect(restored.messages.length, original.messages.length);
      expect(restored.messages.first.content, original.messages.first.content);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = ChatSession(
        id: 'session-id',
        title: 'Original Title',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Original preview',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        preview: 'Updated preview',
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Updated Title');
      expect(updated.preview, 'Updated preview');
      expect(updated.createdAt, original.createdAt);
      expect(updated.lastUpdatedAt, original.lastUpdatedAt);
    });

    test('copyWith keeps original fields when not provided', () {
      final original = ChatSession(
        id: 'session-id',
        title: 'Original Title',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 30),
        messages: [],
        preview: 'Original preview',
      );

      final updated = original.copyWith();

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.preview, original.preview);
      expect(updated.createdAt, original.createdAt);
      expect(updated.lastUpdatedAt, original.lastUpdatedAt);
    });

    test('copyWith can update messages', () {
      final originalMessages = [
        ChatMessage(
          content: 'Original',
          isUser: true,
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
      ];

      final original = ChatSession(
        id: 'session-id',
        title: 'Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: originalMessages,
        preview: 'Preview',
      );

      final newMessages = [
        ChatMessage(
          content: 'New message',
          isUser: false,
          timestamp: DateTime(2024, 1, 1, 10, 1),
        ),
      ];

      final updated = original.copyWith(messages: newMessages);

      expect(updated.messages.length, 1);
      expect(updated.messages.first.content, 'New message');
      expect(original.messages.first.content, 'Original');
    });
  });
}
