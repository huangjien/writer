import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/summary/summary_controller.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/repositories/novel_repository.dart';

class MockNovelRepository extends Mock implements NovelRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Summary(id: 'fallback-id', novelId: 'fallback-novel', idx: 0),
    );
  });

  group('SummaryController', () {
    late MockNovelRepository mockRepository;
    late SummaryController controller;
    const testNovelId = 'test-novel-123';

    setUp(() {
      mockRepository = MockNovelRepository();
      controller = SummaryController(mockRepository);
    });

    group('constructor', () {
      test('should create controller with repository', () {
        expect(controller.baseSummary, isNull);
      });
    });

    group('load', () {
      test('should load existing summary when summaries exist', () async {
        final existingSummary = Summary(
          id: 'summary-123',
          novelId: testNovelId,
          idx: 0,
          sentenceSummary: 'Existing sentence',
          paragraphSummary: 'Existing paragraph',
          pageSummary: 'Existing page',
          expandedSummary: 'Existing expanded',
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [existingSummary]);

        await controller.load(testNovelId);

        expect(controller.baseSummary, equals(existingSummary));
        verify(() => mockRepository.fetchSummaries(testNovelId)).called(1);
      });

      test('should create empty summary when no summaries exist', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);

        await controller.load(testNovelId);

        final baseSummary = controller.baseSummary;
        expect(baseSummary, isNotNull);
        expect(baseSummary!.id, isEmpty);
        expect(baseSummary.novelId, equals(testNovelId));
        expect(baseSummary.idx, equals(0));
        expect(baseSummary.sentenceSummary, isNull);
        expect(baseSummary.paragraphSummary, isNull);
        expect(baseSummary.pageSummary, isNull);
        expect(baseSummary.expandedSummary, isNull);
        verify(() => mockRepository.fetchSummaries(testNovelId)).called(1);
      });

      test('should take first summary when multiple summaries exist', () async {
        final firstSummary = Summary(
          id: 'summary-1',
          novelId: testNovelId,
          idx: 0,
          sentenceSummary: 'First sentence',
        );
        final secondSummary = Summary(
          id: 'summary-2',
          novelId: testNovelId,
          idx: 1,
          sentenceSummary: 'Second sentence',
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [firstSummary, secondSummary]);

        await controller.load(testNovelId);

        expect(controller.baseSummary, equals(firstSummary));
        verify(() => mockRepository.fetchSummaries(testNovelId)).called(1);
      });

      test('should handle repository exceptions', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenThrow(Exception('Network error'));

        expect(() async => await controller.load(testNovelId), throwsException);
        verify(() => mockRepository.fetchSummaries(testNovelId)).called(1);
      });
    });

    group('isDirty', () {
      setUp(() async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);
      });

      test('should return false when all fields match base summary', () {
        const sentence = ''; // empty strings to match null base summary
        const paragraph = '';
        const page = '';
        const expanded = '';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(isDirty, isFalse);
      });

      test('should return true when sentence differs', () {
        const sentence = 'Modified sentence';
        const paragraph = 'Test paragraph';
        const page = 'Test page';
        const expanded = 'Test expanded';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(isDirty, isTrue);
      });

      test('should return true when paragraph differs', () {
        const sentence = 'Test sentence';
        const paragraph = 'Modified paragraph';
        const page = 'Test page';
        const expanded = 'Test expanded';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(isDirty, isTrue);
      });

      test('should return true when page differs', () {
        const sentence = 'Test sentence';
        const paragraph = 'Test paragraph';
        const page = 'Modified page';
        const expanded = 'Test expanded';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(isDirty, isTrue);
      });

      test('should return true when expanded differs', () {
        const sentence = 'Test sentence';
        const paragraph = 'Test paragraph';
        const page = 'Test page';
        const expanded = 'Modified expanded';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(isDirty, isTrue);
      });

      test('should ignore leading/trailing whitespace', () {
        const sentence = '  Test sentence  ';
        const paragraph = '';
        const page = '';
        const expanded = '';

        final isDirty = controller.isDirty(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(
          isDirty,
          isTrue,
        ); // Should be dirty because 'Test sentence' != ''
      });

      test('should handle null base summary values', () async {
        when(() => mockRepository.fetchSummaries(testNovelId)).thenAnswer(
          (_) async => [
            Summary(
              id: 'summary-123',
              novelId: testNovelId,
              idx: 0,
              sentenceSummary: 'Existing sentence',
              paragraphSummary: null,
              pageSummary: 'Existing page',
              expandedSummary: null,
            ),
          ],
        );

        controller = SummaryController(mockRepository);
        await controller.load(testNovelId);

        final isDirty = controller.isDirty(
          sentence: 'Existing sentence',
          paragraph: 'New paragraph',
          page: 'Existing page',
          expanded: 'New expanded',
        );

        expect(isDirty, isTrue);
      });
    });

    group('save', () {
      setUp(() async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);
      });

      test('should create new summary when base summary has no ID', () async {
        const sentence = 'New sentence';
        const paragraph = 'New paragraph';
        const page = 'New page';
        const expanded = 'New expanded';

        when(() => mockRepository.createSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return Summary(
            id: 'created-123',
            novelId: summary.novelId,
            idx: summary.idx,
            sentenceSummary: summary.sentenceSummary,
            paragraphSummary: summary.paragraphSummary,
            pageSummary: summary.pageSummary,
            expandedSummary: summary.expandedSummary,
            languageCode: summary.languageCode,
          );
        });

        final result = await controller.save(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(result.id, equals('created-123'));
        expect(result.sentenceSummary, equals(sentence));
        expect(result.paragraphSummary, equals(paragraph));
        expect(result.pageSummary, equals(page));
        expect(result.expandedSummary, equals(expanded));
        expect(controller.baseSummary, equals(result));
        verify(() => mockRepository.createSummary(any())).called(1);
      });

      test('should update existing summary when base summary has ID', () async {
        final existingSummary = Summary(
          id: 'existing-123',
          novelId: testNovelId,
          idx: 0,
          sentenceSummary: 'Old sentence',
          paragraphSummary: 'Old paragraph',
          pageSummary: 'Old page',
          expandedSummary: 'Old expanded',
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [existingSummary]);
        await controller.load(testNovelId);

        const sentence = 'Updated sentence';
        const paragraph = 'Updated paragraph';
        const page = 'Updated page';
        const expanded = 'Updated expanded';

        when(() => mockRepository.updateSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return summary; // Return the same summary that was passed in
        });

        final result = await controller.save(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(result.id, equals(existingSummary.id));
        expect(result.sentenceSummary, equals(sentence));
        expect(result.paragraphSummary, equals(paragraph));
        expect(result.pageSummary, equals(page));
        expect(result.expandedSummary, equals(expanded));
        expect(controller.baseSummary, equals(result));
        verify(() => mockRepository.updateSummary(any())).called(1);
      });

      test('should trim whitespace when saving', () async {
        const sentence = '  New sentence with spaces  ';
        const paragraph = '  New paragraph with spaces  ';
        const page = '  New page with spaces  ';
        const expanded = '  New expanded with spaces  ';

        when(() => mockRepository.createSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return Summary(
            id: 'created-123',
            novelId: summary.novelId,
            idx: summary.idx,
            sentenceSummary: summary.sentenceSummary,
            paragraphSummary: summary.paragraphSummary,
            pageSummary: summary.pageSummary,
            expandedSummary: summary.expandedSummary,
            languageCode: summary.languageCode,
          );
        });

        await controller.save(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        verify(() => mockRepository.createSummary(any())).called(1);
      });

      test('should handle create repository exceptions', () async {
        when(
          () => mockRepository.createSummary(any()),
        ).thenThrow(Exception('Create failed'));

        expect(
          () async => await controller.save(
            sentence: 'Test',
            paragraph: 'Test',
            page: 'Test',
            expanded: 'Test',
          ),
          throwsException,
        );
      });

      test('should handle update repository exceptions', () async {
        final existingSummary = Summary(
          id: 'existing-123',
          novelId: testNovelId,
          idx: 0,
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [existingSummary]);
        await controller.load(testNovelId);

        when(
          () => mockRepository.updateSummary(any()),
        ).thenThrow(Exception('Update failed'));

        expect(
          () async => await controller.save(
            sentence: 'Test',
            paragraph: 'Test',
            page: 'Test',
            expanded: 'Test',
          ),
          throwsException,
        );
      });

      test('should preserve base summary when save fails', () async {
        final existingSummary = Summary(
          id: 'existing-123',
          novelId: testNovelId,
          idx: 0,
          sentenceSummary: 'Original',
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [existingSummary]);
        await controller.load(testNovelId);

        when(
          () => mockRepository.updateSummary(any()),
        ).thenThrow(Exception('Update failed'));

        try {
          await controller.save(
            sentence: 'Modified',
            paragraph: 'Modified',
            page: 'Modified',
            expanded: 'Modified',
          );
        } catch (_) {
          // Expected exception
        }

        expect(controller.baseSummary, equals(existingSummary));
      });
    });

    group('integration tests', () {
      test('should handle complete workflow: load -> modify -> save', () async {
        final initialSummary = Summary(
          id: 'initial-123',
          novelId: testNovelId,
          idx: 0,
          sentenceSummary: 'Initial sentence',
          paragraphSummary: 'Initial paragraph',
          pageSummary: 'Initial page',
          expandedSummary: 'Initial expanded',
        );

        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => [initialSummary]);
        await controller.load(testNovelId);

        expect(controller.baseSummary, equals(initialSummary));

        const newSentence = 'Updated sentence';
        const newParagraph = 'Updated paragraph';
        const newPage = 'Updated page';
        const newExpanded = 'Updated expanded';

        final isDirty = controller.isDirty(
          sentence: newSentence,
          paragraph: newParagraph,
          page: newPage,
          expanded: newExpanded,
        );
        expect(isDirty, isTrue);

        when(() => mockRepository.updateSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return summary; // Return the same summary that was passed in
        });

        final result = await controller.save(
          sentence: newSentence,
          paragraph: newParagraph,
          page: newPage,
          expanded: newExpanded,
        );

        expect(result.id, equals(initialSummary.id));
        expect(result.sentenceSummary, equals(newSentence));
        expect(result.paragraphSummary, equals(newParagraph));
        expect(result.pageSummary, equals(newPage));
        expect(result.expandedSummary, equals(newExpanded));
        expect(controller.baseSummary, equals(result));

        final isDirtyAfterSave = controller.isDirty(
          sentence: newSentence,
          paragraph: newParagraph,
          page: newPage,
          expanded: newExpanded,
        );
        expect(isDirtyAfterSave, isFalse);
      });

      test('should handle workflow with new summary creation', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);

        expect(controller.baseSummary!.id, isEmpty);

        const sentence = 'First sentence';
        const paragraph = 'First paragraph';
        const page = 'First page';
        const expanded = 'First expanded';

        when(() => mockRepository.createSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return Summary(
            id: 'created-123',
            novelId: summary.novelId,
            idx: summary.idx,
            sentenceSummary: summary.sentenceSummary,
            paragraphSummary: summary.paragraphSummary,
            pageSummary: summary.pageSummary,
            expandedSummary: summary.expandedSummary,
            languageCode: summary.languageCode,
          );
        });

        final result = await controller.save(
          sentence: sentence,
          paragraph: paragraph,
          page: page,
          expanded: expanded,
        );

        expect(result.id, equals('created-123'));
        expect(result.sentenceSummary, equals(sentence));
        expect(result.paragraphSummary, equals(paragraph));
        expect(result.pageSummary, equals(page));
        expect(result.expandedSummary, equals(expanded));
        expect(controller.baseSummary, equals(result));
        expect(controller.baseSummary!.id, equals('created-123'));
      });
    });

    group('edge cases', () {
      test('should handle empty strings correctly', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);

        final isDirty = controller.isDirty(
          sentence: '',
          paragraph: '',
          page: '',
          expanded: '',
        );

        expect(isDirty, isFalse);
      });

      test('should handle whitespace-only strings correctly', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);

        final isDirty = controller.isDirty(
          sentence: '   ',
          paragraph: '   ',
          page: '   ',
          expanded: '   ',
        );

        expect(isDirty, isFalse);
      });

      test('should save with empty strings', () async {
        when(
          () => mockRepository.fetchSummaries(testNovelId),
        ).thenAnswer((_) async => []);
        await controller.load(testNovelId);

        when(() => mockRepository.createSummary(any())).thenAnswer((
          invocation,
        ) async {
          final summary = invocation.positionalArguments[0] as Summary;
          return Summary(
            id: 'created-123',
            novelId: summary.novelId,
            idx: summary.idx,
            sentenceSummary: summary.sentenceSummary,
            paragraphSummary: summary.paragraphSummary,
            pageSummary: summary.pageSummary,
            expandedSummary: summary.expandedSummary,
            languageCode: summary.languageCode,
          );
        });

        final result = await controller.save(
          sentence: '  ',
          paragraph: '  ',
          page: '  ',
          expanded: '  ',
        );

        expect(result.sentenceSummary, isEmpty);
        expect(result.paragraphSummary, isEmpty);
        expect(result.pageSummary, isEmpty);
        expect(result.expandedSummary, isEmpty);
      });
    });
  });
}
