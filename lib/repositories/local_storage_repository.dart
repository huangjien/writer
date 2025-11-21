import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter_cache.dart';
import '../models/novel.dart';

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
}
