import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/user_progress.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/progress_notifier.dart';
import 'package:writer/state/providers.dart';

enum SaveStatus { notEnabled, noUser, saved, error }

Future<SaveStatus> saveReaderProgress({
  required Ref ref,
  required String novelId,
  required String chapterId,
  required double scrollOffset,
  required int ttsIndex,
}) async {
  final isSignedIn = ref.read(isSignedInProvider);
  if (!isSignedIn) return SaveStatus.notEnabled;

  final user = await ref.read(currentUserProvider.future);
  if (user == null) return SaveStatus.noUser;

  final progress = UserProgress(
    userId: user.id,
    novelId: novelId,
    chapterId: chapterId,
    scrollOffset: scrollOffset,
    ttsCharIndex: ttsIndex,
    updatedAt: DateTime.now(),
  );

  // ProgressController calls Repository which calls RemoteRepository.
  final ok = await ref.read(progressControllerProvider.notifier).save(progress);
  ref.invalidate(lastProgressProvider(novelId));
  ref.invalidate(latestUserProgressProvider);
  return ok ? SaveStatus.saved : SaveStatus.error;
}
