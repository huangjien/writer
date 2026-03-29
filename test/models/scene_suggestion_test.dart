import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene_suggestion.dart';

void main() {
  group('SceneSuggestion', () {
    test('should create instance with required fields', () {
      const suggestion = SceneSuggestion(
        suggestedText: 'The hero entered the dark room cautiously.',
        relevanceScore: 0.85,
        rationale: 'Builds tension and advances the plot.',
      );

      expect(
        suggestion.suggestedText,
        'The hero entered the dark room cautiously.',
      );
      expect(suggestion.relevanceScore, 0.85);
      expect(suggestion.rationale, 'Builds tension and advances the plot.');
      expect(suggestion.alternativeApproaches, isEmpty);
    });

    test('should create instance with alternative approaches', () {
      const suggestion = SceneSuggestion(
        suggestedText: 'The hero entered the dark room cautiously.',
        relevanceScore: 0.85,
        rationale: 'Builds tension and advances the plot.',
        alternativeApproaches: [
          'The hero burst into the room with weapons drawn.',
          'The hero hesitated at the doorway, listening.',
        ],
      );

      expect(suggestion.alternativeApproaches.length, 2);
    });

    test('should convert to map correctly', () {
      const suggestion = SceneSuggestion(
        suggestedText: 'Test suggestion',
        relevanceScore: 0.9,
        rationale: 'Test rationale',
        alternativeApproaches: ['Alternative 1'],
      );

      final map = suggestion.toMap();

      expect(map['suggested_text'], 'Test suggestion');
      expect(map['relevance_score'], 0.9);
      expect(map['rationale'], 'Test rationale');
      expect(map['alternative_approaches'], ['Alternative 1']);
    });

    test('should create from map correctly', () {
      final map = {
        'suggested_text': 'Test suggestion',
        'relevance_score': 0.9,
        'rationale': 'Test rationale',
        'alternative_approaches': ['Alternative 1', 'Alternative 2'],
      };

      final suggestion = SceneSuggestion.fromMap(map);

      expect(suggestion.suggestedText, 'Test suggestion');
      expect(suggestion.relevanceScore, 0.9);
      expect(suggestion.rationale, 'Test rationale');
      expect(suggestion.alternativeApproaches.length, 2);
    });

    test('should copy with new values', () {
      const suggestion = SceneSuggestion(
        suggestedText: 'Original text',
        relevanceScore: 0.7,
        rationale: 'Original rationale',
      );

      final copied = suggestion.copyWith(
        suggestedText: 'New text',
        relevanceScore: 0.9,
      );

      expect(copied.suggestedText, 'New text');
      expect(copied.relevanceScore, 0.9);
      expect(copied.rationale, 'Original rationale');
    });

    test('should handle numeric relevance score from map', () {
      final map = {
        'suggested_text': 'Test',
        'relevance_score': 0.85,
        'rationale': 'Test',
        'alternative_approaches': [],
      };

      final suggestion = SceneSuggestion.fromMap(map);
      expect(suggestion.relevanceScore, 0.85);
    });
  });

  group('SceneSuggestionRequest', () {
    final testCharacters = [
      const Character(
        novelId: 'novel1',
        name: 'Hero',
        role: 'protagonist',
        bio: 'Brave warrior',
      ),
      const Character(novelId: 'novel1', name: 'Villain', role: 'antagonist'),
    ];

    test('should create instance with required fields', () {
      const request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the entrance.',
      );

      expect(request.currentScene, 'The hero stood at the entrance.');
      expect(request.previousScenes, isEmpty);
      expect(request.genre, 'general');
      expect(request.tone, 'neutral');
      expect(request.characters, isEmpty);
    });

    test('should create instance with all fields', () {
      final request = SceneSuggestionRequest(
        currentScene: 'The hero stood at the entrance.',
        previousScenes: ['Scene 1', 'Scene 2'],
        genre: 'fantasy',
        tone: 'dramatic',
        characters: testCharacters,
        sceneContext: 'Final confrontation scene',
      );

      expect(request.currentScene, 'The hero stood at the entrance.');
      expect(request.previousScenes.length, 2);
      expect(request.genre, 'fantasy');
      expect(request.tone, 'dramatic');
      expect(request.characters.length, 2);
      expect(request.sceneContext, 'Final confrontation scene');
    });

    test('should convert to map correctly', () {
      final request = SceneSuggestionRequest(
        currentScene: 'Test scene',
        previousScenes: ['Previous'],
        genre: 'scifi',
        tone: 'dark',
        characters: testCharacters,
        sceneContext: 'Context',
      );

      final map = request.toMap();

      expect(map['current_scene'], 'Test scene');
      expect(map['previous_scenes'], ['Previous']);
      expect(map['genre'], 'scifi');
      expect(map['tone'], 'dark');
      expect(map['scene_context'], 'Context');
      expect(map['characters'], isList);
    });

    test('should create from map correctly', () {
      final map = {
        'current_scene': 'Test scene',
        'previous_scenes': ['Previous'],
        'genre': 'romance',
        'tone': 'light',
        'characters': [
          {
            'novel_id': 'novel1',
            'name': 'Hero',
            'role': 'protagonist',
            'bio': 'Brave',
          },
        ],
        'scene_context': 'Test context',
      };

      final request = SceneSuggestionRequest.fromMap(map);

      expect(request.currentScene, 'Test scene');
      expect(request.previousScenes, ['Previous']);
      expect(request.genre, 'romance');
      expect(request.tone, 'light');
      expect(request.characters.length, 1);
      expect(request.characters.first.name, 'Hero');
      expect(request.sceneContext, 'Test context');
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {
        'current_scene': 'Test scene',
        'previous_scenes': [],
        'genre': 'general',
        'tone': 'neutral',
        'characters': [],
      };

      final request = SceneSuggestionRequest.fromMap(map);

      expect(request.currentScene, 'Test scene');
      expect(request.sceneContext, isNull);
    });

    test('should copy with new values', () {
      const request = SceneSuggestionRequest(
        currentScene: 'Original scene',
        genre: 'fantasy',
      );

      final copied = request.copyWith(currentScene: 'New scene', tone: 'dark');

      expect(copied.currentScene, 'New scene');
      expect(copied.genre, 'fantasy');
      expect(copied.tone, 'dark');
    });

    test('should handle null characters gracefully', () {
      const request = SceneSuggestionRequest(
        currentScene: 'Test scene',
        characters: [],
      );

      final map = request.toMap();
      expect(map['characters'], []);
    });
  });

  group('SuggestionGenre', () {
    test('should have all expected genres', () {
      expect(SuggestionGenre.values.length, 10);
      expect(SuggestionGenre.values, contains(SuggestionGenre.general));
      expect(SuggestionGenre.values, contains(SuggestionGenre.fantasy));
      expect(SuggestionGenre.values, contains(SuggestionGenre.romance));
      expect(SuggestionGenre.values, contains(SuggestionGenre.scifi));
      expect(SuggestionGenre.values, contains(SuggestionGenre.mystery));
    });
  });

  group('SuggestionTone', () {
    test('should have all expected tones', () {
      expect(SuggestionTone.values.length, 8);
      expect(SuggestionTone.values, contains(SuggestionTone.neutral));
      expect(SuggestionTone.values, contains(SuggestionTone.serious));
      expect(SuggestionTone.values, contains(SuggestionTone.humorous));
      expect(SuggestionTone.values, contains(SuggestionTone.dark));
      expect(SuggestionTone.values, contains(SuggestionTone.dramatic));
    });
  });
}
