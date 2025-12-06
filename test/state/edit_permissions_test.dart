import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/edit_permissions.dart';
import 'package:writer/state/providers.dart';
import '../shared/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user123');
  });

  test('editRoleProvider returns none when disabled', () async {
    final container = ProviderContainer(
      overrides: [supabaseEnabledProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('editRoleProvider returns none when no user', () async {
    when(() => mockAuth.currentUser).thenReturn(null);

    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWithValue(true),
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });

  test('editRoleProvider returns owner if is_owner RPC true', () async {
    when(
      () => mockClient.rpc('is_owner', params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(true));

    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWithValue(true),
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.owner);
  });

  test('editRoleProvider returns contributor if is_member RPC true', () async {
    when(
      () => mockClient.rpc('is_owner', params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(false));
    when(
      () => mockClient.rpc('is_member', params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(true));

    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWithValue(true),
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.contributor);
  });

  test('editRoleProvider returns none if both RPC false', () async {
    when(
      () => mockClient.rpc('is_owner', params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(false));
    when(
      () => mockClient.rpc('is_member', params: any(named: 'params')),
    ).thenAnswer((_) => FakePostgrestFilterBuilder(false));

    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWithValue(true),
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
    );
    addTearDown(container.dispose);

    final role = await container.read(editRoleProvider('n1').future);
    expect(role, EditRole.none);
  });
}
