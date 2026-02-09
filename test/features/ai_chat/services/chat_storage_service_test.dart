import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/models/chat_message.dart';
import 'package:writer/features/ai_chat/models/chat_session.dart';
import 'package:writer/features/ai_chat/services/chat_storage_service.dart';

void main() {
  group('ChatStorageService', () {
    late SharedPreferences prefs;
    late ChatStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = ChatStorageService(prefs);
    });

    test('loadSessions returns empty list when no data stored', () {
      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('loadSessions returns empty list after clearing', () async {
      final session = ChatSession(
        id: 'test-id',
        title: 'Test Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Preview',
      );
      await storage.saveSessions([session]);
      await prefs.remove('ai_chat_sessions');

      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('loadSessions returns empty list on invalid JSON', () async {
      await prefs.setString('ai_chat_sessions', 'invalid json{{}');

      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('loadSessions returns empty list on non-Array JSON', () async {
      await prefs.setString('ai_chat_sessions', jsonEncode({'key': 'value'}));

      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('saveSessions stores sessions correctly', () async {
      final session = ChatSession(
        id: 'test-id',
        title: 'Test Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Preview',
      );

      await storage.saveSessions([session]);

      final jsonString = prefs.getString('ai_chat_sessions');
      expect(jsonString, isNotNull);
      final json = jsonDecode(jsonString!);
      expect(json, isList);
      expect(json.length, 1);
      expect(json[0]['id'], 'test-id');
      expect(json[0]['title'], 'Test Session');
    });

    test('saveSessions overwrites existing data', () async {
      final session1 = ChatSession(
        id: 'id-1',
        title: 'Session 1',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Preview 1',
      );

      await storage.saveSessions([session1]);

      final session2 = ChatSession(
        id: 'id-2',
        title: 'Session 2',
        createdAt: DateTime(2024, 1, 1, 11, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 0),
        messages: [],
        preview: 'Preview 2',
      );

      await storage.saveSessions([session2]);

      final sessions = storage.loadSessions();
      expect(sessions.length, 1);
      expect(sessions[0].id, 'id-2');
    });

    test('saveSessions and loadSessions roundtrip', () async {
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

      final original = ChatSession(
        id: 'session-id',
        title: 'Roundtrip Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 30),
        messages: messages,
        preview: 'Preview',
      );

      await storage.saveSessions([original]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      final restored = loaded[0];
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.preview, original.preview);
      expect(restored.createdAt, original.createdAt);
      expect(restored.lastUpdatedAt, original.lastUpdatedAt);
      expect(restored.messages.length, original.messages.length);
      expect(restored.messages[0].content, original.messages[0].content);
      expect(restored.messages[1].content, original.messages[1].content);
    });

    test('saveSessions handles multiple sessions', () async {
      final sessions = [
        ChatSession(
          id: 'id-1',
          title: 'Session 1',
          createdAt: DateTime(2024, 1, 1, 10, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
          messages: [],
          preview: 'Preview 1',
        ),
        ChatSession(
          id: 'id-2',
          title: 'Session 2',
          createdAt: DateTime(2024, 1, 1, 11, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 11, 0),
          messages: [],
          preview: 'Preview 2',
        ),
        ChatSession(
          id: 'id-3',
          title: 'Session 3',
          createdAt: DateTime(2024, 1, 1, 12, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 12, 0),
          messages: [],
          preview: 'Preview 3',
        ),
      ];

      await storage.saveSessions(sessions);
      final loaded = storage.loadSessions();

      expect(loaded.length, 3);
      expect(loaded[0].id, 'id-1');
      expect(loaded[1].id, 'id-2');
      expect(loaded[2].id, 'id-3');
    });

    test('saveSessions preserves session order', () async {
      final sessions = [
        ChatSession(
          id: 'first',
          title: 'First',
          createdAt: DateTime(2024, 1, 1, 10, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
          messages: [],
          preview: 'First',
        ),
        ChatSession(
          id: 'second',
          title: 'Second',
          createdAt: DateTime(2024, 1, 1, 11, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 11, 0),
          messages: [],
          preview: 'Second',
        ),
        ChatSession(
          id: 'third',
          title: 'Third',
          createdAt: DateTime(2024, 1, 1, 12, 0),
          lastUpdatedAt: DateTime(2024, 1, 1, 12, 0),
          messages: [],
          preview: 'Third',
        ),
      ];

      await storage.saveSessions(sessions);
      final loaded = storage.loadSessions();

      expect(loaded[0].id, 'first');
      expect(loaded[1].id, 'second');
      expect(loaded[2].id, 'third');
    });

    test('saveSessions handles sessions with special characters', () async {
      final session = ChatSession(
        id: 'special-id',
        title: '对话标题 "测试" & Review 😊',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: '用户说: "Hello @user #tag" 🎉\nNew line',
      );

      await storage.saveSessions([session]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      expect(loaded[0].title, session.title);
      expect(loaded[0].preview, session.preview);
    });

    test('saveSessions handles sessions with many messages', () async {
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

      await storage.saveSessions([session]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      expect(loaded[0].messages.length, 100);
      expect(loaded[0].messages.first.content, 'Message 0');
      expect(loaded[0].messages.last.content, 'Message 99');
    });

    test('saveSessions handles empty list', () async {
      await storage.saveSessions([]);

      final jsonString = prefs.getString('ai_chat_sessions');
      expect(jsonString, isNotNull);
      final json = jsonDecode(jsonString!);
      expect(json, isList);
      expect(json, isEmpty);
    });

    test('loadSessions handles empty list', () async {
      await storage.saveSessions([]);

      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('loadSessions handles partially valid data', () async {
      final validSession = ChatSession(
        id: 'valid-id',
        title: 'Valid Session',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Valid',
      );

      final jsonData = jsonEncode([
        validSession.toJson(),
        {'invalid': 'data'},
      ]);
      await prefs.setString('ai_chat_sessions', jsonData);

      final sessions = storage.loadSessions();
      expect(sessions, isEmpty);
    });

    test('saveSessions preserves datetime precision', () async {
      final createdAt = DateTime(2024, 1, 1, 10, 30, 45, 123);
      final updatedAt = DateTime(2024, 1, 1, 11, 45, 30, 456);

      final session = ChatSession(
        id: 'time-session',
        title: 'Time Test',
        createdAt: createdAt,
        lastUpdatedAt: updatedAt,
        messages: [],
        preview: 'Preview',
      );

      await storage.saveSessions([session]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      expect(loaded[0].createdAt, createdAt);
      expect(loaded[0].lastUpdatedAt, updatedAt);
    });

    test('saveSessions handles sessions with null-like values', () async {
      final session = ChatSession(
        id: 'null-test',
        title: '',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: '',
      );

      await storage.saveSessions([session]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      expect(loaded[0].title, '');
      expect(loaded[0].preview, '');
    });

    test('saveSessions can be called multiple times', () async {
      final session1 = ChatSession(
        id: 'id-1',
        title: 'Session 1',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: [],
        preview: 'Preview 1',
      );

      await storage.saveSessions([session1]);

      final session2 = ChatSession(
        id: 'id-2',
        title: 'Session 2',
        createdAt: DateTime(2024, 1, 1, 11, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 11, 0),
        messages: [],
        preview: 'Preview 2',
      );

      await storage.saveSessions([session2]);

      final sessions = storage.loadSessions();
      expect(sessions.length, 1);
      expect(sessions[0].id, 'id-2');
    });

    test('saveSessions handles large session data', () async {
      final longTitle = 'A' * 200;
      final longPreview = 'B' * 500;
      final manyMessages = List.generate(
        50,
        (index) => ChatMessage(
          content: 'x' * 100,
          isUser: index % 2 == 0,
          timestamp: DateTime(2024, 1, 1).add(Duration(seconds: index)),
        ),
      );

      final session = ChatSession(
        id: 'large-session',
        title: longTitle,
        createdAt: DateTime(2024, 1, 1, 10, 0),
        lastUpdatedAt: DateTime(2024, 1, 1, 10, 0),
        messages: manyMessages,
        preview: longPreview,
      );

      await storage.saveSessions([session]);
      final loaded = storage.loadSessions();

      expect(loaded.length, 1);
      expect(loaded[0].title.length, 200);
      expect(loaded[0].preview.length, 500);
      expect(loaded[0].messages.length, 50);
    });
  });
}
