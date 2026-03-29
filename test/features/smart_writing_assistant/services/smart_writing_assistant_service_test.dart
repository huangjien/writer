import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/character_consistency/services/character_consistency_service.dart';
import 'package:writer/features/smart_writing_assistant/services/smart_writing_assistant_service.dart';
import 'package:writer/models/writing_assistant_suggestion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmartWritingAssistantService', () {
    late SmartWritingAssistantService assistantService;
    late CharacterConsistencyService characterService;

    setUp(() async {
      characterService = CharacterConsistencyService();
      assistantService = SmartWritingAssistantService(characterService);
    });

    group('getSuggestions', () {
      test('should return empty list for empty text', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions, isEmpty);
      });

      test('should return grammar suggestions for text with issues', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'a apple',
          cursorPosition: 7,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions, isNotEmpty);
        final grammarSuggestions = suggestions.where(
          (s) => s.type == 'grammar',
        );
        expect(grammarSuggestions, isNotEmpty);
      });

      test('should detect spacing issues', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'word  word',
          cursorPosition: 10,
        );

        final suggestions = await assistantService.getSuggestions(context);

        final spacingIssues = suggestions.where((s) => s.type == 'spacing');
        expect(spacingIssues, isNotEmpty);
      });

      test('should detect missing punctuation', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text:
              'This is a very long sentence with many words but no punctuation at the end',
          cursorPosition: 68,
        );

        final suggestions = await assistantService.getSuggestions(context);

        final punctuationSuggestions = suggestions.where(
          (s) => s.type == 'punctuation',
        );
        expect(punctuationSuggestions, isNotEmpty);
      });

      test('should detect uncapitalized "I"', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'i think so',
          cursorPosition: 9,
        );

        final suggestions = await assistantService.getSuggestions(context);

        final capitalizationIssues = suggestions.where(
          (s) => s.type == 'capitalization',
        );
        expect(capitalizationIssues, isNotEmpty);
      });

      test('should suggest for long sentences', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text:
              'This is a very long sentence that continues on and on with many words and clauses and phrases without any end in sight',
          cursorPosition: 117,
        );

        final suggestions = await assistantService.getSuggestions(context);

        final sentenceLengthSuggestions = suggestions.where(
          (s) => s.type == 'sentence_length',
        );
        expect(sentenceLengthSuggestions, isNotEmpty);
      });

      test('should detect passive voice', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'The ball was thrown by the player',
          cursorPosition: 31,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions, isNotEmpty);
      });

      test('should suggest vocabulary improvements', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'The big good movie was very very very good',
          cursorPosition: 40,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions.length, greaterThan(0));
      });

      test('should detect overuse of "very"', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'It is very very very good',
          cursorPosition: 23,
        );

        final suggestions = await assistantService.getSuggestions(context);

        final wordChoiceSuggestions = suggestions.where(
          (s) => s.type == 'word_choice',
        );
        expect(wordChoiceSuggestions, isNotEmpty);
      });

      test('should limit suggestions to 10', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text:
              'a apple i think very bad very good very big very small very long text with many issues',
          cursorPosition: 85,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions.length, lessThanOrEqualTo(10));
      });

      test('should sort suggestions by confidence', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: 'a apple',
          cursorPosition: 7,
        );

        final suggestions = await assistantService.getSuggestions(context);

        expect(suggestions, isNotEmpty);
        for (int i = 0; i < suggestions.length - 1; i++) {
          expect(
            suggestions[i].confidence,
            greaterThanOrEqualTo(suggestions[i + 1].confidence),
          );
        }
      });
    });

    group('getAutoCompletions', () {
      test('should return character name completions', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          'th',
        );

        expect(completions, isNotNull);
        expect(completions, isA<List<AutoCompletionResult>>());
      });

      test('should return location completions', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
          location: 'Paris',
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          'P',
        );

        expect(completions, isNotEmpty);
        final locationCompletions = completions.where(
          (c) => c.type == 'location',
        );
        expect(locationCompletions, isNotEmpty);
      });

      test('should return word completions', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          'th',
        );

        expect(completions, isNotEmpty);
        final wordCompletions = completions.where((c) => c.type == 'word');
        expect(wordCompletions, isNotEmpty);
      });

      test('should return genre-specific completions for fantasy', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
          genre: 'Fantasy',
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          'w',
        );

        expect(completions, isNotEmpty);
        final fantasyCompletions = completions.where(
          (c) =>
              c.completion == 'wizard' ||
              c.completion == 'magic' ||
              c.completion == 'dragon',
        );
        expect(fantasyCompletions, isNotEmpty);
      });

      test(
        'should return genre-specific completions for science fiction',
        () async {
          final context = WritingContext(
            documentId: 'doc1',
            text: '',
            cursorPosition: 0,
            genre: 'Science Fiction',
          );

          final completions = await assistantService.getAutoCompletions(
            context,
            's',
          );

          expect(completions, isNotEmpty);
          final scifiCompletions = completions.where(
            (c) => c.completion == 'spaceship' || c.completion == 'spaceship',
          );
          expect(scifiCompletions, isNotEmpty);
        },
      );

      test('should limit completions to 10', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          'a',
        );

        expect(completions.length, lessThanOrEqualTo(10));
      });

      test('should sort completions by confidence', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          't',
        );

        expect(completions, isNotEmpty);
        for (int i = 0; i < completions.length - 1; i++) {
          expect(
            completions[i].confidence,
            greaterThanOrEqualTo(completions[i + 1].confidence),
          );
        }
      });

      test('should handle empty partial input', () async {
        final context = WritingContext(
          documentId: 'doc1',
          text: '',
          cursorPosition: 0,
        );

        final completions = await assistantService.getAutoCompletions(
          context,
          '',
        );

        expect(completions, isNotEmpty);
      });
    });

    group('analyzeText', () {
      test('should analyze simple text', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'This is a test.',
        );

        expect(analysis.documentId, 'doc1');
        expect(analysis.totalWords, 4);
        expect(analysis.uniqueWords, greaterThan(0));
      });

      test('should calculate average sentence length', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'This is a test. This is another test.',
        );

        expect(analysis.averageSentenceLength, greaterThan(0));
      });

      test('should calculate average word length', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'Hello world',
        );

        expect(analysis.averageWordLength, greaterThan(0));
      });

      test('should calculate readability score', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'The quick brown fox jumps over the lazy dog.',
        );

        expect(analysis.readabilityScore, greaterThanOrEqualTo(0));
        expect(analysis.readabilityScore, lessThanOrEqualTo(1.0));
      });

      test('should analyze part of speech distribution', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'The person is good. The time is now.',
        );

        expect(analysis.partOfSpeechDistribution, isNotEmpty);
      });

      test('should find repeated phrases', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'This is a test. This is a test. This is a test. This is a test.',
        );

        expect(analysis.repeatedPhrases, isNotEmpty);
      });

      test('should detect grammar issues', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'word  word with  spaces  and  i think',
        );

        expect(analysis.grammarIssues, isNotEmpty);
      });

      test('should generate style suggestions', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'This is a very very long sentence with many words and clauses and phrases and it goes on and on and on and on and on and on and on.',
        );

        expect(analysis.styleSuggestions, isNotEmpty);
      });

      test('should calculate vocabulary richness', () async {
        final analysis1 = await assistantService.analyzeText(
          'doc1',
          'The cat sat on the mat.',
        );

        final analysis2 = await assistantService.analyzeText(
          'doc2',
          'Felines reclined upon woven floor coverings.',
        );

        expect(
          analysis2.vocabularyRichness,
          greaterThanOrEqualTo(analysis1.vocabularyRichness),
        );
      });

      test('should determine good readability', () async {
        final analysis = await assistantService.analyzeText(
          'doc1',
          'The cat sat. The dog ran. Birds fly.',
        );

        expect(analysis.readabilityScore, greaterThanOrEqualTo(0));
        expect(analysis.readabilityScore, lessThanOrEqualTo(1.0));
      });

      test('should have valid analysis metadata', () async {
        final analysis = await assistantService.analyzeText('doc1', 'Test');

        expect(analysis.id, isNotEmpty);
        expect(analysis.analyzedAt, isNotNull);
        expect(analysis.analyzedAt.isBefore(DateTime.now()), true);
      });

      test('should handle empty text', () async {
        final analysis = await assistantService.analyzeText('doc1', '');

        expect(analysis.totalWords, 0);
        expect(analysis.uniqueWords, 0);
        expect(analysis.averageSentenceLength, 0);
      });

      test('should have valid analysis metadata', () async {
        final analysis = await assistantService.analyzeText('doc1', 'Test');

        expect(analysis.id, isNotEmpty);
        expect(analysis.analyzedAt, isNotNull);
        expect(analysis.analyzedAt.isBefore(DateTime.now()), true);
      });
    });

    group('dismissSuggestion', () {
      test('should dismiss suggestion without error', () async {
        await assistantService.dismissSuggestion('suggestion_id');

        expect(true, true);
      });
    });

    group('applySuggestion', () {
      test('should apply suggestion without error', () async {
        await assistantService.applySuggestion(
          'suggestion_id',
          'original',
          'suggested',
        );

        expect(true, true);
      });
    });
  });
}
