import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/reader/logic/reader_navigation.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/state/performance_settings.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/repositories/chapter_repository.dart';

class CapturingChapterRepo implements ChapterPort {
  Chapter? lastPrefetched;
  @override
  Future<List<Chapter>> getChapters(String novelId) async => const [];
  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    lastPrefetched = chapter;
    return chapter;
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {}
  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {}
  @override
  Future<int> getNextIdx(String novelId) async => 1;
  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    return Chapter(
      id: 'c$idx',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {}

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {}
}

void main() {
  test('computeNext and computePrev return expected results', () {
    final all = [
      const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'A', content: 'a'),
      const Chapter(id: 'c2', novelId: 'n1', idx: 2, title: null, content: 'b'),
      const Chapter(id: 'c3', novelId: 'n1', idx: 3, title: 'C', content: 'c'),
    ];
    final next = computeNext(all, 0, 'n1');
    expect(next!.chapterId, 'c2');
    expect(next.title, 'Chapter 2');
    expect(next.currentIdx, 1);
    final prev = computePrev(all, 2, 'n1');
    expect(prev!.chapterId, 'c2');
    expect(prev.title, 'Chapter 2');
    expect(prev.currentIdx, 1);
    expect(computePrev(all, 0, 'n1'), isNull);
    expect(computeNext(all, 2, 'n1'), isNull);
  });

  testWidgets('prefetchNextIfEnabled triggers repository fetch when enabled', (
    tester,
  ) async {
    final repo = CapturingChapterRepo();
    final all = [
      const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'A', content: 'a'),
      const Chapter(id: 'c2', novelId: 'n1', idx: 2, title: 'B', content: 'b'),
    ];
    final app = ProviderScope(
      overrides: [
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        chapterRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pumpWidget(app);
    await prefetchNextIfEnabled(
      context: tester.element(find.byType(Scaffold)),
      all: all,
      fromIdx: 0,
    );
    expect(repo.lastPrefetched?.id, 'c2');
  });

  testWidgets('prefetchNextIfEnabled does nothing when disabled', (
    tester,
  ) async {
    final repo = CapturingChapterRepo();
    final all = [
      const Chapter(id: 'c1', novelId: 'n1', idx: 1, title: 'A', content: 'a'),
    ];
    final app = ProviderScope(
      overrides: [
        performanceSettingsProvider.overrideWith(
          (ref) => PerformanceSettingsNotifier.lazy(),
        ),
        chapterRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pumpWidget(app);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
      listen: false,
    );
    await container
        .read(performanceSettingsProvider.notifier)
        .setPrefetchNextChapter(false);
    await tester.pump();
    await prefetchNextIfEnabled(
      context: tester.element(find.byType(Scaffold)),
      all: all,
      fromIdx: 0,
    );
    expect(repo.lastPrefetched, isNull);
  });
}
