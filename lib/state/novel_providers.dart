import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/recent_progress_details.dart';
import '../repositories/novel_repository.dart';
import 'providers.dart';
import 'progress_providers.dart';
import '../main.dart';

final novelsProvider = FutureProvider<List<Novel>>((ref) async {
  // Re-run when auth state changes to keep Library fresh after login/logout
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const [];
  final repo = ref.watch(novelRepositoryProvider);
  return repo.fetchPublicNovels();
});

/// My Novels: novels where the current user is a member (owner or contributor).
final memberNovelsProvider = FutureProvider<List<Novel>>((ref) async {
  // React to auth changes so membership list updates on login/logout.
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const [];
  final repo = ref.watch(novelRepositoryProvider);
  return repo.fetchMemberNovels();
});

/// Library novels: union of public novels and novels where the current user is a member.
final libraryNovelsProvider = FutureProvider<List<Novel>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  final local = ref.watch(localStorageRepositoryProvider);
  if (!isSignedIn) {
    final cached = await local.getLibraryNovels();
    return cached;
  }
  final public = await ref.watch(novelsProvider.future);
  final memberAsync = ref.watch(memberNovelsProvider);
  if (memberAsync.hasError) {
    final cached = await local.getLibraryNovels();
    if (cached.isNotEmpty) {
      final byId = <String, Novel>{};
      for (final n in public) {
        byId[n.id] = n;
      }
      for (final n in cached) {
        byId[n.id] = n;
      }
      return byId.values.toList();
    }
    return public;
  }
  final member = await ref.watch(memberNovelsProvider.future);
  final byId = <String, Novel>{};
  for (final n in public) {
    byId[n.id] = n;
  }
  for (final n in member) {
    byId[n.id] = n;
  }
  final union = byId.values.toList();
  await local.saveLibraryNovels(union);
  return union;
});

final novelProvider = FutureProvider.family<Novel?, String>((
  ref,
  novelId,
) async {
  final repo = ref.watch(novelRepositoryProvider);
  return repo.getNovel(novelId);
});

final chaptersProvider = FutureProvider.family<List<Chapter>, String>((
  ref,
  novelId,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const [];
  final repo = ref.watch(novelRepositoryProvider);
  return repo.fetchChaptersByNovel(novelId);
});

final recentProgressDetailsProvider =
    FutureProvider<List<RecentProgressDetails>>((ref) async {
      final recentProgress = await ref.watch(recentUserProgressProvider.future);
      final novelRepo = ref.watch(novelRepositoryProvider);

      final details = <RecentProgressDetails>[];
      for (final progress in recentProgress) {
        final novel = await novelRepo.getNovel(progress.novelId);
        final chapter = await novelRepo.getChapter(progress.chapterId);
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
