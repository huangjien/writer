import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/hot_topics/hot_topics_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository implements RemoteRepository {
  final List<dynamic> platformsData;
  final List<dynamic> latestTopicsData;
  final List<dynamic> trackingData;
  final List<dynamic> trendingData;
  final bool shouldThrowError;

  MockRemoteRepository({
    this.platformsData = const [],
    this.latestTopicsData = const [],
    this.trackingData = const [],
    this.trendingData = const [],
    this.shouldThrowError = false,
  });

  @override
  String get baseUrl => 'http://localhost:5600';

  @override
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    if (shouldThrowError) {
      throw Exception('Network error');
    }

    if (path == 'hot-topics/platforms') {
      return platformsData;
    } else if (path == 'hot-topics/latest') {
      return latestTopicsData;
    } else if (path == 'hot-topics/tracking') {
      return trackingData;
    } else if (path.contains('hot-topics/tracking') &&
        path.contains('trending')) {
      return trendingData;
    }

    return [];
  }

  @override
  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchCharacterProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchSceneProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsage?> getCurrentMonthUsage() async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsageHistory?> getUsageHistory({
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAdminLogs({int lines = 1000}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getAdminLogsEnhanced({
    int maxSizeKb = 50,
    int fileIndex = 0,
    String? level,
    String? logger,
    String? searchText,
    String? startDate,
    String? endDate,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getHotTopicsPlatforms() async {
    return platformsData;
  }

  @override
  Future<List<dynamic>> getLatestHotTopics({
    String? regionCode,
    String? platformKey,
    int? limit,
  }) async {
    return latestTopicsData;
  }

  @override
  Future<List<dynamic>> getHotTopicsTracking({
    String? regionCode,
    int? minMomentumScore,
    int? minTimesSeen,
    int? limit,
  }) async {
    return trackingData;
  }

  @override
  Future<List<dynamic>> getHotTopicSnapshots(
    String topicFingerprint, {
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getTrendingHotTopics({
    String? regionCode,
    int? minMomentumScore,
    int? limit,
  }) async {
    return trendingData;
  }
}

void main() {
  group('hotTopicsProviders', () {
    test('hotTopicsRegionCodeProvider returns default region code', () {
      final container = ProviderContainer();
      final regionCode = container.read(hotTopicsRegionCodeProvider);

      expect(regionCode, 'zh-CN');
    });

    test('hotTopicsPlatformKeyProvider returns null by default', () {
      final container = ProviderContainer();
      final platformKey = container.read(hotTopicsPlatformKeyProvider);

      expect(platformKey, isNull);
    });

    test('hotTopicsLimitProvider returns default limit', () {
      final container = ProviderContainer();
      final limit = container.read(hotTopicsLimitProvider);

      expect(limit, 100);
    });

    test('hotTopicsFilterProvider returns default filter', () {
      final container = ProviderContainer();
      final filter = container.read(hotTopicsFilterProvider);

      expect(filter.regionCode, 'zh-CN');
      expect(filter.platformKey, isNull);
    });

    test('hotTopicsPlatformsProvider returns list of platforms', () async {
      final mockRepo = MockRemoteRepository(
        platformsData: [
          {
            'platform_key': 'weibo',
            'name': 'Weibo',
            'icon_url': 'https://example.com/weibo.png',
            'region_code': 'zh-CN',
            'is_active': true,
          },
          {
            'platform_key': 'twitter',
            'name': 'Twitter',
            'icon_url': 'https://example.com/twitter.png',
            'region_code': 'en',
            'is_active': true,
          },
        ],
      );

      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
      );

      await container.read(hotTopicsPlatformsProvider.future);

      final platforms = container.read(hotTopicsPlatformsProvider);

      expect(platforms.value, isNotNull);
      expect(platforms.value!.length, 2);
      expect(platforms.value![0].platformKey, 'weibo');
      expect(platforms.value![0].name, 'Weibo');
      expect(platforms.value![1].platformKey, 'twitter');
      expect(platforms.value![1].name, 'Twitter');
    });

    test(
      'hotTopicsPlatformsProvider returns empty list when no data',
      () async {
        final mockRepo = MockRemoteRepository(platformsData: []);

        final container = ProviderContainer(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
        );

        await container.read(hotTopicsPlatformsProvider.future);

        final platforms = container.read(hotTopicsPlatformsProvider);

        expect(platforms.value, isEmpty);
      },
    );

    test('latestHotTopicsProvider returns list of topics', () async {
      final mockRepo = MockRemoteRepository(
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic 1',
            'crawled_at': '2024-01-01T00:00:00.000',
            'created_at': '2024-01-01T00:00:00.000',
            'updated_at': '2024-01-01T00:00:00.000',
          },
          {
            'id': 'topic-2',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 2,
            'title': 'Test Topic 2',
            'crawled_at': '2024-01-01T00:00:00.000',
            'created_at': '2024-01-01T00:00:00.000',
            'updated_at': '2024-01-01T00:00:00.000',
          },
        ],
      );

      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
      );

      await container.read(latestHotTopicsProvider.future);

      final topics = container.read(latestHotTopicsProvider);

      expect(topics.value, isNotNull);
      expect(topics.value!.length, 2);
      expect(topics.value![0].id, 'topic-1');
      expect(topics.value![0].title, 'Test Topic 1');
      expect(topics.value![1].id, 'topic-2');
      expect(topics.value![1].title, 'Test Topic 2');
    });

    test('latestHotTopicsProvider returns empty list when no data', () async {
      final mockRepo = MockRemoteRepository(latestTopicsData: []);

      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
      );

      await container.read(latestHotTopicsProvider.future);

      final topics = container.read(latestHotTopicsProvider);

      expect(topics.value, isEmpty);
    });

    test('hotTopicsTrackingProvider returns list of tracking data', () async {
      final mockRepo = MockRemoteRepository(
        trackingData: [
          {
            'topic_fingerprint': 'fp-1',
            'region_code': 'zh-CN',
            'times_seen': 10,
            'days_seen': 5,
            'consecutive_days': 3,
            'velocity_24h': 100,
            'first_seen_at': '2024-01-01T00:00:00.000',
            'last_seen_at': '2024-01-05T00:00:00.000',
            'max_rank': 1,
            'avg_rank': 2.5,
            'momentum_score': 80,
          },
        ],
      );

      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
      );

      await container.read(hotTopicsTrackingProvider.future);

      final tracking = container.read(hotTopicsTrackingProvider);

      expect(tracking.value, isNotNull);
      expect(tracking.value!.length, 1);
      expect(tracking.value![0].topicFingerprint, 'fp-1');
      expect(tracking.value![0].timesSeen, 10);
      expect(tracking.value![0].momentumScore, 80);
    });

    test('trendingHotTopicsProvider returns list of trending topics', () async {
      final mockRepo = MockRemoteRepository(
        trendingData: [
          {
            'topic_fingerprint': 'fp-2',
            'region_code': 'zh-CN',
            'momentum_score': 90,
            'times_seen': 15,
            'days_seen': 7,
            'consecutive_days': 5,
            'velocity_24h': 150,
            'first_seen_at': '2024-01-01T00:00:00.000',
            'last_seen_at': '2024-01-07T00:00:00.000',
            'max_rank': 1,
            'avg_rank': 1.5,
          },
        ],
      );

      final container = ProviderContainer(
        overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
      );

      await container.read(trendingHotTopicsProvider.future);

      final trending = container.read(trendingHotTopicsProvider);

      expect(trending.value, isNotNull);
      expect(trending.value!.length, 1);
      expect(trending.value![0].topicFingerprint, 'fp-2');
      expect(trending.value![0].momentumScore, 90);
    });

    test('HotTopicsFilter copyWith creates updated filter', () {
      const filter = HotTopicsFilter(regionCode: 'zh-CN', platformKey: null);

      final updated = filter.copyWith(regionCode: 'en', platformKey: 'twitter');

      expect(updated.regionCode, 'en');
      expect(updated.platformKey, 'twitter');
    });

    test('HotTopicsFilter copyWith preserves unchanged values', () {
      const filter = HotTopicsFilter(regionCode: 'zh-CN', platformKey: 'weibo');

      final updated = filter.copyWith(regionCode: 'en');

      expect(updated.regionCode, 'en');
      expect(updated.platformKey, 'weibo');
    });
  });
}
