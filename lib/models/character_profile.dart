class CharacterProfile {
  final String id;
  final String name;
  final int? age;
  final String? role;
  final List<String> physicalTraits;
  final List<String> personalityTraits;
  final SpeechPattern speechPattern;
  final List<String> behavioralTendencies;
  final Map<String, String> relationships;
  final List<SceneAppearance> sceneAppearances;
  final DateTime createdAt;
  final DateTime updatedAt;

  CharacterProfile({
    required this.id,
    required this.name,
    this.age,
    this.role,
    this.physicalTraits = const [],
    this.personalityTraits = const [],
    SpeechPattern? speechPattern,
    this.behavioralTendencies = const [],
    this.relationships = const {},
    this.sceneAppearances = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : speechPattern = speechPattern ?? SpeechPattern(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get consistencyScore {
    if (sceneAppearances.isEmpty) return 1.0;

    double totalConsistency = 0.0;
    int checkedTraits = 0;

    for (final appearance in sceneAppearances) {
      for (final trait in personalityTraits) {
        if (appearance.observedTraits.contains(trait)) {
          totalConsistency += 1.0;
        }
        checkedTraits++;
      }

      for (final trait in physicalTraits) {
        if (appearance.observedPhysicalTraits.contains(trait)) {
          totalConsistency += 1.0;
        }
        checkedTraits++;
      }

      if (speechPattern.typicalPhrases.isNotEmpty) {
        int phraseMatches = 0;
        for (final phrase in speechPattern.typicalPhrases) {
          if (appearance.dialogueSamples.any(
            (sample) => sample.toLowerCase().contains(phrase.toLowerCase()),
          )) {
            phraseMatches++;
          }
        }
        if (phraseMatches > 0) {
          totalConsistency +=
              phraseMatches / speechPattern.typicalPhrases.length;
        }
        checkedTraits++;
      }
    }

    return checkedTraits > 0
        ? (totalConsistency / checkedTraits).clamp(0.0, 1.0)
        : 1.0;
  }

  int get totalAppearances => sceneAppearances.length;

  List<String> get inconsistentTraits {
    final inconsistent = <String>[];

    if (sceneAppearances.isEmpty) return inconsistent;

    for (final trait in personalityTraits) {
      final appearanceCount = sceneAppearances
          .where((app) => app.observedTraits.contains(trait))
          .length;

      if (appearanceCount < sceneAppearances.length / 2) {
        inconsistent.add(
          'Personality: $trait ($appearanceCount/${sceneAppearances.length} scenes)',
        );
      }
    }

    for (final trait in physicalTraits) {
      final appearanceCount = sceneAppearances
          .where((app) => app.observedPhysicalTraits.contains(trait))
          .length;

      if (appearanceCount < sceneAppearances.length / 2) {
        inconsistent.add(
          'Physical: $trait ($appearanceCount/${sceneAppearances.length} scenes)',
        );
      }
    }

    return inconsistent;
  }

  CharacterProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? role,
    List<String>? physicalTraits,
    List<String>? personalityTraits,
    SpeechPattern? speechPattern,
    List<String>? behavioralTendencies,
    Map<String, String>? relationships,
    List<SceneAppearance>? sceneAppearances,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CharacterProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      role: role ?? this.role,
      physicalTraits: physicalTraits ?? this.physicalTraits,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      speechPattern: speechPattern ?? this.speechPattern,
      behavioralTendencies: behavioralTendencies ?? this.behavioralTendencies,
      relationships: relationships ?? this.relationships,
      sceneAppearances: sceneAppearances ?? this.sceneAppearances,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'role': role,
      'physical_traits': physicalTraits,
      'personality_traits': personalityTraits,
      'speech_pattern': speechPattern.toMap(),
      'behavioral_tendencies': behavioralTendencies,
      'relationships': relationships,
      'scene_appearances': sceneAppearances.map((app) => app.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CharacterProfile.fromMap(Map<String, dynamic> map) {
    return CharacterProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int?,
      role: map['role'] as String?,
      physicalTraits: List<String>.from(map['physical_traits'] ?? []),
      personalityTraits: List<String>.from(map['personality_traits'] ?? []),
      speechPattern: map['speech_pattern'] != null
          ? SpeechPattern.fromMap(map['speech_pattern'] as Map<String, dynamic>)
          : null,
      behavioralTendencies: List<String>.from(
        map['behavioral_tendencies'] ?? [],
      ),
      relationships: Map<String, String>.from(map['relationships'] ?? {}),
      sceneAppearances:
          (map['scene_appearances'] as List<dynamic>?)
              ?.map(
                (item) => SceneAppearance.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}

class SpeechPattern {
  final String? typicalTone;
  final List<String> typicalPhrases;
  final List<String> vocabularyLevel;
  final String? sentenceStructure;
  final List<String> fillerWords;

  SpeechPattern({
    this.typicalTone,
    this.typicalPhrases = const [],
    this.vocabularyLevel = const [],
    this.sentenceStructure,
    this.fillerWords = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'typical_tone': typicalTone,
      'typical_phrases': typicalPhrases,
      'vocabulary_level': vocabularyLevel,
      'sentence_structure': sentenceStructure,
      'filler_words': fillerWords,
    };
  }

  factory SpeechPattern.fromMap(Map<String, dynamic> map) {
    return SpeechPattern(
      typicalTone: map['typical_tone'] as String?,
      typicalPhrases: List<String>.from(map['typical_phrases'] ?? []),
      vocabularyLevel: List<String>.from(map['vocabulary_level'] ?? []),
      sentenceStructure: map['sentence_structure'] as String?,
      fillerWords: List<String>.from(map['filler_words'] ?? []),
    );
  }
}

class SceneAppearance {
  final String sceneId;
  final String? sceneTitle;
  final DateTime appearanceDate;
  final List<String> observedTraits;
  final List<String> observedPhysicalTraits;
  final List<String> dialogueSamples;
  final List<String> observedBehaviors;
  final String? notes;

  SceneAppearance({
    required this.sceneId,
    this.sceneTitle,
    required this.appearanceDate,
    this.observedTraits = const [],
    this.observedPhysicalTraits = const [],
    this.dialogueSamples = const [],
    this.observedBehaviors = const [],
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'scene_id': sceneId,
      'scene_title': sceneTitle,
      'appearance_date': appearanceDate.toIso8601String(),
      'observed_traits': observedTraits,
      'observed_physical_traits': observedPhysicalTraits,
      'dialogue_samples': dialogueSamples,
      'observed_behaviors': observedBehaviors,
      'notes': notes,
    };
  }

  factory SceneAppearance.fromMap(Map<String, dynamic> map) {
    return SceneAppearance(
      sceneId: map['scene_id'] as String,
      sceneTitle: map['scene_title'] as String?,
      appearanceDate: DateTime.parse(map['appearance_date'] as String),
      observedTraits: List<String>.from(map['observed_traits'] ?? []),
      observedPhysicalTraits: List<String>.from(
        map['observed_physical_traits'] ?? [],
      ),
      dialogueSamples: List<String>.from(map['dialogue_samples'] ?? []),
      observedBehaviors: List<String>.from(map['observed_behaviors'] ?? []),
      notes: map['notes'] as String?,
    );
  }
}
