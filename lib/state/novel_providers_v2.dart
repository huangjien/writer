import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/recent_progress_details.dart';
import './data_manager_provider.dart';
import './progress_providers.dart';
import './providers.dart';

final novelsProviderV2 = FutureProvider<List<Novel>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  final dataManager = ref.watch(dataManagerProvider);

  if (!isSignedIn) {
    final local = ref.watch(localStorageRepositoryProvider);
    return local.getLibraryNovels();
  }

  return dataManager.getAllNovels();
});

final memberNovelsProviderV2 = FutureProvider<List<Novel>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const [];

  final dataManager = ref.watch(dataManagerProvider);
  final allNovels = await dataManager.getAllNovels();
  final memberNovels = allNovels.where((n) => !n.isPublic).toList();
  return memberNovels;
});

final libraryNovelsProviderV2 = FutureProvider<List<Novel>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);

  if (!isSignedIn) {
    final local = ref.watch(localStorageRepositoryProvider);
    return local.getLibraryNovels();
  }

  final dataManager = ref.watch(dataManagerProvider);
  return dataManager.getAllNovels();
});

final novelProviderV2 = FutureProvider.family<Novel?, String>((
  ref,
  novelId,
) async {
  final dataManager = ref.watch(dataManagerProvider);
  return dataManager.getNovel(novelId);
});

final chaptersProviderV2 = FutureProvider.family<List<Chapter>, String>((
  ref,
  novelId,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const [];

  final dataManager = ref.watch(dataManagerProvider);
  return dataManager.getChapters(novelId);
});

final recentProgressDetailsProviderV2 =
    FutureProvider<List<RecentProgressDetails>>((ref) async {
      final recentProgress = await ref.watch(recentUserProgressProvider.future);
      final dataManager = ref.watch(dataManagerProvider);

      final details = <RecentProgressDetails>[];
      for (final progress in recentProgress) {
        final novel = await dataManager.getNovel(progress.novelId);
        final chapter = await dataManager.getChapter(
          Chapter(id: progress.chapterId, novelId: progress.novelId, idx: 0),
        );
        if (novel != null && chapter != null) {
          details.add(
            RecentProgressDetails(
              userProgress: progress,
              novel: novel,
              chapter: chapter,
            ),
          );
        }
      }
      return details;
    });
