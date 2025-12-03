import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/state/chapter_edit_controller.dart';

class FakeChapterRepo implements ChapterPort {
  Chapter? lastUpdated;
  String? lastDeletedId;
  int nextIdx = 2;
  bool throwOnUpdate = false;
  bool throwOnCreate = false;
  bool throwOnDelete = false;
  List<Chapter> chapters = [];

  @override
  Future<Chapter> createChapter({
    required String novelId,
    required int idx,
    String? title,
    String? content,
  }) async {
    if (throwOnCreate) throw StateError('create failed');
    return Chapter(
      id: 'new',
      novelId: novelId,
      idx: idx,
      title: title,
      content: content,
    );
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    if (throwOnDelete) throw StateError('delete failed');
    lastDeletedId = chapterId;
  }

  @override
  Future<Chapter> getChapter(Chapter chapter) async {
    return chapter;
  }

  @override
  Future<List<Chapter>> getChapters(String novelId) async {
    return chapters;
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    return nextIdx;
  }

  @override
  Future<void> updateChapterIdx(String chapterId, int newIdx) async {
    final i = chapters.indexWhere((c) => c.id == chapterId);
    if (i >= 0) {
      final c = chapters[i];
      chapters[i] = Chapter(
        id: c.id,
        novelId: c.novelId,
        idx: newIdx,
        title: c.title,
        content: c.content,
      );
    }
  }

  @override
  Future<void> bulkShiftIdx(String novelId, int fromIdx, int delta) async {
    chapters = chapters
        .map(
          (c) => c.idx >= fromIdx
              ? Chapter(
                  id: c.id,
                  novelId: c.novelId,
                  idx: c.idx + delta,
                  title: c.title,
                  content: c.content,
                )
              : c,
        )
        .toList();
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    if (throwOnUpdate) throw StateError('update failed');
    lastUpdated = chapter;
  }
}

void main() {
  final initial = Chapter(
    id: 'c1',
    novelId: 'n1',
    idx: 1,
    title: 'T',
    content: 'C',
  );

  ProviderContainer makeContainer(FakeChapterRepo repo) {
    final container = ProviderContainer(
      overrides: [
        chapterEditControllerProvider(
          initial,
        ).overrideWith((ref) => ChapterEditController(initial, repo)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('setTitle and setContent mark state dirty', () async {
    final repo = FakeChapterRepo();
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    notifier.setTitle('New');
    notifier.setContent('Body');

    final state = container.read(chapterEditControllerProvider(initial));
    expect(state.title, 'New');
    expect(state.content, 'Body');
    expect(state.isDirty, true);
  });

  test('save success resets dirty and isSaving', () async {
    final repo = FakeChapterRepo();
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    final ok = await notifier.save();
    expect(ok, true);

    final state = container.read(chapterEditControllerProvider(initial));
    expect(state.isSaving, false);
    expect(state.isDirty, false);
    expect(repo.lastUpdated?.id, 'c1');
  });

  test('save failure sets errorMessage', () async {
    final repo = FakeChapterRepo()..throwOnUpdate = true;
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    final ok = await notifier.save();
    expect(ok, false);

    final state = container.read(chapterEditControllerProvider(initial));
    expect(state.errorMessage?.isNotEmpty, true);
  });

  test('createNextChapter success returns created chapter', () async {
    final repo = FakeChapterRepo()..nextIdx = 3;
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    final created = await notifier.createNextChapter(defaultTitle: 'Chapter 3');
    expect(created?.idx, 3);

    final state = container.read(chapterEditControllerProvider(initial));
    expect(state.isSaving, false);
  });

  test(
    'changeIndexFromFloat reorders by rounding and shifting up range',
    () async {
      final repo = FakeChapterRepo();
      final initialHigh = const Chapter(
        id: 'c118',
        novelId: 'n1',
        idx: 118,
        title: 'Old 118',
        content: null,
      );
      repo.chapters = [
        initialHigh,
        const Chapter(
          id: 'c15',
          novelId: 'n1',
          idx: 15,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c16',
          novelId: 'n1',
          idx: 16,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c117',
          novelId: 'n1',
          idx: 117,
          title: 't',
          content: null,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          chapterEditControllerProvider(
            initialHigh,
          ).overrideWith((ref) => ChapterEditController(initialHigh, repo)),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        chapterEditControllerProvider(initialHigh).notifier,
      );

      final ok = await notifier.changeIndexFromFloat(14.5);
      expect(ok, true);
      final c15 = repo.chapters.firstWhere((c) => c.id == 'c15');
      final c16 = repo.chapters.firstWhere((c) => c.id == 'c16');
      final c117 = repo.chapters.firstWhere((c) => c.id == 'c117');
      final moved = repo.chapters.firstWhere((c) => c.id == 'c118');
      expect(moved.idx, 15);
      expect(c15.idx, 16);
      expect(c16.idx, 17);
      expect(c117.idx, 118);
    },
  );

  test('deleteCurrentChapter success returns true', () async {
    final repo = FakeChapterRepo();
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    final ok = await notifier.deleteCurrentChapter();
    expect(ok, true);
    expect(repo.lastDeletedId, 'c1');
  });

  test('formatContent formats text correctly', () async {
    final repo = FakeChapterRepo();
    final container = makeContainer(repo);
    final notifier = container.read(
      chapterEditControllerProvider(initial).notifier,
    );

    notifier.setContent('Line 1\nLine 2\n\nLine 3');
    notifier.formatContent();

    final state = container.read(chapterEditControllerProvider(initial));
    // Expect no indentation and double newlines
    expect(state.content, 'Line 1\n\nLine 2\n\nLine 3');
    expect(state.isDirty, true);
  });
  test(
    'deleteCurrentChapter normalizes indices to contiguous sequence',
    () async {
      final repo = FakeChapterRepo();
      final toDelete = const Chapter(
        id: 'c121',
        novelId: 'n1',
        idx: 121,
        title: 'Del',
        content: null,
      );
      repo.chapters = [
        const Chapter(
          id: 'c1',
          novelId: 'n1',
          idx: 1,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c14',
          novelId: 'n1',
          idx: 14,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c16',
          novelId: 'n1',
          idx: 16,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c17',
          novelId: 'n1',
          idx: 17,
          title: 't',
          content: null,
        ),
        const Chapter(
          id: 'c118',
          novelId: 'n1',
          idx: 118,
          title: 't',
          content: null,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          chapterEditControllerProvider(
            toDelete,
          ).overrideWith((ref) => ChapterEditController(toDelete, repo)),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        chapterEditControllerProvider(toDelete).notifier,
      );
      final ok = await notifier.deleteCurrentChapter();
      expect(ok, true);
      final normalized = repo.chapters..sort((a, b) => a.idx.compareTo(b.idx));
      for (int i = 0; i < normalized.length; i++) {
        expect(normalized[i].idx, i + 1);
      }
    },
  );
}
