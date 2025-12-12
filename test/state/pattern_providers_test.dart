import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/state/pattern_providers.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/patterns_service.dart';
import 'package:writer/models/pattern.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakePatternsService extends PatternsService {
  FakePatternsService() : super(baseUrl: 'http://example.com');
  List<Pattern> items = const [
    Pattern(
      id: 'p1',
      title: 'A',
      description: null,
      content: 'X',
      usageRules: null,
    ),
    Pattern(
      id: 'p2',
      title: 'B',
      description: 'd',
      content: 'Y',
      usageRules: {'x': true},
    ),
  ];
  @override
  Future<List<Pattern>> fetchPatterns() async => items;
  @override
  Future<Pattern> getPattern(String id) async =>
      items.firstWhere((e) => e.id == id);
}

void main() {
  test('patternsProvider returns empty when Supabase disabled', () async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWith((_) => false)],
    );
    addTearDown(container.dispose);
    final result = await container.read(patternsProvider.future);
    expect(result, isEmpty);
    final p = await container.read(patternByIdProvider('p1').future);
    expect(p, isNull);
  });

  test('patterns providers return from service when enabled', () async {
    final fake = FakePatternsService();
    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWith((_) => true),
        authStateProvider.overrideWith(
          (ref) =>
              Stream.value(AuthState(AuthChangeEvent.initialSession, null)),
        ),
        patternsServiceRefProvider.overrideWith((_) => fake),
      ],
    );
    addTearDown(container.dispose);
    final list = await container.read(patternsProvider.future);
    expect(list.length, 2);
    final p = await container.read(patternByIdProvider('p2').future);
    expect(p?.title, 'B');
  });
}
