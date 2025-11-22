import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/models/character_note.dart';

void main() {
  test('CharacterNote.fromRow maps supabase row', () {
    final now = DateTime.parse('2025-01-01T00:00:00Z');
    final row = {
      'id': 'uuid-1',
      'novel_id': 'novel-1',
      'idx': 2,
      'title': 'Alice',
      'character_summaries': 'Short bio',
      'character_synopses': 'Longer synopsis',
      'language_code': 'en',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    final note = CharacterNote.fromRow(row);
    expect(note.id, 'uuid-1');
    expect(note.novelId, 'novel-1');
    expect(note.idx, 2);
    expect(note.title, 'Alice');
    expect(note.characterSummaries, 'Short bio');
    expect(note.characterSynopses, 'Longer synopsis');
    expect(note.languageCode, 'en');
    expect(note.createdAt.toIso8601String(), now.toIso8601String());
    expect(note.updatedAt.toIso8601String(), now.toIso8601String());
  });

  test('CharacterNote.toRow emits supabase keys', () {
    final now = DateTime.parse('2025-01-01T00:00:00Z');
    final note = CharacterNote(
      id: 'uuid-2',
      novelId: 'novel-2',
      idx: 5,
      title: null,
      characterSummaries: null,
      characterSynopses: null,
      languageCode: 'en',
      createdAt: now,
      updatedAt: now,
    );
    final row = note.toRow();
    expect(row['id'], 'uuid-2');
    expect(row['novel_id'], 'novel-2');
    expect(row['idx'], 5);
    expect(row['title'], null);
    expect(row['character_summaries'], null);
    expect(row['character_synopses'], null);
    expect(row['language_code'], 'en');
    expect(row['created_at'], now.toIso8601String());
    expect(row['updated_at'], now.toIso8601String());
  });
}
