import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:writer/features/character_consistency/services/character_consistency_service.dart';
import 'package:writer/models/writing_assistant_suggestion.dart';

class SmartWritingAssistantService {
  final CharacterConsistencyService _characterService;
  final Uuid _uuid = Uuid();

  SmartWritingAssistantService(this._characterService);

  Future<List<WritingAssistantSuggestion>> getSuggestions(
    WritingContext context,
  ) async {
    final suggestions = <WritingAssistantSuggestion>[];

    final beforeText = context.getTextBeforeCursor(length: 500);
    final afterText = context.getTextAfterCursor(length: 200);

    suggestions.addAll(await _getGrammarSuggestions(beforeText, afterText));
    suggestions.addAll(await _getStyleSuggestions(beforeText, context));
    suggestions.addAll(await _getVocabularySuggestions(beforeText));
    suggestions.addAll(await _getConsistencySuggestions(context));

    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return suggestions.take(10).toList();
  }

  Future<List<WritingAssistantSuggestion>> _getGrammarSuggestions(
    String beforeText,
    String afterText,
  ) async {
    final suggestions = <WritingAssistantSuggestion>[];
    final text = beforeText + afterText;

    final issues = <String, String>{};

    if (RegExp(r'\ba\b\s+[aeiou]').hasMatch(text)) {
      issues['grammar'] = 'Use "an" before words starting with a vowel';
    }

    if (RegExp(r'\s{2,}').hasMatch(text)) {
      issues['spacing'] = 'Multiple spaces detected';
    }

    if (!RegExp(r'[.!?]$').hasMatch(beforeText.trim()) &&
        beforeText.trim().isNotEmpty &&
        beforeText.trim().split(' ').length > 5) {
      issues['punctuation'] = 'Consider ending the sentence with punctuation';
    }

    if (RegExp(r'\bi\b').hasMatch(text)) {
      issues['capitalization'] = 'Capitalize the pronoun "I"';
    }

    for (final entry in issues.entries) {
      suggestions.add(
        WritingAssistantSuggestion(
          id: _uuid.v4(),
          type: entry.key,
          suggestion: entry.value,
          context: beforeText,
          confidence: 0.7,
          createdAt: DateTime.now(),
        ),
      );
    }

    return suggestions;
  }

  Future<List<WritingAssistantSuggestion>> _getStyleSuggestions(
    String beforeText,
    WritingContext context,
  ) async {
    final suggestions = <WritingAssistantSuggestion>[];

    final words = beforeText.split(' ');
    if (words.length > 15) {
      suggestions.add(
        WritingAssistantSuggestion(
          id: _uuid.v4(),
          type: 'sentence_length',
          suggestion:
              'This sentence is quite long. Consider breaking it into shorter sentences for better readability.',
          context: beforeText,
          confidence: 0.6,
          createdAt: DateTime.now(),
        ),
      );
    }

    final passiveVoicePatterns = [
      RegExp(r'\b(was|were)\s+\w+ed\b'),
      RegExp(r'\b(been)\s+\w+ed\b'),
    ];

    for (final pattern in passiveVoicePatterns) {
      if (pattern.hasMatch(beforeText)) {
        suggestions.add(
          WritingAssistantSuggestion(
            id: _uuid.v4(),
            type: 'passive_voice',
            suggestion: 'Consider using active voice for more engaging writing',
            context: beforeText,
            confidence: 0.65,
            createdAt: DateTime.now(),
          ),
        );
        break;
      }
    }

    final veryCount = RegExp(r'\bvery\b').allMatches(beforeText).length;
    if (veryCount > 2) {
      suggestions.add(
        WritingAssistantSuggestion(
          id: _uuid.v4(),
          type: 'word_choice',
          suggestion:
              'Try replacing "very" with stronger, more specific adjectives',
          context: beforeText,
          confidence: 0.7,
          createdAt: DateTime.now(),
        ),
      );
    }

    return suggestions;
  }

  Future<List<WritingAssistantSuggestion>> _getVocabularySuggestions(
    String beforeText,
  ) async {
    final suggestions = <WritingAssistantSuggestion>[];

    final weakWords = {
      'good': ['excellent', 'outstanding', 'superb', 'exceptional'],
      'bad': ['terrible', 'awful', 'poor', 'dreadful'],
      'big': ['enormous', 'massive', 'immense', 'vast'],
      'small': ['tiny', 'minuscule', 'compact', 'petite'],
      'said': ['whispered', 'shouted', 'exclaimed', 'murmured'],
      'went': ['rushed', 'strolled', 'marched', 'hurried'],
    };

    for (final entry in weakWords.entries) {
      if (RegExp(r'\b${entry.key}\b').hasMatch(beforeText)) {
        suggestions.add(
          WritingAssistantSuggestion(
            id: _uuid.v4(),
            type: 'vocabulary',
            suggestion:
                'Consider using a more specific word: ${entry.value.join(", ")}',
            context: beforeText,
            confidence: 0.6,
            createdAt: DateTime.now(),
            metadata: {'suggestions': entry.value},
          ),
        );
      }
    }

    return suggestions;
  }

  Future<List<WritingAssistantSuggestion>> _getConsistencySuggestions(
    WritingContext context,
  ) async {
    final suggestions = <WritingAssistantSuggestion>[];

    try {
      final profiles = await _characterService.getProfiles();

      if (context.nearbyCharacters != null) {
        for (final characterName in context.nearbyCharacters!) {
          final profile = profiles
              .where((p) => p.name == characterName)
              .firstOrNull;

          if (profile != null) {
            if (profile.personalityTraits.isNotEmpty) {
              suggestions.add(
                WritingAssistantSuggestion(
                  id: _uuid.v4(),
                  type: 'character_voice',
                  suggestion:
                      'Consider $characterName\'s personality traits: ${profile.personalityTraits.join(", ")}',
                  context: characterName,
                  confidence: 0.75,
                  createdAt: DateTime.now(),
                  metadata: {'character_id': profile.id},
                ),
              );
            }

            if (profile.behavioralTendencies.isNotEmpty) {
              suggestions.add(
                WritingAssistantSuggestion(
                  id: _uuid.v4(),
                  type: 'character_consistency',
                  suggestion:
                      'Keep in mind $characterName\'s behaviors: ${profile.behavioralTendencies.join(", ")}',
                  context: characterName,
                  confidence: 0.7,
                  createdAt: DateTime.now(),
                  metadata: {'character_id': profile.id},
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching character profiles: $e');
    }

    return suggestions;
  }

  Future<List<AutoCompletionResult>> getAutoCompletions(
    WritingContext context,
    String partialInput,
  ) async {
    final completions = <AutoCompletionResult>[];

    completions.addAll(await _getCharacterNameCompletions(partialInput));
    completions.addAll(await _getLocationCompletions(partialInput, context));
    completions.addAll(await _getWordCompletions(partialInput, context));

    completions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return completions.take(10).toList();
  }

  Future<List<AutoCompletionResult>> _getCharacterNameCompletions(
    String partialInput,
  ) async {
    final completions = <AutoCompletionResult>[];

    try {
      final profiles = await _characterService.getProfiles();

      final matchingProfiles = profiles.where((profile) {
        return profile.name.toLowerCase().startsWith(
          partialInput.toLowerCase(),
        );
      }).toList();

      for (final profile in matchingProfiles) {
        completions.add(
          AutoCompletionResult(
            id: _uuid.v4(),
            completion: profile.name,
            type: 'character_name',
            confidence: 0.95,
            alternatives: profile.role != null
                ? [profile.name, profile.role!]
                : [profile.name],
          ),
        );
      }
    } catch (e) {
      print('Error fetching character names: $e');
    }

    return completions;
  }

  Future<List<AutoCompletionResult>> _getLocationCompletions(
    String partialInput,
    WritingContext context,
  ) async {
    final completions = <AutoCompletionResult>[];

    final knownLocations = [
      'New York',
      'London',
      'Paris',
      'Tokyo',
      'Sydney',
      'Berlin',
      'Rome',
      'Madrid',
      'Moscow',
      'Beijing',
    ];

    if (context.location != null) {
      knownLocations.add(context.location!);
    }

    final matchingLocations = knownLocations.where((location) {
      return location.toLowerCase().startsWith(partialInput.toLowerCase());
    }).toList();

    for (final location in matchingLocations) {
      completions.add(
        AutoCompletionResult(
          id: _uuid.v4(),
          completion: location,
          type: 'location',
          confidence: 0.85,
        ),
      );
    }

    return completions;
  }

  Future<List<AutoCompletionResult>> _getWordCompletions(
    String partialInput,
    WritingContext context,
  ) async {
    final completions = <AutoCompletionResult>[];

    final commonWords = [
      'the',
      'be',
      'to',
      'of',
      'and',
      'a',
      'in',
      'that',
      'have',
      'I',
      'it',
      'for',
      'not',
      'on',
      'with',
      'he',
      'as',
      'you',
      'do',
      'at',
      'this',
      'but',
      'his',
      'by',
      'from',
      'they',
      'we',
      'say',
      'her',
      'she',
      'or',
      'an',
      'will',
      'my',
      'one',
      'all',
      'would',
      'there',
      'their',
    ];

    final matchingWords = commonWords.where((word) {
      return word.toLowerCase().startsWith(partialInput.toLowerCase());
    }).toList();

    for (final word in matchingWords) {
      completions.add(
        AutoCompletionResult(
          id: _uuid.v4(),
          completion: word,
          type: 'word',
          confidence: 0.6,
        ),
      );
    }

    final genreSpecific = await _getGenreSpecificWords(context.genre);
    final matchingGenreWords = genreSpecific.where((word) {
      return word.toLowerCase().startsWith(partialInput.toLowerCase());
    }).toList();

    for (final word in matchingGenreWords) {
      completions.add(
        AutoCompletionResult(
          id: _uuid.v4(),
          completion: word,
          type: 'word',
          confidence: 0.75,
        ),
      );
    }

    return completions;
  }

  Future<List<String>> _getGenreSpecificWords(String? genre) async {
    switch (genre?.toLowerCase()) {
      case 'fantasy':
        return [
          'magic',
          'wizard',
          'dragon',
          'spell',
          'potion',
          'kingdom',
          'castle',
          'knight',
          'sword',
          'quest',
          'enchanted',
          'mystical',
          'ancient',
        ];
      case 'science fiction':
        return [
          'spaceship',
          'laser',
          'robot',
          'alien',
          'planet',
          'galaxy',
          'warp',
          'android',
          'cyborg',
          'quantum',
          'hologram',
          'nebula',
          'cosmic',
        ];
      case 'mystery':
        return [
          'detective',
          'clue',
          'evidence',
          'suspect',
          'alibi',
          'mystery',
          'investigation',
          'witness',
          'crime',
          'deduction',
          'secret',
        ];
      case 'romance':
        return [
          'love',
          'heart',
          'passion',
          'desire',
          'embrace',
          'whisper',
          'gaze',
          'affection',
          'romantic',
          'tender',
          'devotion',
          'cherish',
        ];
      default:
        return [];
    }
  }

  Future<WritingAnalysis> analyzeText(String documentId, String text) async {
    final words = text.split(RegExp(r'\s+'));
    final nonEmptyWords = words.where((w) => w.isNotEmpty).toList();

    final totalWords = nonEmptyWords.length;
    final uniqueWords = nonEmptyWords.toSet().length;

    final sentences = text.split(RegExp(r'[.!?]+'));
    final nonEmptySentences = sentences
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final averageSentenceLength = nonEmptySentences.isNotEmpty
        ? totalWords / nonEmptySentences.length
        : 0.0;

    final totalCharacters = nonEmptyWords.fold<int>(
      0,
      (sum, word) => sum + word.length,
    );
    final averageWordLength = totalWords > 0
        ? totalCharacters / totalWords
        : 0.0;

    final readabilityScore = _calculateReadabilityScore(
      averageSentenceLength,
      averageWordLength,
    );

    final partOfSpeechDistribution = await _analyzePartOfSpeech(nonEmptyWords);

    final repeatedPhrases = _findRepeatedPhrases(text);

    final grammarIssues = await _detectGrammarIssues(text);

    final styleSuggestions = await _generateStyleSuggestions(
      text,
      averageSentenceLength,
      averageWordLength,
    );

    return WritingAnalysis(
      id: _uuid.v4(),
      documentId: documentId,
      totalWords: totalWords,
      uniqueWords: uniqueWords,
      averageSentenceLength: averageSentenceLength,
      averageWordLength: averageWordLength,
      readabilityScore: readabilityScore,
      partOfSpeechDistribution: partOfSpeechDistribution,
      repeatedPhrases: repeatedPhrases,
      grammarIssues: grammarIssues,
      styleSuggestions: styleSuggestions,
      analyzedAt: DateTime.now(),
    );
  }

  double _calculateReadabilityScore(
    double averageSentenceLength,
    double averageWordLength,
  ) {
    final score =
        206.835 - (1.015 * averageSentenceLength) - (84.6 * averageWordLength);

    return (score / 100).clamp(0.0, 1.0);
  }

  Future<Map<String, int>> _analyzePartOfSpeech(List<String> words) async {
    final distribution = <String, int>{};

    final commonNouns = [
      'time',
      'person',
      'way',
      'day',
      'thing',
      'man',
      'world',
      'life',
      'hand',
    ];
    final commonVerbs = [
      'be',
      'have',
      'do',
      'say',
      'go',
      'get',
      'make',
      'know',
      'think',
      'take',
    ];
    final commonAdjectives = [
      'good',
      'new',
      'first',
      'last',
      'long',
      'great',
      'little',
      'own',
      'other',
    ];

    for (final word in words) {
      final lowerWord = word.toLowerCase();

      if (commonNouns.contains(lowerWord)) {
        distribution['noun'] = (distribution['noun'] ?? 0) + 1;
      } else if (commonVerbs.contains(lowerWord)) {
        distribution['verb'] = (distribution['verb'] ?? 0) + 1;
      } else if (commonAdjectives.contains(lowerWord)) {
        distribution['adjective'] = (distribution['adjective'] ?? 0) + 1;
      }
    }

    return distribution;
  }

  List<String> _findRepeatedPhrases(String text) {
    final repeated = <String>[];

    final words = text.toLowerCase().split(RegExp(r'[^\w]+'));
    final phrases = <String, int>{};

    for (int i = 0; i < words.length - 2; i++) {
      final phrase = '${words[i]} ${words[i + 1]} ${words[i + 2]}';
      phrases[phrase] = (phrases[phrase] ?? 0) + 1;
    }

    for (final entry in phrases.entries) {
      if (entry.value > 2) {
        repeated.add('"${entry.key}" used ${entry.value} times');
      }
    }

    return repeated;
  }

  Future<List<String>> _detectGrammarIssues(String text) async {
    final issues = <String>[];

    if (RegExp(r'\s{2,}').hasMatch(text)) {
      issues.add('Multiple consecutive spaces');
    }

    if (RegExp(r'[a-z][A-Z]').hasMatch(text)) {
      issues.add('Possible missing space between words');
    }

    if (RegExp(r'\b(i)\b').hasMatch(text)) {
      issues.add('Pronoun "I" should be capitalized');
    }

    if (RegExp(r'\.\s*[a-z]').hasMatch(text)) {
      issues.add('Possible missing capitalization after period');
    }

    return issues;
  }

  Future<List<String>> _generateStyleSuggestions(
    String text,
    double averageSentenceLength,
    double averageWordLength,
  ) async {
    final suggestions = <String>[];

    if (averageSentenceLength > 20) {
      suggestions.add(
        'Average sentence length is quite long (${averageSentenceLength.toStringAsFixed(1)} words). Consider using shorter sentences for better readability.',
      );
    } else if (averageSentenceLength < 10) {
      suggestions.add(
        'Average sentence length is quite short (${averageSentenceLength.toStringAsFixed(1)} words). Vary sentence length for better flow.',
      );
    }

    if (averageWordLength < 4) {
      suggestions.add(
        'Consider using more specific vocabulary to enrich your writing.',
      );
    }

    final veryCount = RegExp(r'\bvery\b').allMatches(text).length;
    if (veryCount > 5) {
      suggestions.add(
        'The word "very" is used $veryCount times. Try using stronger adjectives instead.',
      );
    }

    final passiveVoiceCount = RegExp(
      r'\b(was|were)\s+\w+ed\b',
    ).allMatches(text).length;
    if (passiveVoiceCount > 3) {
      suggestions.add(
        '$passiveVoiceCount instances of passive voice detected. Consider using active voice for more engaging writing.',
      );
    }

    return suggestions;
  }

  Future<void> dismissSuggestion(String suggestionId) async {
    // print('Dismissing suggestion: $suggestionId');
  }

  Future<void> applySuggestion(
    String suggestionId,
    String originalText,
    String suggestedReplacement,
  ) async {
    debugPrint(
      'Applying suggestion $suggestionId: $originalText -> $suggestedReplacement',
    );
  }
}
