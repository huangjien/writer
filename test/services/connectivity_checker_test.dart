import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/services/connectivity_checker.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late RealConnectivityChecker checker;

  setUp(() {
    mockConnectivity = MockConnectivity();
    checker = RealConnectivityChecker(connectivity: mockConnectivity);
  });

  test('checkConnectivity returns true when connected (wifi)', () async {
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);

    expect(await checker.checkConnectivity(), isTrue);
  });

  test('checkConnectivity returns true when connected (mobile)', () async {
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.mobile]);

    expect(await checker.checkConnectivity(), isTrue);
  });

  test('checkConnectivity returns false when not connected', () async {
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.none]);

    expect(await checker.checkConnectivity(), isFalse);
  });

  test('onConnectivityChanged forwards stream', () {
    final stream = Stream.fromIterable([
      [ConnectivityResult.wifi],
      [ConnectivityResult.none],
    ]);
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => stream);

    expect(
      checker.onConnectivityChanged,
      emitsInOrder([
        [ConnectivityResult.wifi],
        [ConnectivityResult.none],
      ]),
    );
  });
}
