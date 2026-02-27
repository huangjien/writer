import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/summary/state/character_templates_list_providers.dart';
import 'package:writer/models/character_template_row.dart';
import 'package:writer/models/token_usage.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/repositories/template_repository.dart';
import 'package:writer/state/providers.dart';

class MockRemoteRepository implements RemoteRepository {
  List<CharacterTemplateRow> _searchResults;
  final bool shouldThrowError;

  MockRemoteRepository({
    List<CharacterTemplateRow>? searchResults,
    this.shouldThrowError = false,
  }) : _searchResults = searchResults ?? [];

  @override
  String get baseUrl => 'http://localhost:5600';

  void setSearchResults(List<CharacterTemplateRow> results) {
    _searchResults = results;
  }

  @override
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool retryUnauthorized = false,
  }) async {
    if (shouldThrowError) {
      throw Exception('Search failed');
    }
    return _searchResults.map((r) => r.toRow()).toList();
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool retryUnauthorized = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchCharacterProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertCharacter({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchSceneProfile(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> generateCharacterTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> generateSceneTemplate({
    required String title,
    required String templateContent,
    String? name,
    String? languageCode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> convertScene({
    required String name,
    required String templateContent,
    required String language,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsage?> getCurrentMonthUsage() async {
    throw UnimplementedError();
  }

  @override
  Future<TokenUsageHistory?> getUsageHistory({
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAdminLogs({int lines = 1000}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getAdminLogsEnhanced({
    int maxSizeKb = 50,
    int fileIndex = 0,
    String? level,
    String? logger,
    String? searchText,
    String? startDate,
    String? endDate,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getHotTopicsPlatforms({String? regionCode}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getLatestHotTopics({
    String? regionCode,
    String? platformKey,
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getHotTopicsTracking({
    String? regionCode,
    int? minMomentumScore,
    int? minTimesSeen,
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getHotTopicSnapshots(
    String topicFingerprint, {
    int? limit,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getTrendingHotTopics({
    String? regionCode,
    int? minMomentumScore,
    int? limit,
  }) async {
    throw UnimplementedError();
  }
}

class MockTemplateRepository extends TemplateRepository {
  final bool shouldThrowError;
  final List<CharacterTemplateRow> searchResults;

  MockTemplateRepository({
    this.shouldThrowError = false,
    this.searchResults = const [],
  }) : super(MockRemoteRepository());

  @override
  Future<List<CharacterTemplateRow>> searchCharacterTemplates(
    String query, {
    int limit = 10,
    int offset = 0,
    String? languageCode,
  }) async {
    if (shouldThrowError) {
      throw Exception('Search failed');
    }
    return searchResults;
  }
}

void main() {
  group('CharacterTemplatesListState', () {
    test('creates state with all required fields', () {
      final searchCtrl = TextEditingController();
      final state = CharacterTemplatesListState(
        items: const [],
        displayItems: const [],
        searchCtrl: searchCtrl,
      );

      expect(state.items, isEmpty);
      expect(state.displayItems, isEmpty);
      expect(state.isLoading, false);
      expect(state.isSearchLoading, false);
      expect(state.error, isNull);
      expect(state.searchCtrl, searchCtrl);
      expect(state.lastRowTapAt, isNull);
      expect(state.lastRowTapId, isNull);
      expect(state.selectedId, isNull);
    });

    test('copyWith creates new state with updated fields', () {
      final searchCtrl = TextEditingController();
      final state = CharacterTemplatesListState(
        items: const [],
        displayItems: const [],
        searchCtrl: searchCtrl,
      );

      final now = DateTime.now();
      final updated = state.copyWith(
        items: [
          CharacterTemplateRow(
            id: '1',
            idx: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        isLoading: false,
        error: 'Test error',
        lastRowTapAt: now,
        lastRowTapId: 'template-1',
        selectedId: 'selected-1',
      );

      expect(updated.items.length, 1);
      expect(updated.isLoading, false);
      expect(updated.error, 'Test error');
      expect(updated.lastRowTapAt, now);
      expect(updated.lastRowTapId, 'template-1');
      expect(updated.selectedId, 'selected-1');
      expect(updated.searchCtrl, same(searchCtrl));
    });

    test('copyWith preserves unchanged fields', () {
      final searchCtrl = TextEditingController();
      final items = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      final state = CharacterTemplatesListState(
        items: items,
        displayItems: items,
        searchCtrl: searchCtrl,
        isLoading: true,
      );

      final updated = state.copyWith(isLoading: false);

      expect(updated.items, same(items));
      expect(updated.displayItems, same(items));
      expect(updated.searchCtrl, same(searchCtrl));
      expect(updated.isLoading, false);
    });
  });

  group('CharacterTemplatesListNotifier', () {
    test('build creates initial state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final state = notifier.state;

      expect(state.items, isEmpty);
      expect(state.displayItems, isEmpty);
      expect(state.isLoading, true);
      expect(state.isSearchLoading, false);
      expect(state.error, isNull);
      expect(state.searchCtrl, isA<TextEditingController>());
    });

    test('setItems updates items and displayItems', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final items = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      notifier.setItems(items, items);

      expect(notifier.state.items, same(items));
      expect(notifier.state.displayItems, same(items));
    });

    test('setLoading updates loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);

      expect(notifier.state.isLoading, true);

      notifier.setLoading(false);

      expect(notifier.state.isLoading, false);
    });

    test('setSearchLoading updates search loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);

      expect(notifier.state.isSearchLoading, false);

      notifier.setSearchLoading(true);

      expect(notifier.state.isSearchLoading, true);
    });

    test('setError updates error message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);

      notifier.setError('Test error');

      expect(notifier.state.error, 'Test error');

      notifier.setError(null);

      expect(notifier.state.error, isNull);
    });

    test('setSelectedId updates selected ID', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);

      notifier.setSelectedId('template-1');

      expect(notifier.state.selectedId, 'template-1');

      notifier.setSelectedId(null);

      expect(notifier.state.selectedId, isNull);
    });

    test('setLastRowTap updates last tap info', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final now = DateTime.now();

      notifier.setLastRowTap(now, 'template-1');

      expect(notifier.state.lastRowTapAt, now);
      expect(notifier.state.lastRowTapId, 'template-1');
    });

    test('setLocalSearch filters items when signed out', () async {
      final container = ProviderContainer(
        overrides: [isSignedInProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final items = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Hero',
        ),
        CharacterTemplateRow(
          id: '2',
          idx: 1,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Villain',
        ),
      ];
      notifier.setItems(items, items);
      notifier.state.searchCtrl.text = 'hero';

      await notifier.setLocalSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.displayItems.length, 1);
      expect(notifier.state.displayItems.first.title, 'Hero');
    });

    test('setLocalSearch shows all items when query is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final items = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Hero',
        ),
      ];
      notifier.setItems(items, []);
      notifier.state.searchCtrl.text = '';

      await notifier.setLocalSearch();

      expect(notifier.state.displayItems, items);
    });

    test('setLocalSearch performs remote search when signed in', () async {
      final searchResults = [
        CharacterTemplateRow(
          id: 'remote-1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Remote Hero',
        ),
      ];
      final mockTemplateRepo = MockTemplateRepository(
        searchResults: searchResults,
      );
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      final items = [
        CharacterTemplateRow(
          id: '1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Local Hero',
        ),
      ];
      notifier.setItems(items, items);
      notifier.state.searchCtrl.text = 'hero';

      await notifier.setLocalSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.displayItems.length, 1);
      expect(notifier.state.displayItems.first.title, 'Remote Hero');
    });

    test('setLocalSearch sets error on exception', () async {
      final mockTemplateRepo = MockTemplateRepository(shouldThrowError: true);
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      notifier.state.searchCtrl.text = 'test';

      await notifier.setLocalSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.error, isNotNull);
    });

    test('smartSearch requires sign in', () async {
      final container = ProviderContainer(
        overrides: [isSignedInProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      notifier.state.searchCtrl.text = 'hero';

      await notifier.smartSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.error, 'Please sign in to search');
    });

    test('smartSearch returns early when query is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      notifier.state.searchCtrl.text = '';

      await notifier.smartSearch();

      expect(notifier.state.isSearchLoading, false);
    });

    test('smartSearch sets error on exception', () async {
      final mockTemplateRepo = MockTemplateRepository(shouldThrowError: true);
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      notifier.state.searchCtrl.text = 'test';

      await notifier.smartSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.error, isNotNull);
    });

    test('smartSearch performs remote search when signed in', () async {
      final searchResults = [
        CharacterTemplateRow(
          id: 'remote-1',
          idx: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          title: 'Remote Hero',
        ),
      ];
      final mockTemplateRepo = MockTemplateRepository(
        searchResults: searchResults,
      );
      final container = ProviderContainer(
        overrides: [
          isSignedInProvider.overrideWithValue(true),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(characterTemplatesListProvider.notifier);
      notifier.state.searchCtrl.text = 'hero';

      await notifier.smartSearch();

      expect(notifier.state.isSearchLoading, false);
      expect(notifier.state.displayItems.length, 1);
      expect(notifier.state.displayItems.first.id, 'remote-1');
      expect(notifier.state.displayItems.first.title, 'Remote Hero');
    });

    test('provider exposes state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(characterTemplatesListProvider);

      expect(state, isA<CharacterTemplatesListState>());
    });
  });
}
