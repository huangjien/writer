import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_line.dart';
import 'providers.dart';
import '../services/story_lines_service.dart';

final storyLinesServiceRefProvider = Provider<StoryLinesService>((ref) {
  return ref.watch(storyLinesServiceProvider);
});

final storyLinesProvider = FutureProvider<List<StoryLine>>((ref) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return const <StoryLine>[];
  ref.watch(authStateProvider);
  final svc = ref.watch(storyLinesServiceRefProvider);
  return svc.fetchStoryLines();
});

final storyLineByIdProvider = FutureProvider.family<StoryLine?, String>((
  ref,
  id,
) async {
  final enabled = ref.watch(supabaseEnabledProvider);
  if (!enabled) return null;
  ref.watch(authStateProvider);
  final svc = ref.watch(storyLinesServiceRefProvider);
  return svc.getStoryLine(id);
});
