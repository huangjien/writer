import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/theme_analysis.dart';

void main() {
  group('ThemeAnalysis', () {
    late ThemeAnalysis analysis;
    late ThemeConflict conflict;

    setUp(() {
      conflict = ThemeConflict(
        id: 'conflict1',
        themes: ['love', 'duty'],
        description: 'Romeo must choose between love and family duty',
        resolution: 'Tragic death resolves both',
        isResolved: true,
      );

      analysis = ThemeAnalysis(
        id: 'analysis1',
        documentId: 'doc1',
        themes: ['love', 'death', 'redemption'],
        themeWeights: {'love': 0.6, 'death': 0.3, 'redemption': 0.1},
        motifs: ['light', 'darkness', 'stars'],
        symbols: ['rose', 'dagger', 'poison'],
        characterArcs: [
          'Romeo: innocent to tragic',
          'Juliet: oppressed to liberated',
        ],
        narrativeThreads: ['forbidden love', 'family feud'],
        conflicts: [conflict],
        overallCoherence: 0.85,
        analyzedAt: DateTime(2026, 3, 29),
      );
    });

    test('should create instance with all fields', () {
      expect(analysis.id, 'analysis1');
      expect(analysis.documentId, 'doc1');
      expect(analysis.themes, ['love', 'death', 'redemption']);
      expect(analysis.overallCoherence, 0.85);
      expect(analysis.motifs.length, 3);
      expect(analysis.symbols.length, 3);
    });

    test('should return primary theme', () {
      expect(analysis.primaryTheme, 'love');
    });

    test('should return primary theme as empty string for no themes', () {
      final emptyAnalysis = ThemeAnalysis(
        id: 'analysis2',
        documentId: 'doc2',
        themes: [],
        themeWeights: {},
        motifs: [],
        symbols: [],
        characterArcs: [],
        narrativeThreads: [],
        conflicts: [],
        overallCoherence: 0.0,
        analyzedAt: DateTime.now(),
      );

      expect(emptyAnalysis.primaryTheme, '');
    });

    test('should get coherence for theme', () {
      expect(analysis.getCoherenceForTheme('love'), 0.6);
      expect(analysis.getCoherenceForTheme('death'), 0.3);
      expect(analysis.getCoherenceForTheme('nonexistent'), 0.0);
    });

    test('should get conflicts for theme', () {
      final loveConflicts = analysis.getConflictsForTheme('love');
      expect(loveConflicts.length, 1);
      expect(loveConflicts.first.themes, contains('love'));
    });

    test('should get conflicts for theme with no matches', () {
      final redemptionConflicts = analysis.getConflictsForTheme('redemption');
      expect(redemptionConflicts, isEmpty);
    });

    test('should determine coherence', () {
      expect(analysis.isCoherent, true);

      final incoherentAnalysis = analysis.copyWith(overallCoherence: 0.5);
      expect(incoherentAnalysis.isCoherent, false);
    });

    test('should copy with new values', () {
      final updated = analysis.copyWith(
        themes: ['power', 'corruption'],
        overallCoherence: 0.9,
      );

      expect(updated.themes, ['power', 'corruption']);
      expect(updated.overallCoherence, 0.9);
      expect(updated.id, 'analysis1');
      expect(updated.documentId, 'doc1');
    });

    test('should serialize to map', () {
      final map = analysis.toMap();

      expect(map['id'], 'analysis1');
      expect(map['document_id'], 'doc1');
      expect(map['themes'], ['love', 'death', 'redemption']);
      expect(map['theme_weights'], {
        'love': 0.6,
        'death': 0.3,
        'redemption': 0.1,
      });
      expect(map['overall_coherence'], 0.85);
      expect(map['conflicts'], isA<List>());
    });

    test('should deserialize from map', () {
      final map = {
        'id': 'analysis1',
        'document_id': 'doc1',
        'themes': ['love', 'death'],
        'theme_weights': {'love': 0.7, 'death': 0.3},
        'motifs': ['fire', 'water'],
        'symbols': ['heart', 'sword'],
        'character_arcs': ['Hero: transformation'],
        'narrative_threads': ['quest'],
        'conflicts': [
          {
            'id': 'conflict1',
            'themes': ['love', 'death'],
            'description': 'Test conflict',
            'resolution': 'Resolution',
            'is_resolved': true,
          },
        ],
        'overall_coherence': 0.75,
        'analyzed_at': '2026-03-29T00:00:00.000Z',
      };

      final fromMap = ThemeAnalysis.fromMap(map);

      expect(fromMap.id, 'analysis1');
      expect(fromMap.themes, ['love', 'death']);
      expect(fromMap.overallCoherence, 0.75);
      expect(fromMap.conflicts.length, 1);
      expect(fromMap.conflicts.first.description, 'Test conflict');
    });

    test('should handle empty lists in serialization', () {
      final emptyAnalysis = ThemeAnalysis(
        id: 'analysis2',
        documentId: 'doc2',
        themes: [],
        themeWeights: {},
        motifs: [],
        symbols: [],
        characterArcs: [],
        narrativeThreads: [],
        conflicts: [],
        overallCoherence: 0.0,
        analyzedAt: DateTime(2026, 3, 29),
      );

      final map = emptyAnalysis.toMap();
      final fromMap = ThemeAnalysis.fromMap(map);

      expect(fromMap.themes, isEmpty);
      expect(fromMap.motifs, isEmpty);
      expect(fromMap.conflicts, isEmpty);
    });

    test('should handle null values in deserialization', () {
      final map = {'id': 'analysis1', 'document_id': 'doc1'};

      final fromMap = ThemeAnalysis.fromMap(map);

      expect(fromMap.themes, isEmpty);
      expect(fromMap.overallCoherence, 0.0);
      expect(fromMap.conflicts, isEmpty);
    });
  });

  group('ThemeConflict', () {
    test('should create instance with all fields', () {
      final conflict = ThemeConflict(
        id: 'conflict1',
        themes: ['good', 'evil'],
        description: 'The eternal struggle',
        resolution: 'Good prevails',
        isResolved: true,
      );

      expect(conflict.id, 'conflict1');
      expect(conflict.themes, ['good', 'evil']);
      expect(conflict.description, 'The eternal struggle');
      expect(conflict.resolution, 'Good prevails');
      expect(conflict.isResolved, true);
    });

    test('should copy with new values', () {
      final conflict = ThemeConflict(
        id: 'conflict1',
        themes: ['love'],
        description: 'Test conflict',
        resolution: '',
        isResolved: false,
      );

      final updated = conflict.copyWith(
        description: 'Updated conflict',
        isResolved: true,
      );

      expect(updated.id, 'conflict1');
      expect(updated.description, 'Updated conflict');
      expect(updated.isResolved, true);
    });

    test('should serialize to map', () {
      final conflict = ThemeConflict(
        id: 'conflict1',
        themes: ['power', 'corruption'],
        description: 'Power corrupts',
        resolution: 'Power is renounced',
        isResolved: false,
      );

      final map = conflict.toMap();

      expect(map['id'], 'conflict1');
      expect(map['themes'], ['power', 'corruption']);
      expect(map['description'], 'Power corrupts');
      expect(map['is_resolved'], false);
    });

    test('should deserialize from map', () {
      final map = {
        'id': 'conflict1',
        'themes': ['fate', 'free_will'],
        'description': 'Destiny vs choice',
        'resolution': 'Both coexist',
        'is_resolved': true,
      };

      final conflict = ThemeConflict.fromMap(map);

      expect(conflict.id, 'conflict1');
      expect(conflict.themes, ['fate', 'free_will']);
      expect(conflict.description, 'Destiny vs choice');
      expect(conflict.isResolved, true);
    });

    test('should handle missing optional fields in deserialization', () {
      final map = {
        'id': 'conflict1',
        'themes': ['test'],
        'description': 'Test',
      };

      final conflict = ThemeConflict.fromMap(map);

      expect(conflict.resolution, '');
      expect(conflict.isResolved, false);
    });
  });

  group('ThemeElement', () {
    test('should create instance with all fields', () {
      final element = ThemeElement(
        name: 'Water',
        type: 'motif',
        occurrences: 15,
        contexts: ['rain scene', 'river crossing'],
        significance: 0.8,
      );

      expect(element.name, 'Water');
      expect(element.type, 'motif');
      expect(element.occurrences, 15);
      expect(element.contexts.length, 2);
      expect(element.significance, 0.8);
    });

    test('should serialize to map', () {
      final element = ThemeElement(
        name: 'Fire',
        type: 'symbol',
        occurrences: 10,
        contexts: ['passion', 'destruction'],
        significance: 0.9,
      );

      final map = element.toMap();

      expect(map['name'], 'Fire');
      expect(map['type'], 'symbol');
      expect(map['occurrences'], 10);
      expect(map['contexts'], ['passion', 'destruction']);
    });

    test('should deserialize from map', () {
      final map = {
        'name': 'Light',
        'type': 'motif',
        'occurrences': 20,
        'contexts': ['hope', 'truth'],
        'significance': 0.85,
      };

      final element = ThemeElement.fromMap(map);

      expect(element.name, 'Light');
      expect(element.type, 'motif');
      expect(element.occurrences, 20);
      expect(element.contexts, ['hope', 'truth']);
    });
  });

  group('NarrativeStructure', () {
    late NarrativeStructure structure;
    late PlotPoint plotPoint;

    setUp(() {
      plotPoint = PlotPoint(
        name: 'Inciting Incident',
        description: 'Hero receives call to adventure',
        position: 1,
        act: 'Act 1',
      );

      structure = NarrativeStructure(
        id: 'structure1',
        structureType: 'Three Act',
        plotPoints: [plotPoint],
        actBreakdown: {'Act 1': 25, 'Act 2': 50, 'Act 3': 25},
        pacingScore: 0.8,
      );
    });

    test('should create instance with all fields', () {
      expect(structure.id, 'structure1');
      expect(structure.structureType, 'Three Act');
      expect(structure.plotPoints.length, 1);
      expect(structure.actBreakdown['Act 1'], 25);
      expect(structure.pacingScore, 0.8);
    });

    test('should copy with new values', () {
      final updated = structure.copyWith(
        structureType: 'Five Act',
        pacingScore: 0.9,
      );

      expect(updated.structureType, 'Five Act');
      expect(updated.pacingScore, 0.9);
      expect(updated.id, 'structure1');
    });

    test('should serialize to map', () {
      final map = structure.toMap();

      expect(map['id'], 'structure1');
      expect(map['structure_type'], 'Three Act');
      expect(map['plot_points'], isA<List>());
      expect(map['act_breakdown'], {'Act 1': 25, 'Act 2': 50, 'Act 3': 25});
      expect(map['pacing_score'], 0.8);
    });

    test('should deserialize from map', () {
      final map = {
        'id': 'structure1',
        'structure_type': 'Hero\'s Journey',
        'plot_points': [
          {
            'name': 'Climax',
            'description': 'Final battle',
            'position': 17,
            'act': 'Act 3',
          },
        ],
        'act_breakdown': {'Setup': 25, 'Confrontation': 50, 'Resolution': 25},
        'pacing_score': 0.85,
      };

      final fromMap = NarrativeStructure.fromMap(map);

      expect(fromMap.id, 'structure1');
      expect(fromMap.structureType, 'Hero\'s Journey');
      expect(fromMap.plotPoints.length, 1);
      expect(fromMap.plotPoints.first.name, 'Climax');
      expect(fromMap.pacingScore, 0.85);
    });

    test('should handle empty plot points', () {
      final emptyStructure = NarrativeStructure(
        id: 'structure2',
        structureType: 'Linear',
        plotPoints: [],
        actBreakdown: {},
        pacingScore: 0.0,
      );

      expect(emptyStructure.plotPoints, isEmpty);
      expect(emptyStructure.actBreakdown, isEmpty);
    });
  });

  group('PlotPoint', () {
    test('should create instance with all fields', () {
      final plotPoint = PlotPoint(
        name: 'Midpoint',
        description: 'Hero faces major setback',
        position: 10,
        act: 'Act 2',
      );

      expect(plotPoint.name, 'Midpoint');
      expect(plotPoint.description, 'Hero faces major setback');
      expect(plotPoint.position, 10);
      expect(plotPoint.act, 'Act 2');
    });

    test('should copy with new values', () {
      final plotPoint = PlotPoint(
        name: 'Setup',
        description: 'Initial scene',
        position: 1,
        act: 'Act 1',
      );

      final updated = plotPoint.copyWith(name: 'Resolution', position: 20);

      expect(updated.name, 'Resolution');
      expect(updated.position, 20);
      expect(updated.act, 'Act 1');
    });

    test('should serialize to map', () {
      final plotPoint = PlotPoint(
        name: 'Crisis',
        description: 'All seems lost',
        position: 15,
        act: 'Act 3',
      );

      final map = plotPoint.toMap();

      expect(map['name'], 'Crisis');
      expect(map['description'], 'All seems lost');
      expect(map['position'], 15);
      expect(map['act'], 'Act 3');
    });

    test('should deserialize from map', () {
      final map = {
        'name': 'Climax',
        'description': 'Final confrontation',
        'position': 18,
        'act': 'Act 3',
      };

      final plotPoint = PlotPoint.fromMap(map);

      expect(plotPoint.name, 'Climax');
      expect(plotPoint.description, 'Final confrontation');
      expect(plotPoint.position, 18);
      expect(plotPoint.act, 'Act 3');
    });
  });
}
