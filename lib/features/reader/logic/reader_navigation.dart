import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chapter.dart';
import '../../../repositories/chapter_repository.dart';
import '../../../state/performance_settings.dart';

class ChapterNavResult {
  final String chapterId;
  final String title;
  final String? content;
  final int currentIdx;
  const ChapterNavResult({
    required this.chapterId,
    required this.title,
    required this.content,
    required this.currentIdx,
  });
}

ChapterNavResult? computeNext(
  List<Chapter> all,
  int currentIdx,
  String novelId,
) {
  final nextIdx = currentIdx + 1;
  if (nextIdx >= all.length) return null;
  final next = all[nextIdx];
  return ChapterNavResult(
    chapterId: next.id,
    title: next.title ?? 'Chapter ${next.idx}',
    content: next.content,
    currentIdx: nextIdx,
  );
}

ChapterNavResult? computePrev(
  List<Chapter> all,
  int currentIdx,
  String novelId,
) {
  final prevIdx = currentIdx - 1;
  if (prevIdx < 0) return null;
  final prev = all[prevIdx];
  return ChapterNavResult(
    chapterId: prev.id,
    title: prev.title ?? 'Chapter ${prev.idx}',
    content: prev.content,
    currentIdx: prevIdx,
  );
}

Future<void> prefetchNextIfEnabled({
  required BuildContext context,
  required List<Chapter> all,
  required int fromIdx,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final perf = container.read(performanceSettingsProvider);
  if (!perf.prefetchNextChapter) return;
  final idx = fromIdx + 1;
  if (idx >= all.length) return;
  final next = all[idx];
  final repo = container.read(chapterRepositoryProvider);
  await repo.getChapter(next);
}
