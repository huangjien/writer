import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/scene_suggestion/services/scene_suggestion_service.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene_suggestion.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/ai_agent_settings.dart';

class MockAiChatService implements AiChatService {
  String? responseToReturn;
  Object? errorToThrow;

  @override
  Future<Map<String, dynamic>?> betaEvaluateChapter({
    required String novelId,
    required String chapterId,
    required String content,
    String language = 'en',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkHealth() async {
    throw UnimplementedError();
  }

  @override
  Future<String> compressContext(
    String context, {
    AppLocalizations? l10n,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn ?? 'Compressed context';
  }

  @override
  Future<List<double>?> embed(String input, {String? model}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessage(
    String message, {
    AiAgentSettings? settings,
    AppLocalizations? l10n,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessageDeepAgent(
    String message, {
    String? context,
    int? maxPlanSteps,
    int? maxToolRounds,
    String reflectionMode = 'off',
    bool includeDetails = false,
    AppLocalizations? l10n,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn ?? 'Default response';
  }

  @override
  Stream<String> streamMessage(
    String message, {
    AiAgentSettings? settings,
  }) async* {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> ragSearch({
    required String query,
    String? category,
    int initialTopK = 10,
    int finalTopK = 5,
    bool refinementEnabled = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> verifyUser() async {
    throw UnimplementedError();
  }

  @override
  RemoteRepository get remote => throw UnimplementedError();
}

void main() {
  late MockAiChatService mockAiChatService;
  late SceneSuggestionService sceneSuggestionService;

  setUp(() {
    mockAiChatService = MockAiChatService();
    sceneSuggestionService = SceneSuggestionService(mockAiChatService);
  });

  group('Suggestion Ranking', () {
    test('should rank suggestions by relevance score', () {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Low quality suggestion',
          relevanceScore: 0.5,
          rationale: 'Basic continuation',
        ),
        const SceneSuggestion(
          suggestedText: 'High quality suggestion',
          relevanceScore: 0.9,
          rationale: 'Excellent continuation with great details',
        ),
        const SceneSuggestion(
          suggestedText: 'Medium quality suggestion',
          relevanceScore: 0.7,
          rationale: 'Good continuation',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(suggestions);

      expect(ranked.length, 3);
      expect(ranked[0].suggestedText, 'High quality suggestion');
      expect(ranked[1].suggestedText, 'Medium quality suggestion');
      expect(ranked[2].suggestedText, 'Low quality suggestion');
    });

    test('should calculate coherence score correctly', () {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
        genre: 'fantasy',
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText:
              'The hero approached the gates. They were tall and imposing.',
          relevanceScore: 0.7,
          rationale: 'Continues the scene naturally',
        ),
        const SceneSuggestion(
          suggestedText: 'Dragon.',
          relevanceScore: 0.7,
          rationale: 'Short',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked.length, 2);
      expect(ranked[0].suggestedText, contains('approached'));
    });

    test('should calculate creativity score correctly', () {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Simple continuation without alternatives',
          relevanceScore: 0.7,
          rationale: 'Basic',
          alternativeApproaches: [],
        ),
        const SceneSuggestion(
          suggestedText:
              'Creative continuation with unique vocabulary and alternatives',
          relevanceScore: 0.7,
          rationale: 'Innovative',
          alternativeApproaches: [
            'Alternative 1',
            'Alternative 2',
            'Alternative 3',
          ],
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(suggestions);

      expect(ranked.length, 2);
      expect(ranked[0].alternativeApproaches.length, greaterThan(0));
    });

    test('should calculate consistency score correctly', () {
      final characters = [
        const Character(novelId: 'novel1', name: 'Hero', role: 'protagonist'),
        const Character(novelId: 'novel1', name: 'Villain', role: 'antagonist'),
      ];

      final request = SceneSuggestionRequest(
        currentScene: 'The hero prepared for battle.',
        genre: 'fantasy',
        characters: characters,
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Someone entered the room.',
          relevanceScore: 0.7,
          rationale: 'Generic',
        ),
        const SceneSuggestion(
          suggestedText:
              'Hero drew their sword as Villain appeared in the doorway.',
          relevanceScore: 0.7,
          rationale: 'Character-focused',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked.length, 2);
      expect(ranked[0].suggestedText, contains('Hero'));
    });

    test('should handle empty suggestion list', () {
      final ranked = sceneSuggestionService.rankSuggestions([]);
      expect(ranked, isEmpty);
    });

    test('should combine all scoring factors', () {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the entrance.',
        genre: 'fantasy',
        characters: [
          Character(novelId: 'novel1', name: 'Hero', role: 'protagonist'),
        ],
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText:
              'Hero walked forward. Then Hero stopped. Then Hero '
              'walked again. Hero. Hero. Hero.',
          relevanceScore: 0.7,
          rationale: 'Repetitive',
          alternativeApproaches: [],
        ),
        const SceneSuggestion(
          suggestedText:
              'The protagonist advanced with determination, eyes fixed on '
              'the horizon. Unexpectedly, a mysterious figure emerged.',
          relevanceScore: 0.7,
          rationale: 'Well-structured and coherent',
          alternativeApproaches: ['Alternative 1', 'Alternative 2'],
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked.length, 2);
      expect(ranked[0].rationale, 'Well-structured and coherent');
    });
  });

  group('Coherence Scoring', () {
    test('should reward appropriate word overlap', () {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Castle gates opened slowly.',
          relevanceScore: 0.5,
          rationale: 'Good',
        ),
        const SceneSuggestion(
          suggestedText:
              'Castle gates opened slowly. Castle gates were impressive.',
          relevanceScore: 0.7,
          rationale: 'Better coherence',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked[0].rationale, 'Better coherence');
      expect(ranked[1].rationale, 'Good');
    });

    test('should reward multi-sentence suggestions', () {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Single sentence.',
          relevanceScore: 0.5,
          rationale: 'Basic',
        ),
        const SceneSuggestion(
          suggestedText:
              'First sentence. Second sentence. Third sentence with detail.',
          relevanceScore: 0.7,
          rationale: 'Detailed',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(suggestions);

      expect(ranked[0].suggestedText, contains('Third'));
      expect(ranked[1].suggestedText, 'Single sentence.');
    });
  });

  group('Creativity Scoring', () {
    test('should reward multiple alternative approaches', () {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Main suggestion',
          relevanceScore: 0.7,
          rationale: 'Creative',
          alternativeApproaches: [
            'Alternative 1',
            'Alternative 2',
            'Alternative 3',
            'Alternative 4',
          ],
        ),
        const SceneSuggestion(
          suggestedText: 'Another suggestion',
          relevanceScore: 0.7,
          rationale: 'Less creative',
          alternativeApproaches: ['Only one alternative'],
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(suggestions);

      expect(ranked[0].alternativeApproaches.length, greaterThan(1));
      expect(ranked[1].alternativeApproaches.length, 1);
    });

    test('should reward vocabulary richness', () {
      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'same word repeated same word repeated same word',
          relevanceScore: 0.7,
          rationale: 'Repetitive',
        ),
        const SceneSuggestion(
          suggestedText:
              'Unique diverse vocabulary varied lexicon rich terminology',
          relevanceScore: 0.7,
          rationale: 'Rich',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(suggestions);

      expect(ranked[0].suggestedText, contains('vocabulary'));
    });
  });

  group('Consistency Scoring', () {
    test('should reward character mentions', () {
      final characters = [
        const Character(novelId: 'novel1', name: 'Hero', role: 'protagonist'),
        const Character(novelId: 'novel1', name: 'Villain', role: 'antagonist'),
      ];

      final request = SceneSuggestionRequest(
        currentScene: 'Scene text',
        characters: characters,
        genre: 'fantasy',
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Someone entered the room.',
          relevanceScore: 0.7,
          rationale: 'Generic',
        ),
        const SceneSuggestion(
          suggestedText:
              'Hero and Villain confronted each other while Hero spoke.',
          relevanceScore: 0.7,
          rationale: 'Character-rich',
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked[0].rationale, 'Character-rich');
      expect(ranked[1].rationale, 'Generic');
    });

    test('should be case-insensitive for character names', () {
      const request = SceneSuggestionRequest(
        currentScene: 'Scene text',
        characters: [
          Character(novelId: 'novel1', name: 'Hero', role: 'protagonist'),
        ],
        genre: 'fantasy',
      );

      final suggestions = [
        const SceneSuggestion(
          suggestedText: 'Someone did something. Someone continued.',
          relevanceScore: 0.7,
          rationale: 'No character',
          alternativeApproaches: ['Alternative 1'],
        ),
        const SceneSuggestion(
          suggestedText: 'hero HERO hErO',
          relevanceScore: 0.7,
          rationale: 'All cases',
          alternativeApproaches: ['Alternative 1', 'Alternative 2'],
        ),
      ];

      final ranked = sceneSuggestionService.rankSuggestions(
        suggestions,
        request: request,
      );

      expect(ranked[0].rationale, 'All cases');
      expect(ranked[1].rationale, 'No character');
    });
  });
}
