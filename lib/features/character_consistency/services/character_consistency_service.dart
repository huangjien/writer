import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/models/character_profile.dart';
import 'package:writer/models/scene.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';

class CharacterConsistencyService {
  static const String _profilesKey = 'character_profiles';

  SharedPreferences? _prefs;
  List<CharacterProfile> _cachedProfiles = [];

  CharacterConsistencyService({AiChatService? aiService});

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<CharacterProfile>> getProfiles() async {
    if (_cachedProfiles.isNotEmpty) {
      return List.from(_cachedProfiles);
    }

    final prefs = await _preferences;
    final profilesJson = prefs.getString(_profilesKey);

    if (profilesJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(profilesJson);
      final profiles = decoded
          .map((item) => CharacterProfile.fromMap(item as Map<String, dynamic>))
          .toList();
      _cachedProfiles = profiles;
      return List.from(profiles);
    } catch (e) {
      return [];
    }
  }

  Future<CharacterProfile?> getProfileById(String id) async {
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<CharacterProfile> createProfile({
    required String name,
    int? age,
    String? role,
    List<String> physicalTraits = const [],
    List<String> personalityTraits = const [],
    SpeechPattern? speechPattern,
    List<String> behavioralTendencies = const [],
    Map<String, String> relationships = const {},
  }) async {
    final profile = CharacterProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      role: role,
      physicalTraits: physicalTraits,
      personalityTraits: personalityTraits,
      speechPattern: speechPattern,
      behavioralTendencies: behavioralTendencies,
      relationships: relationships,
    );

    final profiles = await getProfiles();
    _cachedProfiles = [...profiles, profile];
    await _saveProfiles(_cachedProfiles);

    return profile;
  }

  Future<CharacterProfile> updateProfile(
    String id, {
    String? name,
    int? age,
    String? role,
    List<String>? physicalTraits,
    List<String>? personalityTraits,
    SpeechPattern? speechPattern,
    List<String>? behavioralTendencies,
    Map<String, String>? relationships,
  }) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((p) => p.id == id);

    if (index == -1) {
      throw Exception('Profile not found');
    }

    final updatedProfile = profiles[index].copyWith(
      name: name,
      age: age,
      role: role,
      physicalTraits: physicalTraits,
      personalityTraits: personalityTraits,
      speechPattern: speechPattern,
      behavioralTendencies: behavioralTendencies,
      relationships: relationships,
      updatedAt: DateTime.now(),
    );

    _cachedProfiles = [...profiles];
    _cachedProfiles[index] = updatedProfile;
    await _saveProfiles(_cachedProfiles);

    return updatedProfile;
  }

  Future<void> deleteProfile(String id) async {
    final profiles = await getProfiles();
    _cachedProfiles = profiles.where((profile) => profile.id != id).toList();
    await _saveProfiles(_cachedProfiles);
  }

  Future<ConsistencyAnalysis> analyzeCharacterConsistency(
    String profileId,
    List<Scene> scenes,
  ) async {
    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found');
    }

    final traitAnalysis = _analyzeTraitConsistency(profile);
    final dialogueAnalysis = await _analyzeDialoguePatterns(profile, scenes);
    final behaviorAnalysis = _analyzeBehavioralConsistency(profile);
    final anomalies = _detectAnomalies(profile);

    return ConsistencyAnalysis(
      profileId: profileId,
      overallScore: _calculateOverallScore(
        traitAnalysis,
        dialogueAnalysis,
        behaviorAnalysis,
      ),
      traitConsistency: traitAnalysis,
      dialoguePatterns: dialogueAnalysis,
      behavioralConsistency: behaviorAnalysis,
      anomalies: anomalies,
      suggestions: await _generateSuggestions(
        profile,
        traitAnalysis,
        dialogueAnalysis,
        behaviorAnalysis,
      ),
      analyzedAt: DateTime.now(),
    );
  }

  TraitConsistencyAnalysis _analyzeTraitConsistency(CharacterProfile profile) {
    if (profile.sceneAppearances.isEmpty) {
      return TraitConsistencyAnalysis(
        consistentTraits: [],
        inconsistentTraits: [],
        missingTraits: [],
        consistencyScore: 1.0,
      );
    }

    final consistentTraits = <String>[];
    final inconsistentTraits = <String>[];
    final missingTraits = <String>[];

    final totalScenes = profile.sceneAppearances.length;

    for (final trait in profile.personalityTraits) {
      final appearances = profile.sceneAppearances
          .where((app) => app.observedTraits.contains(trait))
          .length;

      if (appearances == totalScenes) {
        consistentTraits.add(trait);
      } else if (appearances >= totalScenes / 2) {
        inconsistentTraits.add('$trait ($appearances/$totalScenes scenes)');
      } else {
        missingTraits.add('$trait ($appearances/$totalScenes scenes)');
      }
    }

    final score =
        consistentTraits.length /
        (consistentTraits.length +
            inconsistentTraits.length +
            missingTraits.length);

    return TraitConsistencyAnalysis(
      consistentTraits: consistentTraits,
      inconsistentTraits: inconsistentTraits,
      missingTraits: missingTraits,
      consistencyScore: score,
    );
  }

  Future<DialoguePatternAnalysis> _analyzeDialoguePatterns(
    CharacterProfile profile,
    List<Scene> scenes,
  ) async {
    final dialogueSamples = <String>[];
    final phraseUsage = <String, int>{};

    for (final appearance in profile.sceneAppearances) {
      dialogueSamples.addAll(appearance.dialogueSamples);
    }

    for (final phrase in profile.speechPattern.typicalPhrases) {
      final count = dialogueSamples
          .where(
            (sample) => sample.toLowerCase().contains(phrase.toLowerCase()),
          )
          .length;
      phraseUsage[phrase] = count;
    }

    double patternScore = 1.0;
    if (profile.speechPattern.typicalPhrases.isNotEmpty) {
      final totalUsage = phraseUsage.values.reduce((a, b) => a + b);
      final expectedUsage =
          profile.speechPattern.typicalPhrases.length *
          dialogueSamples.length *
          0.3;
      patternScore = (totalUsage / (expectedUsage + 1)).clamp(0.0, 1.0);
    }

    return DialoguePatternAnalysis(
      totalDialogueSamples: dialogueSamples.length,
      phraseUsage: phraseUsage,
      patternConsistencyScore: patternScore,
      toneConsistency: profile.speechPattern.typicalTone,
    );
  }

  BehavioralConsistencyAnalysis _analyzeBehavioralConsistency(
    CharacterProfile profile,
  ) {
    if (profile.sceneAppearances.isEmpty) {
      return BehavioralConsistencyAnalysis(
        consistentBehaviors: [],
        inconsistentBehaviors: [],
        consistencyScore: 1.0,
      );
    }

    final consistentBehaviors = <String>[];
    final inconsistentBehaviors = <String>[];

    final totalScenes = profile.sceneAppearances.length;

    for (final behavior in profile.behavioralTendencies) {
      final behaviorKeywords = behavior
          .toLowerCase()
          .split(' ')
          .where((w) => w.length > 3)
          .toList();

      final appearances = profile.sceneAppearances
          .where(
            (app) => app.observedBehaviors.any(
              (obs) => behaviorKeywords.any(
                (keyword) => obs.toLowerCase().contains(keyword),
              ),
            ),
          )
          .length;

      if (appearances >= totalScenes * 0.7) {
        consistentBehaviors.add(behavior);
      } else if (appearances > 0) {
        inconsistentBehaviors.add(
          '$behavior ($appearances/$totalScenes scenes)',
        );
      }
    }

    final score =
        consistentBehaviors.length /
        (consistentBehaviors.length + inconsistentBehaviors.length + 1);

    return BehavioralConsistencyAnalysis(
      consistentBehaviors: consistentBehaviors,
      inconsistentBehaviors: inconsistentBehaviors,
      consistencyScore: score,
    );
  }

  List<ConsistencyAnomaly> _detectAnomalies(CharacterProfile profile) {
    final anomalies = <ConsistencyAnomaly>[];

    for (final appearance in profile.sceneAppearances) {
      for (final trait in profile.personalityTraits) {
        if (!appearance.observedTraits.contains(trait) &&
            !appearance.observedTraits.any(
              (t) =>
                  t.toLowerCase().contains(trait.toLowerCase().split(' ')[0]),
            )) {
          anomalies.add(
            ConsistencyAnomaly(
              type: AnomalyType.missingTrait,
              description:
                  'Missing trait: $trait in scene ${appearance.sceneTitle ?? appearance.sceneId}',
              sceneId: appearance.sceneId,
              severity: AnomalySeverity.low,
            ),
          );
        }
      }

      for (final trait in profile.physicalTraits) {
        if (!appearance.observedPhysicalTraits.contains(trait)) {
          anomalies.add(
            ConsistencyAnomaly(
              type: AnomalyType.missingPhysicalTrait,
              description:
                  'Physical trait not mentioned: $trait in ${appearance.sceneTitle ?? appearance.sceneId}',
              sceneId: appearance.sceneId,
              severity: AnomalySeverity.low,
            ),
          );
        }
      }
    }

    return anomalies;
  }

  Future<List<String>> _generateSuggestions(
    CharacterProfile profile,
    TraitConsistencyAnalysis traitAnalysis,
    DialoguePatternAnalysis dialogueAnalysis,
    BehavioralConsistencyAnalysis behaviorAnalysis,
  ) async {
    final suggestions = <String>[];

    if (traitAnalysis.consistencyScore < 0.7) {
      suggestions.add(
        'Consider reinforcing core personality traits in scenes where they are missing or inconsistent.',
      );
    }

    if (dialogueAnalysis.patternConsistencyScore < 0.6) {
      suggestions.add(
        'Review dialogue to ensure consistent use of characteristic phrases and speech patterns.',
      );
    }

    if (behaviorAnalysis.consistencyScore < 0.7) {
      suggestions.add(
        'Add behavioral consistency cues in scenes where the character\'s typical behaviors are absent.',
      );
    }

    if (profile.sceneAppearances.length < 3) {
      suggestions.add(
        'Character appears in fewer than 3 scenes. Consider adding more appearances for better consistency tracking.',
      );
    }

    return suggestions;
  }

  double _calculateOverallScore(
    TraitConsistencyAnalysis traitAnalysis,
    DialoguePatternAnalysis dialogueAnalysis,
    BehavioralConsistencyAnalysis behaviorAnalysis,
  ) {
    return (traitAnalysis.consistencyScore * 0.4 +
        dialogueAnalysis.patternConsistencyScore * 0.3 +
        behaviorAnalysis.consistencyScore * 0.3);
  }

  Future<CharacterProfile> addSceneAppearance(
    String profileId,
    SceneAppearance appearance,
  ) async {
    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found');
    }

    final updatedAppearances = [...profile.sceneAppearances, appearance];
    _cachedProfiles.removeWhere((p) => p.id == profileId);
    _cachedProfiles.add(
      profile.copyWith(
        sceneAppearances: updatedAppearances,
        updatedAt: DateTime.now(),
      ),
    );

    await _saveProfiles(_cachedProfiles);

    final updated = await getProfileById(profileId);
    if (updated == null) {
      throw Exception('Failed to update profile');
    }

    return updated;
  }

  Future<void> _saveProfiles(List<CharacterProfile> profiles) async {
    final prefs = await _preferences;
    final profilesJson = jsonEncode(profiles.map((p) => p.toMap()).toList());
    await prefs.setString(_profilesKey, profilesJson);
  }

  void clearCache() {
    _cachedProfiles = [];
  }

  Future<List<CharacterProfile>> searchProfiles(String query) async {
    final profiles = await getProfiles();
    final lowerQuery = query.toLowerCase();

    return profiles
        .where(
          (profile) =>
              profile.name.toLowerCase().contains(lowerQuery) ||
              (profile.role?.toLowerCase().contains(lowerQuery) ?? false) ||
              profile.personalityTraits.any(
                (trait) => trait.toLowerCase().contains(lowerQuery),
              ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getCharacterStatistics(String profileId) async {
    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found');
    }

    return {
      'total_appearances': profile.totalAppearances,
      'consistency_score': profile.consistencyScore,
      'total_traits':
          profile.personalityTraits.length + profile.physicalTraits.length,
      'total_relationships': profile.relationships.length,
      'first_appearance': profile.sceneAppearances.isNotEmpty
          ? profile.sceneAppearances
                .map((a) => a.appearanceDate)
                .reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'last_appearance': profile.sceneAppearances.isNotEmpty
          ? profile.sceneAppearances
                .map((a) => a.appearanceDate)
                .reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }
}

class ConsistencyAnalysis {
  final String profileId;
  final double overallScore;
  final TraitConsistencyAnalysis traitConsistency;
  final DialoguePatternAnalysis dialoguePatterns;
  final BehavioralConsistencyAnalysis behavioralConsistency;
  final List<ConsistencyAnomaly> anomalies;
  final List<String> suggestions;
  final DateTime analyzedAt;

  ConsistencyAnalysis({
    required this.profileId,
    required this.overallScore,
    required this.traitConsistency,
    required this.dialoguePatterns,
    required this.behavioralConsistency,
    required this.anomalies,
    required this.suggestions,
    required this.analyzedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'overall_score': overallScore,
      'trait_consistency': traitConsistency.toMap(),
      'dialogue_patterns': dialoguePatterns.toMap(),
      'behavioral_consistency': behavioralConsistency.toMap(),
      'anomalies': anomalies.map((a) => a.toMap()).toList(),
      'suggestions': suggestions,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}

class TraitConsistencyAnalysis {
  final List<String> consistentTraits;
  final List<String> inconsistentTraits;
  final List<String> missingTraits;
  final double consistencyScore;

  TraitConsistencyAnalysis({
    required this.consistentTraits,
    required this.inconsistentTraits,
    required this.missingTraits,
    required this.consistencyScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'consistent_traits': consistentTraits,
      'inconsistent_traits': inconsistentTraits,
      'missing_traits': missingTraits,
      'consistency_score': consistencyScore,
    };
  }
}

class DialoguePatternAnalysis {
  final int totalDialogueSamples;
  final Map<String, int> phraseUsage;
  final double patternConsistencyScore;
  final String? toneConsistency;

  DialoguePatternAnalysis({
    required this.totalDialogueSamples,
    required this.phraseUsage,
    required this.patternConsistencyScore,
    this.toneConsistency,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_dialogue_samples': totalDialogueSamples,
      'phrase_usage': phraseUsage,
      'pattern_consistency_score': patternConsistencyScore,
      'tone_consistency': toneConsistency,
    };
  }
}

class BehavioralConsistencyAnalysis {
  final List<String> consistentBehaviors;
  final List<String> inconsistentBehaviors;
  final double consistencyScore;

  BehavioralConsistencyAnalysis({
    required this.consistentBehaviors,
    required this.inconsistentBehaviors,
    required this.consistencyScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'consistent_behaviors': consistentBehaviors,
      'inconsistent_behaviors': inconsistentBehaviors,
      'consistency_score': consistencyScore,
    };
  }
}

class ConsistencyAnomaly {
  final AnomalyType type;
  final String description;
  final String sceneId;
  final AnomalySeverity severity;

  ConsistencyAnomaly({
    required this.type,
    required this.description,
    required this.sceneId,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'description': description,
      'scene_id': sceneId,
      'severity': severity.name,
    };
  }
}

enum AnomalyType {
  missingTrait,
  missingPhysicalTrait,
  dialogueInconsistency,
  behaviorInconsistency,
}

enum AnomalySeverity { low, medium, high }
