import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

class FakeFuture extends Fake implements Future<String> {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(String value) onValue, {
    Function? onError,
  }) async {
    return onValue('success');
  }
}

void main() {
  test('faking then', () async {
    final fake = FakeFuture();
    final result = await fake;
    expect(result, 'success');
  });
}
