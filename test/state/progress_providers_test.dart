import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/progress_providers.dart';
import 'package:writer/state/providers.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockSupabaseStreamFilterBuilder extends Mock
    implements SupabaseStreamFilterBuilder {}

class MockSupabaseStreamBuilder extends Mock implements SupabaseStreamBuilder {}

// Helper to mock the chain: from -> stream -> eq -> order -> limit -> map
// Since map() returns a Stream, we can just mock stream() to return a Stream<List<Map>>.
// However, the provider uses:
// .from(...).stream(...).eq(...).order(...).limit(...)
// This chain returns a SupabaseStreamBuilder which is a Stream<List<Map<String, dynamic>>>.

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  // In supabase_flutter v2, stream() returns a SupabaseStreamFilterBuilder
  // then .eq returns a SupabaseStreamFilterBuilder (or similar)
  // eventually it acts as a Stream.

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user123');
  });

  test('latestUserProgressProvider returns null when no user', () async {
    when(() => mockAuth.currentUser).thenReturn(null);

    final container = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(mockClient)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(latestUserProgressProvider, (prev, _) {});
    final value = await container.read(latestUserProgressProvider.future);
    expect(value, isNull);
    sub.close();
  });

  test('recentUserProgressProvider returns empty list when no user', () async {
    when(() => mockAuth.currentUser).thenReturn(null);

    final container = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(mockClient)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(recentUserProgressProvider, (prev, _) {});
    final value = await container.read(recentUserProgressProvider.future);
    expect(value, isEmpty);
    sub.close();
  });
}
