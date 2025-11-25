import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/about/about_screen.dart';
import 'helpers/test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AboutScreen shows version from package.json', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const pkgJson = '{"name":"writer","version":"1.3.1"}';
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'package.json') {
          final bytes = utf8.encode(pkgJson);
          final buffer = Uint8List.fromList(bytes).buffer;
          return ByteData.view(buffer);
        }
        return null;
      },
    );
    final scope = await buildAppScope(
      child: materialAppFor(home: const AboutScreen()),
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    expect(find.textContaining('Version:'), findsOneWidget);
    expect(find.textContaining('1.3.1'), findsOneWidget);
  });
}
