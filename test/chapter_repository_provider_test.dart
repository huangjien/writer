import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/main.dart';

void main() {
  test('chapterRepositoryProvider can be read', () {
    SharedPreferences.setMockInitialValues({});
    final remote = RemoteRepository(
      'http://example.com',
      client: MockClient((request) async => http.Response('[]', 200)),
    );
    final container = ProviderContainer(
      overrides: [
        remoteRepositoryProvider.overrideWithValue(remote),
        localStorageRepositoryProvider.overrideWith(
          (ref) => LocalStorageRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(chapterRepositoryProvider), isNotNull);
  });
}
