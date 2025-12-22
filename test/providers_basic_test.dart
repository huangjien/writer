import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/providers.dart';

void main() {
  test('isSignedInProvider is false by default', () async {
    final container = ProviderContainer();
    expect(container.read(isSignedInProvider), isFalse);
  });
}
