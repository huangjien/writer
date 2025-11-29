import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/supabase_config.dart';

Future<void> testExecutable(FutureOr<void> Function() main) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (supabaseEnabled) {
    try {
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
      );
    } catch (_) {}
  }
  await main();
}
