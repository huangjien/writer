import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('supabaseEnabled reflects env defines', () {
    final hasUrl = supabaseUrl.isNotEmpty;
    final hasKey = supabaseAnonKey.isNotEmpty;
    if (hasUrl && hasKey) {
      expect(supabaseEnabled, isTrue);
    } else {
      expect(supabaseEnabled, isFalse);
    }
  });
}
