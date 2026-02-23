class HotTopic {
  final String id;
  final String platformKey;
  final String regionCode;
  final String languageCode;
  final int rank;
  final String title;
  final String? description;
  final String? url;
  final int? heatScore;
  final int? commentCount;
  final int? likeCount;
  final int? shareCount;
  final Map<String, dynamic>? rawData;

  // AI analysis fields
  final int? novelPotentialScore;
  final List<String>? genreTags;
  final String? storySentiment;
  final String? predictedTrend;
  final int? predictedLifespanDays;
  final double? confidenceScore;

  final DateTime crawledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HotTopic({
    required this.id,
    required this.platformKey,
    required this.regionCode,
    required this.languageCode,
    required this.rank,
    required this.title,
    this.description,
    this.url,
    this.heatScore,
    this.commentCount,
    this.likeCount,
    this.shareCount,
    this.rawData,
    this.novelPotentialScore,
    this.genreTags,
    this.storySentiment,
    this.predictedTrend,
    this.predictedLifespanDays,
    this.confidenceScore,
    required this.crawledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HotTopic.fromMap(Map<String, dynamic> map) {
    final crawledAt = map['crawled_at'];
    final createdAt = map['created_at'];
    final updatedAt = map['updated_at'];
    return HotTopic(
      id: (map['id'] ?? '') as String,
      platformKey: (map['platform_key'] ?? '') as String,
      regionCode: (map['region_code'] ?? '') as String,
      languageCode: (map['language_code'] ?? '') as String,
      rank: (map['rank'] ?? 0) as int,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      url: map['url'] as String?,
      heatScore: map['heat_score'] as int?,
      commentCount: map['comment_count'] as int?,
      likeCount: map['like_count'] as int?,
      shareCount: map['share_count'] as int?,
      rawData: map['raw_data'] as Map<String, dynamic>?,
      novelPotentialScore: map['novel_potential_score'] as int?,
      genreTags: (map['genre_tags'] as List<dynamic>?)?.cast<String>(),
      storySentiment: map['story_sentiment'] as String?,
      predictedTrend: map['predicted_trend'] as String?,
      predictedLifespanDays: map['predicted_lifespan_days'] as int?,
      confidenceScore: map['confidence_score'] as double?,
      crawledAt: crawledAt is String
          ? DateTime.parse(crawledAt)
          : DateTime.now(),
      createdAt: createdAt is String
          ? DateTime.parse(createdAt)
          : DateTime.now(),
      updatedAt: updatedAt is String
          ? DateTime.parse(updatedAt)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform_key': platformKey,
      'region_code': regionCode,
      'language_code': languageCode,
      'rank': rank,
      'title': title,
      'description': description,
      'url': url,
      'heat_score': heatScore,
      'comment_count': commentCount,
      'like_count': likeCount,
      'share_count': shareCount,
      'raw_data': rawData,
      'novel_potential_score': novelPotentialScore,
      'genre_tags': genreTags,
      'story_sentiment': storySentiment,
      'predicted_trend': predictedTrend,
      'predicted_lifespan_days': predictedLifespanDays,
      'confidence_score': confidenceScore,
      'crawled_at': crawledAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HotTopic copyWith({
    String? id,
    String? platformKey,
    String? regionCode,
    String? languageCode,
    int? rank,
    String? title,
    String? description,
    String? url,
    int? heatScore,
    int? commentCount,
    int? likeCount,
    int? shareCount,
    Map<String, dynamic>? rawData,
    int? novelPotentialScore,
    List<String>? genreTags,
    String? storySentiment,
    String? predictedTrend,
    int? predictedLifespanDays,
    double? confidenceScore,
    DateTime? crawledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotTopic(
      id: id ?? this.id,
      platformKey: platformKey ?? this.platformKey,
      regionCode: regionCode ?? this.regionCode,
      languageCode: languageCode ?? this.languageCode,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      heatScore: heatScore ?? this.heatScore,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      rawData: rawData ?? this.rawData,
      novelPotentialScore: novelPotentialScore ?? this.novelPotentialScore,
      genreTags: genreTags ?? this.genreTags,
      storySentiment: storySentiment ?? this.storySentiment,
      predictedTrend: predictedTrend ?? this.predictedTrend,
      predictedLifespanDays:
          predictedLifespanDays ?? this.predictedLifespanDays,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      crawledAt: crawledAt ?? this.crawledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HotTopicPlatform {
  final String platformKey;
  final String name;
  final String? iconUrl;
  final String regionCode;
  final bool isActive;

  const HotTopicPlatform({
    required this.platformKey,
    required this.name,
    this.iconUrl,
    required this.regionCode,
    required this.isActive,
  });

  factory HotTopicPlatform.fromMap(Map<String, dynamic> map) {
    return HotTopicPlatform(
      platformKey: (map['platform_key'] ?? '') as String,
      name: (map['display_name'] ?? map['name'] ?? '') as String,
      iconUrl: map['icon_url'] as String?,
      regionCode: (map['region_code'] ?? '') as String,
      isActive: (map['is_active'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform_key': platformKey,
      'name': name,
      'icon_url': iconUrl,
      'region_code': regionCode,
      'is_active': isActive,
    };
  }

  HotTopicPlatform copyWith({
    String? platformKey,
    String? name,
    String? iconUrl,
    String? regionCode,
    bool? isActive,
  }) {
    return HotTopicPlatform(
      platformKey: platformKey ?? this.platformKey,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      regionCode: regionCode ?? this.regionCode,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HotTopicTracking {
  final String topicFingerprint;
  final String regionCode;
  final int? timesSeen;
  final int? daysSeen;
  final int? consecutiveDays;
  final int? velocity24h;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;
  final int? maxRank;
  final double? avgRank;
  final int? momentumScore;

  const HotTopicTracking({
    required this.topicFingerprint,
    required this.regionCode,
    this.timesSeen,
    this.daysSeen,
    this.consecutiveDays,
    this.velocity24h,
    this.firstSeenAt,
    this.lastSeenAt,
    this.maxRank,
    this.avgRank,
    this.momentumScore,
  });

  factory HotTopicTracking.fromMap(Map<String, dynamic> map) {
    final firstSeenAt = map['first_seen_at'];
    final lastSeenAt = map['last_seen_at'];
    return HotTopicTracking(
      topicFingerprint: (map['topic_fingerprint'] ?? '') as String,
      regionCode: (map['region_code'] ?? '') as String,
      timesSeen: map['times_seen'] as int?,
      daysSeen: map['days_seen'] as int?,
      consecutiveDays: map['consecutive_days'] as int?,
      velocity24h: map['velocity_24h'] as int?,
      firstSeenAt: firstSeenAt is String ? DateTime.parse(firstSeenAt) : null,
      lastSeenAt: lastSeenAt is String ? DateTime.parse(lastSeenAt) : null,
      maxRank: map['max_rank'] as int?,
      avgRank: map['avg_rank'] as double?,
      momentumScore: map['momentum_score'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic_fingerprint': topicFingerprint,
      'region_code': regionCode,
      'times_seen': timesSeen,
      'days_seen': daysSeen,
      'consecutive_days': consecutiveDays,
      'velocity_24h': velocity24h,
      'first_seen_at': firstSeenAt?.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'max_rank': maxRank,
      'avg_rank': avgRank,
      'momentum_score': momentumScore,
    };
  }

  HotTopicTracking copyWith({
    String? topicFingerprint,
    String? regionCode,
    int? timesSeen,
    int? daysSeen,
    int? consecutiveDays,
    int? velocity24h,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    int? maxRank,
    double? avgRank,
    int? momentumScore,
  }) {
    return HotTopicTracking(
      topicFingerprint: topicFingerprint ?? this.topicFingerprint,
      regionCode: regionCode ?? this.regionCode,
      timesSeen: timesSeen ?? this.timesSeen,
      daysSeen: daysSeen ?? this.daysSeen,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      velocity24h: velocity24h ?? this.velocity24h,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      maxRank: maxRank ?? this.maxRank,
      avgRank: avgRank ?? this.avgRank,
      momentumScore: momentumScore ?? this.momentumScore,
    );
  }
}
