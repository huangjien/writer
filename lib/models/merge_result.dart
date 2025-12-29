class MergeResult {
  final String mergedContent;
  final bool hasConflicts;
  final List<ConflictRegion> conflicts;
  final bool success;

  const MergeResult({
    required this.mergedContent,
    this.hasConflicts = false,
    this.conflicts = const [],
    this.success = true,
  });

  MergeResult copyWith({
    String? mergedContent,
    bool? hasConflicts,
    List<ConflictRegion>? conflicts,
    bool? success,
  }) {
    return MergeResult(
      mergedContent: mergedContent ?? this.mergedContent,
      hasConflicts: hasConflicts ?? this.hasConflicts,
      conflicts: conflicts ?? this.conflicts,
      success: success ?? this.success,
    );
  }
}

class ConflictRegion {
  final int startLine;
  final int endLine;
  final String localContent;
  final String remoteContent;

  const ConflictRegion({
    required this.startLine,
    required this.endLine,
    required this.localContent,
    required this.remoteContent,
  });

  ConflictRegion copyWith({
    int? startLine,
    int? endLine,
    String? localContent,
    String? remoteContent,
  }) {
    return ConflictRegion(
      startLine: startLine ?? this.startLine,
      endLine: endLine ?? this.endLine,
      localContent: localContent ?? this.localContent,
      remoteContent: remoteContent ?? this.remoteContent,
    );
  }
}
