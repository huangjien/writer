import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/state/chapter_edit_controller.dart';
import 'package:novel_reader/models/chapter.dart';
import 'package:novel_reader/repositories/chapter_port.dart';

class FakeChapterRepo implements ChapterPort {
  Chapter? lastUpdated;
  String? lastDeletedId;
  int nextIdx = 2;
  bool throwOnUpdate = false;
  bool throwOnCreate = false;
  bool throwOnDelete = false;

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
    return [];
  }

  @override
  Future<int> getNextIdx(String novelId) async {
    return nextIdx;
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

  test('setTitle and setContent mark state dirty', () async {
    final repo = FakeChapterRepo();
    final ctrl = ChapterEditController(initial, repo);
    ctrl.setTitle('New');
    ctrl.setContent('Body');
    expect(ctrl.state.title, 'New');
    expect(ctrl.state.content, 'Body');
    expect(ctrl.state.isDirty, true);
  });

  test('save success resets dirty and isSaving', () async {
    final repo = FakeChapterRepo();
    final ctrl = ChapterEditController(initial, repo);
    final ok = await ctrl.save();
    expect(ok, true);
    expect(ctrl.state.isSaving, false);
    expect(ctrl.state.isDirty, false);
    expect(repo.lastUpdated?.id, 'c1');
  });

  test('save failure sets errorMessage', () async {
    final repo = FakeChapterRepo()..throwOnUpdate = true;
    final ctrl = ChapterEditController(initial, repo);
    final ok = await ctrl.save();
    expect(ok, false);
    expect(ctrl.state.errorMessage?.isNotEmpty, true);
  });

  test('createNextChapter success returns created chapter', () async {
    final repo = FakeChapterRepo()..nextIdx = 3;
    final ctrl = ChapterEditController(initial, repo);
    final created = await ctrl.createNextChapter(defaultTitle: 'Chapter 3');
    expect(created?.idx, 3);
    expect(ctrl.state.isSaving, false);
  });

  test('deleteCurrentChapter success returns true', () async {
    final repo = FakeChapterRepo();
    final ctrl = ChapterEditController(initial, repo);
    final ok = await ctrl.deleteCurrentChapter();
    expect(ok, true);
    expect(repo.lastDeletedId, 'c1');
  });
}
