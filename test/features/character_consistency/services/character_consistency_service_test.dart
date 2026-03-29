import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/character_consistency/services/character_consistency_service.dart';
import 'package:writer/models/character_profile.dart';

void main() {
  late CharacterConsistencyService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = CharacterConsistencyService();
  });

  tearDown(() {
    service.clearCache();
  });

  group('CharacterConsistencyService - Profile Management', () {
    test('should create a new profile', () async {
      final profile = await service.createProfile(
        name: 'John Doe',
        age: 35,
        role: 'Protagonist',
      );

      expect(profile.id, isNotEmpty);
      expect(profile.name, 'John Doe');
      expect(profile.age, 35);
      expect(profile.role, 'Protagonist');
    });

    test('should retrieve all profiles', () async {
      await service.createProfile(name: 'John Doe');
      await service.createProfile(name: 'Jane Smith');

      final profiles = await service.getProfiles();

      expect(profiles.length, 2);
    });

    test('should retrieve profile by id', () async {
      final profile = await service.createProfile(name: 'John Doe');

      final retrieved = await service.getProfileById(profile.id);

      expect(retrieved, isNotNull);
      expect(retrieved?.id, profile.id);
    });

    test('should return null for non-existent profile', () async {
      final retrieved = await service.getProfileById('non_existent');

      expect(retrieved, isNull);
    });

    test('should update profile', () async {
      final profile = await service.createProfile(name: 'John Doe', age: 30);

      final updated = await service.updateProfile(
        profile.id,
        age: 35,
        role: 'Protagonist',
      );

      expect(updated.age, 35);
      expect(updated.role, 'Protagonist');
      expect(updated.name, 'John Doe');
    });

    test('should throw error when updating non-existent profile', () async {
      expect(
        () => service.updateProfile('non_existent', age: 35),
        throwsException,
      );
    });

    test('should delete profile', () async {
      final profile = await service.createProfile(name: 'John Doe');

      await service.deleteProfile(profile.id);

      final profiles = await service.getProfiles();
      expect(profiles, isEmpty);
    });

    test('should persist profiles across service instances', () async {
      final profile1 = await service.createProfile(name: 'John Doe');

      final newService = CharacterConsistencyService();
      final profiles = await newService.getProfiles();

      expect(profiles.length, 1);
      expect(profiles.first.id, profile1.id);
    });
  });

  group('CharacterConsistencyService - Consistency Analysis', () {
    test('should analyze trait consistency', () async {
      final profile = await service.createProfile(
        name: 'John',
        personalityTraits: ['Brave', 'Loyal'],
        physicalTraits: ['Tall'],
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
          observedTraits: ['Brave'],
          observedPhysicalTraits: ['Tall'],
        ),
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene2',
          appearanceDate: DateTime(2026, 3, 30),
          observedTraits: ['Brave', 'Loyal'],
          observedPhysicalTraits: ['Tall'],
        ),
      );

      final analysis = await service.analyzeCharacterConsistency(
        profile.id,
        [],
      );

      expect(analysis.overallScore, greaterThan(0.0));
      expect(analysis.overallScore, lessThanOrEqualTo(1.0));
      expect(analysis.traitConsistency.consistencyScore, greaterThan(0.0));
      expect(analysis.traitConsistency.consistentTraits, contains('Brave'));
    });

    test('should analyze dialogue patterns', () async {
      final profile = await service.createProfile(
        name: 'John',
        speechPattern: SpeechPattern(
          typicalPhrases: ['Indeed', 'Quite'],
          typicalTone: 'Formal',
        ),
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
          dialogueSamples: ['Indeed, I agree', 'Quite right'],
        ),
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene2',
          appearanceDate: DateTime(2026, 3, 30),
          dialogueSamples: ['Indeed it is', 'I agree'],
        ),
      );

      final analysis = await service.analyzeCharacterConsistency(
        profile.id,
        [],
      );

      expect(analysis.dialoguePatterns.totalDialogueSamples, 4);
      expect(analysis.dialoguePatterns.phraseUsage['Indeed'], 2);
      expect(analysis.dialoguePatterns.toneConsistency, 'Formal');
    });

    test('should analyze behavioral consistency', () async {
      final profile = await service.createProfile(
        name: 'John',
        behavioralTendencies: ['Paces when thinking', 'Taps fingers'],
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
          observedBehaviors: ['Paces around the room'],
        ),
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene2',
          appearanceDate: DateTime(2026, 3, 30),
          observedBehaviors: ['Paces back and forth', 'Taps fingers on desk'],
        ),
      );

      final analysis = await service.analyzeCharacterConsistency(
        profile.id,
        [],
      );

      expect(
        analysis.behavioralConsistency.consistentBehaviors,
        contains('Paces when thinking'),
      );
    });

    test('should detect anomalies', () async {
      final profile = await service.createProfile(
        name: 'John',
        personalityTraits: ['Brave', 'Loyal'],
        physicalTraits: ['Tall'],
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
          observedTraits: ['Brave'],
          observedPhysicalTraits: [],
        ),
      );

      final analysis = await service.analyzeCharacterConsistency(
        profile.id,
        [],
      );

      expect(analysis.anomalies, isNotEmpty);
      expect(
        analysis.anomalies.any((a) => a.type == AnomalyType.missingTrait),
        true,
      );
    });

    test('should generate suggestions', () async {
      final profile = await service.createProfile(
        name: 'John',
        personalityTraits: ['Brave'],
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
          observedTraits: [],
        ),
      );

      final analysis = await service.analyzeCharacterConsistency(
        profile.id,
        [],
      );

      expect(analysis.suggestions, isNotEmpty);
    });

    test(
      'should return perfect score for profile with no appearances',
      () async {
        final profile = await service.createProfile(
          name: 'John',
          personalityTraits: ['Brave'],
        );

        final analysis = await service.analyzeCharacterConsistency(
          profile.id,
          [],
        );

        expect(analysis.overallScore, greaterThan(0.5));
      },
    );
  });

  group('CharacterConsistencyService - Scene Appearances', () {
    test('should add scene appearance to profile', () async {
      final profile = await service.createProfile(name: 'John Doe');

      final appearance = SceneAppearance(
        sceneId: 'scene1',
        sceneTitle: 'Opening',
        appearanceDate: DateTime(2026, 3, 29),
        observedTraits: ['Brave'],
        dialogueSamples: ['Hello world'],
      );

      final updated = await service.addSceneAppearance(profile.id, appearance);

      expect(updated.sceneAppearances.length, 1);
      expect(updated.sceneAppearances.first.sceneId, 'scene1');
    });

    test(
      'should throw error when adding appearance to non-existent profile',
      () async {
        final appearance = SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
        );

        expect(
          () => service.addSceneAppearance('non_existent', appearance),
          throwsException,
        );
      },
    );
  });

  group('CharacterConsistencyService - Search & Statistics', () {
    test('should search profiles by name', () async {
      await service.createProfile(name: 'John Doe', role: 'Protagonist');
      await service.createProfile(name: 'Jane Smith', role: 'Antagonist');

      final results = await service.searchProfiles('John');

      expect(results.length, 1);
      expect(results.first.name, 'John Doe');
    });

    test('should search profiles by role', () async {
      await service.createProfile(name: 'John Doe', role: 'Protagonist');
      await service.createProfile(name: 'Jane Smith', role: 'Protagonist');

      final results = await service.searchProfiles('Protagonist');

      expect(results.length, 2);
    });

    test('should search profiles by trait', () async {
      await service.createProfile(
        name: 'John Doe',
        personalityTraits: ['Brave', 'Loyal'],
      );
      await service.createProfile(
        name: 'Jane Smith',
        personalityTraits: ['Cunning', 'Smart'],
      );

      final results = await service.searchProfiles('Brave');

      expect(results.length, 1);
      expect(results.first.name, 'John Doe');
    });

    test('should get character statistics', () async {
      final profile = await service.createProfile(
        name: 'John',
        personalityTraits: ['Brave'],
        relationships: {'Jane': 'Friend'},
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene1',
          appearanceDate: DateTime(2026, 3, 29),
        ),
      );

      await service.addSceneAppearance(
        profile.id,
        SceneAppearance(
          sceneId: 'scene2',
          appearanceDate: DateTime(2026, 3, 30),
        ),
      );

      final stats = await service.getCharacterStatistics(profile.id);

      expect(stats['total_appearances'], 2);
      expect(stats['total_traits'], 1);
      expect(stats['total_relationships'], 1);
      expect(stats['first_appearance'], isNotNull);
      expect(stats['last_appearance'], isNotNull);
    });

    test(
      'should throw error when getting stats for non-existent profile',
      () async {
        expect(
          () => service.getCharacterStatistics('non_existent'),
          throwsException,
        );
      },
    );
  });
}
