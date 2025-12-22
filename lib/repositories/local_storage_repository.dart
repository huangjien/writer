import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter_cache.dart';
import '../models/novel.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/template.dart';
import '../models/character_note.dart';
import '../models/scene_note.dart';
import '../models/character_template_row.dart';
import '../models/scene_template_row.dart';

class LocalStorageRepository {
  final Future<SharedPreferences> Function() _prefs;
  final DateTime Function() _now;

  LocalStorageRepository({
    Future<SharedPreferences> Function()? prefs,
    DateTime Function()? now,
  }) : _prefs = prefs ?? SharedPreferences.getInstance,
       _now = now ?? DateTime.now;

  Future<void> saveChapter(ChapterCache chapter) async {
    final prefs = await _prefs();
    await prefs.setString(chapter.chapterId, jsonEncode(chapter.toJson()));
  }

  Future<ChapterCache?> getChapter(String chapterId) async {
    final prefs = await _prefs();
    final chapterJson = prefs.getString(chapterId);
    if (chapterJson != null) {
      return ChapterCache.fromJson(jsonDecode(chapterJson));
    }
    return null;
  }

  Future<void> saveChapters(List<ChapterCache> chapters) async {
    final prefs = await _prefs();
    for (final chapter in chapters) {
      await prefs.setString(chapter.chapterId, jsonEncode(chapter.toJson()));
    }
  }

  Future<void> removeChapter(String chapterId) async {
    final prefs = await _prefs();
    await prefs.remove(chapterId);
  }

  Future<int> clearChapterCache() async {
    final prefs = await _prefs();
    final keys = prefs.getKeys();
    int removed = 0;
    for (final key in keys) {
      final value = prefs.getString(key);
      if (value == null) continue;
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          final hasShape =
              decoded.containsKey('chapterId') &&
              decoded.containsKey('novelId') &&
              decoded.containsKey('idx') &&
              decoded.containsKey('content') &&
              decoded.containsKey('lastUpdated');
          if (hasShape) {
            await prefs.remove(key);
            removed++;
          }
        }
      } catch (_) {}
    }
    return removed;
  }

  Future<void> saveLibraryNovels(List<Novel> novels) async {
    final prefs = await _prefs();
    final list = novels
        .map(
          (n) => {
            'id': n.id,
            'title': n.title,
            'author': n.author,
            'description': n.description,
            'cover_url': n.coverUrl,
            'language_code': n.languageCode,
            'is_public': n.isPublic,
          },
        )
        .toList();
    await prefs.setString('library_novels_cache', jsonEncode(list));
  }

  Future<List<Novel>> getLibraryNovels() async {
    final prefs = await _prefs();
    final raw = prefs.getString('library_novels_cache');
    if (raw == null) return <Novel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>().map(Novel.fromMap).toList();
      }
    } catch (_) {}
    return <Novel>[];
  }

  Future<void> saveSummaryText(String novelId, String text) async {
    final prefs = await _prefs();
    await prefs.setString('summary_text_$novelId', text);
  }

  Future<String?> getSummaryText(String novelId) async {
    final prefs = await _prefs();
    return prefs.getString('summary_text_$novelId');
  }

  Future<void> saveCharacterForm(
    String novelId,
    Character character, {
    int? idx,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(
      'character_form_$novelId',
      jsonEncode(character.toMap()),
    );
  }

  Future<Character?> getCharacterForm(String novelId, {int? idx}) async {
    final prefs = await _prefs();
    final raw = prefs.getString('character_form_$novelId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return Character.fromMap(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {
    final prefs = await _prefs();
    final payload = {
      'title': title,
      'character_summaries': summaries,
      'character_synopses': synopses,
      'language_code': languageCode,
    };
    await prefs.setString('character_note_form_$novelId', jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    final prefs = await _prefs();
    final raw = prefs.getString('character_note_form_$novelId');
    if (raw != null) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    final prefs = await _prefs();
    await prefs.setString('scene_form_$novelId', jsonEncode(scene.toMap()));
  }

  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    final prefs = await _prefs();
    final raw = prefs.getString('scene_form_$novelId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return Scene.fromMap(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    final prefs = await _prefs();
    await prefs.setString(
      'character_template_form_$novelId',
      jsonEncode(item.toMap()),
    );
  }

  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async {
    final prefs = await _prefs();
    final raw = prefs.getString('character_template_form_$novelId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return TemplateItem.fromMap(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {
    final prefs = await _prefs();
    await prefs.setString(
      'scene_template_form_$novelId',
      jsonEncode(item.toMap()),
    );
  }

  Future<TemplateItem?> getSceneTemplateForm(String novelId) async {
    final prefs = await _prefs();
    final raw = prefs.getString('scene_template_form_$novelId');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return TemplateItem.fromMap(decoded);
      } catch (_) {}
    }
    return null;
  }

  // List methods used to return Sync+Local. Now they only return local default if implemented, or empty?
  // The implementations below were previously mixed.
  // Ideally, these list methods should be removed from here and moved to NotesRepository entirely,
  // but to preserve existing contract for non-sync usage (if any), I'll keep them returning empty or local defaults.
  // Actually, listCharacterNotes returned [local] if offline.

  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    final cached = await getCharacterNoteForm(novelId);
    if (cached == null) return <CharacterNote>[];
    final now = _now();
    return [
      CharacterNote(
        id: 'local-$novelId-1',
        novelId: novelId,
        idx: 1,
        title: cached['title'] as String?,
        characterSummaries: cached['character_summaries'] as String?,
        characterSynopses: cached['character_synopses'] as String?,
        languageCode: (cached['language_code'] as String?) ?? 'en',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<int> nextCharacterIdx(String novelId) async {
    return 2; // Default
  }

  Future<void> deleteCharacterNoteById(String id) async {
    // Local delete not supported/needed by ID.
  }

  Future<void> deleteCharacterNoteByIdx(String novelId, int idx) async {
    final prefs = await _prefs();
    await prefs.remove('character_note_form_$novelId');
  }

  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    final cached = await getSceneForm(novelId);
    if (cached == null) return <SceneNote>[];
    final now = _now();
    return [
      SceneNote(
        id: 'local-$novelId-1',
        novelId: novelId,
        idx: 1,
        title: cached.title,
        sceneSummaries: cached.summary,
        sceneSynopses: cached.location,
        languageCode: 'en',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<int> nextSceneIdx(String novelId) async {
    return 2;
  }

  Future<void> deleteSceneNoteById(String id) async {}

  Future<void> deleteSceneNoteByIdx(String novelId, int idx) async {
    final prefs = await _prefs();
    await prefs.remove('scene_form_$novelId');
  }

  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    return <CharacterTemplateRow>[];
  }

  Future<void> deleteCharacterTemplate(String id) async {}

  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async {
    return null;
  }

  Future<void> updateCharacterTemplate(
    String id, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
  }) async {}

  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    return <SceneTemplateRow>[];
  }

  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    return <SceneTemplateRow>[];
  }

  Future<List<CharacterTemplateRow>> searchCharacterTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    return <CharacterTemplateRow>[];
  }

  Future<void> refreshSceneTemplateEmbedding(String templateId) async {}

  Future<void> refreshCharacterTemplateEmbedding(String templateId) async {}

  Future<void> deleteSceneTemplate(String id) async {}

  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    return null;
  }

  Future<void> updateSceneTemplate(
    String id, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
  }) async {}
}
