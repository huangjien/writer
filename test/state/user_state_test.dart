import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/models/user.dart';
import 'package:writer/repositories/user_repository.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/storage_service_provider.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockStorageService mockStorageService;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockStorageService = MockStorageService();
    when(() => mockStorageService.getString(any())).thenReturn(null);
    when(
      () => mockStorageService.setString(any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockStorageService.remove(any())).thenAnswer((_) async => true);
  });

  ProviderContainer createContainer({String? initialSession}) {
    // Setup storage to return initial session
    when(() => mockStorageService.getString(any())).thenReturn(initialSession);

    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        storageServiceProvider.overrideWithValue(mockStorageService),
        // We use the real SessionNotifier but with mocked storage
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(mockStorageService, initialSession),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial state is AsyncValue.data(null) when no session', () {
    final container = createContainer();
    final state = container.read(userProvider);
    expect(state, isA<AsyncData<User?>>());
    expect(state.value, null);
  });

  test('fetches user when session is initially present', () async {
    final user = User(id: '1', email: 'test@example.com');
    when(
      () => mockUserRepository.fetchUser('session-123'),
    ).thenAnswer((_) async => user);

    final container = createContainer(initialSession: 'session-123');

    // Initial read should trigger fetch, eventually leading to data
    // We expect it to transition: Loading -> Data

    // Note: Since init() is called in constructor, the first state we see might already be loading
    // or even data if it was synchronous (but it's not).

    final stream = container.read(userProvider.notifier).stream;

    await expectLater(
      stream,
      emitsThrough(
        predicate<AsyncValue<User?>>(
          (value) => value is AsyncData && value.value == user,
        ),
      ),
    );

    verify(() => mockUserRepository.fetchUser('session-123')).called(1);
  });

  test('updates user when session changes', () async {
    final user = User(id: '1', email: 'test@example.com');
    when(
      () => mockUserRepository.fetchUser('new-session'),
    ).thenAnswer((_) async => user);

    final container = createContainer();

    // Initial state
    expect(container.read(userProvider).value, null);

    // Update session
    container.read(sessionProvider.notifier).setSessionId('new-session');

    // Wait for stream to emit data
    final stream = container.read(userProvider.notifier).stream;

    await expectLater(
      stream,
      emitsThrough(
        predicate<AsyncValue<User?>>(
          (value) => value is AsyncData && value.value == user,
        ),
      ),
    );

    verify(() => mockUserRepository.fetchUser('new-session')).called(1);
  });

  test('clears user when session is cleared', () async {
    final user = User(id: '1', email: 'test@example.com');
    when(
      () => mockUserRepository.fetchUser('session-123'),
    ).thenAnswer((_) async => user);

    final container = createContainer(initialSession: 'session-123');
    final stream = container.read(userProvider.notifier).stream;

    // Wait for initial fetch
    await expectLater(
      stream,
      emitsThrough(
        predicate<AsyncValue<User?>>(
          (value) => value is AsyncData && value.value == user,
        ),
      ),
    );

    // Prepare expectation for null
    final future = expectLater(
      stream,
      emitsThrough(
        predicate<AsyncValue<User?>>(
          (value) => value is AsyncData && value.value == null,
        ),
      ),
    );

    // Clear session
    await container.read(sessionProvider.notifier).clear();

    // Wait for expectation
    await future;
  });

  test('clears session if fetchUser returns null (invalid session)', () async {
    when(
      () => mockUserRepository.fetchUser('invalid-session'),
    ).thenAnswer((_) async => null);

    final container = createContainer(initialSession: 'invalid-session');

    // Trigger
    container.read(userProvider);

    // Wait for async operations
    await Future.delayed(const Duration(milliseconds: 50));

    // Session should be cleared
    verify(() => mockStorageService.remove(any())).called(1);

    // User state should eventually be null (reset by session listener)
    final state = container.read(userProvider);
    expect(state, isA<AsyncData<User?>>());
    expect(state.value, null);
  });

  test('handles fetch errors gracefully', () async {
    final exception = Exception('Network error');
    when(
      () => mockUserRepository.fetchUser('session-123'),
    ).thenAnswer((_) async => throw exception);

    final container = createContainer(initialSession: 'session-123');

    container.read(userProvider);

    await Future.delayed(const Duration(milliseconds: 50));

    final state = container.read(userProvider);
    expect(state, isA<AsyncError>());
    expect((state as AsyncError).error, exception);
  });
}
