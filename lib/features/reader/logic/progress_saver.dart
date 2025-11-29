import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_progress.dart';
import '../../../state/progress_providers.dart';
import '../../../state/progress_notifier.dart';
import '../../../state/providers.dart';

enum SaveStatus { notEnabled, noUser, saved, error }

@visibleForTesting
User? Function()? mockGetUser;

@visibleForTesting
bool? mockSupabaseEnabled;

Future<SaveStatus> saveReaderProgress({
  required Ref ref,
  required String novelId,
  required String chapterId,
  required double scrollOffset,
  required int ttsIndex,
}) async {
  final bool enabled = mockSupabaseEnabled != null
      ? mockSupabaseEnabled!
      : ref.read(supabaseEnabledProvider);
  if (!enabled) return SaveStatus.notEnabled;

  User? user;
  if (mockGetUser != null) {
    user = mockGetUser!();
  } else {
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      // If we are testing with enabled=true but Supabase not init, return error or handle gracefully
      if (mockSupabaseEnabled == true) {
        // Fallback if we forgot to mock user in test
        return SaveStatus.error;
      }
      rethrow;
    }
  }

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
