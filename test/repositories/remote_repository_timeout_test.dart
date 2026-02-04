import 'package:flutter_test/flutter_test.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/shared/constants.dart';

void main() {
  group('RemoteRepository timeout', () {
    test('default timeout matches kLlmTimeout and is at least 60s', () {
      expect(RemoteRepository.defaultTimeout, kLlmTimeout);
      expect(
        RemoteRepository.defaultTimeout.inSeconds,
        greaterThanOrEqualTo(60),
      );
    });
  });
}
