import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() main) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await resetSharedPreferences();
  await main();
  await resetSharedPreferences();
}

/// Reset SharedPreferences mock between tests to prevent test isolation issues.
Future<void> resetSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
}
