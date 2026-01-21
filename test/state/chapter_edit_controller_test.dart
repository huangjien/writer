import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/chapter.dart';
import 'package:writer/repositories/chapter_port.dart';
import 'package:writer/state/chapter_edit_controller.dart';
import 'package:writer/common/errors/offline_exception.dart';

class MockChapterPort extends Mock implements ChapterPort {}

class FakeChapter extends Fake implements Chapter {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChapter());
  });

  group('ChapterEditController', () {
    late MockChapterPort mockRepo;
    late Chapter initialChapter;

    setUp(() {
      mockRepo = MockChapterPort();
      initialChapter = const Chapter(
        id: 'c1',
        novelId: 'n1',
        idx: 1,
        title: 'Initial Title',
        content: 'Initial Content',
      );
    });

    test('initializes with correct state', () {
      final controller = ChapterEditController(initialChapter, mockRepo);
      expect(controller.state.chapterId, 'c1');
      expect(controller.state.title, 'Initial Title');
      expect(controller.state.content, 'Initial Content');
      expect(controller.state.isDirty, false);
      expect(controller.state.isSaving, false);
    });

    test('setTitle updates state and sets isDirty', () {
      final controller = ChapterEditController(initialChapter, mockRepo);
      controller.setTitle('New Title');
      expect(controller.state.title, 'New Title');
      expect(controller.state.isDirty, true);
    });

    test('setContent updates state and sets isDirty', () {
      final controller = ChapterEditController(initialChapter, mockRepo);
      controller.setContent('New Content');
      expect(controller.state.content, 'New Content');
      expect(controller.state.isDirty, true);
    });

    test('save calls updateChapter and resets isDirty on success', () async {
      final controller = ChapterEditController(initialChapter, mockRepo);

      when(() => mockRepo.updateChapter(any())).thenAnswer((_) async {});

      controller.setTitle('Updated Title');
      final result = await controller.save();

      expect(result, true);
      verify(
        () => mockRepo.updateChapter(
          any(
            that: isA<Chapter>()
                .having((c) => c.id, 'id', 'c1')
                .having((c) => c.title, 'title', 'Updated Title'),
          ),
        ),
      ).called(1);

      expect(controller.state.isDirty, false);
      expect(controller.state.isSaving, false);
      expect(controller.state.errorMessage, isNull);
    });

    test('save handles OfflineException', () async {
      final controller = ChapterEditController(initialChapter, mockRepo);

      when(
        () => mockRepo.updateChapter(any()),
      ).thenThrow(const OfflineException('No internet'));

      controller.setTitle('Updated Title');
      final result = await controller.save();

      expect(result, true); // Still returns true for offline save
      expect(controller.state.isQueuedForSync, true);
      expect(controller.state.offlineMessage, 'No internet');
      expect(controller.state.isSaving, false);
    });

    test('save sets errorMessage on generic failure', () async {
      final controller = ChapterEditController(initialChapter, mockRepo);

      when(
        () => mockRepo.updateChapter(any()),
      ).thenThrow(Exception('Save failed'));

      controller.setTitle('Updated Title');
      final result = await controller.save();

      expect(result, false);
      expect(controller.state.isDirty, true); // Remains dirty on failure
      expect(controller.state.isSaving, false);
      expect(controller.state.errorMessage, contains('Save failed'));
    });

    test(
      'deleteCurrentChapter calls deleteChapter and normalizes indices',
      () async {
        final controller = ChapterEditController(initialChapter, mockRepo);

        when(() => mockRepo.deleteChapter('c1')).thenAnswer((_) async {});
        when(() => mockRepo.getChapters('n1')).thenAnswer((_) async => []);

        final result = await controller.deleteCurrentChapter();

        expect(result, true);
        verify(() => mockRepo.deleteChapter('c1')).called(1);
        verify(
          () => mockRepo.getChapters('n1'),
        ).called(1); // called by _normalizeIndices
      },
    );
  });
}
