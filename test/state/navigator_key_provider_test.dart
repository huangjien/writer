import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/navigator_key_provider.dart';

void main() {
  test('globalNavigatorKeyProvider returns a GlobalKey<NavigatorState>', () {
    final container = ProviderContainer();
    final key = container.read(globalNavigatorKeyProvider);
    expect(key, isA<GlobalKey<NavigatorState>>());
  });
}
