import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/scene_template_row.dart';
import 'package:writer/models/scene_note.dart';

void main() {
  group('Models Serialization', () {
    test('CharacterTemplateRow to/from row', () {
      final now = DateTime.now().toUtc();
      // Truncate to microseconds to match string serialization precision usually
      // ISO8601 string preserves microseconds.

      final original = CharacterTemplateRow(
        id: 'id-1',
        idx: 1,
        title: 'Title',
        characterSummaries: 'Summary',
        characterSynopses: 'Synopsis',
        languageCode: 'en',
        createdBy: 'user-1',
        createdAt: now,
        updatedAt: now,
      );

      final row = original.toRow();
      expect(row['id'], 'id-1');
      expect(row['idx'], 1);
      expect(row['title'], 'Title');
      expect(row['character_summaries'], 'Summary');
      expect(row['character_synopses'], 'Synopsis');
      expect(row['language_code'], 'en');
      expect(row['created_by'], 'user-1');
      expect(row['created_at'], now.toIso8601String());

      final restored = CharacterTemplateRow.fromRow(row);
      expect(restored.id, original.id);
      expect(restored.idx, original.idx);
      expect(restored.title, original.title);
      expect(restored.characterSummaries, original.characterSummaries);
      expect(restored.characterSynopses, original.characterSynopses);
      expect(restored.languageCode, original.languageCode);
      expect(restored.createdBy, original.createdBy);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('SceneTemplateRow to/from row', () {
      final now = DateTime.now().toUtc();
      final original = SceneTemplateRow(
        id: 'st-1',
        idx: 2,
        title: 'Scene T',
        sceneSummaries: 'Scene Sum',
        sceneSynopses: 'Scene Syn',
        languageCode: 'zh',
        createdBy: 'user-2',
        createdAt: now,
        updatedAt: now,
      );

      final row = original.toRow();
      expect(row['id'], 'st-1');
      expect(row['idx'], 2);
      expect(row['title'], 'Scene T');
      expect(row['scene_summaries'], 'Scene Sum');
      expect(row['scene_synopses'], 'Scene Syn');
      expect(row['language_code'], 'zh');
      expect(row['created_by'], 'user-2');

      final restored = SceneTemplateRow.fromRow(row);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.sceneSummaries, original.sceneSummaries);
      expect(restored.languageCode, original.languageCode);
    });

    test('SceneNote to/from row', () {
      final now = DateTime.now().toUtc();
      final original = SceneNote(
        id: 'sn-1',
        novelId: 'nid-1',
        idx: 3,
        title: 'Note T',
        sceneSummaries: 'Note Sum',
        sceneSynopses: 'Note Syn',
        languageCode: 'fr',
        createdAt: now,
        updatedAt: now,
      );

      final row = original.toRow();
      expect(row['id'], 'sn-1');
      expect(row['novel_id'], 'nid-1');
      expect(row['idx'], 3);
      expect(row['title'], 'Note T');
      expect(row['scene_summaries'], 'Note Sum');
      expect(row['scene_synopses'], 'Note Syn');
      expect(row['language_code'], 'fr');

      final restored = SceneNote.fromRow(row);
      expect(restored.id, original.id);
      expect(restored.novelId, original.novelId);
      expect(restored.title, original.title);
      expect(restored.sceneSummaries, original.sceneSummaries);
      expect(restored.languageCode, original.languageCode);
    });

    test('CharacterTemplateRow nullable fields', () {
      final now = DateTime.now();
      final original = CharacterTemplateRow(
        id: 'id-2',
        idx: 0,
        createdAt: now,
        updatedAt: now,
      );
      final row = original.toRow();
      expect(row['title'], null);
      expect(row['character_summaries'], null);

      final restored = CharacterTemplateRow.fromRow(row);
      expect(restored.title, null);
      expect(restored.languageCode, 'en'); // default
    });
  });
}
