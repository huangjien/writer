import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import '../models/character_note.dart';
import '../models/scene_note.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final remote = ref.watch(remoteRepositoryProvider);
  return NotesRepository(remote);
});

class NotesRepository {
  final RemoteRepository _remote;

  NotesRepository(this._remote);

  // Characters

  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    try {
      final res = await _remote.get(
        'notes/characters',
        queryParameters: {'novel_id': novelId},
      );
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(CharacterNote.fromRow)
            .toList();
      }
      if (res is Map && res.containsKey('items') && res['items'] is List) {
        return (res['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(CharacterNote.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertCharacterNote({
    required String novelId,
    required int idx,
    String? title,
    String? summaries, // Maps to character_summaries
    String? synopses, // Maps to character_synopses
    String? languageCode,
  }) async {
    final body = {
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'character_summaries': summaries,
      'character_synopses': synopses,
      'language_code': languageCode ?? 'en',
    };
    await _remote.post('notes/characters', body);
  }

  Future<void> deleteCharacterNoteById(String id) async {
    await _remote.delete('notes/characters/$id');
  }

  Future<void> deleteCharacterNoteByIdx(String novelId, int idx) async {
    await _remote.delete(
      'notes/characters',
      queryParameters: {'novel_id': novelId, 'idx': idx.toString()},
    );
  }

  // Scenes

  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    try {
      final res = await _remote.get(
        'notes/scenes',
        queryParameters: {'novel_id': novelId},
      );
      if (res is List) {
        return res.cast<Map<String, dynamic>>().map(SceneNote.fromRow).toList();
      }
      if (res is Map && res.containsKey('items') && res['items'] is List) {
        return (res['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(SceneNote.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertSceneNote({
    required String novelId,
    required int idx,
    String? title,
    String? summaries, // Maps to scene_summaries
    String? synopses, // Maps to scene_synopses
    String? languageCode,
  }) async {
    final body = {
      'novel_id': novelId,
      'idx': idx,
      'title': title,
      'scene_summaries': summaries,
      'scene_synopses': synopses,
      'language_code': languageCode ?? 'en',
    };
    await _remote.post('notes/scenes', body);
  }

  Future<void> deleteSceneNoteById(String id) async {
    await _remote.delete('notes/scenes/$id');
  }

  Future<void> deleteSceneNoteByIdx(String novelId, int idx) async {
    await _remote.delete(
      'notes/scenes',
      queryParameters: {'novel_id': novelId, 'idx': idx.toString()},
    );
  }
}
