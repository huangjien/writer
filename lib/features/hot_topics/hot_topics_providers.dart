import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/models/hot_topic.dart';
import 'package:writer/repositories/remote_repository.dart';

final hotTopicsPlatformsProvider =
    FutureProvider.autoDispose<List<HotTopicPlatform>>((ref) async {
      final repo = ref.watch(remoteRepositoryProvider);
      final data = await repo.getHotTopicsPlatforms();
      return data
          .map<HotTopicPlatform>(
            (item) => HotTopicPlatform.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    });

final hotTopicsRegionCodeProvider = Provider<String>((ref) {
  return 'zh-CN';
});

final hotTopicsPlatformKeyProvider = Provider<String?>((ref) {
  return null;
});

final hotTopicsLimitProvider = Provider<int>((ref) {
  return 100;
});

final latestHotTopicsProvider = FutureProvider.autoDispose<List<HotTopic>>((
  ref,
) async {
  final repo = ref.watch(remoteRepositoryProvider);
  final regionCode = ref.watch(hotTopicsRegionCodeProvider);
  final platformKey = ref.watch(hotTopicsPlatformKeyProvider);
  final limit = ref.watch(hotTopicsLimitProvider);

  final data = await repo.getLatestHotTopics(
    regionCode: regionCode,
    platformKey: platformKey,
    limit: limit,
  );
  return data
      .map<HotTopic>((item) => HotTopic.fromMap(item as Map<String, dynamic>))
      .toList();
});

final hotTopicsTrackingProvider =
    FutureProvider.autoDispose<List<HotTopicTracking>>((ref) async {
      final repo = ref.watch(remoteRepositoryProvider);
      final regionCode = ref.watch(hotTopicsRegionCodeProvider);
      final limit = ref.watch(hotTopicsLimitProvider);

      final data = await repo.getHotTopicsTracking(
        regionCode: regionCode,
        limit: limit,
      );
      return data
          .map<HotTopicTracking>(
            (item) => HotTopicTracking.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    });

final trendingHotTopicsProvider =
    FutureProvider.autoDispose<List<HotTopicTracking>>((ref) async {
      final repo = ref.watch(remoteRepositoryProvider);
      final regionCode = ref.watch(hotTopicsRegionCodeProvider);
      final limit = ref.watch(hotTopicsLimitProvider);

      final data = await repo.getTrendingHotTopics(
        regionCode: regionCode,
        minMomentumScore: 50,
        limit: limit,
      );
      return data
          .map<HotTopicTracking>(
            (item) => HotTopicTracking.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    });

final hotTopicsFilterProvider = StateProvider<HotTopicsFilter>((ref) {
  return const HotTopicsFilter(regionCode: 'zh-CN', platformKey: null);
});

class HotTopicsFilter {
  final String regionCode;
  final String? platformKey;

  const HotTopicsFilter({required this.regionCode, this.platformKey});

  HotTopicsFilter copyWith({String? regionCode, String? platformKey}) {
    return HotTopicsFilter(
      regionCode: regionCode ?? this.regionCode,
      platformKey: platformKey ?? this.platformKey,
    );
  }
}
