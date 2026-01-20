import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/summary.dart';
import 'package:writer/models/snowflake.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:writer/shared/api_exception.dart';
import 'summary_controller.dart';

class SummaryState {
  final Summary? baseSummary;
  final bool saving;
  final String? error;
  final bool refreshing;
  final bool isDirty;
  final bool showCoach;
  final bool showSentenceCoach;
  final bool showParagraphCoach;
  final bool showPageCoach;
  final bool sentenceAiSatisfied;
  final bool paragraphAiSatisfied;
  final bool pageAiSatisfied;
  final bool expandedAiSatisfied;
  final SnowflakeRefinementOutput? sentenceLastOutput;
  final SnowflakeRefinementOutput? paragraphLastOutput;
  final SnowflakeRefinementOutput? pageLastOutput;
  final SnowflakeRefinementOutput? expandedLastOutput;

  const SummaryState({
    this.baseSummary,
    this.saving = false,
    this.error,
    this.refreshing = false,
    this.isDirty = false,
    this.showCoach = false,
    this.showSentenceCoach = false,
    this.showParagraphCoach = false,
    this.showPageCoach = false,
    this.sentenceAiSatisfied = false,
    this.paragraphAiSatisfied = false,
    this.pageAiSatisfied = false,
    this.expandedAiSatisfied = false,
    this.sentenceLastOutput,
    this.paragraphLastOutput,
    this.pageLastOutput,
    this.expandedLastOutput,
  });

  SummaryState copyWith({
    Summary? baseSummary,
    bool? saving,
    String? error,
    bool clearError = false,
    bool? refreshing,
    bool? isDirty,
    bool? showCoach,
    bool? showSentenceCoach,
    bool? showParagraphCoach,
    bool? showPageCoach,
    bool? sentenceAiSatisfied,
    bool? paragraphAiSatisfied,
    bool? pageAiSatisfied,
    bool? expandedAiSatisfied,
    SnowflakeRefinementOutput? sentenceLastOutput,
    SnowflakeRefinementOutput? paragraphLastOutput,
    SnowflakeRefinementOutput? pageLastOutput,
    SnowflakeRefinementOutput? expandedLastOutput,
  }) {
    return SummaryState(
      baseSummary: baseSummary ?? this.baseSummary,
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      refreshing: refreshing ?? this.refreshing,
      isDirty: isDirty ?? this.isDirty,
      showCoach: showCoach ?? this.showCoach,
      showSentenceCoach: showSentenceCoach ?? this.showSentenceCoach,
      showParagraphCoach: showParagraphCoach ?? this.showParagraphCoach,
      showPageCoach: showPageCoach ?? this.showPageCoach,
      sentenceAiSatisfied: sentenceAiSatisfied ?? this.sentenceAiSatisfied,
      paragraphAiSatisfied: paragraphAiSatisfied ?? this.paragraphAiSatisfied,
      pageAiSatisfied: pageAiSatisfied ?? this.pageAiSatisfied,
      expandedAiSatisfied: expandedAiSatisfied ?? this.expandedAiSatisfied,
      sentenceLastOutput: sentenceLastOutput ?? this.sentenceLastOutput,
      paragraphLastOutput: paragraphLastOutput ?? this.paragraphLastOutput,
      pageLastOutput: pageLastOutput ?? this.pageLastOutput,
      expandedLastOutput: expandedLastOutput ?? this.expandedLastOutput,
    );
  }
}

class SummaryNotifier extends Notifier<SummaryState> {
  late final SummaryController _controller;

  @override
  SummaryState build() {
    _controller = SummaryController(ref.read(novelRepositoryProvider));
    return const SummaryState();
  }

  Future<void> load(String novelId) async {
    state = state.copyWith(refreshing: true);
    try {
      await _controller.load(novelId);
      state = state.copyWith(
        baseSummary: _controller.baseSummary,
        isDirty: false,
      );
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        state = state.copyWith(refreshing: false);
      } else {
        state = state.copyWith(error: e.toString());
      }
    } finally {
      state = state.copyWith(refreshing: false);
    }
  }

  void onFieldChanged({
    required String sentence,
    required String paragraph,
    required String page,
    required String expanded,
  }) {
    final base = state.baseSummary;

    final sentenceChanged = sentence != (base?.sentenceSummary ?? '');
    final paragraphChanged = paragraph != (base?.paragraphSummary ?? '');
    final pageChanged = page != (base?.pageSummary ?? '');
    final expandedChanged = expanded != (base?.expandedSummary ?? '');

    state = state.copyWith(
      sentenceAiSatisfied: sentenceChanged ? false : state.sentenceAiSatisfied,
      paragraphAiSatisfied: paragraphChanged
          ? false
          : state.paragraphAiSatisfied,
      pageAiSatisfied: pageChanged ? false : state.pageAiSatisfied,
      expandedAiSatisfied: expandedChanged ? false : state.expandedAiSatisfied,
      sentenceLastOutput: sentenceChanged ? null : state.sentenceLastOutput,
      paragraphLastOutput: paragraphChanged ? null : state.paragraphLastOutput,
      pageLastOutput: pageChanged ? null : state.pageLastOutput,
      expandedLastOutput: expandedChanged ? null : state.expandedLastOutput,
    );

    final dirty = _controller.isDirty(
      sentence: sentence,
      paragraph: paragraph,
      page: page,
      expanded: expanded,
    );

    if (dirty != state.isDirty) {
      state = state.copyWith(isDirty: dirty);
    }
  }

  void resetCoaches() {
    state = state.copyWith(
      showCoach: false,
      showSentenceCoach: false,
      showParagraphCoach: false,
      showPageCoach: false,
    );
  }

  void toggleSentenceCoach() {
    final newValue = !state.showSentenceCoach;
    state = state.copyWith(
      showSentenceCoach: newValue,
      showCoach: false,
      showParagraphCoach: false,
      showPageCoach: false,
    );
  }

  void toggleParagraphCoach() {
    final newValue = !state.showParagraphCoach;
    state = state.copyWith(
      showParagraphCoach: newValue,
      showCoach: false,
      showSentenceCoach: false,
      showPageCoach: false,
    );
  }

  void togglePageCoach() {
    final newValue = !state.showPageCoach;
    state = state.copyWith(
      showPageCoach: newValue,
      showCoach: false,
      showSentenceCoach: false,
      showParagraphCoach: false,
    );
  }

  void toggleExpandedCoach() {
    final newValue = !state.showCoach;
    state = state.copyWith(
      showCoach: newValue,
      showSentenceCoach: false,
      showParagraphCoach: false,
      showPageCoach: false,
    );
  }

  void setSentenceAiSatisfied(bool satisfied) {
    state = state.copyWith(sentenceAiSatisfied: satisfied);
  }

  void setParagraphAiSatisfied(bool satisfied) {
    state = state.copyWith(paragraphAiSatisfied: satisfied);
  }

  void setPageAiSatisfied(bool satisfied) {
    state = state.copyWith(pageAiSatisfied: satisfied);
  }

  void setExpandedAiSatisfied(bool satisfied) {
    state = state.copyWith(expandedAiSatisfied: satisfied);
  }

  void setSentenceLastOutput(SnowflakeRefinementOutput? output) {
    state = state.copyWith(sentenceLastOutput: output);
  }

  void setParagraphLastOutput(SnowflakeRefinementOutput? output) {
    state = state.copyWith(paragraphLastOutput: output);
  }

  void setPageLastOutput(SnowflakeRefinementOutput? output) {
    state = state.copyWith(pageLastOutput: output);
  }

  void setExpandedLastOutput(SnowflakeRefinementOutput? output) {
    state = state.copyWith(expandedLastOutput: output);
  }

  Future<Summary> save({
    required String sentence,
    required String paragraph,
    required String page,
    required String expanded,
  }) async {
    state = state.copyWith(saving: true, clearError: true);
    try {
      final saved = await _controller.save(
        sentence: sentence,
        paragraph: paragraph,
        page: page,
        expanded: expanded,
      );
      state = state.copyWith(baseSummary: saved, saving: false, isDirty: false);
      return saved;
    } catch (e) {
      state = state.copyWith(error: e.toString(), saving: false);
      rethrow;
    }
  }
}

final summaryProvider = NotifierProvider<SummaryNotifier, SummaryState>(
  SummaryNotifier.new,
);
