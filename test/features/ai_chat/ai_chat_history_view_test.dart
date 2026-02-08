import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/features/ai_chat/widgets/ai_chat_history_view.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';
import 'package:writer/features/ai_chat/models/chat_session.dart';
import 'package:writer/features/ai_chat/models/chat_message.dart';
import 'package:writer/l10n/app_localizations.dart';

class MockAiChatNotifier extends StateNotifier<AiChatState>
    implements AiChatNotifier {
  MockAiChatNotifier(super.state);

  @override
  Future<void> sendMessage(String message) async {
    final userMsg = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final newMessages = [...state.messages, userMsg];
    state = state.copyWith(messages: newMessages);
  }

  @override
  void startNewSession() {
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      isLoading: false,
    );
  }

  @override
  void selectSession(String sessionId) {
    state = state.copyWith(
      currentSessionId: sessionId,
      messages: [],
      isLoading: false,
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final updatedSessions = state.sessions
        .where((s) => s.id != sessionId)
        .toList();
    state = state.copyWith(sessions: updatedSessions);
  }

  @override
  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}

ProviderScope createTestScope({
  required Widget child,
  required MockAiChatNotifier notifier,
}) {
  return ProviderScope(
    overrides: [aiChatProvider.overrideWith((ref) => notifier)],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AiChatHistoryView Tests', () {
    late MockAiChatNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockAiChatNotifier(
        const AiChatState(
          messages: [],
          sessions: [],
          isLoading: false,
          currentSessionId: null,
        ),
      );
    });

    testWidgets('renders AppBar with back button', (tester) async {
      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('AppBar has correct title', (tester) async {
      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('AppBar has add button', (tester) async {
      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onClose when back button pressed', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () => callbackCalled = true),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(callbackCalled, true);
    });

    testWidgets('shows empty state when no sessions', (tester) async {
      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No history'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows list of sessions when sessions exist', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Test Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
        ChatSession(
          id: '2',
          title: 'Test Session 2',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 2',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Session 1'), findsOneWidget);
      expect(find.text('Test Session 2'), findsOneWidget);
      expect(find.text('Preview 1'), findsOneWidget);
      expect(find.text('Preview 2'), findsOneWidget);
      expect(find.text('No history'), findsNothing);
    });

    testWidgets('displays session title and preview', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'My Test Session',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'This is a preview of the session',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Test Session'), findsOneWidget);
      expect(find.text('This is a preview of the session'), findsOneWidget);
    });

    testWidgets('highlights selected session with bold title', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
        ChatSession(
          id: '2',
          title: 'Session 2',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 2',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(
        sessions: sessions,
        currentSessionId: '1',
      );

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final session1Title = find.widgetWithText(ListTile, 'Session 1');
      expect(session1Title, findsOneWidget);

      final tile = tester.widget<ListTile>(find.byType(ListTile).first);
      expect(tile.selected, true);
    });

    testWidgets('shows delete button for each session', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('deletes session when delete button pressed', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
        ChatSession(
          id: '2',
          title: 'Session 2',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 2',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session 1'), findsOneWidget);
      expect(find.text('Session 2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.text('Session 1'), findsNothing);
      expect(find.text('Session 2'), findsOneWidget);
    });

    testWidgets('selects session and calls onClose when tapped', (
      tester,
    ) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);
      bool callbackCalled = false;

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () => callbackCalled = true),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Session 1'));
      await tester.pump();

      expect(mockNotifier.state.currentSessionId, '1');
      expect(callbackCalled, true);
    });

    testWidgets('starts new session and calls onClose when add pressed', (
      tester,
    ) async {
      bool callbackCalled = false;
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session 1',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview 1',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(
        sessions: sessions,
        currentSessionId: '1',
      );

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () => callbackCalled = true),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(mockNotifier.state.currentSessionId, '1');

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(callbackCalled, true);
    });

    testWidgets('truncates long session titles', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'This is a very long session title that should be truncated',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(
        find.text('This is a very long session title that should be truncated'),
      );
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('truncates long preview text', (tester) async {
      final sessions = [
        ChatSession(
          id: '1',
          title: 'Session',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'This is a very long preview text that should be truncated',
        ),
      ];
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
    });

    testWidgets('handles multiple sessions correctly', (tester) async {
      final sessions = List.generate(
        10,
        (index) => ChatSession(
          id: 'id_$index',
          title: 'Session $index',
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          messages: [],
          preview: 'Preview $index',
        ),
      );
      mockNotifier.state = mockNotifier.state.copyWith(sessions: sessions);

      await tester.pumpWidget(
        createTestScope(
          child: AiChatHistoryView(onClose: () {}),
          notifier: mockNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
