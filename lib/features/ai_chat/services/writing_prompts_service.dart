import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/ai_chat/models/writing_prompt.dart';

const _customPromptsKey = 'writing_prompts_custom';

class WritingPromptsService {
  WritingPromptsService(this._prefs);

  final SharedPreferences _prefs;

  static final List<WritingPrompt> defaultPrompts = [
    const WritingPrompt(
      id: 'scene_1',
      text: 'Write a scene where a small mistake changes everything.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_2',
      text: 'Describe a room using only sounds and textures.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_3',
      text: 'Start with: "I didn\'t expect to see you here."',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_4',
      text: 'Write a calm moment right before chaos.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_5',
      text: 'Reveal a secret using an everyday object.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_6',
      text: 'Your character receives a letter they were never meant to read.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_7',
      text: 'A promise made long ago comes due today.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'scene_8',
      text: 'Write a scene that ends with a choice.',
      category: WritingPromptCategory.sceneStarters,
    ),
    const WritingPrompt(
      id: 'char_1',
      text:
          'Describe your character\'s defining trait through their actions, not their thoughts.',
      category: WritingPromptCategory.characterDevelopment,
      aiContext:
          'Help me develop a character trait through showing vs telling.',
    ),
    const WritingPrompt(
      id: 'char_2',
      text: 'Write a scene showing your character under extreme pressure.',
      category: WritingPromptCategory.characterDevelopment,
      aiContext: 'Generate a character-building scene under pressure.',
    ),
    const WritingPrompt(
      id: 'char_3',
      text:
          'Create a backstory conflict that shaped your character\'s worldview.',
      category: WritingPromptCategory.characterDevelopment,
      aiContext: 'Help me create a compelling character backstory.',
    ),
    const WritingPrompt(
      id: 'char_4',
      text:
          'Write dialogue where your character lies about something important.',
      category: WritingPromptCategory.characterDevelopment,
      aiContext:
          'Help me write convincing character dialogue with hidden motivations.',
    ),
    const WritingPrompt(
      id: 'char_5',
      text: 'Show your character\'s greatest fear without naming it.',
      category: WritingPromptCategory.characterDevelopment,
      aiContext: 'Show character fear through subtext and actions.',
    ),
    const WritingPrompt(
      id: 'dialogue_1',
      text: 'Write dialogue where the truth is never said directly.',
      category: WritingPromptCategory.dialogue,
      aiContext: 'Help me write subtext-heavy dialogue.',
    ),
    const WritingPrompt(
      id: 'dialogue_2',
      text:
          'Two characters argue but are actually talking about something else entirely.',
      category: WritingPromptCategory.dialogue,
      aiContext: 'Help me write parallel dialogue with hidden meaning.',
    ),
    const WritingPrompt(
      id: 'dialogue_3',
      text: 'Write a conversation that starts friendly and ends in tension.',
      category: WritingPromptCategory.dialogue,
      aiContext: 'Show me how to build tension through dialogue.',
    ),
    const WritingPrompt(
      id: 'dialogue_4',
      text:
          'Your character must convince someone of something they don\'t believe.',
      category: WritingPromptCategory.dialogue,
      aiContext: 'Help me write persuasive dialogue.',
    ),
    const WritingPrompt(
      id: 'world_1',
      text: 'Describe your world through a local\'s daily routine.',
      category: WritingPromptCategory.worldBuilding,
      aiContext: 'Help me show world-building through everyday life.',
    ),
    const WritingPrompt(
      id: 'world_2',
      text: 'What\'s a rule in your world that everyone breaks?',
      category: WritingPromptCategory.worldBuilding,
      aiContext: 'Help me create interesting world rules and exceptions.',
    ),
    const WritingPrompt(
      id: 'world_3',
      text:
          'Show the socioeconomic divide in your world without mentioning money.',
      category: WritingPromptCategory.worldBuilding,
      aiContext: 'Show socioeconomic divides through setting and lifestyle.',
    ),
    const WritingPrompt(
      id: 'world_4',
      text:
          'Write about a historical event that everyone in your world knows wrong.',
      category: WritingPromptCategory.worldBuilding,
      aiContext:
          'Help me create historical myths and how they differ from truth.',
    ),
    const WritingPrompt(
      id: 'plot_1',
      text: 'A character must choose between two good options.',
      category: WritingPromptCategory.plot,
      aiContext: 'Help me write a meaningful moral dilemma.',
    ),
    const WritingPrompt(
      id: 'plot_2',
      text:
          'The antagonist believes they\'re the hero. Write their perspective.',
      category: WritingPromptCategory.plot,
      aiContext: 'Help me write a compelling antagonist viewpoint.',
    ),
    const WritingPrompt(
      id: 'plot_3',
      text: 'Plant a detail in chapter one that pays off in chapter ten.',
      category: WritingPromptCategory.plot,
      aiContext: 'Help me plan foreshadowing and payoff.',
    ),
    const WritingPrompt(
      id: 'plot_4',
      text:
          'Write a scene where everything goes wrong. Then rewrite it where everything goes right.',
      category: WritingPromptCategory.plot,
      aiContext: 'Help me write parallel scenes with different outcomes.',
    ),
    const WritingPrompt(
      id: 'exercise_1',
      text: 'Write a paragraph with no adjectives.',
      category: WritingPromptCategory.writingExercises,
    ),
    const WritingPrompt(
      id: 'exercise_2',
      text: 'Describe emotion using only physical sensations.',
      category: WritingPromptCategory.writingExercises,
    ),
    const WritingPrompt(
      id: 'exercise_3',
      text: 'Write the same scene from three different character perspectives.',
      category: WritingPromptCategory.writingExercises,
    ),
    const WritingPrompt(
      id: 'exercise_4',
      text: 'Take a cliché and subvert it in one paragraph.',
      category: WritingPromptCategory.writingExercises,
    ),
    const WritingPrompt(
      id: 'exercise_5',
      text: 'Write a scene using only five different words.',
      category: WritingPromptCategory.writingExercises,
    ),
    const WritingPrompt(
      id: 'template_1',
      text: 'Help me create a character arc template for [character name].',
      category: WritingPromptCategory.templates,
      aiContext: 'Generate a character arc structure.',
    ),
    const WritingPrompt(
      id: 'template_2',
      text: 'Give me a three-act structure outline for [plot concept].',
      category: WritingPromptCategory.templates,
      aiContext: 'Generate a three-act story structure.',
    ),
    const WritingPrompt(
      id: 'template_3',
      text: 'Create a scene template for [type of scene].',
      category: WritingPromptCategory.templates,
      aiContext: 'Generate a scene structure template.',
    ),
    const WritingPrompt(
      id: 'template_4',
      text: 'Build a dialogue exchange template showing [emotional arc].',
      category: WritingPromptCategory.templates,
      aiContext: 'Generate a dialogue structure template.',
    ),
  ];

  List<WritingPrompt> getAllPrompts() {
    final customPrompts = _loadCustomPrompts();
    return [...defaultPrompts, ...customPrompts];
  }

  List<WritingPrompt> getPromptsByCategory(WritingPromptCategory category) {
    return getAllPrompts()
        .where((prompt) => prompt.category == category)
        .toList();
  }

  List<WritingPrompt> searchPrompts(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllPrompts()
        .where(
          (prompt) =>
              prompt.text.toLowerCase().contains(lowerQuery) ||
              (prompt.aiContext?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  WritingPrompt? getPromptById(String id) {
    return getAllPrompts().cast<WritingPrompt?>().firstWhere(
      (prompt) => prompt?.id == id,
      orElse: () => null,
    );
  }

  List<WritingPrompt> _loadCustomPrompts() {
    final jsonString = _prefs.getString(_customPromptsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => WritingPrompt.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCustomPrompts(List<WritingPrompt> prompts) async {
    final jsonList = prompts.map((p) => p.toJson()).toList();
    await _prefs.setString(_customPromptsKey, json.encode(jsonList));
  }

  Future<void> addCustomPrompt(WritingPrompt prompt) async {
    final customPrompts = _loadCustomPrompts();
    final newPrompt = prompt.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      isCustom: true,
    );
    customPrompts.add(newPrompt);
    await _saveCustomPrompts(customPrompts);
  }

  Future<void> updateCustomPrompt(WritingPrompt prompt) async {
    if (!prompt.isCustom) return;

    final customPrompts = _loadCustomPrompts();
    final index = customPrompts.indexWhere((p) => p.id == prompt.id);
    if (index >= 0) {
      customPrompts[index] = prompt;
      await _saveCustomPrompts(customPrompts);
    }
  }

  Future<void> deleteCustomPrompt(String id) async {
    final customPrompts = _loadCustomPrompts();
    customPrompts.removeWhere((p) => p.id == id);
    await _saveCustomPrompts(customPrompts);
  }

  List<WritingPrompt> getCustomPrompts() {
    return _loadCustomPrompts();
  }

  WritingPrompt getRandomPrompt({WritingPromptCategory? category}) {
    final prompts = category != null
        ? getPromptsByCategory(category)
        : getAllPrompts();
    if (prompts.isEmpty) {
      return const WritingPrompt(
        id: 'fallback',
        text: 'Tell me about your story and I\'ll help you develop it.',
        category: WritingPromptCategory.custom,
      );
    }
    prompts.shuffle();
    return prompts.first;
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final writingPromptsServiceProvider = Provider<WritingPromptsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WritingPromptsService(prefs);
});

final writingPromptsProvider = Provider<List<WritingPrompt>>((ref) {
  final service = ref.watch(writingPromptsServiceProvider);
  return service.getAllPrompts();
});

final writingPromptsByCategoryProvider =
    Provider.family<List<WritingPrompt>, WritingPromptCategory>((
      ref,
      category,
    ) {
      final service = ref.watch(writingPromptsServiceProvider);
      return service.getPromptsByCategory(category);
    });

final writingPromptSearchProvider =
    Provider.family<List<WritingPrompt>, String>((ref, query) {
      if (query.isEmpty) return [];
      final service = ref.watch(writingPromptsServiceProvider);
      return service.searchPrompts(query);
    });

final customWritingPromptsProvider = Provider<List<WritingPrompt>>((ref) {
  final service = ref.watch(writingPromptsServiceProvider);
  return service.getCustomPrompts();
});
