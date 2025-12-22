import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story_line.dart';
import 'providers.dart';
import '../services/story_lines_service.dart';

final storyLinesServiceRefProvider = Provider<StoryLinesService>((ref) {
  return ref.watch(storyLinesServiceProvider);
});

final storyLinesProvider = FutureProvider<List<StoryLine>>((ref) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return const <StoryLine>[];
  final svc = ref.watch(storyLinesServiceRefProvider);
  return svc.fetchStoryLines();
});

final storyLineByIdProvider = FutureProvider.family<StoryLine?, String>((
  ref,
  id,
) async {
  ref.watch(authStateProvider);
  final isSignedIn = ref.watch(isSignedInProvider);
  if (!isSignedIn) return null;
  final svc = ref.watch(storyLinesServiceRefProvider);
  return svc.getStoryLine(id);
});
