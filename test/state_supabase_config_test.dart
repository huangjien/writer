import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/supabase_config.dart';

void main() {
  test('supabaseEnabled is false when env missing', () {
    expect(supabaseEnabled, false);
  });
}
