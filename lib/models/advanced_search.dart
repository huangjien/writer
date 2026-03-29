class SearchQuery {
  final String query;
  final SearchType type;
  final SearchScope scope;
  final DateTime createdAt;
  final Map<String, dynamic>? filters;
  final List<String>? documentIds;
  final String? authorId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  SearchQuery({
    required this.query,
    this.type = SearchType.text,
    this.scope = SearchScope.all,
    required this.createdAt,
    this.filters,
    this.documentIds,
    this.authorId,
    this.dateFrom,
    this.dateTo,
  });

  bool get hasFilters => filters != null && filters!.isNotEmpty;
  bool get hasDateRange => dateFrom != null || dateTo != null;

  SearchQuery copyWith({
    String? query,
    SearchType? type,
    SearchScope? scope,
    DateTime? createdAt,
    Map<String, dynamic>? filters,
    List<String>? documentIds,
    String? authorId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      createdAt: createdAt ?? this.createdAt,
      filters: filters ?? this.filters,
      documentIds: documentIds ?? this.documentIds,
      authorId: authorId ?? this.authorId,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'type': type.name,
      'scope': scope.name,
      'created_at': createdAt.toIso8601String(),
      'filters': filters,
      'document_ids': documentIds,
      'author_id': authorId,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
    };
  }

  factory SearchQuery.fromMap(Map<String, dynamic> map) {
    return SearchQuery(
      query: map['query'] as String,
      type: SearchType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SearchType.text,
      ),
      scope: SearchScope.values.firstWhere(
        (e) => e.name == map['scope'],
        orElse: () => SearchScope.all,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      filters: map['filters'] as Map<String, dynamic>?,
      documentIds: map['document_ids'] != null
          ? List<String>.from(map['document_ids'])
          : null,
      authorId: map['author_id'] as String?,
      dateFrom: map['date_from'] != null
          ? DateTime.parse(map['date_from'] as String)
          : null,
      dateTo: map['date_to'] != null
          ? DateTime.parse(map['date_to'] as String)
          : null,
    );
  }
}

enum SearchType { text, fuzzy, phrase, regex, semantic }

enum SearchScope { all, title, content, metadata, comments }

class SearchResult {
  final String id;
  final String documentId;
  final String documentTitle;
  final String snippet;
  final int? matchPosition;
  final double relevanceScore;
  final SearchResultType type;
  final DateTime? lastModified;
  final Map<String, dynamic>? highlights;

  SearchResult({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.snippet,
    this.matchPosition,
    required this.relevanceScore,
    required this.type,
    this.lastModified,
    this.highlights,
  });

  bool get isHighlyRelevant => relevanceScore >= 0.8;

  SearchResult copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? snippet,
    int? matchPosition,
    double? relevanceScore,
    SearchResultType? type,
    DateTime? lastModified,
    Map<String, dynamic>? highlights,
  }) {
    return SearchResult(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      snippet: snippet ?? this.snippet,
      matchPosition: matchPosition ?? this.matchPosition,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      type: type ?? this.type,
      lastModified: lastModified ?? this.lastModified,
      highlights: highlights ?? this.highlights,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'document_title': documentTitle,
      'snippet': snippet,
      'match_position': matchPosition,
      'relevance_score': relevanceScore,
      'type': type.name,
      'last_modified': lastModified?.toIso8601String(),
      'highlights': highlights,
    };
  }

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      documentTitle: map['document_title'] as String,
      snippet: map['snippet'] as String,
      matchPosition: map['match_position'] as int?,
      relevanceScore: (map['relevance_score'] as num).toDouble(),
      type: SearchResultType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SearchResultType.document,
      ),
      lastModified: map['last_modified'] != null
          ? DateTime.parse(map['last_modified'] as String)
          : null,
      highlights: map['highlights'] as Map<String, dynamic>?,
    );
  }
}

enum SearchResultType {
  document,
  paragraph,
  sentence,
  character,
  scene,
  comment,
}

class SearchFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;
  final bool isActive;

  SearchFilter({
    required this.field,
    required this.operator,
    required this.value,
    this.isActive = true,
  });

  SearchFilter copyWith({
    String? field,
    FilterOperator? operator,
    dynamic value,
    bool? isActive,
  }) {
    return SearchFilter(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'operator': operator.name,
      'value': value,
      'is_active': isActive,
    };
  }

  factory SearchFilter.fromMap(Map<String, dynamic> map) {
    return SearchFilter(
      field: map['field'] as String,
      operator: FilterOperator.values.firstWhere(
        (e) => e.name == map['operator'],
        orElse: () => FilterOperator.equals,
      ),
      value: map['value'],
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}

enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  between,
  inList,
}

class SearchHistory {
  final String id;
  final SearchQuery query;
  final int resultCount;
  final DateTime searchedAt;
  final bool wasSuccessful;

  SearchHistory({
    required this.id,
    required this.query,
    required this.resultCount,
    required this.searchedAt,
    required this.wasSuccessful,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query.toMap(),
      'result_count': resultCount,
      'searched_at': searchedAt.toIso8601String(),
      'was_successful': wasSuccessful,
    };
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'] as String,
      query: SearchQuery.fromMap(map['query'] as Map<String, dynamic>),
      resultCount: map['result_count'] as int,
      searchedAt: DateTime.parse(map['searched_at'] as String),
      wasSuccessful: map['was_successful'] as bool,
    );
  }
}

class SearchIndex {
  final String id;
  final String documentId;
  final List<IndexedTerm> terms;
  final DateTime indexedAt;
  final int totalWords;
  final Map<String, int> termFrequencies;

  SearchIndex({
    required this.id,
    required this.documentId,
    required this.terms,
    required this.indexedAt,
    required this.totalWords,
    required this.termFrequencies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'terms': terms.map((t) => t.toMap()).toList(),
      'indexed_at': indexedAt.toIso8601String(),
      'total_words': totalWords,
      'term_frequencies': termFrequencies,
    };
  }

  factory SearchIndex.fromMap(Map<String, dynamic> map) {
    return SearchIndex(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      terms: (map['terms'] as List<dynamic>)
          .map((t) => IndexedTerm.fromMap(t as Map<String, dynamic>))
          .toList(),
      indexedAt: DateTime.parse(map['indexed_at'] as String),
      totalWords: map['total_words'] as int,
      termFrequencies: Map<String, int>.from(map['term_frequencies'] ?? {}),
    );
  }
}

class IndexedTerm {
  final String term;
  final int frequency;
  final List<int> positions;
  final double weight;

  IndexedTerm({
    required this.term,
    required this.frequency,
    required this.positions,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'frequency': frequency,
      'positions': positions,
      'weight': weight,
    };
  }

  factory IndexedTerm.fromMap(Map<String, dynamic> map) {
    return IndexedTerm(
      term: map['term'] as String,
      frequency: map['frequency'] as int,
      positions: List<int>.from(map['positions'] ?? []),
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SearchSuggestion {
  final String suggestion;
  final SuggestionType type;
  final int frequency;
  final double confidence;

  SearchSuggestion({
    required this.suggestion,
    required this.type,
    required this.frequency,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'suggestion': suggestion,
      'type': type.name,
      'frequency': frequency,
      'confidence': confidence,
    };
  }

  factory SearchSuggestion.fromMap(Map<String, dynamic> map) {
    return SearchSuggestion(
      suggestion: map['suggestion'] as String,
      type: SuggestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SuggestionType.autocomplete,
      ),
      frequency: map['frequency'] as int,
      confidence: (map['confidence'] as num).toDouble(),
    );
  }
}

enum SuggestionType { autocomplete, spelling, related, popular }

class SearchAnalytics {
  final int totalSearches;
  final int successfulSearches;
  final int failedSearches;
  final Map<String, int> popularTerms;
  final double averageResultCount;
  final DateTime lastUpdated;

  SearchAnalytics({
    required this.totalSearches,
    required this.successfulSearches,
    required this.failedSearches,
    required this.popularTerms,
    required this.averageResultCount,
    required this.lastUpdated,
  });

  double get successRate {
    if (totalSearches == 0) return 0.0;
    return successfulSearches / totalSearches;
  }

  Map<String, dynamic> toMap() {
    return {
      'total_searches': totalSearches,
      'successful_searches': successfulSearches,
      'failed_searches': failedSearches,
      'popular_terms': popularTerms,
      'average_result_count': averageResultCount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory SearchAnalytics.fromMap(Map<String, dynamic> map) {
    return SearchAnalytics(
      totalSearches: map['total_searches'] as int,
      successfulSearches: map['successful_searches'] as int,
      failedSearches: map['failed_searches'] as int,
      popularTerms: Map<String, int>.from(map['popular_terms'] ?? {}),
      averageResultCount: (map['average_result_count'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
  }
}
