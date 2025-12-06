import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/novel_providers.dart';
import 'package:writer/models/novel.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/repositories/novel_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/providers.dart';

class CapturingLocalRepo extends LocalStorageRepository {
  List<Novel>? lastSaved;
  @override
  Future<void> saveLibraryNovels(List<Novel> novels) async {
    lastSaved = novels;
    await super.saveLibraryNovels(novels);
  }
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'libraryNovelsProvider unions public and member lists and saves cache',
    () async {
      final cache = CapturingLocalRepo();
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(
            (ref) =>
                Stream.value(AuthState(AuthChangeEvent.initialSession, null)),
          ),
          app_main.localStorageRepositoryProvider.overrideWith((_) => cache),
          novelsProvider.overrideWith(
            (ref) async => const [
              Novel(
                id: 'n1',
                title: 'A',
                author: 'X',
                description: 'D',
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
            ],
          ),
          memberNovelsProvider.overrideWith(
            (ref) async => const [
              Novel(
                id: 'n2',
                title: 'B',
                author: null,
                description: null,
                coverUrl: null,
                languageCode: 'en',
                isPublic: true,
              ),
            ],
          ),
        ],
      );
      final sub1 = container.listen(novelsProvider, (prev, _) {});
      final sub2 = container.listen(memberNovelsProvider, (prev, _) {});
      final union = await container.read(libraryNovelsProvider.future);
      expect(union.map((n) => n.id).toSet(), {'n1', 'n2'});
      expect(cache.lastSaved?.length, 2);
      sub1.close();
      sub2.close();
    },
  );

  test('novelProvider returns a single novel by id', () async {
    final container = ProviderContainer(
      overrides: [
        novelsProvider.overrideWith((ref) async => const []),
        novelRepositoryProvider.overrideWith((ref) => FakeNovelSingle()),
      ],
    );
    final n = await container.read(novelProvider('nx').future);
    expect(n?.id, 'nx');
  });
}

class FakeNovelSingle extends NovelRepository {
  FakeNovelSingle() : super(SupabaseClient('http://example.com', 'anon'));
  @override
  Future<Novel?> getNovel(String novelId) async {
    return Novel(
      id: novelId,
      title: 'T',
      author: 'A',
      description: 'D',
      coverUrl: null,
      languageCode: 'en',
      isPublic: true,
    );
  }
}
