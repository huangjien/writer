class WritingAssistantSuggestion {
  final String id;
  final String type;
  final String suggestion;
  final String context;
  final double confidence;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  WritingAssistantSuggestion({
    required this.id,
    required this.type,
    required this.suggestion,
    required this.context,
    required this.confidence,
    required this.createdAt,
    this.metadata,
  });

  WritingAssistantSuggestion copyWith({
    String? id,
    String? type,
    String? suggestion,
    String? context,
    double? confidence,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return WritingAssistantSuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      suggestion: suggestion ?? this.suggestion,
      context: context ?? this.context,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'suggestion': suggestion,
      'context': context,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory WritingAssistantSuggestion.fromMap(Map<String, dynamic> map) {
    return WritingAssistantSuggestion(
      id: map['id'] as String,
      type: map['type'] as String,
      suggestion: map['suggestion'] as String,
      context: map['context'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

enum SuggestionType {
  grammar,
  style,
  vocabulary,
  sentenceStructure,
  clarity,
  tone,
  consistency,
  pacing,
  dialogue,
  description,
}

class WritingContext {
  final String documentId;
  final String text;
  final int cursorPosition;
  final String? currentScene;
  final List<String>? nearbyCharacters;
  final String? location;
  final String? genre;
  final String? tone;

  WritingContext({
    required this.documentId,
    required this.text,
    required this.cursorPosition,
    this.currentScene,
    this.nearbyCharacters,
    this.location,
    this.genre,
    this.tone,
  });

  String getTextBeforeCursor({int length = 200}) {
    final start = (cursorPosition - length).clamp(0, text.length);
    return text.substring(start, cursorPosition);
  }

  String getTextAfterCursor({int length = 200}) {
    final end = (cursorPosition + length).clamp(0, text.length);
    return text.substring(cursorPosition, end);
  }

  WritingContext copyWith({
    String? documentId,
    String? text,
    int? cursorPosition,
    String? currentScene,
    List<String>? nearbyCharacters,
    String? location,
    String? genre,
    String? tone,
  }) {
    return WritingContext(
      documentId: documentId ?? this.documentId,
      text: text ?? this.text,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      currentScene: currentScene ?? this.currentScene,
      nearbyCharacters: nearbyCharacters ?? this.nearbyCharacters,
      location: location ?? this.location,
      genre: genre ?? this.genre,
      tone: tone ?? this.tone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'text': text,
      'cursor_position': cursorPosition,
      'current_scene': currentScene,
      'nearby_characters': nearbyCharacters,
      'location': location,
      'genre': genre,
      'tone': tone,
    };
  }

  factory WritingContext.fromMap(Map<String, dynamic> map) {
    return WritingContext(
      documentId: map['document_id'] as String,
      text: map['text'] as String,
      cursorPosition: map['cursor_position'] as int,
      currentScene: map['current_scene'] as String?,
      nearbyCharacters: map['nearby_characters'] as List<String>?,
      location: map['location'] as String?,
      genre: map['genre'] as String?,
      tone: map['tone'] as String?,
    );
  }
}

class AutoCompletionResult {
  final String id;
  final String completion;
  final String type;
  final double confidence;
  final List<String>? alternatives;

  AutoCompletionResult({
    required this.id,
    required this.completion,
    required this.type,
    required this.confidence,
    this.alternatives,
  });

  AutoCompletionResult copyWith({
    String? id,
    String? completion,
    String? type,
    double? confidence,
    List<String>? alternatives,
  }) {
    return AutoCompletionResult(
      id: id ?? this.id,
      completion: completion ?? this.completion,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completion': completion,
      'type': type,
      'confidence': confidence,
      'alternatives': alternatives,
    };
  }

  factory AutoCompletionResult.fromMap(Map<String, dynamic> map) {
    return AutoCompletionResult(
      id: map['id'] as String,
      completion: map['completion'] as String,
      type: map['type'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      alternatives: map['alternatives'] as List<String>?,
    );
  }
}

enum CompletionType {
  characterName,
  location,
  item,
  description,
  dialogue,
  action,
}

class WritingAnalysis {
  final String id;
  final String documentId;
  final int totalWords;
  final int uniqueWords;
  final double averageSentenceLength;
  final double averageWordLength;
  final double readabilityScore;
  final Map<String, int> partOfSpeechDistribution;
  final List<String> repeatedPhrases;
  final List<String> grammarIssues;
  final List<String> styleSuggestions;
  final DateTime analyzedAt;

  WritingAnalysis({
    required this.id,
    required this.documentId,
    required this.totalWords,
    required this.uniqueWords,
    required this.averageSentenceLength,
    required this.averageWordLength,
    required this.readabilityScore,
    required this.partOfSpeechDistribution,
    required this.repeatedPhrases,
    required this.grammarIssues,
    required this.styleSuggestions,
    required this.analyzedAt,
  });

  double get vocabularyRichness {
    if (totalWords == 0) return 0.0;
    return uniqueWords / totalWords;
  }

  bool get hasGoodReadability => readabilityScore >= 0.6;

  WritingAnalysis copyWith({
    String? id,
    String? documentId,
    int? totalWords,
    int? uniqueWords,
    double? averageSentenceLength,
    double? averageWordLength,
    double? readabilityScore,
    Map<String, int>? partOfSpeechDistribution,
    List<String>? repeatedPhrases,
    List<String>? grammarIssues,
    List<String>? styleSuggestions,
    DateTime? analyzedAt,
  }) {
    return WritingAnalysis(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      totalWords: totalWords ?? this.totalWords,
      uniqueWords: uniqueWords ?? this.uniqueWords,
      averageSentenceLength:
          averageSentenceLength ?? this.averageSentenceLength,
      averageWordLength: averageWordLength ?? this.averageWordLength,
      readabilityScore: readabilityScore ?? this.readabilityScore,
      partOfSpeechDistribution:
          partOfSpeechDistribution ?? this.partOfSpeechDistribution,
      repeatedPhrases: repeatedPhrases ?? this.repeatedPhrases,
      grammarIssues: grammarIssues ?? this.grammarIssues,
      styleSuggestions: styleSuggestions ?? this.styleSuggestions,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'total_words': totalWords,
      'unique_words': uniqueWords,
      'average_sentence_length': averageSentenceLength,
      'average_word_length': averageWordLength,
      'readability_score': readabilityScore,
      'part_of_speech_distribution': partOfSpeechDistribution,
      'repeated_phrases': repeatedPhrases,
      'grammar_issues': grammarIssues,
      'style_suggestions': styleSuggestions,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  factory WritingAnalysis.fromMap(Map<String, dynamic> map) {
    return WritingAnalysis(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      totalWords: map['total_words'] as int,
      uniqueWords: map['unique_words'] as int,
      averageSentenceLength: (map['average_sentence_length'] as num).toDouble(),
      averageWordLength: (map['average_word_length'] as num).toDouble(),
      readabilityScore: (map['readability_score'] as num).toDouble(),
      partOfSpeechDistribution: Map<String, int>.from(
        map['part_of_speech_distribution'] ?? {},
      ),
      repeatedPhrases: List<String>.from(map['repeated_phrases'] ?? []),
      grammarIssues: List<String>.from(map['grammar_issues'] ?? []),
      styleSuggestions: List<String>.from(map['style_suggestions'] ?? []),
      analyzedAt: DateTime.parse(map['analyzed_at'] as String),
    );
  }
}
