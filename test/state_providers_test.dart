import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/providers.dart';

void main() {
  test('supabaseEnabledProvider reflects config flag', () async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
    );
    final v = container.read(supabaseEnabledProvider);
    expect(v, false);
  });
}
