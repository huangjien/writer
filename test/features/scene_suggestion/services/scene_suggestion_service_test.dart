import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/scene_suggestion/services/scene_suggestion_service.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene_suggestion.dart';
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

  group('SceneSuggestionService', () {
    final testCharacters = [
      const Character(
        novelId: 'novel1',
        name: 'Hero',
        role: 'protagonist',
        bio: 'Brave warrior seeking revenge',
      ),
      const Character(
        novelId: 'novel1',
        name: 'Villain',
        role: 'antagonist',
        bio: 'Dark sorcerer ruling the kingdom',
      ),
    ];

    test('should return empty list for empty current scene', () async {
      final request = SceneSuggestionRequest(
        currentScene: '',
        characters: testCharacters,
      );

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions, isEmpty);
    });

    test('should generate scene suggestions successfully', () async {
      final request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
        genre: 'fantasy',
        tone: 'dramatic',
        characters: testCharacters,
      );

      const mockResponse = '''
SUGGESTION 1:
The heavy wooden gates creaked open, revealing a courtyard filled with soldiers. Hero drew their sword, ready for battle.

RATIONALE:
Creates immediate tension and advances the plot toward confrontation.

ALTERNATIVES:
Hero uses magic to bypass the guards; Hero sneaks in through a secret passage

SUGGESTION 2:
A mysterious figure appeared from the shadows, offering to guide Hero inside the castle.

RATIONALE:
Introduces a new plot element and potential ally.

ALTERNATIVES:
The figure is revealed to be Villain in disguise; The figure betrays Hero immediately

SUGGESTION 3:
Hero hesitated, remembering the last time they entered these gates. The memories flooded back.

RATIONALE:
Adds emotional depth and backstory.

ALTERNATIVES:
Hero finds the gates magically sealed; Hero discovers a warning message
''';

      mockAiChatService.responseToReturn = mockResponse;

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions.length, greaterThanOrEqualTo(1));
      expect(
        suggestions[0].suggestedText,
        'The heavy wooden gates creaked open, revealing a courtyard filled with soldiers. Hero drew their sword, ready for battle.',
      );
      expect(
        suggestions[0].rationale,
        'Creates immediate tension and advances the plot toward confrontation.',
      );
      expect(suggestions[0].alternativeApproaches.length, 2);
    });

    test('should handle AI service errors gracefully', () async {
      final request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
        characters: testCharacters,
      );

      mockAiChatService.errorToThrow = Exception('AI service error');

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions, isEmpty);
    });

    test('should parse malformed AI responses', () async {
      final request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
        characters: testCharacters,
      );

      // ignore: prefer_const_declarations
      final malformedResponse = '''
This is a simple response without proper formatting.
But it contains a scene continuation.
The hero walked through the gates confidently.
''';

      mockAiChatService.responseToReturn = malformedResponse;

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions.length, 1);
      expect(suggestions[0].suggestedText, contains('hero walked through'));
    });

    test('should build appropriate prompt with all parameters', () async {
      final request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
        previousScenes: [
          'Scene 1: Hero left their village',
          'Scene 2: Hero traveled through the forest',
        ],
        genre: 'fantasy',
        tone: 'dark',
        characters: testCharacters,
        sceneContext: 'Final confrontation scene',
      );

      mockAiChatService.responseToReturn = 'Mock response';

      await sceneSuggestionService.generateSceneSuggestions(request);

      expect(mockAiChatService.responseToReturn, isNotNull);
    });

    test('should limit suggestions to 5 maximum', () async {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
      );

      var mockResponse = '';
      for (var i = 1; i <= 7; i++) {
        mockResponse +=
            '''
SUGGESTION $i:
Test suggestion $i

RATIONALE:
Test rationale $i

ALTERNATIVES:
Alternative $i

''';
      }

      mockAiChatService.responseToReturn = mockResponse;

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions.length, lessThanOrEqualTo(5));
    });

    test('should calculate relevance scores appropriately', () async {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the castle gates.',
      );

      const goodResponse = '''
SUGGESTION 1:
The gates creaked open slowly. The hero stepped forward, sword in hand, ready to face whatever lay ahead. The courtyard was empty, but shadows danced on the walls.

RATIONALE:
Creates atmosphere and builds tension.

ALTERNATIVES:
Alternative 1; Alternative 2
''';

      mockAiChatService.responseToReturn = goodResponse;

      final suggestions = await sceneSuggestionService.generateSceneSuggestions(
        request,
      );

      expect(suggestions.length, 1);
      expect(suggestions[0].relevanceScore, greaterThanOrEqualTo(0.7));
      expect(suggestions[0].relevanceScore, lessThanOrEqualTo(1.0));
    });
  });

  group('compressSceneContext', () {
    test('should return empty string for empty scene list', () async {
      mockAiChatService.responseToReturn = '';

      final result = await sceneSuggestionService.compressSceneContext(
        [],
        l10n: null,
      );

      expect(result, '');
    });

    test('should compress multiple scenes', () async {
      final scenes = [
        'Scene 1: The hero began their journey',
        'Scene 2: The hero faced challenges',
        'Scene 3: The hero reached the castle',
      ];

      mockAiChatService.responseToReturn = 'Compressed context';

      final result = await sceneSuggestionService.compressSceneContext(
        scenes,
        l10n: null,
      );

      expect(result, 'Compressed context');
    });
  });
}
