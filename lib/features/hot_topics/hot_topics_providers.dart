import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writer/models/hot_topic.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/controllers/app_settings.dart';

String _mapLanguageToRegionCode(String languageCode) {
  switch (languageCode) {
    case 'zh':
      return 'zh-CN';
    case 'zh-TW':
      return 'zh-TW';
    case 'de':
      return 'de';
    case 'es':
      return 'es';
    case 'it':
      return 'it';
    case 'fr':
      return 'fr';
    case 'ru':
      return 'ru';
    case 'ja':
      return 'ja';
    case 'ko':
      return 'ko';
    case 'en':
      // English users get US region hot topics
      return 'en-US';
    default:
      return 'zh-CN';
  }
}

final hotTopicsPlatformsProvider =
    FutureProvider.autoDispose<List<HotTopicPlatform>>((ref) async {
      final repo = ref.watch(remoteRepositoryProvider);
      final regionCode = ref.watch(hotTopicsRegionCodeProvider);
      final data = await repo.getHotTopicsPlatforms(regionCode: regionCode);
      final platforms = data
          .map<HotTopicPlatform>(
            (item) => HotTopicPlatform.fromMap(item as Map<String, dynamic>),
          )
          .where((p) => p.isActive)
          .toList();
      final regional = platforms
          .where((p) => p.regionCode == regionCode)
          .toList();
      return regional.isNotEmpty ? regional : platforms;
    });

final hotTopicsRegionCodeProvider = Provider<String>((ref) {
  final appLocale = ref.watch(appSettingsProvider);
  return _mapLanguageToRegionCode(appLocale.languageCode);
});

final hotTopicsPlatformKeyProvider = Provider<String?>((ref) {
  final filter = ref.watch(hotTopicsFilterProvider);
  return filter.platformKey;
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
  return const HotTopicsFilter(platformKey: null);
});

class HotTopicsFilter {
  final String? platformKey;

  const HotTopicsFilter({this.platformKey});

  static const Object _unset = Object();

  HotTopicsFilter copyWith({Object? platformKey = _unset}) {
    return HotTopicsFilter(
      platformKey: identical(platformKey, _unset)
          ? this.platformKey
          : platformKey as String?,
    );
  }
}
