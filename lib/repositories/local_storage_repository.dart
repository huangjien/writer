import 'dart:convert';
import '../services/storage_service.dart';
import '../models/chapter_cache.dart';
import '../models/novel.dart';
import '../models/character.dart';
import '../models/character_note.dart';
import '../models/scene.dart';
import '../models/scene_note.dart';
import '../models/template.dart';
import '../models/character_template_row.dart';
import '../models/scene_template_row.dart';

/// Repository for local storage operations
///
/// This repository uses the StorageService abstraction for better testability.
class LocalStorageRepository {
  final StorageService _storage;

  LocalStorageRepository(this._storage);

  /// Save a chapter to cache
  Future<void> saveChapter(ChapterCache chapter) async {
    await _storage.setString(
      'chapter_${chapter.chapterId}',
      jsonEncode(chapter.toJson()),
    );
  }

  /// Get a chapter from cache
  Future<ChapterCache?> getChapter(String chapterId) async {
    final json = _storage.getString('chapter_$chapterId');
    if (json == null) return null;
    try {
      return ChapterCache.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  /// Save multiple chapters to cache
  Future<void> saveChapters(List<ChapterCache> chapters) async {
    for (final chapter in chapters) {
      await saveChapter(chapter);
    }
  }

  /// Remove a chapter from cache
  Future<void> removeChapter(String chapterId) async {
    await _storage.remove('chapter_$chapterId');
  }

  /// Clear all chapter cache entries
  Future<int> clearChapterCache() async {
    final keys = _storage.getKeys();
    int removed = 0;
    for (final key in keys) {
      if (key.startsWith('chapter_')) {
        await _storage.remove(key);
        removed++;
      }
    }
    return removed;
  }

  /// Save library novels to cache
  Future<void> saveLibraryNovels(List<Novel> novels) async {
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
    await _storage.setString('library_novels_cache', jsonEncode(list));
  }

  /// Get library novels from cache
  Future<List<Novel>> getLibraryNovels() async {
    final json = _storage.getString('library_novels_cache');
    if (json == null) return <Novel>[];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>().map(Novel.fromMap).toList();
      }
    } catch (_) {
      return <Novel>[];
    }
    return <Novel>[];
  }

  /// Save summary text
  Future<void> saveSummaryText(String novelId, String text) async {
    await _storage.setString('summary_text_$novelId', text);
  }

  /// Get summary text
  Future<String?> getSummaryText(String novelId) async {
    return _storage.getString('summary_text_$novelId');
  }

  /// Save character form
  Future<void> saveCharacterForm(
    String novelId,
    Character character, {
    int? idx,
  }) async {
    final payload = character.toMap();
    await _storage.setString('character_form_$novelId', jsonEncode(payload));
  }

  /// Get character form
  Future<Character?> getCharacterForm(String novelId, {int? idx}) async {
    final json = _storage.getString('character_form_$novelId');
    if (json == null) return null;
    try {
      return Character.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Save character note form
  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {
    final payload = {
      'title': title,
      'character_summaries': summaries,
      'character_synopses': synopses,
      'language_code': languageCode,
      'idx': idx,
    };
    await _storage.setString(
      'character_note_form_$novelId',
      jsonEncode(payload),
    );
  }

  /// Get character note form
  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    final json = _storage.getString('character_note_form_$novelId');
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Save scene form
  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    final payload = {
      'novel_id': novelId,
      'title': scene.title,
      'summary': scene.summary,
      'location': scene.location,
      'language_code': 'en',
      'idx': idx,
    };
    await _storage.setString('scene_form_$novelId', jsonEncode(payload));
  }

  /// Get scene form
  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    final json = _storage.getString('scene_form_$novelId');
    if (json == null) return null;
    try {
      return Scene.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Save character template form
  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    await _storage.setString(
      'character_template_form_$novelId',
      jsonEncode(item.toMap()),
    );
  }

  /// Get character template form
  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async {
    final json = _storage.getString('character_template_form_$novelId');
    if (json == null) return null;
    try {
      return TemplateItem.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Save scene template form
  Future<void> saveSceneTemplateForm(
    String novelId,
    TemplateItem item, {
    String languageCode = 'en',
  }) async {
    final payload = {...item.toMap(), 'language_code': languageCode};
    await _storage.setString(
      'scene_template_form_$novelId',
      jsonEncode(payload),
    );
  }

  /// Get scene template form
  Future<TemplateItem?> getSceneTemplateForm(String novelId) async {
    final json = _storage.getString('scene_template_form_$novelId');
    if (json == null) return null;
    try {
      return TemplateItem.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Delete character form
  Future<void> deleteCharacterForm(String novelId) async {
    await _storage.remove('character_form_$novelId');
  }

  /// Delete character note form
  Future<void> deleteCharacterNoteForm(String novelId) async {
    await _storage.remove('character_note_form_$novelId');
  }

  /// Delete scene form
  Future<void> deleteSceneForm(String novelId) async {
    await _storage.remove('scene_form_$novelId');
  }

  /// Delete character template
  Future<void> deleteCharacterTemplate(String id) async {
    await _storage.remove('character_template_form_$id');
  }

  /// Delete scene template
  Future<void> deleteSceneTemplate(String id) async {
    await _storage.remove('scene_template_form_$id');
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    return _storage.getKeys();
  }

  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    final json = _storage.getString('character_note_form_$novelId');
    if (json == null) return [];
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return [
        CharacterNote(
          id: 'temp',
          novelId: novelId,
          idx: map['idx'] ?? 0,
          title: map['title'],
          characterSummaries: map['character_summaries'],
          characterSynopses: map['character_synopses'],
          languageCode: map['language_code'] ?? 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    final json = _storage.getString('scene_form_$novelId');
    if (json == null) return [];
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return [
        SceneNote(
          id: 'temp',
          novelId: novelId,
          idx: map['idx'] ?? 0,
          title: map['title'],
          sceneSummaries: map['summary'],
          languageCode: map['language_code'] ?? 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<List<CharacterTemplateRow>> listCharacterTemplates() async => [];
  Future<List<SceneTemplateRow>> listSceneTemplates({int? limit}) async => [];
  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int? limit,
    String? languageCode,
  }) async => [];
  Future<int> nextCharacterIdx(String novelId) async => 2;
  Future<int> nextSceneIdx(String novelId) async => 2;
  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async =>
      null;
  Future<SceneTemplateRow?> getSceneTemplateById(String id) async => null;
}
