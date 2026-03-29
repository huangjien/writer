import 'character.dart';

class SceneSuggestion {
  final String suggestedText;
  final double relevanceScore;
  final String rationale;
  final List<String> alternativeApproaches;

  const SceneSuggestion({
    required this.suggestedText,
    required this.relevanceScore,
    required this.rationale,
    this.alternativeApproaches = const [],
  });

  Map<String, dynamic> toMap() => {
    'suggested_text': suggestedText,
    'relevance_score': relevanceScore,
    'rationale': rationale,
    'alternative_approaches': alternativeApproaches,
  };

  factory SceneSuggestion.fromMap(Map<String, dynamic> map) => SceneSuggestion(
    suggestedText: map['suggested_text'] as String,
    relevanceScore: (map['relevance_score'] as num).toDouble(),
    rationale: map['rationale'] as String,
    alternativeApproaches: map['alternative_approaches'] is List
        ? List<String>.from(map['alternative_approaches'] as List)
        : [],
  );

  SceneSuggestion copyWith({
    String? suggestedText,
    double? relevanceScore,
    String? rationale,
    List<String>? alternativeApproaches,
  }) => SceneSuggestion(
    suggestedText: suggestedText ?? this.suggestedText,
    relevanceScore: relevanceScore ?? this.relevanceScore,
    rationale: rationale ?? this.rationale,
    alternativeApproaches: alternativeApproaches ?? this.alternativeApproaches,
  );
}

class SceneSuggestionRequest {
  final String currentScene;
  final List<String> previousScenes;
  final String genre;
  final String tone;
  final List<Character> characters;
  final String? sceneContext;

  const SceneSuggestionRequest({
    required this.currentScene,
    this.previousScenes = const [],
    this.genre = 'general',
    this.tone = 'neutral',
    this.characters = const [],
    this.sceneContext,
  });

  Map<String, dynamic> toMap() => {
    'current_scene': currentScene,
    'previous_scenes': previousScenes,
    'genre': genre,
    'tone': tone,
    'characters': characters.map((c) => c.toMap()).toList(),
    if (sceneContext != null) 'scene_context': sceneContext,
  };

  factory SceneSuggestionRequest.fromMap(Map<String, dynamic> map) =>
      SceneSuggestionRequest(
        currentScene: map['current_scene'] as String,
        previousScenes: map['previous_scenes'] is List
            ? List<String>.from(map['previous_scenes'] as List)
            : [],
        genre: map['genre'] as String? ?? 'general',
        tone: map['tone'] as String? ?? 'neutral',
        characters: map['characters'] is List
            ? (map['characters'] as List)
                  .map((m) => Character.fromMap(m as Map<String, dynamic>))
                  .toList()
            : [],
        sceneContext: map['scene_context'] as String?,
      );

  SceneSuggestionRequest copyWith({
    String? currentScene,
    List<String>? previousScenes,
    String? genre,
    String? tone,
    List<Character>? characters,
    String? sceneContext,
  }) => SceneSuggestionRequest(
    currentScene: currentScene ?? this.currentScene,
    previousScenes: previousScenes ?? this.previousScenes,
    genre: genre ?? this.genre,
    tone: tone ?? this.tone,
    characters: characters ?? this.characters,
    sceneContext: sceneContext ?? this.sceneContext,
  );
}

enum SuggestionGenre {
  general,
  fantasy,
  romance,
  scifi,
  mystery,
  thriller,
  horror,
  literary,
  youngAdult,
  historical,
}

enum SuggestionTone {
  neutral,
  serious,
  humorous,
  dark,
  light,
  dramatic,
  romantic,
  suspenseful,
}
