import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/routing/app_router.dart';

void main() {
  test('appRouterProvider returns a GoRouter', () {
    final container = ProviderContainer();
    final router = container.read(appRouterProvider);
    expect(router, isNotNull);
    expect(router.configuration.routes.isNotEmpty, true);
  });
}
