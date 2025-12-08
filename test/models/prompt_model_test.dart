import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/prompt.dart';

void main() {
  test('Prompt fromJson/toJson and validations', () {
    final json = {
      'id': 'p1',
      'user_id': 'u1',
      'prompt_key': 'system.beta.editor',
      'language': 'zh-CN',
      'content': 'Hello',
      'is_public': true,
      'created_at': '2025-01-01T00:00:00Z',
      'updated_at': '2025-01-02T00:00:00Z',
    };
    final p = Prompt.fromJson(json);
    expect(p.id, 'p1');
    expect(p.userId, 'u1');
    expect(p.promptKey, 'system.beta.editor');
    expect(p.language, 'zh-CN');
    expect(p.content, 'Hello');
    expect(p.isPublic, isTrue);
    expect(p.createdAt?.year, 2025);
    expect(p.updatedAt?.day, 2);

    final out = p.toJson();
    expect(out['id'], 'p1');
    expect(out['user_id'], 'u1');
    expect(out['prompt_key'], 'system.beta.editor');
    expect(out['language'], 'zh-CN');
    expect(out['content'], 'Hello');
    expect(out['is_public'], true);
    expect((out['created_at'] as String).startsWith('2025-01-01'), isTrue);

    expect(Prompt.isValidPromptKey('system.beta.male'), isTrue);
    expect(Prompt.isValidPromptKey('system.beta.female'), isTrue);
    expect(Prompt.isValidPromptKey('system.beta.teenager'), isTrue);
    expect(Prompt.isValidPromptKey('system.beta.editor'), isTrue);
    expect(Prompt.isValidPromptKey('system.beta.invalid'), isFalse);

    expect(Prompt.isValidLanguage('en'), isTrue);
    expect(Prompt.isValidLanguage('zh'), isTrue);
    expect(Prompt.isValidLanguage('zh-CN'), isTrue);
    expect(Prompt.isValidLanguage('english'), isFalse);
  });
}
