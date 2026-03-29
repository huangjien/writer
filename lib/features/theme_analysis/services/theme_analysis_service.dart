import 'package:uuid/uuid.dart';
import 'package:writer/models/theme_analysis.dart';

class ThemeAnalysisService {
  final Uuid _uuid = Uuid();
  final Map<String, List<String>> _themeKeywords = {
    'love': [
      'love',
      'passion',
      'desire',
      'affection',
      'heart',
      'romance',
      'relationship',
      'intimacy',
      'devotion',
      'eros',
      'cherish',
    ],
    'death': [
      'death',
      'die',
      'dead',
      'kill',
      'murder',
      'grave',
      'funeral',
      'end',
      'tragic',
      'fate',
      'mortality',
      'dying',
      'loss',
    ],
    'power': [
      'power',
      'control',
      'rule',
      'authority',
      'dominance',
      'strength',
      'king',
      'queen',
      'throne',
      'empire',
      'conquest',
      'force',
    ],
    'freedom': [
      'freedom',
      'liberty',
      'escape',
      'release',
      'independence',
      'break free',
      'autonomy',
      'free',
      'liberation',
      'emancipation',
    ],
    'revenge': [
      'revenge',
      'retribution',
      'vengeance',
      'payback',
      'avenge',
      'grudge',
      'settle scores',
      'justice',
      'retaliation',
      'punish',
    ],
    'redemption': [
      'redemption',
      'forgive',
      'atone',
      'salvation',
      'reform',
      'change',
      'grow',
      'improve',
      'mend',
      'reconcile',
      'transform',
    ],
    'identity': [
      'identity',
      'self',
      'who am I',
      'discover',
      'true self',
      'personality',
      'character',
      'becoming',
      'authentic',
      'belief',
    ],
    'coming of age': [
      'grow up',
      'mature',
      'youth',
      'child',
      'adult',
      'learn',
      'experience',
      'naive',
      'innocent',
      'wisdom',
      'lesson',
    ],
    'war': [
      'war',
      'battle',
      'fight',
      'conflict',
      'soldier',
      'army',
      'combat',
      'strategy',
      'victory',
      'defeat',
      'military',
    ],
    'justice': [
      'justice',
      'law',
      'fair',
      'rights',
      'innocent',
      'guilty',
      'court',
      'trial',
      'judge',
      'truth',
      'equality',
      'moral',
    ],
  };

  final Map<String, List<String>> _commonMotifs = {
    'light': ['light', 'bright', 'sun', 'dawn', 'glow', 'shine', 'radiant'],
    'darkness': ['dark', 'shadow', 'night', 'black', 'gloom', 'obscur'],
    'water': ['water', 'rain', 'river', 'sea', 'ocean', 'wave', 'flood'],
    'fire': ['fire', 'flame', 'burn', 'heat', 'blaze', 'ember'],
    'journey': [
      'journey',
      'travel',
      'road',
      'path',
      'quest',
      'adventure',
      'destination',
    ],
    'circle': ['circle', 'cycle', 'round', 'return', 'repeat', 'eternal'],
    'crossing': ['bridge', 'door', 'gate', 'threshold', 'crossing', 'portal'],
  };

  final Map<String, List<String>> _symbols = {
    'rose': ['rose', 'flower', 'bloom', 'petal', 'garden'],
    'dagger': ['dagger', 'knife', 'blade', 'sword', 'weapon'],
    'ring': ['ring', 'circle', 'band', 'cycle', 'eternity'],
    'mirror': ['mirror', 'reflection', 'self', 'glass', 'see'],
    'bird': ['bird', 'free', 'fly', 'sky', 'wing', 'soar'],
    'snake': ['snake', 'serpent', 'temptation', 'evil', 'wisdom'],
    'tree': ['tree', 'life', 'growth', 'nature', 'root', 'branch'],
  };

  Future<ThemeAnalysis> analyzeThemes(String documentId, String text) async {
    final normalizedText = text.toLowerCase();

    final themes = _identifyThemes(normalizedText);
    final themeWeights = _calculateThemeWeights(normalizedText, themes);
    final motifs = _identifyMotifs(normalizedText);
    final symbols = _identifySymbols(normalizedText);
    final conflicts = _detectConflicts(themes);
    final overallCoherence = _calculateCoherence(themeWeights);

    return ThemeAnalysis(
      id: _uuid.v4(),
      documentId: documentId,
      themes: themes,
      themeWeights: themeWeights,
      motifs: motifs,
      symbols: symbols,
      characterArcs: _analyzeCharacterArcs(normalizedText),
      narrativeThreads: _identifyNarrativeThreads(normalizedText),
      conflicts: conflicts,
      overallCoherence: overallCoherence,
      analyzedAt: DateTime.now(),
    );
  }

  List<String> _identifyThemes(String text) {
    final identifiedThemes = <String>[];

    for (final entry in _themeKeywords.entries) {
      final theme = entry.key;
      final keywords = entry.value;
      var count = 0;

      for (final keyword in keywords) {
        count += RegExp('\\b$keyword\\b').allMatches(text).length;
      }

      if (count >= 3) {
        identifiedThemes.add(theme);
      }
    }

    identifiedThemes.sort((a, b) {
      final aCount = _countThemeOccurrences(text, _themeKeywords[a] ?? []);
      final bCount = _countThemeOccurrences(text, _themeKeywords[b] ?? []);
      return bCount.compareTo(aCount);
    });

    return identifiedThemes;
  }

  int _countThemeOccurrences(String text, List<String> keywords) {
    var count = 0;
    for (final keyword in keywords) {
      count += RegExp('\\b$keyword\\b').allMatches(text).length;
    }
    return count;
  }

  Map<String, double> _calculateThemeWeights(String text, List<String> themes) {
    final weights = <String, double>{};
    final totalOccurrences = <int>[];

    for (final theme in themes) {
      final keywords = _themeKeywords[theme] ?? [];
      final count = _countThemeOccurrences(text, keywords);
      totalOccurrences.add(count);
    }

    final total = totalOccurrences.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return weights;

    for (final theme in themes) {
      final keywords = _themeKeywords[theme] ?? [];
      final count = _countThemeOccurrences(text, keywords);
      weights[theme] = count / total;
    }

    return weights;
  }

  List<String> _identifyMotifs(String text) {
    final motifs = <String>[];

    for (final entry in _commonMotifs.entries) {
      final motif = entry.key;
      final keywords = entry.value;
      var count = 0;

      for (final keyword in keywords) {
        count += RegExp('\\b$keyword\\b').allMatches(text).length;
      }

      if (count >= 3) {
        motifs.add(motif);
      }
    }

    return motifs;
  }

  List<String> _identifySymbols(String text) {
    final symbols = <String>[];

    for (final entry in _symbols.entries) {
      final symbol = entry.key;
      final keywords = entry.value;
      var count = 0;

      for (final keyword in keywords) {
        count += RegExp('\\b$keyword\\b').allMatches(text).length;
      }

      if (count >= 2) {
        symbols.add(symbol);
      }
    }

    return symbols;
  }

  List<String> _analyzeCharacterArcs(String text) {
    final arcs = <String>[];

    if (RegExp(
      r'\b(grow|changed?|learn|develop|become|evolve)\b',
    ).hasMatch(text)) {
      arcs.add('Character transformation arc detected');
    }

    if (RegExp(r'\b(loyal|faithful|devoted|true)\b').hasMatch(text)) {
      arcs.add('Loyalty arc detected');
    }

    if (RegExp(r'\b(fall|risk|strugle|trial|tribulation)\b').hasMatch(text)) {
      arcs.add('Hero\'s journey arc detected');
    }

    if (RegExp(r'\b(betray|trust|faith)\b').hasMatch(text)) {
      arcs.add('Trust and betrayal arc detected');
    }

    if (RegExp(r'\b(conquer|overcome|victory|win)\b').hasMatch(text)) {
      arcs.add('Triumph arc detected');
    }

    return arcs;
  }

  List<String> _identifyNarrativeThreads(String text) {
    final threads = <String>[];

    final threadPatterns = {
      'love story': [r'\b(love|heart|romance)\b'],
      'mystery': [r'\b(mystery|secret|hidden|discover|clue)\b'],
      'conflict': [r'\b(fight|battle|war|conflict|struggle)\b'],
      'journey': [r'\b(journey|travel|quest|adventure|road)\b'],
      'revelation': [r'\b(reveal|truth|discover|learn|know)\b'],
    };

    for (final entry in threadPatterns.entries) {
      final thread = entry.key;
      final patterns = entry.value;
      var count = 0;

      for (final pattern in patterns) {
        count += RegExp(pattern).allMatches(text).length;
      }

      if (count >= 3) {
        threads.add(thread);
      }
    }

    return threads;
  }

  List<ThemeConflict> _detectConflicts(List<String> themes) {
    final conflicts = <ThemeConflict>[];

    final conflictPairs = {
      ['love', 'duty']: 'Love versus responsibility creates tension',
      ['freedom', 'control']: 'Desire for freedom clashes with control',
      ['justice', 'revenge']: 'Justice and revenge present moral dilemmas',
      ['power', 'love']: 'Power corrupts love, creating conflict',
      ['death', 'life']: 'Mortality versus vitality drives the narrative',
    };

    for (final pair in conflictPairs.entries) {
      final themesInConflict = pair.key;
      final hasFirst = themes.contains(themesInConflict[0]);
      final hasSecond = themes.contains(themesInConflict[1]);

      if (hasFirst && hasSecond) {
        conflicts.add(
          ThemeConflict(
            id: _uuid.v4(),
            themes: themesInConflict,
            description: pair.value,
            resolution: '',
            isResolved: false,
          ),
        );
      }
    }

    return conflicts;
  }

  double _calculateCoherence(Map<String, double> themeWeights) {
    if (themeWeights.isEmpty) return 0.0;

    final weights = themeWeights.values.toList();
    if (weights.isEmpty) return 0.0;

    final totalWeight = weights.fold<double>(0, (sum, w) => sum + w);
    if (totalWeight == 0) return 0.0;

    final squaredWeights = weights.map(
      (w) => (w / totalWeight) * (w / totalWeight),
    );
    final sumSquared = squaredWeights.fold<double>(0, (sum, w) => sum + w);

    return sumSquared;
  }

  Future<List<ThemeElement>> getThemeElements(
    String documentId,
    String text,
  ) async {
    final elements = <ThemeElement>[];
    final normalizedText = text.toLowerCase();

    for (final entry in _commonMotifs.entries) {
      final motif = entry.key;
      final keywords = entry.value;
      var count = 0;
      final contexts = <String>[];

      for (final keyword in keywords) {
        final matches = RegExp(
          '.{0,30}$keyword.{0,30}',
        ).allMatches(normalizedText);
        count += matches.length;
        contexts.addAll(matches.take(5).map((m) => m.group(0) ?? ''));
      }

      if (count >= 2) {
        elements.add(
          ThemeElement(
            name: motif,
            type: 'motif',
            occurrences: count,
            contexts: contexts.toSet().toList(),
            significance: (count / normalizedText.split(' ').length).clamp(
              0.0,
              1.0,
            ),
          ),
        );
      }
    }

    for (final entry in _symbols.entries) {
      final symbol = entry.key;
      final keywords = entry.value;
      var count = 0;
      final contexts = <String>[];

      for (final keyword in keywords) {
        final matches = RegExp(
          '.{0,30}$keyword.{0,30}',
        ).allMatches(normalizedText);
        count += matches.length;
        contexts.addAll(matches.take(5).map((m) => m.group(0) ?? ''));
      }

      if (count >= 2) {
        elements.add(
          ThemeElement(
            name: symbol,
            type: 'symbol',
            occurrences: count,
            contexts: contexts.toSet().toList(),
            significance: (count / normalizedText.split(' ').length).clamp(
              0.0,
              1.0,
            ),
          ),
        );
      }
    }

    elements.sort((a, b) => b.significance.compareTo(a.significance));

    return elements;
  }

  Future<NarrativeStructure> analyzeNarrativeStructure(
    String documentId,
    String text,
  ) async {
    final plotPoints = _identifyPlotPoints(text);
    final actBreakdown = _calculateActBreakdown(text, plotPoints);
    final pacingScore = _calculatePacingScore(text, plotPoints);

    return NarrativeStructure(
      id: _uuid.v4(),
      structureType: _determineStructureType(plotPoints),
      plotPoints: plotPoints,
      actBreakdown: actBreakdown,
      pacingScore: pacingScore,
    );
  }

  List<PlotPoint> _identifyPlotPoints(String text) {
    final plotPoints = <PlotPoint>[];
    final sentences = text.split(RegExp(r'[.!?]+'));
    final totalSentences = sentences.length;

    if (totalSentences < 5) return plotPoints;

    final midpoint = totalSentences ~/ 2;
    final climaxIndex = (totalSentences * 0.8).round();

    if (totalSentences > 10) {
      plotPoints.add(
        PlotPoint(
          name: 'Setup',
          description: sentences.first.trim(),
          position: 1,
          act: 'Act 1',
        ),
      );

      plotPoints.add(
        PlotPoint(
          name: 'Inciting Incident',
          description: sentences[(totalSentences * 0.1).round()].trim(),
          position: (totalSentences * 0.1).round(),
          act: 'Act 1',
        ),
      );

      plotPoints.add(
        PlotPoint(
          name: 'Rising Action',
          description: sentences[midpoint].trim(),
          position: midpoint,
          act: 'Act 2',
        ),
      );

      plotPoints.add(
        PlotPoint(
          name: 'Midpoint',
          description: sentences[(midpoint + 2).clamp(0, totalSentences - 1)]
              .trim(),
          position: midpoint + 2,
          act: 'Act 2',
        ),
      );

      plotPoints.add(
        PlotPoint(
          name: 'Climax',
          description: sentences[climaxIndex.clamp(0, totalSentences - 1)]
              .trim(),
          position: climaxIndex,
          act: 'Act 3',
        ),
      );

      plotPoints.add(
        PlotPoint(
          name: 'Falling Action',
          description: sentences[(climaxIndex + 2).clamp(0, totalSentences - 1)]
              .trim(),
          position: climaxIndex + 2,
          act: 'Act 3',
        ),
      );

      if (sentences.length > 1) {
        plotPoints.add(
          PlotPoint(
            name: 'Resolution',
            description: sentences.last.trim(),
            position: totalSentences,
            act: 'Act 3',
          ),
        );
      }
    }

    return plotPoints;
  }

  Map<String, int> _calculateActBreakdown(
    String text,
    List<PlotPoint> plotPoints,
  ) {
    if (plotPoints.isEmpty) {
      return {'Act 1': 33, 'Act 2': 34, 'Act 3': 33};
    }

    final actCounts = <String, int>{'Act 1': 0, 'Act 2': 0, 'Act 3': 0};

    for (final point in plotPoints) {
      actCounts[point.act] = (actCounts[point.act] ?? 0) + 1;
    }

    final total = actCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return actCounts;

    return actCounts.map(
      (key, value) => MapEntry(key, ((value / total) * 100).round()),
    );
  }

  double _calculatePacingScore(String text, List<PlotPoint> plotPoints) {
    if (plotPoints.isEmpty) return 0.5;

    final sentences = text.split(RegExp(r'[.!?]+'));
    final totalSentences = sentences.length;
    final totalPlotPoints = plotPoints.length;

    if (totalSentences == 0) return 0.0;

    final distribution = totalPlotPoints / totalSentences;

    if (distribution < 0.1) return 0.9;
    if (distribution > 0.3) return 0.5;

    return 0.7;
  }

  String _determineStructureType(List<PlotPoint> plotPoints) {
    if (plotPoints.isEmpty) return 'Unknown';

    final acts = plotPoints.map((p) => p.act).toSet();

    if (acts.contains('Act 1') &&
        acts.contains('Act 2') &&
        acts.contains('Act 3')) {
      return 'Three Act Structure';
    }

    if (plotPoints.length >= 5) {
      return 'Hero\'s Journey';
    }

    return 'Linear Narrative';
  }

  Future<ThemeAnalysis> updateAnalysis(
    String analysisId,
    ThemeAnalysis currentAnalysis,
    String newText,
  ) async {
    return analyzeThemes(currentAnalysis.documentId, newText);
  }

  Future<void> saveAnalysis(ThemeAnalysis analysis) async {
    // print('Saving theme analysis for document: ${analysis.documentId}');
  }

  Future<ThemeAnalysis?> loadAnalysis(String documentId) async {
    // print('Loading theme analysis for document: $documentId');
    return null;
  }
}
