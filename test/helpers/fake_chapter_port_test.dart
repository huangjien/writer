import 'package:flutter_test/flutter_test.dart';
import 'package:writer/helpers/fake_chapter_port.dart';
import 'package:writer/models/chapter.dart';

void main() {
  group('FakeChapterPort', () {
    late FakeChapterPort fakePort;
    const testNovelId = 'test-novel-1';
    const testChapterId = 'test-chapter-1';

    setUp(() {
      fakePort = FakeChapterPort();
    });

    test('getChapters returns empty list', () async {
      final chapters = await fakePort.getChapters(testNovelId);
      expect(chapters, isEmpty);
    });

    test('getChapter returns the same chapter', () async {
      final chapter = const Chapter(
        id: testChapterId,
        novelId: testNovelId,
        idx: 1,
        title: 'Test Chapter',
        content: 'Test content',
      );
      final result = await fakePort.getChapter(chapter);
      expect(result, same(chapter));
    });

    test('updateChapter completes successfully', () async {
      final chapter = const Chapter(
        id: testChapterId,
        novelId: testNovelId,
        idx: 1,
        title: 'Test Chapter',
        content: 'Test content',
      );
      await fakePort.updateChapter(chapter);
      expect(true, isTrue); // Test passes if no exception is thrown
    });

    test('updateChapterIdx completes successfully', () async {
      await fakePort.updateChapterIdx(testChapterId, 2);
      expect(true, isTrue); // Test passes if no exception is thrown
    });

    test('bulkShiftIdx completes successfully', () async {
      await fakePort.bulkShiftIdx(testNovelId, 1, 1);
      expect(true, isTrue); // Test passes if no exception is thrown
    });

    test('getNextIdx returns 1', () async {
      final nextIdx = await fakePort.getNextIdx(testNovelId);
      expect(nextIdx, equals(1));
    });

    test('createChapter creates chapter with generated ID', () async {
      final chapter = await fakePort.createChapter(
        novelId: testNovelId,
        idx: 1,
        title: 'Test Chapter',
        content: 'Test content',
      );

      expect(chapter.id, equals('fake-$testNovelId-1'));
      expect(chapter.novelId, equals(testNovelId));
      expect(chapter.idx, equals(1));
      expect(chapter.title, equals('Test Chapter'));
      expect(chapter.content, equals('Test content'));
    });

    test(
      'createChapter uses default title and content when not provided',
      () async {
        final chapter = await fakePort.createChapter(
          novelId: testNovelId,
          idx: 2,
        );

        expect(chapter.id, equals('fake-$testNovelId-2'));
        expect(chapter.novelId, equals(testNovelId));
        expect(chapter.idx, equals(2));
        expect(chapter.title, equals('Chapter 2'));
        expect(chapter.content, equals(''));
      },
    );

    test('deleteChapter completes successfully', () async {
      await fakePort.deleteChapter(testChapterId);
      expect(true, isTrue); // Test passes if no exception is thrown
    });

    test('createMultipleChapters generates unique IDs', () async {
      final chapter1 = await fakePort.createChapter(
        novelId: testNovelId,
        idx: 1,
      );
      final chapter2 = await fakePort.createChapter(
        novelId: testNovelId,
        idx: 2,
      );
      final chapter3 = await fakePort.createChapter(novelId: 'novel-2', idx: 1);

      expect(chapter1.id, equals('fake-$testNovelId-1'));
      expect(chapter2.id, equals('fake-$testNovelId-2'));
      expect(chapter3.id, equals('fake-novel-2-1'));

      expect(chapter1.id, isNot(equals(chapter2.id)));
      expect(chapter1.id, isNot(equals(chapter3.id)));
      expect(chapter2.id, isNot(equals(chapter3.id)));
    });
  });
}
