import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/writing_assistant_suggestion.dart';

void main() {
  group('WritingAssistantSuggestion', () {
    test('should create instance with all fields', () {
      final suggestion = WritingAssistantSuggestion(
        id: '1',
        type: 'grammar',
        suggestion: 'Fix the grammar',
        context: 'The sentence structure is unclear',
        confidence: 0.9,
        createdAt: DateTime(2026, 3, 29),
      );

      expect(suggestion.id, '1');
      expect(suggestion.type, 'grammar');
      expect(suggestion.suggestion, 'Fix the grammar');
      expect(suggestion.context, 'The sentence structure is unclear');
      expect(suggestion.confidence, 0.9);
    });

    test('should copy with new values', () {
      final suggestion = WritingAssistantSuggestion(
        id: '1',
        type: 'grammar',
        suggestion: 'Fix the grammar',
        context: 'The sentence structure is unclear',
        confidence: 0.9,
        createdAt: DateTime(2026, 3, 29),
      );

      final updated = suggestion.copyWith(
        suggestion: 'Updated suggestion',
        confidence: 0.95,
      );

      expect(updated.id, '1');
      expect(updated.suggestion, 'Updated suggestion');
      expect(updated.confidence, 0.95);
      expect(updated.context, 'The sentence structure is unclear');
    });

    test('should serialize to map', () {
      final suggestion = WritingAssistantSuggestion(
        id: '1',
        type: 'grammar',
        suggestion: 'Fix the grammar',
        context: 'The sentence structure is unclear',
        confidence: 0.9,
        createdAt: DateTime(2026, 3, 29),
        metadata: {'key': 'value'},
      );

      final map = suggestion.toMap();

      expect(map['id'], '1');
      expect(map['type'], 'grammar');
      expect(map['suggestion'], 'Fix the grammar');
      expect(map['confidence'], 0.9);
      expect(map['metadata'], {'key': 'value'});
    });

    test('should deserialize from map', () {
      final map = {
        'id': '1',
        'type': 'grammar',
        'suggestion': 'Fix the grammar',
        'context': 'The sentence structure is unclear',
        'confidence': 0.9,
        'created_at': '2026-03-29T00:00:00.000Z',
        'metadata': {'key': 'value'},
      };

      final suggestion = WritingAssistantSuggestion.fromMap(map);

      expect(suggestion.id, '1');
      expect(suggestion.type, 'grammar');
      expect(suggestion.suggestion, 'Fix the grammar');
      expect(suggestion.metadata, {'key': 'value'});
    });
  });

  group('WritingContext', () {
    test('should create instance with all fields', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'This is a sample text',
        cursorPosition: 10,
        currentScene: 'Scene 1',
        nearbyCharacters: ['John', 'Jane'],
        location: 'Office',
        genre: 'Fiction',
        tone: 'Dramatic',
      );

      expect(context.documentId, 'doc1');
      expect(context.text, 'This is a sample text');
      expect(context.cursorPosition, 10);
      expect(context.currentScene, 'Scene 1');
      expect(context.nearbyCharacters, ['John', 'Jane']);
      expect(context.location, 'Office');
    });

    test('should get text before cursor', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'This is a sample text for testing',
        cursorPosition: 16,
      );

      final beforeCursor = context.getTextBeforeCursor(length: 10);
      expect(beforeCursor, 's a sample');
    });

    test('should get text after cursor', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'This is a sample text for testing',
        cursorPosition: 16,
      );

      final afterCursor = context.getTextAfterCursor(length: 10);
      expect(afterCursor, ' text for ');
    });

    test('should handle cursor at start', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'Sample text',
        cursorPosition: 0,
      );

      final beforeCursor = context.getTextBeforeCursor(length: 10);
      expect(beforeCursor, '');
    });

    test('should handle cursor at end', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'Sample text',
        cursorPosition: 11,
      );

      final afterCursor = context.getTextAfterCursor(length: 10);
      expect(afterCursor, '');
    });

    test('should copy with new values', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'This is a sample text',
        cursorPosition: 10,
      );

      final updated = context.copyWith(cursorPosition: 15, location: 'Home');

      expect(updated.cursorPosition, 15);
      expect(updated.location, 'Home');
      expect(updated.text, 'This is a sample text');
    });

    test('should serialize to map', () {
      final context = WritingContext(
        documentId: 'doc1',
        text: 'This is a sample text',
        cursorPosition: 10,
        nearbyCharacters: ['John', 'Jane'],
      );

      final map = context.toMap();

      expect(map['document_id'], 'doc1');
      expect(map['text'], 'This is a sample text');
      expect(map['cursor_position'], 10);
      expect(map['nearby_characters'], ['John', 'Jane']);
    });

    test('should deserialize from map', () {
      final map = {
        'document_id': 'doc1',
        'text': 'This is a sample text',
        'cursor_position': 10,
        'current_scene': 'Scene 1',
        'nearby_characters': ['John', 'Jane'],
        'location': 'Office',
      };

      final context = WritingContext.fromMap(map);

      expect(context.documentId, 'doc1');
      expect(context.text, 'This is a sample text');
      expect(context.currentScene, 'Scene 1');
      expect(context.nearbyCharacters, ['John', 'Jane']);
    });
  });

  group('AutoCompletionResult', () {
    test('should create instance with all fields', () {
      final result = AutoCompletionResult(
        id: '1',
        completion: 'John Doe',
        type: 'character_name',
        confidence: 0.95,
        alternatives: ['John Smith', 'Jane Doe'],
      );

      expect(result.id, '1');
      expect(result.completion, 'John Doe');
      expect(result.type, 'character_name');
      expect(result.confidence, 0.95);
      expect(result.alternatives, ['John Smith', 'Jane Doe']);
    });

    test('should copy with new values', () {
      final result = AutoCompletionResult(
        id: '1',
        completion: 'John Doe',
        type: 'character_name',
        confidence: 0.95,
      );

      final updated = result.copyWith(completion: 'Jane Doe', confidence: 0.98);

      expect(updated.completion, 'Jane Doe');
      expect(updated.confidence, 0.98);
      expect(updated.type, 'character_name');
    });

    test('should serialize to map', () {
      final result = AutoCompletionResult(
        id: '1',
        completion: 'John Doe',
        type: 'character_name',
        confidence: 0.95,
        alternatives: ['John Smith'],
      );

      final map = result.toMap();

      expect(map['id'], '1');
      expect(map['completion'], 'John Doe');
      expect(map['type'], 'character_name');
      expect(map['confidence'], 0.95);
      expect(map['alternatives'], ['John Smith']);
    });

    test('should deserialize from map', () {
      final map = {
        'id': '1',
        'completion': 'John Doe',
        'type': 'character_name',
        'confidence': 0.95,
        'alternatives': ['John Smith'],
      };

      final result = AutoCompletionResult.fromMap(map);

      expect(result.id, '1');
      expect(result.completion, 'John Doe');
      expect(result.type, 'character_name');
      expect(result.alternatives, ['John Smith']);
    });
  });

  group('WritingAnalysis', () {
    test('should create instance with all fields', () {
      final analysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.75,
        partOfSpeechDistribution: {'noun': 300, 'verb': 200},
        repeatedPhrases: ['very good', 'really bad'],
        grammarIssues: ['Missing period'],
        styleSuggestions: ['Use active voice'],
        analyzedAt: DateTime(2026, 3, 29),
      );

      expect(analysis.id, '1');
      expect(analysis.totalWords, 1000);
      expect(analysis.uniqueWords, 500);
      expect(analysis.averageSentenceLength, 15.5);
      expect(analysis.readabilityScore, 0.75);
    });

    test('should calculate vocabulary richness', () {
      final analysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.75,
        partOfSpeechDistribution: {},
        repeatedPhrases: [],
        grammarIssues: [],
        styleSuggestions: [],
        analyzedAt: DateTime(2026, 3, 29),
      );

      expect(analysis.vocabularyRichness, 0.5);
    });

    test('should handle zero total words for vocabulary richness', () {
      final analysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 0,
        uniqueWords: 0,
        averageSentenceLength: 0.0,
        averageWordLength: 0.0,
        readabilityScore: 0.0,
        partOfSpeechDistribution: {},
        repeatedPhrases: [],
        grammarIssues: [],
        styleSuggestions: [],
        analyzedAt: DateTime(2026, 3, 29),
      );

      expect(analysis.vocabularyRichness, 0.0);
    });

    test('should determine good readability', () {
      final goodAnalysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.75,
        partOfSpeechDistribution: {},
        repeatedPhrases: [],
        grammarIssues: [],
        styleSuggestions: [],
        analyzedAt: DateTime(2026, 3, 29),
      );

      final poorAnalysis = WritingAnalysis(
        id: '2',
        documentId: 'doc2',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.5,
        partOfSpeechDistribution: {},
        repeatedPhrases: [],
        grammarIssues: [],
        styleSuggestions: [],
        analyzedAt: DateTime(2026, 3, 29),
      );

      expect(goodAnalysis.hasGoodReadability, true);
      expect(poorAnalysis.hasGoodReadability, false);
    });

    test('should copy with new values', () {
      final analysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.75,
        partOfSpeechDistribution: {},
        repeatedPhrases: [],
        grammarIssues: [],
        styleSuggestions: [],
        analyzedAt: DateTime(2026, 3, 29),
      );

      final updated = analysis.copyWith(
        totalWords: 1500,
        readabilityScore: 0.85,
      );

      expect(updated.totalWords, 1500);
      expect(updated.readabilityScore, 0.85);
      expect(updated.uniqueWords, 500);
    });

    test('should serialize to map', () {
      final analysis = WritingAnalysis(
        id: '1',
        documentId: 'doc1',
        totalWords: 1000,
        uniqueWords: 500,
        averageSentenceLength: 15.5,
        averageWordLength: 4.5,
        readabilityScore: 0.75,
        partOfSpeechDistribution: {'noun': 300},
        repeatedPhrases: ['very good'],
        grammarIssues: ['Missing period'],
        styleSuggestions: ['Use active voice'],
        analyzedAt: DateTime(2026, 3, 29),
      );

      final map = analysis.toMap();

      expect(map['id'], '1');
      expect(map['total_words'], 1000);
      expect(map['readability_score'], 0.75);
      expect(map['part_of_speech_distribution'], {'noun': 300});
    });

    test('should deserialize from map', () {
      final map = {
        'id': '1',
        'document_id': 'doc1',
        'total_words': 1000,
        'unique_words': 500,
        'average_sentence_length': 15.5,
        'average_word_length': 4.5,
        'readability_score': 0.75,
        'part_of_speech_distribution': {'noun': 300},
        'repeated_phrases': ['very good'],
        'grammar_issues': ['Missing period'],
        'style_suggestions': ['Use active voice'],
        'analyzed_at': '2026-03-29T00:00:00.000Z',
      };

      final analysis = WritingAnalysis.fromMap(map);

      expect(analysis.id, '1');
      expect(analysis.totalWords, 1000);
      expect(analysis.readabilityScore, 0.75);
      expect(analysis.partOfSpeechDistribution, {'noun': 300});
      expect(analysis.repeatedPhrases, ['very good']);
    });
  });

  group('SuggestionType', () {
    test('should have all required types', () {
      expect(SuggestionType.values.length, greaterThan(0));
      expect(SuggestionType.grammar, isNotNull);
      expect(SuggestionType.style, isNotNull);
      expect(SuggestionType.vocabulary, isNotNull);
      expect(SuggestionType.sentenceStructure, isNotNull);
      expect(SuggestionType.clarity, isNotNull);
      expect(SuggestionType.tone, isNotNull);
      expect(SuggestionType.consistency, isNotNull);
      expect(SuggestionType.pacing, isNotNull);
      expect(SuggestionType.dialogue, isNotNull);
      expect(SuggestionType.description, isNotNull);
    });
  });

  group('CompletionType', () {
    test('should have all required types', () {
      expect(CompletionType.values.length, greaterThan(0));
      expect(CompletionType.characterName, isNotNull);
      expect(CompletionType.location, isNotNull);
      expect(CompletionType.item, isNotNull);
      expect(CompletionType.description, isNotNull);
      expect(CompletionType.dialogue, isNotNull);
      expect(CompletionType.action, isNotNull);
    });
  });
}
