import '../../models/summary.dart';
import '../../repositories/novel_repository.dart';

/// Controller for summary screen business logic
///
/// This controller handles the business logic for managing summaries,
/// separating it from the UI layer for better testability.
class SummaryController {
  final NovelRepository _repository;

  SummaryController(this._repository);

  Summary? _baseSummary;

  /// Get the base summary
  Summary? get baseSummary => _baseSummary;

  /// Load summary for a novel
  Future<void> load(String novelId) async {
    final summaries = await _repository.fetchSummaries(novelId);
    if (summaries.isNotEmpty) {
      _baseSummary = summaries.first;
    } else {
      _baseSummary = Summary(id: '', novelId: novelId, idx: 0);
    }
  }

  /// Check if the current form is dirty (has unsaved changes)
  bool isDirty({
    required String sentence,
    required String paragraph,
    required String page,
    required String expanded,
  }) {
    return sentence.trim() != (_baseSummary?.sentenceSummary ?? '').trim() ||
        paragraph.trim() != (_baseSummary?.paragraphSummary ?? '').trim() ||
        page.trim() != (_baseSummary?.pageSummary ?? '').trim() ||
        expanded.trim() != (_baseSummary?.expandedSummary ?? '').trim();
  }

  /// Save the summary
  Future<Summary> save({
    required String sentence,
    required String paragraph,
    required String page,
    required String expanded,
  }) async {
    final newSummary = _baseSummary!.copyWith(
      sentenceSummary: sentence.trim(),
      paragraphSummary: paragraph.trim(),
      pageSummary: page.trim(),
      expandedSummary: expanded.trim(),
    );

    Summary saved;
    if (newSummary.id.isEmpty) {
      saved = await _repository.createSummary(newSummary);
    } else {
      saved = await _repository.updateSummary(newSummary);
    }

    _baseSummary = saved;
    return saved;
  }
}
