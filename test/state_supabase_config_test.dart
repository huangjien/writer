import 'package:flutter_test/flutter_test.dart';
import 'package:novel_reader/state/supabase_config.dart';

void main() {
  test('supabaseEnabled is false when env missing', () {
    expect(supabaseEnabled, false);
  });
}
