import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/character_profile.dart';

void main() {
  group('CharacterProfile', () {
    test('should create instance with required fields', () {
      final profile = CharacterProfile(id: 'char1', name: 'John Doe');

      expect(profile.id, 'char1');
      expect(profile.name, 'John Doe');
      expect(profile.age, isNull);
      expect(profile.role, isNull);
      expect(profile.physicalTraits, isEmpty);
      expect(profile.personalityTraits, isEmpty);
      expect(profile.behavioralTendencies, isEmpty);
      expect(profile.relationships, isEmpty);
      expect(profile.sceneAppearances, isEmpty);
    });

    test('should create instance with all fields', () {
      final speechPattern = SpeechPattern(
        typicalTone: 'Formal',
        typicalPhrases: ['Indeed', 'Quite'],
        vocabularyLevel: ['Advanced'],
        sentenceStructure: 'Complex',
        fillerWords: ['um', 'ah'],
      );

      final profile = CharacterProfile(
        id: 'char1',
        name: 'John Doe',
        age: 35,
        role: 'Protagonist',
        physicalTraits: ['Tall', 'Dark hair'],
        personalityTraits: ['Brave', 'Intelligent'],
        speechPattern: speechPattern,
        behavioralTendencies: ['Paces when thinking'],
        relationships: {'Jane': 'Love interest'},
      );

      expect(profile.id, 'char1');
      expect(profile.name, 'John Doe');
      expect(profile.age, 35);
      expect(profile.role, 'Protagonist');
      expect(profile.physicalTraits.length, 2);
      expect(profile.personalityTraits.length, 2);
      expect(profile.speechPattern.typicalTone, 'Formal');
      expect(profile.behavioralTendencies.length, 1);
      expect(profile.relationships.length, 1);
    });

    test('should calculate consistency score correctly', () {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave', 'Loyal'],
        physicalTraits: ['Tall'],
        speechPattern: SpeechPattern(typicalPhrases: ['Indeed']),
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
            observedTraits: ['Brave'],
            observedPhysicalTraits: ['Tall'],
            dialogueSamples: ['Indeed, I agree'],
            observedBehaviors: [],
          ),
          SceneAppearance(
            sceneId: 'scene2',
            appearanceDate: DateTime(2026, 3, 30),
            observedTraits: ['Brave', 'Loyal'],
            observedPhysicalTraits: ['Tall'],
            dialogueSamples: ['Indeed'],
            observedBehaviors: [],
          ),
        ],
      );

      final score = profile.consistencyScore;
      expect(score, greaterThan(0.5));
      expect(score, lessThanOrEqualTo(1.0));
    });

    test('should return perfect consistency when no appearances', () {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave'],
        physicalTraits: ['Tall'],
      );

      expect(profile.consistencyScore, 1.0);
    });

    test('should identify inconsistent traits', () {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        personalityTraits: ['Brave', 'Loyal'],
        physicalTraits: ['Tall'],
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
            observedTraits: ['Brave'],
            observedPhysicalTraits: [],
            dialogueSamples: [],
            observedBehaviors: [],
          ),
          SceneAppearance(
            sceneId: 'scene2',
            appearanceDate: DateTime(2026, 3, 30),
            observedTraits: ['Brave'],
            observedPhysicalTraits: [],
            dialogueSamples: [],
            observedBehaviors: [],
          ),
        ],
      );

      final inconsistent = profile.inconsistentTraits;
      expect(inconsistent, isNotEmpty);
      expect(inconsistent.any((item) => item.contains('Loyal')), true);
      expect(inconsistent.any((item) => item.contains('Tall')), true);
    });

    test('should copy with new values', () {
      final profile = CharacterProfile(id: 'char1', name: 'John Doe', age: 30);

      final copied = profile.copyWith(age: 35, role: 'Protagonist');

      expect(copied.id, 'char1');
      expect(copied.name, 'John Doe');
      expect(copied.age, 35);
      expect(copied.role, 'Protagonist');
    });

    test('should convert to map correctly', () {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John Doe',
        age: 35,
        role: 'Protagonist',
      );

      final map = profile.toMap();

      expect(map['id'], 'char1');
      expect(map['name'], 'John Doe');
      expect(map['age'], 35);
      expect(map['role'], 'Protagonist');
      expect(map['physical_traits'], isList);
      expect(map['personality_traits'], isList);
    });

    test('should create from map correctly', () {
      final map = {
        'id': 'char1',
        'name': 'John Doe',
        'age': 35,
        'role': 'Protagonist',
        'physical_traits': ['Tall'],
        'personality_traits': ['Brave'],
        'speech_pattern': {
          'typical_tone': 'Formal',
          'typical_phrases': ['Indeed'],
          'vocabulary_level': [],
          'sentence_structure': null,
          'filler_words': [],
        },
        'behavioral_tendencies': [],
        'relationships': {},
        'scene_appearances': [],
        'created_at': '2026-03-29T00:00:00.000',
        'updated_at': '2026-03-29T00:00:00.000',
      };

      final profile = CharacterProfile.fromMap(map);

      expect(profile.id, 'char1');
      expect(profile.name, 'John Doe');
      expect(profile.age, 35);
      expect(profile.role, 'Protagonist');
      expect(profile.physicalTraits, ['Tall']);
      expect(profile.personalityTraits, ['Brave']);
      expect(profile.speechPattern.typicalTone, 'Formal');
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {'id': 'char1', 'name': 'John Doe'};

      final profile = CharacterProfile.fromMap(map);

      expect(profile.age, isNull);
      expect(profile.role, isNull);
      expect(profile.physicalTraits, isEmpty);
      expect(profile.personalityTraits, isEmpty);
    });

    test('should calculate total appearances', () {
      final profile = CharacterProfile(
        id: 'char1',
        name: 'John',
        sceneAppearances: [
          SceneAppearance(
            sceneId: 'scene1',
            appearanceDate: DateTime(2026, 3, 29),
          ),
          SceneAppearance(
            sceneId: 'scene2',
            appearanceDate: DateTime(2026, 3, 30),
          ),
          SceneAppearance(
            sceneId: 'scene3',
            appearanceDate: DateTime(2026, 3, 31),
          ),
        ],
      );

      expect(profile.totalAppearances, 3);
    });
  });

  group('SpeechPattern', () {
    test('should create with default values', () {
      final pattern = SpeechPattern();

      expect(pattern.typicalTone, isNull);
      expect(pattern.typicalPhrases, isEmpty);
      expect(pattern.vocabularyLevel, isEmpty);
      expect(pattern.sentenceStructure, isNull);
      expect(pattern.fillerWords, isEmpty);
    });

    test('should create with all fields', () {
      final pattern = SpeechPattern(
        typicalTone: 'Casual',
        typicalPhrases: ['Like', 'You know'],
        vocabularyLevel: ['Basic', 'Slang'],
        sentenceStructure: 'Simple',
        fillerWords: ['um', 'uh', 'like'],
      );

      expect(pattern.typicalTone, 'Casual');
      expect(pattern.typicalPhrases.length, 2);
      expect(pattern.vocabularyLevel.length, 2);
      expect(pattern.sentenceStructure, 'Simple');
      expect(pattern.fillerWords.length, 3);
    });

    test('should convert to map and from map correctly', () {
      final pattern = SpeechPattern(
        typicalTone: 'Formal',
        typicalPhrases: ['Indeed'],
      );

      final map = pattern.toMap();
      final restored = SpeechPattern.fromMap(map);

      expect(restored.typicalTone, 'Formal');
      expect(restored.typicalPhrases, ['Indeed']);
    });
  });

  group('SceneAppearance', () {
    test('should create with required fields', () {
      final appearance = SceneAppearance(
        sceneId: 'scene1',
        appearanceDate: DateTime(2026, 3, 29),
      );

      expect(appearance.sceneId, 'scene1');
      expect(appearance.sceneTitle, isNull);
      expect(appearance.observedTraits, isEmpty);
      expect(appearance.observedPhysicalTraits, isEmpty);
      expect(appearance.dialogueSamples, isEmpty);
      expect(appearance.observedBehaviors, isEmpty);
      expect(appearance.notes, isNull);
    });

    test('should create with all fields', () {
      final appearance = SceneAppearance(
        sceneId: 'scene1',
        sceneTitle: 'Opening Scene',
        appearanceDate: DateTime(2026, 3, 29),
        observedTraits: ['Brave', 'Loyal'],
        observedPhysicalTraits: ['Tall', 'Dark hair'],
        dialogueSamples: ['Hello world', 'How are you?'],
        observedBehaviors: ['Paces around room'],
        notes: 'Character introduction',
      );

      expect(appearance.sceneId, 'scene1');
      expect(appearance.sceneTitle, 'Opening Scene');
      expect(appearance.observedTraits.length, 2);
      expect(appearance.observedPhysicalTraits.length, 2);
      expect(appearance.dialogueSamples.length, 2);
      expect(appearance.observedBehaviors.length, 1);
      expect(appearance.notes, 'Character introduction');
    });

    test('should convert to map and from map correctly', () {
      final appearance = SceneAppearance(
        sceneId: 'scene1',
        sceneTitle: 'Battle Scene',
        appearanceDate: DateTime(2026, 3, 29),
        observedTraits: ['Brave'],
        dialogueSamples: ['Charge!'],
      );

      final map = appearance.toMap();
      final restored = SceneAppearance.fromMap(map);

      expect(restored.sceneId, 'scene1');
      expect(restored.sceneTitle, 'Battle Scene');
      expect(restored.observedTraits, ['Brave']);
      expect(restored.dialogueSamples, ['Charge!']);
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {
        'scene_id': 'scene1',
        'appearance_date': '2026-03-29T00:00:00.000',
      };

      final appearance = SceneAppearance.fromMap(map);

      expect(appearance.sceneTitle, isNull);
      expect(appearance.observedTraits, isEmpty);
      expect(appearance.dialogueSamples, isEmpty);
      expect(appearance.notes, isNull);
    });
  });
}
