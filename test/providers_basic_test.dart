import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/providers.dart';

void main() {
  test(
    'supabaseEnabledProvider reflects configuration flag (default false)',
    () async {
      final container = ProviderContainer();
      final enabled = container.read(supabaseEnabledProvider);
      expect(enabled, isFalse);
    },
  );

  // Additional provider tests are omitted to avoid Supabase client initialization in unit tests.
}
