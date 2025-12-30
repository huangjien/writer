import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/chapter_repository.dart';
import 'package:writer/state/providers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'localStorageRepositoryProvider returns LocalStorageRepository',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final repo = container.read(localStorageRepositoryProvider);
      expect(repo, isA<LocalStorageRepository>());
    },
  );

  test('chapterRepositoryProvider returns ChapterRepository', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final repo = container.read(chapterRepositoryProvider);
    expect(repo, isA<ChapterRepository>());
  });
}
