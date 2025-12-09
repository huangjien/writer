import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/supabase_config.dart';
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
  Future<void> saveChapter(ChapterCache chapter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chapter.chapterId, jsonEncode(chapter.toJson()));
  }

  Future<ChapterCache?> getChapter(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final chapterJson = prefs.getString(chapterId);
    if (chapterJson != null) {
      return ChapterCache.fromJson(jsonDecode(chapterJson));
    }
    return null;
  }

  Future<void> saveChapters(List<ChapterCache> chapters) async {
    final prefs = await SharedPreferences.getInstance();
    for (final chapter in chapters) {
      await prefs.setString(chapter.chapterId, jsonEncode(chapter.toJson()));
    }
  }

  Future<void> removeChapter(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chapterId);
  }

  /// Safely clears cached chapter entries by detecting ChapterCache JSON shape.
  Future<int> clearChapterCache() async {
    final prefs = await SharedPreferences.getInstance();
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
      } catch (_) {
        // Ignore non-JSON values
      }
    }
    return removed;
  }

  Future<void> saveLibraryNovels(List<Novel> novels) async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
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

  Future<void> saveCharacterForm(
    String novelId,
    Character character, {
    int? idx,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'character_form_$novelId',
      jsonEncode(character.toMap()),
    );
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        await client.from('characters').upsert({
          'novel_id': novelId,
          'idx': idx ?? 1,
          'title': character.name,
          'character_summaries': character.role,
          'character_synopses': character.bio,
          'language_code': 'en',
        });
      } catch (_) {}
    }
  }

  Future<Character?> getCharacterForm(String novelId, {int? idx}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('character_form_$novelId');
    Character? local;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        local = Character.fromMap(decoded);
      } catch (_) {}
    }
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('characters')
              .select()
              .eq('novel_id', novelId)
              .eq('idx', idx ?? 1)
              .limit(1),
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          final name = (row['title'] as String?) ?? local?.name;
          final role = (row['character_summaries'] as String?);
          final bio = (row['character_synopses'] as String?);
          if (name != null) {
            return Character(
              novelId: novelId,
              name: name,
              role: role,
              bio: bio,
            );
          }
        }
      } catch (_) {}
    }
    return local;
  }

  Future<void> saveCharacterNoteForm(
    String novelId, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
    int? idx,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'title': title,
      'character_summaries': summaries,
      'character_synopses': synopses,
      'language_code': languageCode,
    };
    await prefs.setString('character_note_form_$novelId', jsonEncode(payload));
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        await client.from('characters').upsert({
          'novel_id': novelId,
          'idx': idx ?? 1,
          'title': title,
          'character_summaries': summaries,
          'character_synopses': synopses,
          'language_code': languageCode,
        });
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> getCharacterNoteForm(
    String novelId, {
    int? idx,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('character_note_form_$novelId');
    Map<String, dynamic>? local;
    if (raw != null) {
      try {
        local = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('characters')
              .select()
              .eq('novel_id', novelId)
              .eq('idx', idx ?? 1)
              .limit(1),
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          return {
            'title': row['title'] as String?,
            'character_summaries': row['character_summaries'] as String?,
            'character_synopses': row['character_synopses'] as String?,
            'language_code': row['language_code'] as String? ?? 'en',
          };
        }
      } catch (_) {}
    }
    return local;
  }

  Future<void> saveSceneForm(String novelId, Scene scene, {int? idx}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scene_form_$novelId', jsonEncode(scene.toMap()));
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final summaries = scene.summary;
        final synopses = scene.location;
        await client.from('scenes').upsert({
          'novel_id': novelId,
          'idx': idx ?? 1,
          'title': scene.title,
          'scene_summaries': summaries,
          'scene_synopses': synopses,
          'language_code': 'en',
        });
      } catch (_) {}
    }
  }

  Future<Scene?> getSceneForm(String novelId, {int? idx}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('scene_form_$novelId');
    Scene? local;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        local = Scene.fromMap(decoded);
      } catch (_) {}
    }
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('scenes')
              .select()
              .eq('novel_id', novelId)
              .eq('idx', idx ?? 1)
              .limit(1),
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          final title = (row['title'] as String?) ?? local?.title;
          final summary = row['scene_summaries'] as String?;
          final location = row['scene_synopses'] as String?;
          if (title != null) {
            return Scene(
              novelId: novelId,
              title: title,
              location: location,
              summary: summary,
            );
          }
        }
      } catch (_) {}
    }
    return local;
  }

  Future<void> saveCharacterTemplateForm(
    String novelId,
    TemplateItem item,
  ) async {
    if (supabaseEnabled) {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      final existing = await (uid != null
          ? client
                .from('character_templates')
                .select('id')
                .eq('created_by', uid)
                .ilike('title', item.name.trim())
                .limit(1)
          : client
                .from('character_templates')
                .select('id')
                .ilike('title', item.name.trim())
                .limit(1));
      if ((existing as List).isNotEmpty) {
        throw Exception('Duplicate template name');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'character_template_form_$novelId',
      jsonEncode(item.toMap()),
    );
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        await client.from('character_templates').insert({
          'idx': 1,
          'title': item.name,
          'character_summaries': item.description,
          'language_code': 'en',
          'created_by': uid,
        });
      } catch (_) {}
    }
  }

  Future<TemplateItem?> getCharacterTemplateForm(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('character_template_form_$novelId');
    TemplateItem? local;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        local = TemplateItem.fromMap(decoded);
      } catch (_) {}
    }
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('character_templates')
              .select()
              .eq('idx', 1)
              .order('updated_at', ascending: false)
              .limit(1),
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          return TemplateItem(
            novelId: novelId,
            name: (row['title'] as String?) ?? local?.name ?? '',
            description: row['character_summaries'] as String?,
          );
        }
      } catch (_) {}
    }
    return local;
  }

  Future<void> saveSceneTemplateForm(String novelId, TemplateItem item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'scene_template_form_$novelId',
      jsonEncode(item.toMap()),
    );
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        await client.from('scene_templates').insert({
          'idx': 1,
          'title': item.name,
          'scene_summaries': item.description,
          'language_code': 'en',
          'created_by': uid,
        });
      } catch (_) {}
    }
  }

  Future<TemplateItem?> getSceneTemplateForm(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('scene_template_form_$novelId');
    TemplateItem? local;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        local = TemplateItem.fromMap(decoded);
      } catch (_) {}
    }
    if (supabaseEnabled) {
      try {
        final client = Supabase.instance.client;
        final rows = List<Map<String, dynamic>>.from(
          await client
              .from('scene_templates')
              .select()
              .eq('idx', 1)
              .order('updated_at', ascending: false)
              .limit(1),
        );
        if (rows.isNotEmpty) {
          final row = rows.first;
          return TemplateItem(
            novelId: novelId,
            name: (row['title'] as String?) ?? local?.name ?? '',
            description: row['scene_summaries'] as String?,
          );
        }
      } catch (_) {}
    }
    return local;
  }

  Future<List<CharacterNote>> listCharacterNotes(String novelId) async {
    if (!supabaseEnabled) {
      final cached = await getCharacterNoteForm(novelId);
      if (cached == null) return <CharacterNote>[];
      final now = DateTime.now();
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
    final client = Supabase.instance.client;
    final res = await client
        .from('characters')
        .select(
          'id, novel_id, idx, title, character_summaries, character_synopses, language_code, created_at, updated_at',
        )
        .eq('novel_id', novelId)
        .order('idx', ascending: true);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(CharacterNote.fromRow)
        .toList();
  }

  Future<int> nextCharacterIdx(String novelId) async {
    if (!supabaseEnabled) return 2;
    final client = Supabase.instance.client;
    final rows = await client
        .from('characters')
        .select('idx')
        .eq('novel_id', novelId)
        .order('idx', ascending: false)
        .limit(1);
    final list = (rows as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return 1;
    final maxIdx = (list.first['idx'] as int?) ?? 0;
    return maxIdx + 1;
  }

  Future<void> deleteCharacterNoteById(String id) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    await client.from('characters').delete().eq('id', id);
  }

  Future<void> deleteCharacterNoteByIdx(String novelId, int idx) async {
    if (!supabaseEnabled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('character_note_form_$novelId');
      return;
    }
    final client = Supabase.instance.client;
    await client
        .from('characters')
        .delete()
        .eq('novel_id', novelId)
        .eq('idx', idx);
  }

  Future<List<SceneNote>> listSceneNotes(String novelId) async {
    if (!supabaseEnabled) {
      final cached = await getSceneForm(novelId);
      if (cached == null) return <SceneNote>[];
      final now = DateTime.now();
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
    final client = Supabase.instance.client;
    final res = await client
        .from('scenes')
        .select(
          'id, novel_id, idx, title, scene_summaries, scene_synopses, language_code, created_at, updated_at',
        )
        .eq('novel_id', novelId)
        .order('idx', ascending: true);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(SceneNote.fromRow)
        .toList();
  }

  Future<int> nextSceneIdx(String novelId) async {
    if (!supabaseEnabled) return 2;
    final client = Supabase.instance.client;
    final rows = await client
        .from('scenes')
        .select('idx')
        .eq('novel_id', novelId)
        .order('idx', ascending: false)
        .limit(1);
    final list = (rows as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) return 1;
    final maxIdx = (list.first['idx'] as int?) ?? 0;
    return maxIdx + 1;
  }

  Future<void> deleteSceneNoteById(String id) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    await client.from('scenes').delete().eq('id', id);
  }

  Future<void> deleteSceneNoteByIdx(String novelId, int idx) async {
    if (!supabaseEnabled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scene_form_$novelId');
      return;
    }
    final client = Supabase.instance.client;
    await client.from('scenes').delete().eq('novel_id', novelId).eq('idx', idx);
  }

  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    if (!supabaseEnabled) {
      return <CharacterTemplateRow>[];
    }
    final client = Supabase.instance.client;
    final res = await client
        .from('character_templates')
        .select(
          'id, idx, title, character_summaries, character_synopses, language_code, created_by, created_at, updated_at',
        )
        .order('updated_at', ascending: false);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(CharacterTemplateRow.fromRow)
        .toList();
  }

  Future<void> deleteCharacterTemplate(String id) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    await client.from('character_templates').delete().eq('id', id);
  }

  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async {
    if (!supabaseEnabled) return null;
    final client = Supabase.instance.client;
    final row = await client
        .from('character_templates')
        .select(
          'id, idx, title, character_summaries, character_synopses, language_code, created_by, created_at, updated_at',
        )
        .eq('id', id)
        .single();
    final map = Map<String, dynamic>.from(row);
    return CharacterTemplateRow.fromRow(map);
  }

  Future<void> updateCharacterTemplate(
    String id, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
  }) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    if (title != null && title.trim().isNotEmpty) {
      final uid = client.auth.currentUser?.id;
      final existing = await (uid != null
          ? client
                .from('character_templates')
                .select('id')
                .eq('created_by', uid)
                .ilike('title', title.trim())
                .neq('id', id)
                .limit(1)
          : client
                .from('character_templates')
                .select('id')
                .ilike('title', title.trim())
                .neq('id', id)
                .limit(1));
      if ((existing as List).isNotEmpty) {
        throw Exception('Duplicate template name');
      }
    }
    await client
        .from('character_templates')
        .update({
          'title': title,
          'character_summaries': summaries,
          'character_synopses': synopses,
          'language_code': languageCode,
        })
        .eq('id', id);
  }

  Future<List<SceneTemplateRow>> listSceneTemplates() async {
    if (!supabaseEnabled) {
      return <SceneTemplateRow>[];
    }
    final client = Supabase.instance.client;
    final res = await client
        .from('scene_templates')
        .select(
          'id, idx, title, scene_summaries, scene_synopses, language_code, created_by, created_at, updated_at',
        )
        .order('updated_at', ascending: false);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(SceneTemplateRow.fromRow)
        .toList();
  }

  Future<void> deleteSceneTemplate(String id) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    await client.from('scene_templates').delete().eq('id', id);
  }

  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    if (!supabaseEnabled) return null;
    final client = Supabase.instance.client;
    final row = await client
        .from('scene_templates')
        .select(
          'id, idx, title, scene_summaries, scene_synopses, language_code, created_by, created_at, updated_at',
        )
        .eq('id', id)
        .single();
    final map = Map<String, dynamic>.from(row);
    return SceneTemplateRow.fromRow(map);
  }

  Future<void> updateSceneTemplate(
    String id, {
    String? title,
    String? summaries,
    String? synopses,
    String languageCode = 'en',
  }) async {
    if (!supabaseEnabled) return;
    final client = Supabase.instance.client;
    await client
        .from('scene_templates')
        .update({
          'title': title,
          'scene_summaries': summaries,
          'scene_synopses': synopses,
          'language_code': languageCode,
        })
        .eq('id', id);
  }

  Future<void> saveSummaryText(String novelId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('summary_form_$novelId', text);
  }

  Future<String?> getSummaryText(String novelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('summary_form_$novelId');
  }
}
