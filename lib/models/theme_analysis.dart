class ThemeAnalysis {
  final String id;
  final String documentId;
  final List<String> themes;
  final Map<String, double> themeWeights;
  final List<String> motifs;
  final List<String> symbols;
  final List<String> characterArcs;
  final List<String> narrativeThreads;
  final List<ThemeConflict> conflicts;
  final double overallCoherence;
  final DateTime analyzedAt;

  ThemeAnalysis({
    required this.id,
    required this.documentId,
    required this.themes,
    required this.themeWeights,
    required this.motifs,
    required this.symbols,
    required this.characterArcs,
    required this.narrativeThreads,
    required this.conflicts,
    required this.overallCoherence,
    required this.analyzedAt,
  });

  String get primaryTheme => themes.isNotEmpty ? themes.first : '';

  double getCoherenceForTheme(String theme) {
    return themeWeights[theme] ?? 0.0;
  }

  List<ThemeConflict> getConflictsForTheme(String theme) {
    return conflicts.where((c) => c.themes.contains(theme)).toList();
  }

  bool get isCoherent => overallCoherence >= 0.7;

  ThemeAnalysis copyWith({
    String? id,
    String? documentId,
    List<String>? themes,
    Map<String, double>? themeWeights,
    List<String>? motifs,
    List<String>? symbols,
    List<String>? characterArcs,
    List<String>? narrativeThreads,
    List<ThemeConflict>? conflicts,
    double? overallCoherence,
    DateTime? analyzedAt,
  }) {
    return ThemeAnalysis(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      themes: themes ?? this.themes,
      themeWeights: themeWeights ?? this.themeWeights,
      motifs: motifs ?? this.motifs,
      symbols: symbols ?? this.symbols,
      characterArcs: characterArcs ?? this.characterArcs,
      narrativeThreads: narrativeThreads ?? this.narrativeThreads,
      conflicts: conflicts ?? this.conflicts,
      overallCoherence: overallCoherence ?? this.overallCoherence,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'themes': themes,
      'theme_weights': themeWeights,
      'motifs': motifs,
      'symbols': symbols,
      'character_arcs': characterArcs,
      'narrative_threads': narrativeThreads,
      'conflicts': conflicts.map((c) => c.toMap()).toList(),
      'overall_coherence': overallCoherence,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  factory ThemeAnalysis.fromMap(Map<String, dynamic> map) {
    return ThemeAnalysis(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      themes: List<String>.from(map['themes'] ?? []),
      themeWeights: Map<String, double>.from(
        (map['theme_weights'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      motifs: List<String>.from(map['motifs'] ?? []),
      symbols: List<String>.from(map['symbols'] ?? []),
      characterArcs: List<String>.from(map['character_arcs'] ?? []),
      narrativeThreads: List<String>.from(map['narrative_threads'] ?? []),
      conflicts:
          (map['conflicts'] as List<dynamic>?)
              ?.map((c) => ThemeConflict.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      overallCoherence: (map['overall_coherence'] as num?)?.toDouble() ?? 0.0,
      analyzedAt: map['analyzed_at'] != null
          ? DateTime.parse(map['analyzed_at'] as String)
          : DateTime.now(),
    );
  }
}

class ThemeConflict {
  final String id;
  final List<String> themes;
  final String description;
  final String resolution;
  final bool isResolved;

  ThemeConflict({
    required this.id,
    required this.themes,
    required this.description,
    required this.resolution,
    required this.isResolved,
  });

  ThemeConflict copyWith({
    String? id,
    List<String>? themes,
    String? description,
    String? resolution,
    bool? isResolved,
  }) {
    return ThemeConflict(
      id: id ?? this.id,
      themes: themes ?? this.themes,
      description: description ?? this.description,
      resolution: resolution ?? this.resolution,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'themes': themes,
      'description': description,
      'resolution': resolution,
      'is_resolved': isResolved,
    };
  }

  factory ThemeConflict.fromMap(Map<String, dynamic> map) {
    return ThemeConflict(
      id: map['id'] as String,
      themes: List<String>.from(map['themes'] ?? []),
      description: map['description'] as String,
      resolution: map['resolution'] as String? ?? '',
      isResolved: map['is_resolved'] as bool? ?? false,
    );
  }
}

class ThemeElement {
  final String name;
  final String type;
  final int occurrences;
  final List<String> contexts;
  final double significance;

  ThemeElement({
    required this.name,
    required this.type,
    required this.occurrences,
    required this.contexts,
    required this.significance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'occurrences': occurrences,
      'contexts': contexts,
      'significance': significance,
    };
  }

  factory ThemeElement.fromMap(Map<String, dynamic> map) {
    return ThemeElement(
      name: map['name'] as String,
      type: map['type'] as String,
      occurrences: map['occurrences'] as int,
      contexts: List<String>.from(map['contexts'] ?? []),
      significance: (map['significance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NarrativeStructure {
  final String id;
  final String structureType;
  final List<PlotPoint> plotPoints;
  final Map<String, int> actBreakdown;
  final double pacingScore;

  NarrativeStructure({
    required this.id,
    required this.structureType,
    required this.plotPoints,
    required this.actBreakdown,
    required this.pacingScore,
  });

  NarrativeStructure copyWith({
    String? id,
    String? structureType,
    List<PlotPoint>? plotPoints,
    Map<String, int>? actBreakdown,
    double? pacingScore,
  }) {
    return NarrativeStructure(
      id: id ?? this.id,
      structureType: structureType ?? this.structureType,
      plotPoints: plotPoints ?? this.plotPoints,
      actBreakdown: actBreakdown ?? this.actBreakdown,
      pacingScore: pacingScore ?? this.pacingScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'structure_type': structureType,
      'plot_points': plotPoints.map((p) => p.toMap()).toList(),
      'act_breakdown': actBreakdown,
      'pacing_score': pacingScore,
    };
  }

  factory NarrativeStructure.fromMap(Map<String, dynamic> map) {
    return NarrativeStructure(
      id: map['id'] as String,
      structureType: map['structure_type'] as String,
      plotPoints:
          (map['plot_points'] as List<dynamic>?)
              ?.map((p) => PlotPoint.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      actBreakdown: Map<String, int>.from(map['act_breakdown'] ?? {}),
      pacingScore: (map['pacing_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PlotPoint {
  final String name;
  final String description;
  final int position;
  final String act;

  PlotPoint({
    required this.name,
    required this.description,
    required this.position,
    required this.act,
  });

  PlotPoint copyWith({
    String? name,
    String? description,
    int? position,
    String? act,
  }) {
    return PlotPoint(
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      act: act ?? this.act,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'position': position,
      'act': act,
    };
  }

  factory PlotPoint.fromMap(Map<String, dynamic> map) {
    return PlotPoint(
      name: map['name'] as String,
      description: map['description'] as String,
      position: map['position'] as int,
      act: map['act'] as String,
    );
  }
}
