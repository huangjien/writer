import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/models/recent_progress_details.dart';
import './data_manager_provider.dart';
import './progress_providers.dart';
import './providers.dart';

final novelsProviderV2 = FutureProvider<List<Novel>>((ref) async {
  return ref.watch(libraryNovelsProviderV2.future);
});

final memberNovelsProviderV2 = FutureProvider<List<Novel>>((ref) async {
  final allNovels = await ref.watch(libraryNovelsProviderV2.future);
  return allNovels.where((n) => !n.isPublic).toList();
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

      final details = await Future.wait(
        recentProgress.map((progress) async {
          final novelFuture = dataManager.getNovel(progress.novelId);
          final chapterFuture = dataManager.getChapter(
            Chapter(id: progress.chapterId, novelId: progress.novelId, idx: 0),
          );
          final results = await Future.wait<dynamic>([
            novelFuture,
            chapterFuture,
          ]);
          final novel = results[0] as Novel?;
          final chapter = results[1] as Chapter?;
          if (novel == null || chapter == null) {
            return null;
          }
          return RecentProgressDetails(
            userProgress: progress,
            novel: novel,
            chapter: chapter,
          );
        }),
      );
      return details.whereType<RecentProgressDetails>().toList();
    });
