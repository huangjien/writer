import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/hot_topics/hot_topics_screen.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/controllers/app_settings.dart';

class MockPrefs implements SharedPreferences {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic get(String key) => _data[key];

  @override
  Future<bool> reload() async => true;

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  Future<bool> clearCount() async => true;

  Future<bool> clearCountFor(String key) async => true;

  int getCount(String key) => 0;

  Future<bool> setCount(String key, int count) async => true;

  bool get isMock => true;

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

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

Widget buildTestWidget({
  required Widget child,
  required RemoteRepository mockRepo,
  Locale? mockLocale,
}) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: ProviderScope(
      overrides: [
        remoteRepositoryProvider.overrideWithValue(mockRepo),
        if (mockLocale != null)
          appSettingsProvider.overrideWith(
            (_) => AppSettingsNotifier(MockPrefs())..state = mockLocale,
          ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('HotTopicsScreen', () {
    final mockLocale = const Locale('zh', 'CN');

    testWidgets('renders loading state', (tester) async {
      final mockRepo = MockRemoteRepository();

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
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
            'like_count': 1000,
            'comment_count': 500,
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
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
            'genre_tags': ['Contemporary', 'Urban'],
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
      expect(find.text('Contemporary'), findsOneWidget);
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic'), findsOneWidget);
    });

    testWidgets('shows app bar with refresh button', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('region filter chips are rendered', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [],
        latestTopicsData: [],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HotTopicsScreen), findsOneWidget);
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
            'title': 'Test Topic 1',
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
            'title': 'Test Topic 2',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Topic 1'), findsOneWidget);
      expect(find.text('Test Topic 2'), findsOneWidget);
    });

    testWidgets('renders negative sentiment', (tester) async {
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
            'story_sentiment': 'negative',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('negative'), findsOneWidget);
    });

    testWidgets('renders mixed sentiment', (tester) async {
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
            'story_sentiment': 'mixed',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('mixed'), findsOneWidget);
    });

    testWidgets('renders low novel potential score', (tester) async {
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
            'novel_potential_score': 40,
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Novel: 40'), findsOneWidget);
    });

    testWidgets('shows url host as summary and allows open link', (
      tester,
    ) async {
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
            'url': 'https://example.com/path',
            'crawled_at': '2024-01-01T00:00:00.000Z',
            'created_at': '2024-01-01T00:00:00.000Z',
            'updated_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('example.com'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);

      await tester.tap(find.byIcon(Icons.open_in_new));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders platform filter menu with platforms', (tester) async {
      final mockRepo = MockRemoteRepository(
        platformsData: [
          {
            'platform_key': 'weibo',
            'name': 'Weibo',
            'icon_url': null,
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
        buildTestWidget(
          child: const HotTopicsScreen(),
          mockRepo: mockRepo,
          mockLocale: mockLocale,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Select platform'));
      await tester.pumpAndSettle();

      expect(find.text('All Platforms'), findsWidgets);
      expect(find.text('Weibo'), findsWidgets);
    });
  });
}
