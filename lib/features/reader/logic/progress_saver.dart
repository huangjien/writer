import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_progress.dart';
import '../../../state/progress_providers.dart';
import '../../../state/progress_notifier.dart';
import '../../../state/supabase_config.dart';

enum SaveStatus { notEnabled, noUser, saved, error }

Future<SaveStatus> saveReaderProgress({
  required WidgetRef ref,
  required String novelId,
  required String chapterId,
  required double scrollOffset,
  required int ttsIndex,
}) async {
  if (!supabaseEnabled) return SaveStatus.notEnabled;
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) return SaveStatus.noUser;
  final progress = UserProgress(
    userId: user.id,
    novelId: novelId,
    chapterId: chapterId,
    scrollOffset: scrollOffset,
    ttsCharIndex: ttsIndex,
    updatedAt: DateTime.now(),
  );
  final ok = await ref.read(progressControllerProvider.notifier).save(progress);
  ref.invalidate(lastProgressProvider(novelId));
  ref.invalidate(latestUserProgressProvider);
  return ok ? SaveStatus.saved : SaveStatus.error;
}
