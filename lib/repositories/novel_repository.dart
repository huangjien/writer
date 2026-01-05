import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/summary.dart';
import 'remote_repository.dart';

final novelRepositoryProvider = Provider<NovelRepository>((ref) {
  return NovelRepository(ref.watch(remoteRepositoryProvider));
});

class NovelRepository {
  final RemoteRepository remote;

  NovelRepository(this.remote);

  Future<List<Novel>> fetchPublicNovels() async {
    final res = await remote.get('novels/public');
    if (res is List) {
      final list = res.cast<Map<String, dynamic>>();
      return list.map(Novel.fromMap).toList();
    }
    return [];
  }

  Future<List<Chapter>> fetchChaptersByNovel(String novelId) async {
    final res = await remote.get('novels/$novelId/chapters');
    if (res is List) {
      final list = res.cast<Map<String, dynamic>>();
      return list.map(Chapter.fromJson).toList();
    }
    return [];
  }

  Future<Novel> createNovel({
    required String title,
    String? author,
    String? description,
    String? coverUrl,
    String languageCode = 'en',
    bool isPublic = true,
  }) async {
    final body = {
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'language_code': languageCode,
      'is_public': isPublic,
    };
    final res = await remote.post('novels', body);
    if (res is Map<String, dynamic>) {
      return Novel.fromMap(res);
    }
    throw Exception('Failed to create novel');
  }

  Future<Novel?> getNovel(String novelId) async {
    try {
      final res = await remote.get('novels/$novelId');
      if (res is Map<String, dynamic>) {
        return Novel.fromMap(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final res = await remote.get('chapters/$chapterId');
      if (res is Map<String, dynamic>) {
        return Chapter.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteNovel(String novelId) async {
    await remote.delete('novels/$novelId');
  }

  Future<void> updateNovelMetadata(
    String novelId, {
    String? title,
    String? description,
    String? coverUrl,
    String? languageCode,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (coverUrl != null) body['cover_url'] = coverUrl;
    if (languageCode != null) body['language_code'] = languageCode;
    if (isPublic != null) body['is_public'] = isPublic;

    if (body.isEmpty) return;
    await remote.patch('novels/$novelId', body);
  }

  Future<List<Summary>> fetchSummaries(String novelId) async {
    final res = await remote.get('summaries/novel/$novelId');
    if (res is List) {
      final list = res.cast<Map<String, dynamic>>();
      return list.map(Summary.fromJson).toList();
    }
    return [];
  }

  Future<Summary> createSummary(Summary summary) async {
    final body = summary.toJson()..remove('id');
    final res = await remote.post('summaries', body);
    if (res is Map<String, dynamic>) {
      return Summary.fromJson(res);
    }
    throw Exception('Failed to create summary');
  }

  Future<Summary> updateSummary(Summary summary) async {
    final body = summary.toJson();
    final res = await remote.patch('summaries/${summary.id}', body);
    if (res is Map<String, dynamic>) {
      return Summary.fromJson(res);
    }
    throw Exception('Failed to update summary');
  }

  Future<void> addContributor({
    required String novelId,
    required String userId,
  }) async {
    // Feature currently not supported by backend proxy
    throw UnimplementedError(
      'Backend does not support adding contributors yet.',
    );
  }

  Future<List<Novel>> fetchMemberNovels({
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await remote.get(
      'novels/member',
      queryParameters: {'limit': limit.toString(), 'offset': offset.toString()},
      retryUnauthorized: false,
    );
    if (res is List) {
      final list = res.cast<Map<String, dynamic>>();
      return list.map(Novel.fromMap).toList();
    }
    return [];
  }

  Future<void> addContributorByEmail({
    required String novelId,
    required String email,
  }) async {
    final body = {'email': email};
    await remote.post('novels/$novelId/contributors', body);
  }
}
