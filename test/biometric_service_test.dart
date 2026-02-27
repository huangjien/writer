import 'package:flutter_test/flutter_test.dart';
import 'package:writer/services/biometric_service.dart';

void main() {
  group('BiometricTokenStatus', () {
    test('has correct enum values', () {
      expect(BiometricTokenStatus.valid, isNotNull);
      expect(BiometricTokenStatus.expired, isNotNull);
      expect(BiometricTokenStatus.noTokensWithCredentials, isNotNull);
      expect(BiometricTokenStatus.noTokens, isNotNull);
      expect(BiometricTokenStatus.error, isNotNull);
    });

    test('enum values are unique', () {
      const values = BiometricTokenStatus.values;
      final uniqueValues = values.toSet();
      expect(values.length, uniqueValues.length);
    });

    test('enum has 5 values', () {
      expect(BiometricTokenStatus.values.length, 5);
    });
  });

  group('BiometricService', () {
    test('creates service with default dependencies', () {
      final service = BiometricService();
      expect(service, isNotNull);
    });
  });
}
