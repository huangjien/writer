import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/ai_chat/state/ai_chat_providers.dart';

class MockAiChatService extends Mock implements AiChatService {}

void main() {
  late MockAiChatService mockAiChatService;
  late ProviderContainer container;

  setUp(() {
    mockAiChatService = MockAiChatService();
    container = ProviderContainer(
      overrides: [aiChatServiceProvider.overrideWithValue(mockAiChatService)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AiChatNotifier', () {
    test('initial state is correct', () {
      final state = container.read(aiChatProvider);
      expect(state.messages, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('sendMessage with empty message does nothing', () async {
      await container.read(aiChatProvider.notifier).sendMessage('');
      final state = container.read(aiChatProvider);
      expect(state.messages, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('sendMessage adds user message and AI response on success', () async {
      when(
        () => mockAiChatService.sendMessage(any()),
      ).thenAnswer((_) async => 'AI Response');

      final notifier = container.read(aiChatProvider.notifier);
      final future = notifier.sendMessage('Hello');

      // Check loading state immediately after call (might need pump if async gap)
      // Since it's a future, we can't easily check the intermediate state without listening
      // But we can check the final state.

      await future;

      final state = container.read(aiChatProvider);
      expect(state.messages.length, 2);
      expect(state.messages[0].content, 'Hello');
      expect(state.messages[0].isUser, isTrue);
      expect(state.messages[1].content, 'AI Response');
      expect(state.messages[1].isUser, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('sendMessage handles error', () async {
      when(
        () => mockAiChatService.sendMessage(any()),
      ).thenThrow(Exception('API Error'));

      await container.read(aiChatProvider.notifier).sendMessage('Hello');

      final state = container.read(aiChatProvider);
      expect(state.messages.length, 2);
      expect(state.messages[0].content, 'Hello');
      expect(state.messages[1].content, 'Error: Exception: API Error');
      expect(state.messages[1].isUser, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('clearMessages resets state', () async {
      when(
        () => mockAiChatService.sendMessage(any()),
      ).thenAnswer((_) async => 'AI Response');

      final notifier = container.read(aiChatProvider.notifier);
      await notifier.sendMessage('Hello');

      notifier.clearMessages();

      final state = container.read(aiChatProvider);
      expect(state.messages, isEmpty);
      expect(state.isLoading, isFalse);
    });

    group('RAG Search', () {
      test('calls ragSearch and updates state with results', () async {
        final ragResult = {
          'refined_query': 'refined hello',
          'results': [
            {
              'title': 'Doc 1',
              'type': 'novel',
              'score': 0.9,
              'content': 'Content 1',
            },
          ],
        };
        when(
          () => mockAiChatService.ragSearch(query: 'hello'),
        ).thenAnswer((_) async => ragResult);

        await container
            .read(aiChatProvider.notifier)
            .sendMessage('/search hello');

        final state = container.read(aiChatProvider);
        expect(state.messages.length, 2);
        expect(state.messages[0].content, '/search hello');
        expect(state.messages[1].content, contains('### RAG Search Results'));
        expect(
          state.messages[1].content,
          contains('Refined Query: "refined hello"'),
        );
        expect(
          state.messages[1].content,
          contains('**Doc 1** (novel) - 90.0%'),
        );
        expect(state.messages[1].content, contains('Content 1'));
        expect(state.isLoading, isFalse);
      });

      test('handles empty RAG results', () async {
        final ragResult = {'refined_query': 'refined hello', 'results': []};
        when(
          () => mockAiChatService.ragSearch(query: 'hello'),
        ).thenAnswer((_) async => ragResult);

        await container
            .read(aiChatProvider.notifier)
            .sendMessage('/search hello');

        final state = container.read(aiChatProvider);
        expect(state.messages[1].content, contains('No results found.'));
      });

      test('handles null RAG result (error case)', () async {
        when(
          () => mockAiChatService.ragSearch(query: 'hello'),
        ).thenAnswer((_) async => null);

        await container
            .read(aiChatProvider.notifier)
            .sendMessage('/search hello');

        final state = container.read(aiChatProvider);
        expect(
          state.messages[1].content,
          contains('Search Error: Exception: Search failed'),
        );
      });

      test('handles RAG exception', () async {
        when(
          () => mockAiChatService.ragSearch(query: 'hello'),
        ).thenThrow(Exception('RAG Error'));

        await container
            .read(aiChatProvider.notifier)
            .sendMessage('/search hello');

        final state = container.read(aiChatProvider);
        expect(
          state.messages[1].content,
          contains('Search Error: Exception: RAG Error'),
        );
      });
    });
  });

  group('AiChatUiNotifier', () {
    test('initial state is closed (false)', () {
      final state = container.read(aiChatUiProvider);
      expect(state, isFalse);
    });

    test('toggleSidebar switches state', () {
      final notifier = container.read(aiChatUiProvider.notifier);

      notifier.toggleSidebar();
      expect(container.read(aiChatUiProvider), isTrue);

      notifier.toggleSidebar();
      expect(container.read(aiChatUiProvider), isFalse);
    });

    test('openSidebar sets state to true', () {
      final notifier = container.read(aiChatUiProvider.notifier);
      notifier.openSidebar();
      expect(container.read(aiChatUiProvider), isTrue);

      // Should stay true
      notifier.openSidebar();
      expect(container.read(aiChatUiProvider), isTrue);
    });

    test('closeSidebar sets state to false', () {
      final notifier = container.read(aiChatUiProvider.notifier);
      notifier.openSidebar(); // First open it
      expect(container.read(aiChatUiProvider), isTrue);

      notifier.closeSidebar();
      expect(container.read(aiChatUiProvider), isFalse);

      // Should stay false
      notifier.closeSidebar();
      expect(container.read(aiChatUiProvider), isFalse);
    });
  });

  group('AiServiceStatusNotifier', () {
    test('initial check updates state', () async {
      // Create a new container to ensure the provider is initialized
      when(() => mockAiChatService.checkHealth()).thenAnswer((_) async => true);

      // Keep the provider alive since it is autoDispose
      final subscription = container.listen(aiServiceStatusProvider, (_, _) {});

      // Reading the provider triggers the initialization and the checkHealth call
      container.read(aiServiceStatusProvider.notifier);
      verify(() => mockAiChatService.checkHealth()).called(1);

      // Wait for the async operation to complete
      await Future.delayed(Duration.zero);

      expect(container.read(aiServiceStatusProvider), isTrue);
      subscription.close();
    });
  });
}
