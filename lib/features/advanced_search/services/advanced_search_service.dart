import 'package:uuid/uuid.dart';
import 'package:writer/models/advanced_search.dart';

class AdvancedSearchService {
  final Uuid _uuid = Uuid();
  final List<SearchHistory> _searchHistory = [];
  final List<SearchIndex> _indices = [];
  final Map<String, int> _termFrequencies = {};

  Future<List<SearchResult>> search(SearchQuery query) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final results = <SearchResult>[];

    final queryLower = query.query.toLowerCase();

    if (query.type == SearchType.text || query.type == SearchType.fuzzy) {
      results.addAll(_searchText(queryLower, query));
    } else if (query.type == SearchType.phrase) {
      results.addAll(_searchPhrase(query.query, query));
    } else if (query.type == SearchType.regex) {
      results.addAll(_searchRegex(query.query, query));
    } else if (query.type == SearchType.semantic) {
      results.addAll(_searchSemantic(query.query, query));
    }

    _addToHistory(query, results.length);

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results;
  }

  List<SearchResult> _searchText(String query, SearchQuery searchQuery) {
    final results = <SearchResult>[];

    final mockDocuments = [
      {
        'id': 'doc1',
        'title': 'Chapter One: The Beginning',
        'content':
            'This is the first chapter of the book. It starts with a great introduction.',
      },
      {
        'id': 'doc2',
        'title': 'Character Development',
        'content': 'The main character grows throughout the story.',
      },
      {
        'id': 'doc3',
        'title': 'The Climax',
        'content':
            'The climax happens when the hero faces their greatest challenge.',
      },
    ];

    for (final doc in mockDocuments) {
      final content = (doc['content'] as String).toLowerCase();
      final title = (doc['title'] as String).toLowerCase();

      if (content.contains(query) || title.contains(query)) {
        final score = _calculateRelevanceScore(
          query,
          doc['content'] as String,
          doc['title'] as String,
        );
        final snippet = _generateSnippet(doc['content'] as String, query);

        results.add(
          SearchResult(
            id: _uuid.v4(),
            documentId: doc['id'] as String,
            documentTitle: doc['title'] as String,
            snippet: snippet,
            relevanceScore: score,
            type: SearchResultType.document,
            lastModified: DateTime.now(),
          ),
        );
      }
    }

    return results;
  }

  List<SearchResult> _searchPhrase(String phrase, SearchQuery searchQuery) {
    final results = <SearchResult>[];

    final mockDocuments = [
      {
        'id': 'doc1',
        'title': 'Chapter One: The Beginning',
        'content': 'This is the first chapter of the book.',
      },
    ];

    for (final doc in mockDocuments) {
      final content = doc['content'] as String;

      if (content.toLowerCase().contains(phrase.toLowerCase())) {
        results.add(
          SearchResult(
            id: _uuid.v4(),
            documentId: doc['id'] as String,
            documentTitle: doc['title'] as String,
            snippet: _generateSnippet(content, phrase),
            relevanceScore: 0.95,
            type: SearchResultType.document,
            lastModified: DateTime.now(),
          ),
        );
      }
    }

    return results;
  }

  List<SearchResult> _searchRegex(String pattern, SearchQuery searchQuery) {
    try {
      final regex = RegExp(pattern, caseSensitive: false);
      final results = <SearchResult>[];

      final mockDocuments = [
        {
          'id': 'doc1',
          'title': 'Chapter One',
          'content': 'This is the first chapter.',
        },
      ];

      for (final doc in mockDocuments) {
        final content = doc['content'] as String;

        if (regex.hasMatch(content)) {
          results.add(
            SearchResult(
              id: _uuid.v4(),
              documentId: doc['id'] as String,
              documentTitle: doc['title'] as String,
              snippet: _generateSnippet(content, pattern),
              relevanceScore: 0.9,
              type: SearchResultType.document,
              lastModified: DateTime.now(),
            ),
          );
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  List<SearchResult> _searchSemantic(String query, SearchQuery searchQuery) {
    final results = <SearchResult>[];

    final semanticMatches = [
      {
        'id': 'doc1',
        'title': 'Character Growth',
        'content': 'The protagonist evolves through trials.',
      },
    ];

    for (final doc in semanticMatches) {
      results.add(
        SearchResult(
          id: _uuid.v4(),
          documentId: doc['id'] as String,
          documentTitle: doc['title'] as String,
          snippet: doc['content'] as String,
          relevanceScore: 0.75,
          type: SearchResultType.document,
          lastModified: DateTime.now(),
        ),
      );
    }

    return results;
  }

  double _calculateRelevanceScore(String query, String content, String title) {
    var score = 0.0;

    final titleLower = title.toLowerCase();
    final contentLower = content.toLowerCase();

    if (titleLower.contains(query)) {
      score += 0.4;
    }

    if (contentLower.contains(query)) {
      score += 0.3;

      final wordCount = contentLower.split(' ').length;
      final queryCount = query.split(' ').length;
      score += (queryCount / wordCount).clamp(0.0, 0.3);
    }

    return score.clamp(0.0, 1.0);
  }

  String _generateSnippet(String content, String query) {
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerContent.indexOf(lowerQuery);

    if (index == -1) {
      return content.length > 100 ? '${content.substring(0, 100)}...' : content;
    }

    final start = (index - 50).clamp(0, content.length);
    final end = (index + query.length + 50).clamp(0, content.length);

    var snippet = content.substring(start, end);

    if (start > 0) snippet = '...$snippet';
    if (end < content.length) snippet = '$snippet...';

    return snippet;
  }

  void _addToHistory(SearchQuery query, int resultCount) {
    final history = SearchHistory(
      id: _uuid.v4(),
      query: query,
      resultCount: resultCount,
      searchedAt: DateTime.now(),
      wasSuccessful: resultCount > 0,
    );

    _searchHistory.add(history);

    if (_searchHistory.length > 100) {
      _searchHistory.removeAt(0);
    }

    _updateTermFrequency(query.query);
  }

  void _updateTermFrequency(String term) {
    _termFrequencies[term.toLowerCase()] =
        (_termFrequencies[term.toLowerCase()] ?? 0) + 1;
  }

  Future<List<SearchSuggestion>> getSuggestions(String partialQuery) async {
    await Future.delayed(const Duration(milliseconds: 30));

    final suggestions = <SearchSuggestion>[];
    final queryLower = partialQuery.toLowerCase();

    final recentTerms = _searchHistory
        .take(10)
        .map((h) => h.query.query)
        .where((term) => term.toLowerCase().startsWith(queryLower))
        .toSet();

    for (final term in recentTerms) {
      final frequency = _termFrequencies[term.toLowerCase()] ?? 1;
      suggestions.add(
        SearchSuggestion(
          suggestion: term,
          type: SuggestionType.autocomplete,
          frequency: frequency,
          confidence: 0.8,
        ),
      );
    }

    final popularTerms = ['character', 'chapter', 'scene', 'dialogue', 'plot'];
    for (final term in popularTerms) {
      if (term.startsWith(queryLower)) {
        suggestions.add(
          SearchSuggestion(
            suggestion: term,
            type: SuggestionType.popular,
            frequency: 10,
            confidence: 0.7,
          ),
        );
      }
    }

    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return suggestions.take(5).toList();
  }

  Future<List<SearchHistory>> getSearchHistory({int limit = 20}) async {
    return _searchHistory.take(limit).toList();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
  }

  Future<void> deleteSearchHistoryItem(String historyId) async {
    _searchHistory.removeWhere((h) => h.id == historyId);
  }

  Future<SearchAnalytics> getAnalytics() async {
    final totalSearches = _searchHistory.length;
    final successfulSearches = _searchHistory
        .where((h) => h.wasSuccessful)
        .length;
    final failedSearches = totalSearches - successfulSearches;

    final resultCounts = _searchHistory.map((h) => h.resultCount).toList();
    final averageResultCount = resultCounts.isNotEmpty
        ? resultCounts.reduce((a, b) => a + b) / resultCounts.length
        : 0.0;

    return SearchAnalytics(
      totalSearches: totalSearches,
      successfulSearches: successfulSearches,
      failedSearches: failedSearches,
      popularTerms: _termFrequencies,
      averageResultCount: averageResultCount,
      lastUpdated: DateTime.now(),
    );
  }

  Future<SearchIndex> indexDocument(
    String documentId,
    String title,
    String content,
  ) async {
    final terms = <IndexedTerm>[];
    final wordFrequencies = <String, int>{};

    final words = content.toLowerCase().split(RegExp(r'\s+'));
    final positions = <String, List<int>>{};

    for (var i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(RegExp(r'[^\w]'), '');

      if (word.isEmpty) continue;

      wordFrequencies[word] = (wordFrequencies[word] ?? 0) + 1;
      positions.putIfAbsent(word, () => []);
      positions[word]!.add(i);
    }

    final totalWords = words.length;

    for (final entry in wordFrequencies.entries) {
      final tf = entry.value / totalWords;
      const idf = 1.0;
      final weight = tf * idf;

      terms.add(
        IndexedTerm(
          term: entry.key,
          frequency: entry.value,
          positions: positions[entry.key] ?? [],
          weight: weight,
        ),
      );
    }

    final index = SearchIndex(
      id: _uuid.v4(),
      documentId: documentId,
      terms: terms,
      indexedAt: DateTime.now(),
      totalWords: totalWords,
      termFrequencies: wordFrequencies,
    );

    _indices.add(index);

    return index;
  }

  Future<void> removeIndex(String documentId) async {
    _indices.removeWhere((index) => index.documentId == documentId);
  }

  Future<void> rebuildIndex(
    String documentId,
    String title,
    String content,
  ) async {
    await removeIndex(documentId);
    await indexDocument(documentId, title, content);
  }

  Future<List<SearchResult>> advancedSearch({
    required String query,
    SearchType type = SearchType.text,
    SearchScope scope = SearchScope.all,
    List<SearchFilter>? filters,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 20,
  }) async {
    final searchQuery = SearchQuery(
      query: query,
      type: type,
      scope: scope,
      createdAt: DateTime.now(),
      filters: filters?.asMap().map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    var results = await search(searchQuery);

    if (filters != null) {
      results = _applyFilters(results, filters);
    }

    if (dateFrom != null) {
      results = results
          .where(
            (r) => r.lastModified != null && r.lastModified!.isAfter(dateFrom),
          )
          .toList();
    }

    if (dateTo != null) {
      results = results
          .where(
            (r) => r.lastModified != null && r.lastModified!.isBefore(dateTo),
          )
          .toList();
    }

    return results.take(limit).toList();
  }

  List<SearchResult> _applyFilters(
    List<SearchResult> results,
    List<SearchFilter> filters,
  ) {
    var filtered = results;

    for (final filter in filters) {
      if (!filter.isActive) continue;

      filtered = filtered.where((result) {
        final highlights = result.highlights ?? {};

        switch (filter.operator) {
          case FilterOperator.equals:
            return highlights[filter.field] == filter.value;
          case FilterOperator.contains:
            return highlights[filter.field]?.toString().contains(
                  filter.value,
                ) ??
                false;
          case FilterOperator.greaterThan:
            final gtValue = highlights[filter.field] as num?;
            return gtValue != null &&
                gtValue.compareTo(filter.value as num) > 0;
          case FilterOperator.lessThan:
            final ltValue = highlights[filter.field] as num?;
            return ltValue != null &&
                ltValue.compareTo(filter.value as num) < 0;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  Future<Map<String, dynamic>> getSearchStatistics() async {
    final analytics = await getAnalytics();

    return {
      'total_searches': analytics.totalSearches,
      'successful_searches': analytics.successfulSearches,
      'failed_searches': analytics.failedSearches,
      'success_rate': analytics.successRate,
      'average_results': analytics.averageResultCount,
      'indexed_documents': _indices.length,
      'total_terms': _indices.fold<int>(
        0,
        (sum, index) => sum + index.terms.length,
      ),
    };
  }

  Future<void> optimizeIndex() async {
    // print('Optimizing search index...');

    for (final index in _indices) {
      index.terms.sort((a, b) => b.weight.compareTo(a.weight));
    }

    _indices.removeWhere((index) => index.terms.isEmpty);

    // print('Optimization complete');
  }

  Future<String> exportSearchData() async {
    final data = {
      'history': _searchHistory.map((h) => h.toMap()).toList(),
      'indices': _indices.map((i) => i.toMap()).toList(),
      'term_frequencies': _termFrequencies,
      'exported_at': DateTime.now().toIso8601String(),
    };

    return data.toString();
  }

  Future<void> importSearchData(String data) async {
    // print('Importing search data: $data');
  }
}
