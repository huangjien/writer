import '../models/merge_result.dart';

class TextMerger {
  /// Perform three-way merge of text content
  ///
  /// Compares base, local, and remote versions
  /// Automatically merges non-conflicting changes
  /// Inserts conflict markers for conflicting regions
  MergeResult merge({
    required String baseContent,
    required String localContent,
    required String remoteContent,
  }) {
    final baseLines = baseContent.split('\n');
    final localLines = localContent.split('\n');
    final remoteLines = remoteContent.split('\n');

    final mergedLines = <String>[];
    final conflicts = <ConflictRegion>[];

    var baseIdx = 0;
    var localIdx = 0;
    var remoteIdx = 0;

    while (baseIdx < baseLines.length ||
        localIdx < localLines.length ||
        remoteIdx < remoteLines.length) {
      // Get current lines
      final baseLine = baseIdx < baseLines.length ? baseLines[baseIdx] : '';
      final localLine = localIdx < localLines.length
          ? localLines[localIdx]
          : '';
      final remoteLine = remoteIdx < remoteLines.length
          ? remoteLines[remoteIdx]
          : '';

      // Determine what changed
      final localChanged = localLine != baseLine;
      final remoteChanged = remoteLine != baseLine;

      if (!localChanged && !remoteChanged) {
        // No change in either - use base
        mergedLines.add(baseLine);
        baseIdx++;
        localIdx++;
        remoteIdx++;
      } else if (localChanged && remoteChanged) {
        // Both changed - check if same change
        if (localLine == remoteLine) {
          // Same change in both - add once
          mergedLines.add(localLine);
        } else {
          // Different changes in same region - conflict
          final startLine = mergedLines.length + 1;
          conflicts.add(
            ConflictRegion(
              startLine: startLine,
              endLine: startLine,
              localContent: localLine,
              remoteContent: remoteLine,
            ),
          );
          // Add conflict markers
          mergedLines.add('<<<<<<< LOCAL');
          mergedLines.add(localLine);
          mergedLines.add('=======');
          mergedLines.add(remoteLine);
          mergedLines.add('>>>>>>> REMOTE');
        }
        baseIdx++;
        localIdx++;
        remoteIdx++;
      } else if (localChanged) {
        // Only local changed
        mergedLines.add(localLine);
        baseIdx++;
        localIdx++;
      } else if (remoteChanged) {
        // Only remote changed
        mergedLines.add(remoteLine);
        baseIdx++;
        remoteIdx++;
      } else {
        // No change - use base
        mergedLines.add(baseLine);
        baseIdx++;
        localIdx++;
        remoteIdx++;
      }
    }

    // Add remaining lines from all versions
    while (baseIdx < baseLines.length) {
      mergedLines.add(baseLines[baseIdx++]);
    }
    while (localIdx < localLines.length) {
      mergedLines.add(localLines[localIdx++]);
    }
    while (remoteIdx < remoteLines.length) {
      mergedLines.add(remoteLines[remoteIdx++]);
    }

    final mergedContent = mergedLines.join('\n');
    final hasConflicts = conflicts.isNotEmpty;

    return MergeResult(
      mergedContent: mergedContent,
      hasConflicts: hasConflicts,
      conflicts: conflicts,
      success: true,
    );
  }
}
