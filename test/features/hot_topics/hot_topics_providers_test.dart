import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/hot_topics/hot_topics_providers.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/controllers/app_settings.dart';

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
  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> generateSceneTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
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
  Future<List<dynamic>> getHotTopicsPlatforms({String? regionCode}) async {
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
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('hotTopicsProviders', () {
    test('hotTopicsRegionCodeProvider returns default region code', () async {
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      final regionCode = container.read(hotTopicsRegionCodeProvider);

      expect(regionCode, 'zh-CN');
    });

    test('hotTopicsPlatformKeyProvider returns null by default', () {
      final container = ProviderContainer();
      final platformKey = container.read(hotTopicsPlatformKeyProvider);

      expect(platformKey, isNull);
      container.dispose();
    });

    test('hotTopicsLimitProvider returns default limit', () {
      final container = ProviderContainer();
      final limit = container.read(hotTopicsLimitProvider);

      expect(limit, 100);
      container.dispose();
    });

    test('hotTopicsFilterProvider returns default filter', () {
      final container = ProviderContainer();
      final filter = container.read(hotTopicsFilterProvider);

      expect(filter.platformKey, isNull);
      container.dispose();
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

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      await container.read(hotTopicsPlatformsProvider.future);

      final platforms = container.read(hotTopicsPlatformsProvider);

      expect(platforms.value, isNotNull);
      expect(platforms.value!.length, 1);
      expect(platforms.value![0].platformKey, 'weibo');
      expect(platforms.value![0].name, 'Weibo');
      container.dispose();
    });

    test(
      'hotTopicsPlatformsProvider returns empty list when no data',
      () async {
        final mockRepo = MockRemoteRepository(platformsData: []);

        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            remoteRepositoryProvider.overrideWithValue(mockRepo),
            appSettingsProvider.overrideWith(
              (_) =>
                  AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
            ),
          ],
        );

        await container.read(hotTopicsPlatformsProvider.future);

        final platforms = container.read(hotTopicsPlatformsProvider);

        expect(platforms.value, isEmpty);
        container.dispose();
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

      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      await container.read(latestHotTopicsProvider.future);

      final topics = container.read(latestHotTopicsProvider);

      expect(topics.value, isNotNull);
      expect(topics.value!.length, 2);
      expect(topics.value![0].id, 'topic-1');
      expect(topics.value![0].title, 'Test Topic 1');
      expect(topics.value![1].id, 'topic-2');
      expect(topics.value![1].title, 'Test Topic 2');
      container.dispose();
    });

    test('latestHotTopicsProvider returns empty list when no data', () async {
      final mockRepo = MockRemoteRepository(latestTopicsData: []);

      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      await container.read(latestHotTopicsProvider.future);

      final topics = container.read(latestHotTopicsProvider);

      expect(topics.value, isEmpty);
      container.dispose();
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

      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      await container.read(hotTopicsTrackingProvider.future);

      final tracking = container.read(hotTopicsTrackingProvider);

      expect(tracking.value, isNotNull);
      expect(tracking.value!.length, 1);
      expect(tracking.value![0].topicFingerprint, 'fp-1');
      expect(tracking.value![0].timesSeen, 10);
      expect(tracking.value![0].momentumScore, 80);
      container.dispose();
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

      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(mockRepo),
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(prefs)..state = const Locale('zh', 'CN'),
          ),
        ],
      );

      await container.read(trendingHotTopicsProvider.future);

      final trending = container.read(trendingHotTopicsProvider);

      expect(trending.value, isNotNull);
      expect(trending.value!.length, 1);
      expect(trending.value![0].topicFingerprint, 'fp-2');
      expect(trending.value![0].momentumScore, 90);
      container.dispose();
    });

    test('HotTopicsFilter copyWith creates updated filter', () {
      const filter = HotTopicsFilter(platformKey: null);

      final updated = filter.copyWith(platformKey: 'twitter');

      expect(updated.platformKey, 'twitter');
    });

    test('HotTopicsFilter copyWith preserves unchanged values', () {
      const filter = HotTopicsFilter(platformKey: 'weibo');

      final updated = filter.copyWith(platformKey: 'twitter');

      expect(updated.platformKey, 'twitter');
    });
  });
}
