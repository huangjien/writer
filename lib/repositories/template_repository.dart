import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/scene_template_row.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final remote = ref.watch(remoteRepositoryProvider);
  return TemplateRepository(remote);
});

class TemplateRepository {
  final RemoteRepository _remote;

  TemplateRepository(this._remote);

  // Character Templates

  Future<List<CharacterTemplateRow>> listCharacterTemplates() async {
    try {
      final res = await _remote.get('templates/characters');
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(CharacterTemplateRow.fromRow)
            .toList();
      }
      if (res is Map && res.containsKey('items') && res['items'] is List) {
        return (res['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(CharacterTemplateRow.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<CharacterTemplateRow?> getCharacterTemplateById(String id) async {
    try {
      final res = await _remote.get('templates/characters/$id');
      if (res is Map<String, dynamic>) {
        return CharacterTemplateRow.fromRow(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertCharacterTemplate({
    String? id,
    String? title,
    String? summaries,
    String? synopses,
    String? languageCode,
  }) async {
    final body = {
      if (title != null) 'title': title,
      if (summaries != null) 'summaries': summaries,
      if (synopses != null) 'synopses': synopses,
      if (languageCode != null) 'language_code': languageCode,
    };
    if (id != null) {
      await _remote.patch('templates/characters/$id', body);
    } else {
      await _remote.post('templates/characters', body);
    }
  }

  Future<void> deleteCharacterTemplate(String id) async {
    await _remote.delete('templates/characters/$id');
  }

  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    return _remote.generateCharacterTemplate(
      title: title,
      templateContent: templateContent,
      name: name,
      languageCode: languageCode,
    );
  }

  Future<List<CharacterTemplateRow>> searchCharacterTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    try {
      final body = {
        'query': query,
        'limit': limit,
        'offset': offset,
        if (languageCode != null) 'language_code': languageCode,
      };
      final res = await _remote.post('templates/characters/search', body);
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(CharacterTemplateRow.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Scene Templates

  Future<List<SceneTemplateRow>> listSceneTemplates({int limit = 200}) async {
    try {
      final res = await _remote.get(
        'templates/scenes',
        queryParameters: {'limit': limit.toString()},
      );
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(SceneTemplateRow.fromRow)
            .toList();
      }
      if (res is Map && res.containsKey('items') && res['items'] is List) {
        return (res['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(SceneTemplateRow.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<SceneTemplateRow?> getSceneTemplateById(String id) async {
    try {
      final res = await _remote.get('templates/scenes/$id');
      if (res is Map<String, dynamic>) {
        return SceneTemplateRow.fromRow(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> upsertSceneTemplate({
    String? id,
    String? title,
    String? summaries,
    String? synopses,
    String? languageCode,
  }) async {
    final body = {
      if (title != null) 'title': title,
      if (summaries != null) 'summaries': summaries,
      if (synopses != null) 'synopses': synopses,
      if (languageCode != null) 'language_code': languageCode,
    };
    Map<String, dynamic>? res;
    if (id != null) {
      res =
          await _remote.patch('templates/scenes/$id', body)
              as Map<String, dynamic>?;
    } else {
      res =
          await _remote.post('templates/scenes', body) as Map<String, dynamic>?;
    }
    if (res != null && res.containsKey('id')) return res['id'] as String;
    return id; // fallback
  }

  Future<void> deleteSceneTemplate(String id) async {
    await _remote.delete('templates/scenes/$id');
  }

  Future<Map<String, dynamic>?> generateSceneTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    return _remote.generateSceneTemplate(
      title: title,
      templateContent: templateContent,
      name: name,
      languageCode: languageCode,
    );
  }

  Future<List<SceneTemplateRow>> searchSceneTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    try {
      final body = {
        'query': query,
        'limit': limit,
        'offset': offset,
        if (languageCode != null) 'language_code': languageCode,
      };
      final res = await _remote.post('templates/scenes/search', body);
      if (res is List) {
        return res
            .cast<Map<String, dynamic>>()
            .map(SceneTemplateRow.fromRow)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
