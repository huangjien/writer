import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/hot_topic.dart';

void main() {
  group('HotTopic', () {
    final testTopic = HotTopic(
      id: 'test-id',
      platformKey: 'weibo',
      regionCode: 'zh-CN',
      languageCode: 'zh',
      rank: 1,
      title: 'Test Topic',
      description: 'Test Description',
      url: 'https://example.com',
      heatScore: 100,
      commentCount: 50,
      likeCount: 200,
      shareCount: 30,
      rawData: {'key': 'value'},
      novelPotentialScore: 80,
      genreTags: ['action', 'drama'],
      storySentiment: 'positive',
      predictedTrend: 'rising',
      predictedLifespanDays: 7,
      confidenceScore: 0.85,
      crawledAt: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('creates instance with all required fields', () {
      final topic = HotTopic(
        id: 'id',
        platformKey: 'platform',
        regionCode: 'region',
        languageCode: 'lang',
        rank: 1,
        title: 'Title',
        crawledAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(topic.id, 'id');
      expect(topic.platformKey, 'platform');
      expect(topic.regionCode, 'region');
      expect(topic.languageCode, 'lang');
      expect(topic.rank, 1);
      expect(topic.title, 'Title');
      expect(topic.description, isNull);
      expect(topic.url, isNull);
      expect(topic.heatScore, isNull);
      expect(topic.commentCount, isNull);
      expect(topic.likeCount, isNull);
      expect(topic.shareCount, isNull);
      expect(topic.rawData, isNull);
      expect(topic.novelPotentialScore, isNull);
      expect(topic.genreTags, isNull);
      expect(topic.storySentiment, isNull);
      expect(topic.predictedTrend, isNull);
      expect(topic.predictedLifespanDays, isNull);
      expect(topic.confidenceScore, isNull);
    });

    test('fromMap creates HotTopic from map', () {
      final map = {
        'id': 'test-id',
        'platform_key': 'weibo',
        'region_code': 'zh-CN',
        'language_code': 'zh',
        'rank': 1,
        'title': 'Test Topic',
        'description': 'Test Description',
        'url': 'https://example.com',
        'heat_score': 100,
        'comment_count': 50,
        'like_count': 200,
        'share_count': 30,
        'raw_data': {'key': 'value'},
        'novel_potential_score': 80,
        'genre_tags': ['action', 'drama'],
        'story_sentiment': 'positive',
        'predicted_trend': 'rising',
        'predicted_lifespan_days': 7,
        'confidence_score': 0.85,
        'crawled_at': '2024-01-01T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final topic = HotTopic.fromMap(map);

      expect(topic.id, 'test-id');
      expect(topic.platformKey, 'weibo');
      expect(topic.regionCode, 'zh-CN');
      expect(topic.languageCode, 'zh');
      expect(topic.rank, 1);
      expect(topic.title, 'Test Topic');
      expect(topic.description, 'Test Description');
      expect(topic.url, 'https://example.com');
      expect(topic.heatScore, 100);
      expect(topic.commentCount, 50);
      expect(topic.likeCount, 200);
      expect(topic.shareCount, 30);
      expect(topic.rawData, {'key': 'value'});
      expect(topic.novelPotentialScore, 80);
      expect(topic.genreTags, ['action', 'drama']);
      expect(topic.storySentiment, 'positive');
      expect(topic.predictedTrend, 'rising');
      expect(topic.predictedLifespanDays, 7);
      expect(topic.confidenceScore, 0.85);
    });

    test('fromMap handles missing fields with defaults', () {
      final map = {
        'id': 'test-id',
        'platform_key': 'weibo',
        'region_code': 'zh-CN',
        'language_code': 'zh',
        'rank': 1,
        'title': 'Test Topic',
        'crawled_at': '2024-01-01T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final topic = HotTopic.fromMap(map);

      expect(topic.description, isNull);
      expect(topic.url, isNull);
      expect(topic.heatScore, isNull);
      expect(topic.commentCount, isNull);
      expect(topic.likeCount, isNull);
      expect(topic.shareCount, isNull);
      expect(topic.rawData, isNull);
      expect(topic.novelPotentialScore, isNull);
      expect(topic.genreTags, isNull);
      expect(topic.storySentiment, isNull);
      expect(topic.predictedTrend, isNull);
      expect(topic.predictedLifespanDays, isNull);
      expect(topic.confidenceScore, isNull);
    });

    test('toMap converts HotTopic to map', () {
      final map = testTopic.toMap();

      expect(map['id'], 'test-id');
      expect(map['platform_key'], 'weibo');
      expect(map['region_code'], 'zh-CN');
      expect(map['language_code'], 'zh');
      expect(map['rank'], 1);
      expect(map['title'], 'Test Topic');
      expect(map['description'], 'Test Description');
      expect(map['url'], 'https://example.com');
      expect(map['heat_score'], 100);
      expect(map['comment_count'], 50);
      expect(map['like_count'], 200);
      expect(map['share_count'], 30);
      expect(map['raw_data'], {'key': 'value'});
      expect(map['novel_potential_score'], 80);
      expect(map['genre_tags'], ['action', 'drama']);
      expect(map['story_sentiment'], 'positive');
      expect(map['predicted_trend'], 'rising');
      expect(map['predicted_lifespan_days'], 7);
      expect(map['confidence_score'], 0.85);
      expect(map['crawled_at'], '2024-01-01T00:00:00.000');
      expect(map['created_at'], '2024-01-01T00:00:00.000');
      expect(map['updated_at'], '2024-01-01T00:00:00.000');
    });

    test('copyWith creates new HotTopic with updated fields', () {
      final updated = testTopic.copyWith(
        title: 'Updated Title',
        rank: 2,
        novelPotentialScore: 90,
      );

      expect(updated.id, testTopic.id);
      expect(updated.title, 'Updated Title');
      expect(updated.rank, 2);
      expect(updated.novelPotentialScore, 90);
      expect(updated.description, testTopic.description);
      expect(updated.platformKey, testTopic.platformKey);
    });

    test('fromMap/toMap roundtrip preserves data', () {
      final map = testTopic.toMap();
      final restored = HotTopic.fromMap(map);

      expect(restored.id, testTopic.id);
      expect(restored.platformKey, testTopic.platformKey);
      expect(restored.regionCode, testTopic.regionCode);
      expect(restored.languageCode, testTopic.languageCode);
      expect(restored.rank, testTopic.rank);
      expect(restored.title, testTopic.title);
      expect(restored.description, testTopic.description);
      expect(restored.url, testTopic.url);
      expect(restored.heatScore, testTopic.heatScore);
      expect(restored.commentCount, testTopic.commentCount);
      expect(restored.likeCount, testTopic.likeCount);
      expect(restored.shareCount, testTopic.shareCount);
      expect(restored.novelPotentialScore, testTopic.novelPotentialScore);
      expect(restored.genreTags, testTopic.genreTags);
      expect(restored.storySentiment, testTopic.storySentiment);
      expect(restored.predictedTrend, testTopic.predictedTrend);
      expect(restored.predictedLifespanDays, testTopic.predictedLifespanDays);
      expect(restored.confidenceScore, testTopic.confidenceScore);
    });

    test('fromMap handles DateTime parsing from string', () {
      final map = {
        'id': 'test-id',
        'platform_key': 'weibo',
        'region_code': 'zh-CN',
        'language_code': 'zh',
        'rank': 1,
        'title': 'Test Topic',
        'crawled_at': '2024-06-15T10:30:00.000',
        'created_at': '2024-06-15T10:30:00.000',
        'updated_at': '2024-06-15T10:30:00.000',
      };

      final topic = HotTopic.fromMap(map);

      expect(topic.crawledAt, DateTime(2024, 6, 15, 10, 30));
      expect(topic.createdAt, DateTime(2024, 6, 15, 10, 30));
      expect(topic.updatedAt, DateTime(2024, 6, 15, 10, 30));
    });
  });

  group('HotTopicPlatform', () {
    final testPlatform = const HotTopicPlatform(
      platformKey: 'weibo',
      name: 'Weibo',
      iconUrl: 'https://example.com/icon.png',
      regionCode: 'zh-CN',
      isActive: true,
    );

    test('creates instance with all fields', () {
      final platform = const HotTopicPlatform(
        platformKey: 'twitter',
        name: 'Twitter',
        regionCode: 'en',
        isActive: true,
      );

      expect(platform.platformKey, 'twitter');
      expect(platform.name, 'Twitter');
      expect(platform.iconUrl, isNull);
      expect(platform.regionCode, 'en');
      expect(platform.isActive, true);
    });

    test('fromMap creates HotTopicPlatform from map', () {
      final map = {
        'platform_key': 'weibo',
        'name': 'Weibo',
        'icon_url': 'https://example.com/icon.png',
        'region_code': 'zh-CN',
        'is_active': true,
      };

      final platform = HotTopicPlatform.fromMap(map);

      expect(platform.platformKey, 'weibo');
      expect(platform.name, 'Weibo');
      expect(platform.iconUrl, 'https://example.com/icon.png');
      expect(platform.regionCode, 'zh-CN');
      expect(platform.isActive, true);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'platform_key': 'twitter',
        'name': 'Twitter',
        'region_code': 'en',
      };

      final platform = HotTopicPlatform.fromMap(map);

      expect(platform.iconUrl, isNull);
      expect(platform.isActive, false);
    });

    test('toMap converts HotTopicPlatform to map', () {
      final map = testPlatform.toMap();

      expect(map['platform_key'], 'weibo');
      expect(map['name'], 'Weibo');
      expect(map['icon_url'], 'https://example.com/icon.png');
      expect(map['region_code'], 'zh-CN');
      expect(map['is_active'], true);
    });

    test('copyWith creates new HotTopicPlatform with updated fields', () {
      final updated = testPlatform.copyWith(
        isActive: false,
        name: 'Updated Weibo',
      );

      expect(updated.platformKey, testPlatform.platformKey);
      expect(updated.name, 'Updated Weibo');
      expect(updated.isActive, false);
      expect(updated.iconUrl, testPlatform.iconUrl);
      expect(updated.regionCode, testPlatform.regionCode);
    });

    test('fromMap/toMap roundtrip preserves data', () {
      final map = testPlatform.toMap();
      final restored = HotTopicPlatform.fromMap(map);

      expect(restored.platformKey, testPlatform.platformKey);
      expect(restored.name, testPlatform.name);
      expect(restored.iconUrl, testPlatform.iconUrl);
      expect(restored.regionCode, testPlatform.regionCode);
      expect(restored.isActive, testPlatform.isActive);
    });
  });

  group('HotTopicTracking', () {
    final testTracking = HotTopicTracking(
      topicFingerprint: 'test-fingerprint',
      regionCode: 'zh-CN',
      timesSeen: 10,
      daysSeen: 5,
      consecutiveDays: 3,
      velocity24h: 100,
      firstSeenAt: DateTime(2024, 1, 1),
      lastSeenAt: DateTime(2024, 1, 5),
      maxRank: 1,
      avgRank: 2.5,
      momentumScore: 80,
    );

    test('creates instance with required fields only', () {
      final tracking = const HotTopicTracking(
        topicFingerprint: 'fingerprint',
        regionCode: 'zh-CN',
      );

      expect(tracking.topicFingerprint, 'fingerprint');
      expect(tracking.regionCode, 'zh-CN');
      expect(tracking.timesSeen, isNull);
      expect(tracking.daysSeen, isNull);
      expect(tracking.consecutiveDays, isNull);
      expect(tracking.velocity24h, isNull);
      expect(tracking.firstSeenAt, isNull);
      expect(tracking.lastSeenAt, isNull);
      expect(tracking.maxRank, isNull);
      expect(tracking.avgRank, isNull);
      expect(tracking.momentumScore, isNull);
    });

    test('fromMap creates HotTopicTracking from map', () {
      final map = {
        'topic_fingerprint': 'test-fingerprint',
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
      };

      final tracking = HotTopicTracking.fromMap(map);

      expect(tracking.topicFingerprint, 'test-fingerprint');
      expect(tracking.regionCode, 'zh-CN');
      expect(tracking.timesSeen, 10);
      expect(tracking.daysSeen, 5);
      expect(tracking.consecutiveDays, 3);
      expect(tracking.velocity24h, 100);
      expect(tracking.firstSeenAt, DateTime(2024, 1, 1));
      expect(tracking.lastSeenAt, DateTime(2024, 1, 5));
      expect(tracking.maxRank, 1);
      expect(tracking.avgRank, 2.5);
      expect(tracking.momentumScore, 80);
    });

    test('fromMap handles missing optional fields', () {
      final map = {'topic_fingerprint': 'fingerprint', 'region_code': 'zh-CN'};

      final tracking = HotTopicTracking.fromMap(map);

      expect(tracking.timesSeen, isNull);
      expect(tracking.daysSeen, isNull);
      expect(tracking.consecutiveDays, isNull);
      expect(tracking.velocity24h, isNull);
      expect(tracking.firstSeenAt, isNull);
      expect(tracking.lastSeenAt, isNull);
      expect(tracking.maxRank, isNull);
      expect(tracking.avgRank, isNull);
      expect(tracking.momentumScore, isNull);
    });

    test('toMap converts HotTopicTracking to map', () {
      final map = testTracking.toMap();

      expect(map['topic_fingerprint'], 'test-fingerprint');
      expect(map['region_code'], 'zh-CN');
      expect(map['times_seen'], 10);
      expect(map['days_seen'], 5);
      expect(map['consecutive_days'], 3);
      expect(map['velocity_24h'], 100);
      expect(map['first_seen_at'], '2024-01-01T00:00:00.000');
      expect(map['last_seen_at'], '2024-01-05T00:00:00.000');
      expect(map['max_rank'], 1);
      expect(map['avg_rank'], 2.5);
      expect(map['momentum_score'], 80);
    });

    test('copyWith creates new HotTopicTracking with updated fields', () {
      final updated = testTracking.copyWith(timesSeen: 20, momentumScore: 90);

      expect(updated.topicFingerprint, testTracking.topicFingerprint);
      expect(updated.timesSeen, 20);
      expect(updated.momentumScore, 90);
      expect(updated.regionCode, testTracking.regionCode);
      expect(updated.daysSeen, testTracking.daysSeen);
    });

    test('fromMap/toMap roundtrip preserves data', () {
      final map = testTracking.toMap();
      final restored = HotTopicTracking.fromMap(map);

      expect(restored.topicFingerprint, testTracking.topicFingerprint);
      expect(restored.regionCode, testTracking.regionCode);
      expect(restored.timesSeen, testTracking.timesSeen);
      expect(restored.daysSeen, testTracking.daysSeen);
      expect(restored.consecutiveDays, testTracking.consecutiveDays);
      expect(restored.velocity24h, testTracking.velocity24h);
      expect(restored.firstSeenAt, testTracking.firstSeenAt);
      expect(restored.lastSeenAt, testTracking.lastSeenAt);
      expect(restored.maxRank, testTracking.maxRank);
      expect(restored.avgRank, testTracking.avgRank);
      expect(restored.momentumScore, testTracking.momentumScore);
    });

    test('fromMap handles null DateTime fields', () {
      final map = {
        'topic_fingerprint': 'fingerprint',
        'region_code': 'zh-CN',
        'first_seen_at': null,
        'last_seen_at': null,
      };

      final tracking = HotTopicTracking.fromMap(map);

      expect(tracking.firstSeenAt, isNull);
      expect(tracking.lastSeenAt, isNull);
    });
  });
}
