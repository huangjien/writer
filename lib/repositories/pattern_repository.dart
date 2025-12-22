import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern.dart';
import 'remote_repository.dart';

final patternRepositoryProvider = Provider<PatternRepository>((ref) {
  return PatternRepository(ref.watch(remoteRepositoryProvider));
});

class PatternRepository {
  final RemoteRepository remote;

  PatternRepository(this.remote);

  Future<List<Pattern>> listPatterns({int limit = 50}) async {
    final res = await remote.get(
      'patterns',
      queryParameters: {'limit': limit.toString(), 'offset': '0'},
    );
    if (res is List) {
      final list = res.cast<Map<String, dynamic>>();
      return list.map(Pattern.fromMap).toList();
    }
    if (res is Map && res['items'] is List) {
      final list = (res['items'] as List).cast<Map<String, dynamic>>();
      return list.map(Pattern.fromMap).toList();
    }
    return [];
  }

  Future<Pattern?> getPattern(String id) async {
    try {
      final res = await remote.get('patterns/$id');
      if (res is Map<String, dynamic>) {
        return Pattern.fromMap(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Pattern> createPattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    List<double>? embedding,
    String? language,
    bool? isPublic,
    bool? locked,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
      'embedding': embedding,
      'language': language,
      'is_public': isPublic,
      'locked': locked,
    };
    final res = await remote.post('patterns', body);
    if (res is Map<String, dynamic>) {
      return Pattern.fromMap(res);
    }
    throw Exception('Failed to create pattern');
  }

  Future<Pattern> updatePattern({
    required String id,
    String? title,
    String? description,
    String? content,
    Map<String, dynamic>? usageRules,
    List<double>? embedding,
    String? language,
    bool? isPublic,
    bool? locked,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (content != null) body['content'] = content;
    if (usageRules != null) body['usage_rules'] = usageRules;
    if (embedding != null) body['embedding'] = embedding;
    if (language != null) body['language'] = language;
    if (isPublic != null) body['is_public'] = isPublic;
    if (locked != null) body['locked'] = locked;
    final res = await remote.patch('patterns/$id', body);
    if (res is Map<String, dynamic>) {
      return Pattern.fromMap(res);
    }
    throw Exception('Failed to update pattern');
  }

  Future<void> deletePattern(String id) async {
    await remote.delete('patterns/$id');
  }
}
