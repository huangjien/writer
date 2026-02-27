import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/state/summary_notifier.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/shared/api_exception.dart';

class MockNovelRepository implements NovelRepository {
  Summary? summaryToReturn;
  List<Summary> summariesToReturn = [];
  bool shouldThrow = false;
  int statusCode = 500;

  @override
  Future<List<Summary>> fetchSummaries(String novelId) async {
    if (shouldThrow) {
      if (statusCode == 401) {
        throw ApiException(401, 'Unauthorized');
      }
      throw Exception('Fetch failed');
    }
    return summariesToReturn;
  }

  @override
  Future<Summary> createSummary(Summary summary) async {
    if (shouldThrow) throw Exception('Create failed');
    return summary.copyWith(id: 'new-id');
  }

  @override
  Future<Summary> updateSummary(Summary summary) async {
    if (shouldThrow) throw Exception('Update failed');
    return summary;
  }

  @override
  noSuchMethod(Invocation invocation) => Future.value(null);
}

void main() {
  group('SummaryState', () {
    test('creates with default values', () {
      const state = SummaryState();
      expect(state.baseSummary, isNull);
      expect(state.saving, false);
      expect(state.error, isNull);
      expect(state.refreshing, false);
      expect(state.isDirty, false);
      expect(state.showCoach, false);
      expect(state.showSentenceCoach, false);
      expect(state.showParagraphCoach, false);
      expect(state.showPageCoach, false);
      expect(state.sentenceAiSatisfied, false);
      expect(state.paragraphAiSatisfied, false);
      expect(state.pageAiSatisfied, false);
      expect(state.expandedAiSatisfied, false);
      expect(state.sentenceLastOutput, isNull);
      expect(state.paragraphLastOutput, isNull);
      expect(state.pageLastOutput, isNull);
      expect(state.expandedLastOutput, isNull);
    });

    test('creates with custom values', () {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Test sentence',
      );
      final state = SummaryState(
        baseSummary: summary,
        saving: true,
        error: 'Test error',
        refreshing: true,
        isDirty: true,
        showCoach: true,
        showSentenceCoach: true,
        showParagraphCoach: true,
        showPageCoach: true,
        sentenceAiSatisfied: true,
        paragraphAiSatisfied: true,
        pageAiSatisfied: true,
        expandedAiSatisfied: true,
        sentenceLastOutput: const SnowflakeRefinementOutput(
          novelId: 'novel-1',
          summaryContent: 'Summary',
          status: 'completed',
          suggestions: [],
        ),
        paragraphLastOutput: const SnowflakeRefinementOutput(
          novelId: 'novel-1',
          summaryContent: 'Summary',
          status: 'completed',
          suggestions: [],
        ),
        pageLastOutput: const SnowflakeRefinementOutput(
          novelId: 'novel-1',
          summaryContent: 'Summary',
          status: 'completed',
          suggestions: [],
        ),
        expandedLastOutput: const SnowflakeRefinementOutput(
          novelId: 'novel-1',
          summaryContent: 'Summary',
          status: 'completed',
          suggestions: [],
        ),
      );
      expect(state.baseSummary, summary);
      expect(state.saving, true);
      expect(state.error, 'Test error');
      expect(state.refreshing, true);
      expect(state.isDirty, true);
      expect(state.showCoach, true);
      expect(state.showSentenceCoach, true);
      expect(state.showParagraphCoach, true);
      expect(state.showPageCoach, true);
      expect(state.sentenceAiSatisfied, true);
      expect(state.paragraphAiSatisfied, true);
      expect(state.pageAiSatisfied, true);
      expect(state.expandedAiSatisfied, true);
      expect(state.sentenceLastOutput, isNotNull);
      expect(state.paragraphLastOutput, isNotNull);
      expect(state.pageLastOutput, isNotNull);
      expect(state.expandedLastOutput, isNotNull);
    });

    test('copyWith updates specified fields', () {
      const state = SummaryState();
      final updated = state.copyWith(
        saving: true,
        error: 'New error',
        isDirty: true,
      );
      expect(updated.saving, true);
      expect(updated.error, 'New error');
      expect(updated.isDirty, true);
      expect(updated.refreshing, false);
    });

    test('copyWith clearError clears error', () {
      const state = SummaryState(error: 'Test error');
      final updated = state.copyWith(clearError: true);
      expect(updated.error, isNull);
    });

    test('copyWith keeps original values when not specified', () {
      const state = SummaryState(saving: true, isDirty: true, error: 'Error');
      final updated = state.copyWith(saving: false);
      expect(updated.saving, false);
      expect(updated.isDirty, true);
      expect(updated.error, 'Error');
    });
  });

  group('SummaryNotifier', () {
    late ProviderContainer container;
    late MockNovelRepository mockRepository;

    setUp(() {
      mockRepository = MockNovelRepository();
      container = ProviderContainer(
        overrides: [novelRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build creates initial state', () {
      final notifier = container.read(summaryProvider.notifier);
      final state = notifier.state;
      expect(state.baseSummary, isNull);
      expect(state.saving, false);
      expect(state.isDirty, false);
    });

    test('load updates state with summary', () async {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Test sentence',
      );
      mockRepository.summariesToReturn = [summary];

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      expect(notifier.state.baseSummary, summary);
      expect(notifier.state.refreshing, false);
      expect(notifier.state.isDirty, false);
      expect(notifier.state.error, isNull);
    });

    test('load creates empty summary when none exists', () async {
      mockRepository.summariesToReturn = [];

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      expect(notifier.state.baseSummary, isNotNull);
      expect(notifier.state.baseSummary!.id, '');
      expect(notifier.state.baseSummary!.novelId, 'novel-1');
      expect(notifier.state.refreshing, false);
      expect(notifier.state.error, isNull);
    });

    test('load sets error on exception', () async {
      mockRepository.shouldThrow = true;

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      expect(notifier.state.refreshing, false);
      expect(notifier.state.error, isNotNull);
    });

    test('load sets refreshing state during load', () async {
      mockRepository.summariesToReturn = [];

      final notifier = container.read(summaryProvider.notifier);
      final loadFuture = notifier.load('novel-1');

      expect(notifier.state.refreshing, true);
      await loadFuture;
      expect(notifier.state.refreshing, false);
    });

    test('load handles 401 error without setting error', () async {
      mockRepository.shouldThrow = true;
      mockRepository.statusCode = 401;

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      expect(notifier.state.refreshing, false);
      expect(notifier.state.error, isNull);
    });

    test('onFieldChanged sets isDirty when fields differ', () {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Original',
        paragraphSummary: 'Original',
        pageSummary: 'Original',
        expandedSummary: 'Original',
      );

      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(baseSummary: summary);

      notifier.onFieldChanged(
        sentence: 'Modified',
        paragraph: 'Modified',
        page: 'Modified',
        expanded: 'Modified',
      );

      expect(notifier.state.isDirty, true);
    });

    test('onFieldChanged does not set isDirty when fields are same', () async {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Same',
        paragraphSummary: 'Same',
        pageSummary: 'Same',
        expandedSummary: 'Same',
      );

      mockRepository.summariesToReturn = [summary];

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      notifier.onFieldChanged(
        sentence: 'Same',
        paragraph: 'Same',
        page: 'Same',
        expanded: 'Same',
      );

      expect(notifier.state.isDirty, false);
    });

    test('onFieldChanged resets AI satisfied flags when field changes', () {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Original',
        paragraphSummary: 'Original',
        pageSummary: 'Original',
        expandedSummary: 'Original',
      );

      const output = SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'Summary',
        status: 'completed',
        suggestions: [],
      );

      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        baseSummary: summary,
        sentenceAiSatisfied: true,
        paragraphAiSatisfied: true,
        pageAiSatisfied: true,
        expandedAiSatisfied: true,
        sentenceLastOutput: output,
        paragraphLastOutput: output,
        pageLastOutput: output,
        expandedLastOutput: output,
      );

      notifier.onFieldChanged(
        sentence: 'Modified',
        paragraph: 'Original',
        page: 'Original',
        expanded: 'Original',
      );

      expect(notifier.state.sentenceAiSatisfied, false);
      expect(notifier.state.paragraphAiSatisfied, true);
      expect(notifier.state.pageAiSatisfied, true);
      expect(notifier.state.expandedAiSatisfied, true);
    });

    test('resetCoaches resets all coach flags', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        showCoach: true,
        showSentenceCoach: true,
        showParagraphCoach: true,
        showPageCoach: true,
      );

      notifier.resetCoaches();

      expect(notifier.state.showCoach, false);
      expect(notifier.state.showSentenceCoach, false);
      expect(notifier.state.showParagraphCoach, false);
      expect(notifier.state.showPageCoach, false);
    });

    test('toggleSentenceCoach toggles and clears other coaches', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        showParagraphCoach: true,
        showPageCoach: true,
      );

      notifier.toggleSentenceCoach();

      expect(notifier.state.showSentenceCoach, true);
      expect(notifier.state.showParagraphCoach, false);
      expect(notifier.state.showPageCoach, false);
      expect(notifier.state.showCoach, false);
    });

    test('toggleParagraphCoach toggles and clears other coaches', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        showSentenceCoach: true,
        showPageCoach: true,
      );

      notifier.toggleParagraphCoach();

      expect(notifier.state.showParagraphCoach, true);
      expect(notifier.state.showSentenceCoach, false);
      expect(notifier.state.showPageCoach, false);
      expect(notifier.state.showCoach, false);
    });

    test('togglePageCoach toggles and clears other coaches', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        showSentenceCoach: true,
        showParagraphCoach: true,
      );

      notifier.togglePageCoach();

      expect(notifier.state.showPageCoach, true);
      expect(notifier.state.showSentenceCoach, false);
      expect(notifier.state.showParagraphCoach, false);
      expect(notifier.state.showCoach, false);
    });

    test('toggleExpandedCoach toggles and clears other coaches', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(
        showSentenceCoach: true,
        showParagraphCoach: true,
        showPageCoach: true,
      );

      notifier.toggleExpandedCoach();

      expect(notifier.state.showCoach, true);
      expect(notifier.state.showSentenceCoach, false);
      expect(notifier.state.showParagraphCoach, false);
      expect(notifier.state.showPageCoach, false);
    });

    test('setSentenceAiSatisfied sets value', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.setSentenceAiSatisfied(true);
      expect(notifier.state.sentenceAiSatisfied, true);

      notifier.setSentenceAiSatisfied(false);
      expect(notifier.state.sentenceAiSatisfied, false);
    });

    test('setParagraphAiSatisfied sets value', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.setParagraphAiSatisfied(true);
      expect(notifier.state.paragraphAiSatisfied, true);

      notifier.setParagraphAiSatisfied(false);
      expect(notifier.state.paragraphAiSatisfied, false);
    });

    test('setPageAiSatisfied sets value', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.setPageAiSatisfied(true);
      expect(notifier.state.pageAiSatisfied, true);

      notifier.setPageAiSatisfied(false);
      expect(notifier.state.pageAiSatisfied, false);
    });

    test('setExpandedAiSatisfied sets value', () {
      final notifier = container.read(summaryProvider.notifier);
      notifier.setExpandedAiSatisfied(true);
      expect(notifier.state.expandedAiSatisfied, true);

      notifier.setExpandedAiSatisfied(false);
      expect(notifier.state.expandedAiSatisfied, false);
    });

    test('setSentenceLastOutput sets output', () {
      const output = SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'Summary',
        status: 'completed',
        suggestions: [],
      );
      final notifier = container.read(summaryProvider.notifier);
      notifier.setSentenceLastOutput(output);
      expect(notifier.state.sentenceLastOutput, output);
    });

    test('setParagraphLastOutput sets output', () {
      const output = SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'Summary',
        status: 'completed',
        suggestions: [],
      );
      final notifier = container.read(summaryProvider.notifier);
      notifier.setParagraphLastOutput(output);
      expect(notifier.state.paragraphLastOutput, output);
    });

    test('setPageLastOutput sets output', () {
      const output = SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'Summary',
        status: 'completed',
        suggestions: [],
      );
      final notifier = container.read(summaryProvider.notifier);
      notifier.setPageLastOutput(output);
      expect(notifier.state.pageLastOutput, output);
    });

    test('setExpandedLastOutput sets output', () {
      const output = SnowflakeRefinementOutput(
        novelId: 'novel-1',
        summaryContent: 'Summary',
        status: 'completed',
        suggestions: [],
      );
      final notifier = container.read(summaryProvider.notifier);
      notifier.setExpandedLastOutput(output);
      expect(notifier.state.expandedLastOutput, output);
    });

    test('save updates state with saved summary', () async {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Test',
      );
      mockRepository.summariesToReturn = [summary];

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      final saved = await notifier.save(
        sentence: 'Updated',
        paragraph: 'Updated',
        page: 'Updated',
        expanded: 'Updated',
      );

      expect(notifier.state.saving, false);
      expect(notifier.state.isDirty, false);
      expect(notifier.state.error, isNull);
      expect(saved, isNotNull);
    });

    test('save sets saving state during save', () async {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Test',
      );
      mockRepository.summariesToReturn = [summary];

      final notifier = container.read(summaryProvider.notifier);
      await notifier.load('novel-1');

      final saveFuture = notifier.save(
        sentence: 'Updated',
        paragraph: 'Updated',
        page: 'Updated',
        expanded: 'Updated',
      );

      expect(notifier.state.saving, true);
      await saveFuture;
      expect(notifier.state.saving, false);
    });

    test('save clears previous error', () async {
      final summary = Summary(
        id: 'test-id',
        novelId: 'novel-1',
        idx: 0,
        sentenceSummary: 'Test',
      );
      mockRepository.summariesToReturn = [summary];

      final notifier = container.read(summaryProvider.notifier);
      notifier.state = notifier.state.copyWith(error: 'Previous error');

      await notifier.load('novel-1');
      await notifier.save(
        sentence: 'Updated',
        paragraph: 'Updated',
        page: 'Updated',
        expanded: 'Updated',
      );

      expect(notifier.state.error, isNull);
    });
  });
}
