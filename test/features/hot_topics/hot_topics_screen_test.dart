import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/hot_topics/hot_topics_screen.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';

class MockRemoteRepository implements RemoteRepository {
  final List<dynamic> platformsData;
  final List<dynamic> latestTopicsData;

  MockRemoteRepository({
    this.platformsData = const [],
    this.latestTopicsData = const [],
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
    if (path == 'hot-topics/platforms') {
      return platformsData;
    } else if (path == 'hot-topics/latest') {
      return latestTopicsData;
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}

void main() {
  group('HotTopicsScreen', () {
    testWidgets('renders loading state', (tester) async {
      final mockRepo = MockRemoteRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HotTopicsScreen), findsOneWidget);
    });

    testWidgets('renders empty state when no topics', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No hot topics found'), findsOneWidget);
    });

    testWidgets('renders topics list', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [
          {
            'platform_key': 'weibo',
            'name': 'Weibo',
            'icon_url': 'https://example.com/weibo.png',
            'region_code': 'zh-CN',
            'is_active': true,
          },
        ],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders topic with description', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'description': 'Test Description',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('renders topic with heat score', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'heat_score': 1500000,
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('1.5M'), findsOneWidget);
    });

    testWidgets('renders topic with like and comment counts', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'like_count': 5000,
            'comment_count': 300,
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('5.0K'), findsOneWidget);
      expect(find.byIcon(Icons.comment), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('renders topic with novel potential score', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'novel_potential_score': 85,
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
      expect(find.text('Novel: 85'), findsOneWidget);
    });

    testWidgets('renders topic with genre tag', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'genre_tags': ['action', 'drama'],
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.text('action'), findsOneWidget);
    });

    testWidgets('renders topic with sentiment', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Test Topic',
            'story_sentiment': 'positive',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
      expect(find.text('positive'), findsOneWidget);
    });

    testWidgets('shows app bar with refresh button', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hot Topics'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders platform filter', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [
          {
            'platform_key': 'weibo',
            'name': 'Weibo',
            'icon_url': 'https://example.com/weibo.png',
            'region_code': 'zh-CN',
            'is_active': true,
          },
        ],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All Platforms'), findsOneWidget);
      expect(find.text('Weibo'), findsOneWidget);
    });

    testWidgets('region filter chips are rendered', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final chips = find.byType(FilterChip);
      expect(chips, findsAtLeastNWidgets(1));
      expect(find.text('🇨🇳 China'), findsOneWidget);
    });

    testWidgets('renders multiple topics', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [
          {
            'id': 'topic-1',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 1,
            'title': 'Topic 1',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
          {
            'id': 'topic-2',
            'platform_key': 'weibo',
            'region_code': 'zh-CN',
            'language_code': 'zh',
            'rank': 2,
            'title': 'Topic 2',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [remoteRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: HotTopicsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Topic 1'), findsOneWidget);
      expect(find.text('Topic 2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
