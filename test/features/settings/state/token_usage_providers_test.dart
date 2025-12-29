import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/settings/state/token_usage_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

void main() {
  group('UsageHistoryParams', () {
    test('creates UsageHistoryParams with default values', () {
      final params = UsageHistoryParams();

      expect(params.startDate, null);
      expect(params.endDate, null);
      expect(params.limit, 100);
      expect(params.offset, 0);
    });

    test('creates UsageHistoryParams with custom values', () {
      final params = UsageHistoryParams(
        startDate: '2024-01-01',
        endDate: '2024-01-31',
        limit: 50,
        offset: 10,
      );

      expect(params.startDate, '2024-01-01');
      expect(params.endDate, '2024-01-31');
      expect(params.limit, 50);
      expect(params.offset, 10);
    });

    test('copyWith creates new instance with updated values', () {
      final originalParams = UsageHistoryParams(
        startDate: '2024-01-01',
        endDate: '2024-01-31',
        limit: 100,
        offset: 0,
      );

      final updatedParams = originalParams.copyWith(
        startDate: '2024-02-01',
        limit: 200,
      );

      expect(updatedParams.startDate, '2024-02-01');
      expect(updatedParams.endDate, '2024-01-31'); // unchanged
      expect(updatedParams.limit, 200);
      expect(updatedParams.offset, 0); // unchanged
    });

    test('copyWith with null values keeps original values', () {
      final originalParams = UsageHistoryParams(
        startDate: '2024-01-01',
        endDate: '2024-01-31',
        limit: 100,
        offset: 0,
      );

      final updatedParams = originalParams.copyWith();

      expect(updatedParams.startDate, '2024-01-01');
      expect(updatedParams.endDate, '2024-01-31');
      expect(updatedParams.limit, 100);
      expect(updatedParams.offset, 0);
    });
  });

  group('currentMonthUsageProvider', () {
    test('returns current month usage from repository', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final expectedUsage = TokenUsage(
        userId: 'user-123',
        year: 2024,
        month: 1,
        inputTokens: 1000,
        outputTokens: 500,
        totalTokens: 1500,
        requestCount: 25,
      );

      when(
        () => mockRepository.getCurrentMonthUsage(),
      ).thenAnswer((_) async => expectedUsage);

      final provider = container.read(currentMonthUsageProvider.future);
      final result = await provider;

      expect(result, expectedUsage);
      verify(() => mockRepository.getCurrentMonthUsage()).called(1);
    });

    test('returns null when repository returns null', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      when(
        () => mockRepository.getCurrentMonthUsage(),
      ).thenAnswer((_) async => null);

      final provider = container.read(currentMonthUsageProvider.future);
      final result = await provider;

      expect(result, isNull);
      verify(() => mockRepository.getCurrentMonthUsage()).called(1);
    });
  });

  group('usageHistoryProvider', () {
    test('returns usage history for default parameters', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final expectedHistory = TokenUsageHistory(
        records: [
          TokenUsageRecord(
            operationType: 'completion',
            modelName: 'gpt-4',
            inputTokens: 100,
            outputTokens: 50,
            createdAt: DateTime.parse('2024-01-15T10:00:00Z'),
          ),
          TokenUsageRecord(
            operationType: 'completion',
            modelName: 'gpt-4',
            inputTokens: 200,
            outputTokens: 100,
            createdAt: DateTime.parse('2024-01-15T11:00:00Z'),
          ),
        ],
        totalCount: 2,
      );

      when(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => expectedHistory);

      final params = UsageHistoryParams();
      final provider = container.read(usageHistoryProvider(params).future);
      final result = await provider;

      expect(result, expectedHistory);
      verify(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });

    test('returns usage history for custom parameters', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final expectedHistory = TokenUsageHistory(
        records: [
          TokenUsageRecord(
            operationType: 'completion',
            modelName: 'gpt-4',
            inputTokens: 150,
            outputTokens: 75,
            createdAt: DateTime.parse('2024-01-10T10:00:00Z'),
          ),
        ],
        totalCount: 1,
      );

      when(
        () => mockRepository.getUsageHistory(
          startDate: '2024-01-01',
          endDate: '2024-01-31',
          limit: 50,
          offset: 10,
        ),
      ).thenAnswer((_) async => expectedHistory);

      final params = UsageHistoryParams(
        startDate: '2024-01-01',
        endDate: '2024-01-31',
        limit: 50,
        offset: 10,
      );
      final provider = container.read(usageHistoryProvider(params).future);
      final result = await provider;

      expect(result, expectedHistory);
      verify(
        () => mockRepository.getUsageHistory(
          startDate: '2024-01-01',
          endDate: '2024-01-31',
          limit: 50,
          offset: 10,
        ),
      ).called(1);
    });

    test('returns null when repository returns null', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      when(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => null);

      final params = UsageHistoryParams();
      final provider = container.read(usageHistoryProvider(params).future);
      final result = await provider;

      expect(result, isNull);
      verify(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });

    test('caches results for same parameters', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final expectedHistory = TokenUsageHistory(records: [], totalCount: 0);

      when(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => expectedHistory);

      final params = UsageHistoryParams();

      // Call provider multiple times with same parameters
      final provider1 = container.read(usageHistoryProvider(params).future);
      final provider2 = container.read(usageHistoryProvider(params).future);

      await provider1;
      await provider2;

      // Should only call repository once due to caching
      verify(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });

    test('does not cache results for different parameters', () async {
      final mockRepository = MockRemoteRepository();
      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final expectedHistory = TokenUsageHistory(records: [], totalCount: 0);

      when(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => expectedHistory);

      when(
        () => mockRepository.getUsageHistory(
          startDate: '2024-01-01',
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => expectedHistory);

      final params1 = UsageHistoryParams();
      final params2 = UsageHistoryParams(startDate: '2024-01-01');

      // Call provider with different parameters
      final provider1 = container.read(usageHistoryProvider(params1).future);
      final provider2 = container.read(usageHistoryProvider(params2).future);

      await provider1;
      await provider2;

      // Should call repository twice for different parameters
      verify(
        () => mockRepository.getUsageHistory(
          startDate: null,
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);

      verify(
        () => mockRepository.getUsageHistory(
          startDate: '2024-01-01',
          endDate: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });
  });
}
