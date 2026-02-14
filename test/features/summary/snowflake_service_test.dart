import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/summary/services/snowflake_service.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/snowflake.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  group('SnowflakeService', () {
    late MockRemoteRepository mockRemote;
    late SnowflakeService snowflakeService;

    setUp(() {
      mockRemote = MockRemoteRepository();
      snowflakeService = SnowflakeService(mockRemote);
    });

    group('refineSummary', () {
      test(
        'returns SnowflakeRefinementOutput when API call succeeds',
        () async {
          const input = SnowflakeRefinementInput(
            novelId: 'novel-123',
            summaryType: 'chapter',
            summaryContent: 'Test summary',
            language: 'en',
          );

          const mockResponse = {
            'novel_id': 'novel-123',
            'summary_content': 'Refined summary',
            'status': 'completed',
            'ai_question': 'What do you think?',
            'suggestions': ['Suggestion 1', 'Suggestion 2'],
            'critique': 'Good job',
            'history': [
              {'role': 'user', 'content': 'User message'},
              {'role': 'assistant', 'content': 'Assistant message'},
            ],
          };

          when(
            () => mockRemote.post('snowflake/refine', input.toJson()),
          ).thenAnswer((_) async => mockResponse);

          final result = await snowflakeService.refineSummary(input);

          expect(result, isNotNull);
          expect(result!.novelId, 'novel-123');
          expect(result.summaryContent, 'Refined summary');
          expect(result.status, 'completed');
          expect(result.aiQuestion, 'What do you think?');
          expect(result.suggestions, ['Suggestion 1', 'Suggestion 2']);
          expect(result.critique, 'Good job');
          expect(result.history, [
            {'role': 'user', 'content': 'User message'},
            {'role': 'assistant', 'content': 'Assistant message'},
          ]);
          verify(
            () => mockRemote.post('snowflake/refine', input.toJson()),
          ).called(1);
        },
      );

      test('returns null when API returns non-map response', () async {
        const input = SnowflakeRefinementInput(
          novelId: 'novel-123',
          summaryType: 'chapter',
          summaryContent: 'Test summary',
        );

        when(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).thenAnswer((_) async => 'string response');

        final result = await snowflakeService.refineSummary(input);

        expect(result, isNull);
        verify(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).called(1);
      });

      test('returns null when API call throws exception', () async {
        const input = SnowflakeRefinementInput(
          novelId: 'novel-123',
          summaryType: 'chapter',
          summaryContent: 'Test summary',
        );

        when(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).thenThrow(Exception('API error'));

        final result = await snowflakeService.refineSummary(input);

        expect(result, isNull);
        verify(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).called(1);
      });

      test('handles input with user response', () async {
        const input = SnowflakeRefinementInput(
          novelId: 'novel-123',
          summaryType: 'chapter',
          summaryContent: 'Test summary',
          userResponse: 'User feedback',
          language: 'zh',
        );

        const mockResponse = {
          'novel_id': 'novel-123',
          'summary_content': 'Refined summary',
          'status': 'completed',
        };

        when(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).thenAnswer((_) async => mockResponse);

        final result = await snowflakeService.refineSummary(input);

        expect(result, isNotNull);
        expect(result!.novelId, 'novel-123');
        expect(result.summaryContent, 'Refined summary');
        verify(
          () => mockRemote.post('snowflake/refine', input.toJson()),
        ).called(1);
      });
    });

    group('getChatHistory', () {
      test(
        'returns SnowflakeRefinementOutput when API call succeeds',
        () async {
          const mockResponse = {
            'novel_id': 'novel-456',
            'summary_content': 'Chat history summary',
            'status': 'completed',
            'history': [
              {'role': 'user', 'content': 'Hello'},
              {'role': 'assistant', 'content': 'Hi there!'},
            ],
          };

          when(
            () => mockRemote.get('snowflake/history/novel-456/chapter'),
          ).thenAnswer((_) async => mockResponse);

          final result = await snowflakeService.getChatHistory(
            'novel-456',
            'chapter',
          );

          expect(result, isNotNull);
          expect(result!.novelId, 'novel-456');
          expect(result.summaryContent, 'Chat history summary');
          expect(result.status, 'completed');
          expect(result.history, [
            {'role': 'user', 'content': 'Hello'},
            {'role': 'assistant', 'content': 'Hi there!'},
          ]);
          verify(
            () => mockRemote.get('snowflake/history/novel-456/chapter'),
          ).called(1);
        },
      );

      test('returns null when API returns non-map response', () async {
        when(
          () => mockRemote.get('snowflake/history/novel-456/chapter'),
        ).thenAnswer((_) async => ['array', 'response']);

        final result = await snowflakeService.getChatHistory(
          'novel-456',
          'chapter',
        );

        expect(result, isNull);
        verify(
          () => mockRemote.get('snowflake/history/novel-456/chapter'),
        ).called(1);
      });

      test('returns null when API call throws exception', () async {
        when(
          () => mockRemote.get('snowflake/history/novel-456/chapter'),
        ).thenThrow(Exception('Network error'));

        final result = await snowflakeService.getChatHistory(
          'novel-456',
          'chapter',
        );

        expect(result, isNull);
        verify(
          () => mockRemote.get('snowflake/history/novel-456/chapter'),
        ).called(1);
      });

      test('handles different summary types', () async {
        const mockResponse = {
          'novel_id': 'novel-789',
          'summary_content': 'Book summary',
          'status': 'completed',
        };

        when(
          () => mockRemote.get('snowflake/history/novel-789/book'),
        ).thenAnswer((_) async => mockResponse);

        final result = await snowflakeService.getChatHistory(
          'novel-789',
          'book',
        );

        expect(result, isNotNull);
        expect(result!.novelId, 'novel-789');
        expect(result.summaryContent, 'Book summary');
        verify(
          () => mockRemote.get('snowflake/history/novel-789/book'),
        ).called(1);
      });
    });

    group('provider', () {
      test('snowflakeServiceProvider provides SnowflakeService instance', () {
        final mockRemote = MockRemoteRepository();
        final container = ProviderContainer(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRemote)],
        );

        final service = container.read(snowflakeServiceProvider);

        expect(service, isA<SnowflakeService>());
        expect(service.remote, mockRemote);
        container.dispose();
      });
    });

    group('integration tests', () {
      test(
        'service works correctly with provider dependency injection',
        () async {
          const input = SnowflakeRefinementInput(
            novelId: 'novel-123',
            summaryType: 'chapter',
            summaryContent: 'Test summary',
          );

          const mockResponse = {
            'novel_id': 'novel-123',
            'summary_content': 'Refined summary',
            'status': 'completed',
          };

          final mockRemote = MockRemoteRepository();
          when(
            () => mockRemote.post('snowflake/refine', input.toJson()),
          ).thenAnswer((_) async => mockResponse);

          final container = ProviderContainer(
            overrides: [remoteRepositoryProvider.overrideWithValue(mockRemote)],
          );

          final service = container.read(snowflakeServiceProvider);
          final result = await service.refineSummary(input);

          expect(result, isNotNull);
          expect(result!.novelId, 'novel-123');
          verify(
            () => mockRemote.post('snowflake/refine', input.toJson()),
          ).called(1);

          container.dispose();
        },
      );
    });
  });
}
