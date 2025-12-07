import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:writer/main.dart' as app_main;

void main() {
  testWidgets('main() runs and builds App', (tester) async {
    SharedPreferences.setMockInitialValues({});
    app_main.main();
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
