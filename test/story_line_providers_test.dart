import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/models/story_line.dart';
import 'package:writer/services/story_lines_service.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/story_line_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeStoryLinesService extends StoryLinesService {
  FakeStoryLinesService() : super(baseUrl: 'http://example.com');

  bool fetchCalled = false;
  bool getCalled = false;
  String? lastGetId;

  List<StoryLine> items = const [
    StoryLine(id: 's1', title: 'A', content: 'C', language: 'en'),
  ];

  @override
  Future<List<StoryLine>> fetchStoryLines() async {
    fetchCalled = true;
    return items;
  }

  @override
  Future<StoryLine> getStoryLine(String id) async {
    getCalled = true;
    lastGetId = id;
    return StoryLine(id: id, title: 'T$id', content: 'C$id', language: 'en');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('storyLinesProvider returns empty when signed out', () async {
    final fake = FakeStoryLinesService();
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isSignedInProvider.overrideWithValue(false),
        authStateProvider.overrideWithValue(null),
        storyLinesServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);

    final list = await container.read(storyLinesProvider.future);
    expect(list, isEmpty);
    expect(fake.fetchCalled, isFalse);
  });

  test('storyLineByIdProvider returns null when signed out', () async {
    final fake = FakeStoryLinesService();
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isSignedInProvider.overrideWithValue(false),
        authStateProvider.overrideWithValue(null),
        storyLinesServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);

    final v = await container.read(storyLineByIdProvider('s1').future);
    expect(v, isNull);
    expect(fake.getCalled, isFalse);
  });

  test('storyLinesProvider calls service when signed in', () async {
    final fake = FakeStoryLinesService();
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isSignedInProvider.overrideWithValue(true),
        authStateProvider.overrideWithValue('session'),
        storyLinesServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);

    final list = await container.read(storyLinesProvider.future);
    expect(list.length, 1);
    expect(list.first.id, 's1');
    expect(fake.fetchCalled, isTrue);
  });

  test('storyLineByIdProvider calls service when signed in', () async {
    final fake = FakeStoryLinesService();
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isSignedInProvider.overrideWithValue(true),
        authStateProvider.overrideWithValue('session'),
        storyLinesServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);

    final v = await container.read(storyLineByIdProvider('s9').future);
    expect(v, isNotNull);
    expect(v!.id, 's9');
    expect(fake.getCalled, isTrue);
    expect(fake.lastGetId, 's9');
  });
}
