import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/ai_chat/services/ai_chat_service.dart';
import 'package:writer/features/scene_suggestion/services/scene_suggestion_prompts.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/models/scene_suggestion.dart';
import 'package:writer/state/ai_agent_settings.dart';

class SceneSuggestionService {
  final AiChatService aiChatService;

  SceneSuggestionService(this.aiChatService);

  Future<List<SceneSuggestion>> generateSceneSuggestions(
    SceneSuggestionRequest request, {
    AiAgentSettings? settings,
    AppLocalizations? l10n,
    int suggestionCount = 3,
  }) async {
    if (request.currentScene.trim().isEmpty) {
      return [];
    }

    try {
      final prompt = _buildSceneSuggestionPrompt(
        request,
        suggestionCount: suggestionCount,
      );

      final context = _buildSceneContext(request);

      final response = await aiChatService.sendMessageDeepAgent(
        prompt,
        context: context,
        maxPlanSteps: settings?.deepAgentMaxPlanSteps,
        maxToolRounds: settings?.deepAgentMaxToolRounds,
        reflectionMode:
            (settings?.deepAgentReflectionMode ?? DeepAgentReflectionMode.off)
                .wireValue,
        includeDetails: false,
        l10n: l10n,
      );

      final suggestions = _parseSceneSuggestions(response, request);

      return rankSuggestions(suggestions, request: request);
    } catch (e) {
      return [];
    }
  }

  String _buildSceneSuggestionPrompt(
    SceneSuggestionRequest request, {
    int suggestionCount = 3,
  }) {
    var prompt = SceneSuggestionPrompts.buildScenePrompt(
      currentScene: request.currentScene,
      genre: request.genre,
      tone: request.tone,
      previousScenes: request.previousScenes,
      sceneContext: request.sceneContext,
      suggestionCount: suggestionCount,
    );

    if (request.characters.isNotEmpty) {
      final characterMaps = request.characters
          .map<Map<String, String>>(
            (c) => {
              'name': c.name,
              if (c.role != null) 'role': c.role!,
              if (c.bio != null && c.bio!.isNotEmpty) 'bio': c.bio!,
            },
          )
          .toList();

      prompt = SceneSuggestionPrompts.enhancePromptWithCharacters(
        prompt,
        characterMaps,
      );
    }

    return prompt;
  }

  String? _buildSceneContext(SceneSuggestionRequest request) {
    if (request.previousScenes.isEmpty) {
      return null;
    }

    final contextParts = <String>[];

    if (request.genre.isNotEmpty && request.genre != 'general') {
      contextParts.add('Genre: ${request.genre}');
    }

    if (request.tone.isNotEmpty && request.tone != 'neutral') {
      contextParts.add('Tone: ${request.tone}');
    }

    if (request.characters.isNotEmpty) {
      final characterInfo = request.characters
          .map(
            (c) =>
                '${c.name}${c.role != null ? ' (${c.role})' : ''}${c.bio != null ? ': ${c.bio}' : ''}',
          )
          .join(', ');
      contextParts.add('Characters: $characterInfo');
    }

    if (contextParts.isEmpty) {
      return null;
    }

    return 'Story Context:\n${contextParts.join('\n')}';
  }

  List<SceneSuggestion> _parseSceneSuggestions(
    String response,
    SceneSuggestionRequest request,
  ) {
    final suggestions = <SceneSuggestion>[];

    final suggestionBlocks = response.split('SUGGESTION ').skip(1);

    for (final block in suggestionBlocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      String? suggestedText;
      String? rationale;
      List<String> alternativeApproaches = [];

      final buffer = StringBuffer();
      var currentSection = 'text';
      var firstLine = true;

      for (final line in lines) {
        if (firstLine && RegExp(r'^\d+:').hasMatch(line)) {
          firstLine = false;
          continue;
        }
        firstLine = false;

        if (line.startsWith('RATIONALE:')) {
          suggestedText = buffer.toString().trim();
          rationale = line.substring('RATIONALE:'.length).trim();
          buffer.clear();
          currentSection = 'rationale';
        } else if (line.startsWith('ALTERNATIVES:')) {
          final alternativesText = line
              .substring('ALTERNATIVES:'.length)
              .trim();
          if (alternativesText.isNotEmpty) {
            alternativeApproaches = alternativesText
                .split(';')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
          currentSection = 'alternatives';
        } else {
          if (currentSection == 'text') {
            if (buffer.isNotEmpty) buffer.write('\n');
            buffer.write(line);
          } else if (currentSection == 'rationale') {
            if (rationale != null && rationale.isNotEmpty) {
              rationale = '$rationale\n$line';
            } else {
              rationale = line;
            }
          } else if (currentSection == 'alternatives') {
            final alternativesText = line.trim();
            if (alternativesText.isNotEmpty) {
              alternativeApproaches.addAll(
                alternativesText
                    .split(';')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty),
              );
            }
          }
        }
      }

      if (suggestedText == null || suggestedText.isEmpty) {
        suggestedText = buffer.toString().trim();
      }

      if (suggestedText.isNotEmpty) {
        suggestions.add(
          SceneSuggestion(
            suggestedText: suggestedText,
            relevanceScore: _calculateRelevanceScore(
              suggestedText,
              rationale ?? '',
            ),
            rationale: rationale?.trim().isNotEmpty == true
                ? rationale!.trim()
                : 'Continues the scene naturally',
            alternativeApproaches: alternativeApproaches,
          ),
        );
      }

      if (suggestions.length >= 5) break;
    }

    if (suggestions.isEmpty) {
      final lines = response.split('\n');
      final cleanedResponse = lines
          .where(
            (line) =>
                line.trim().isNotEmpty &&
                !line.trim().startsWith('SUGGESTION') &&
                !line.trim().startsWith('RATIONALE') &&
                !line.trim().startsWith('ALTERNATIVES'),
          )
          .join('\n')
          .trim();

      if (cleanedResponse.isNotEmpty) {
        suggestions.add(
          SceneSuggestion(
            suggestedText: cleanedResponse,
            relevanceScore: 0.7,
            rationale: 'AI-generated scene continuation',
          ),
        );
      }
    }

    return suggestions;
  }

  double _calculateRelevanceScore(String suggestedText, String rationale) {
    var score = 0.7;

    if (suggestedText.length > 50 && suggestedText.length < 500) {
      score += 0.1;
    }

    if (rationale.isNotEmpty) {
      score += 0.1;
    }

    if (suggestedText.contains('.') && suggestedText.split('.').length > 2) {
      score += 0.05;
    }

    return (score.clamp(0.0, 1.0));
  }

  Future<String> compressSceneContext(
    List<String> scenes, {
    AppLocalizations? l10n,
  }) async {
    if (scenes.isEmpty) {
      return '';
    }

    final context = scenes.join('\n\n---\n\n');
    return aiChatService.compressContext(context, l10n: l10n);
  }

  List<SceneSuggestion> rankSuggestions(
    List<SceneSuggestion> suggestions, {
    SceneSuggestionRequest? request,
  }) {
    if (suggestions.isEmpty) {
      return suggestions;
    }

    final scoredSuggestions = suggestions.map((suggestion) {
      var score = suggestion.relevanceScore;

      score += _calculateCoherenceScore(suggestion, request);
      score += _calculateCreativityScore(suggestion);
      score += _calculateConsistencyScore(suggestion, request);

      return MapEntry(suggestion, score);
    }).toList();

    scoredSuggestions.sort((a, b) => b.value.compareTo(a.value));

    return scoredSuggestions.map((e) => e.key).toList();
  }

  double _calculateCoherenceScore(
    SceneSuggestion suggestion,
    SceneSuggestionRequest? request,
  ) {
    var score = 0.0;

    if (request != null && request.currentScene.isNotEmpty) {
      final currentWords = request.currentScene.split(' ');
      final suggestionWords = suggestion.suggestedText.split(' ');

      final commonWords = currentWords.where(suggestionWords.contains).length;

      final coherenceRatio = currentWords.isNotEmpty
          ? commonWords / currentWords.length
          : 0.0;

      if (coherenceRatio > 0.0 && coherenceRatio < 0.3) {
        score += 0.1;
      }
    }

    if (suggestion.suggestedText.split('.').length >= 2) {
      score += 0.05;
    }

    if (suggestion.rationale.isNotEmpty) {
      score += 0.05;
    }

    return score;
  }

  double _calculateCreativityScore(SceneSuggestion suggestion) {
    var score = 0.0;

    if (suggestion.alternativeApproaches.length >= 2) {
      score += 0.1;
    }

    final words = suggestion.suggestedText.split(' ');
    final uniqueWords = words.toSet().length;
    final vocabularyRichness = words.isNotEmpty
        ? uniqueWords / words.length
        : 0.0;

    if (vocabularyRichness > 0.6) {
      score += 0.05;
    }

    return score;
  }

  double _calculateConsistencyScore(
    SceneSuggestion suggestion,
    SceneSuggestionRequest? request,
  ) {
    var score = 0.0;

    if (request != null && request.characters.isNotEmpty) {
      final characterNames = request.characters
          .map((c) => c.name.toLowerCase())
          .toSet();

      final mentionedCharacters = characterNames
          .where(
            (name) => suggestion.suggestedText.toLowerCase().contains(name),
          )
          .length;

      if (mentionedCharacters > 0) {
        score += mentionedCharacters * 0.05;
      }
    }

    if (request != null &&
        request.genre.isNotEmpty &&
        request.genre != 'general') {
      score += 0.05;
    }

    return score;
  }
}

final sceneSuggestionServiceProvider = Provider<SceneSuggestionService>((ref) {
  return SceneSuggestionService(ref.watch(aiChatServiceProvider));
});
