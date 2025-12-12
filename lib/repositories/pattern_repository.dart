import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pattern.dart';

class PatternRepository {
  final SupabaseClient client;
  PatternRepository(this.client);

  Future<List<Pattern>> listPatterns({int limit = 200}) async {
    final res = await client
        .from('writing_patterns')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(Pattern.fromMap).toList();
  }

  Future<Pattern?> getPattern(String id) async {
    final res = await client
        .from('writing_patterns')
        .select()
        .eq('id', id)
        .single();
    if (res.isEmpty) return null;
    return Pattern.fromMap(res);
  }

  Future<Pattern> createPattern({
    required String title,
    String? description,
    required String content,
    Map<String, dynamic>? usageRules,
    List<double>? embedding,
  }) async {
    final insert = <String, dynamic>{
      'title': title,
      'description': description,
      'content': content,
      'usage_rules': usageRules,
    };
    if (embedding != null) {
      insert['embedding'] = embedding;
    }
    final res = await client
        .from('writing_patterns')
        .insert(insert)
        .select()
        .single();
    return Pattern.fromMap(res);
  }

  Future<Pattern> updatePattern({
    required String id,
    String? title,
    String? description,
    String? content,
    Map<String, dynamic>? usageRules,
    List<double>? embedding,
  }) async {
    final update = <String, dynamic>{};
    if (title != null) update['title'] = title;
    if (description != null) update['description'] = description;
    if (content != null) update['content'] = content;
    if (usageRules != null) update['usage_rules'] = usageRules;
    if (embedding != null) update['embedding'] = embedding;
    final res = await client
        .from('writing_patterns')
        .update(update)
        .eq('id', id)
        .select()
        .single();
    return Pattern.fromMap(res);
  }

  Future<void> deletePattern(String id) async {
    await client.from('writing_patterns').delete().eq('id', id);
  }
}
