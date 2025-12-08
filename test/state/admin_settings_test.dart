import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/admin_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('AdminModeNotifier persists toggles', () async {
    final prefs = await SharedPreferences.getInstance();
    final n = AdminModeNotifier(prefs);
    expect(n.state, isFalse);
    await n.enable();
    expect(n.state, isTrue);
    final n2 = AdminModeNotifier(prefs);
    expect(n2.state, isTrue);
    await n.disable();
    expect(n.state, isFalse);
  });
}
