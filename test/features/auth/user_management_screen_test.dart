import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:writer/features/auth/user_management_screen.dart';
import 'package:writer/models/user.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/user_state.dart';
import 'package:writer/repositories/user_repository.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<User?> fetchUser(String sessionId) async {
    return User(id: 'admin', email: 'admin@example.com');
  }
}

class MockStorageService implements StorageService {
  String? _sessionId;

  @override
  String? getString(String key) =>
      key == 'backend_session_id' ? _sessionId : null;

  @override
  Future<void> setString(String key, String? value) async {
    if (key == 'backend_session_id') {
      _sessionId = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    if (key == 'backend_session_id') {
      _sessionId = null;
    }
  }

  @override
  Set<String> getKeys() => {'backend_session_id'};
}

class MockSessionNotifier extends SessionNotifier {
  MockSessionNotifier(String? initial) : super(MockStorageService()) {
    state = initial;
  }
}

class MockUserStateNotifier extends UserStateNotifier {
  MockUserStateNotifier(Ref ref, AsyncValue<User?>? initial)
    : super(ref, MockUserRepository(), initial);

  @override
  void init() {}
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  testWidgets('UserManagementScreen shows access denied for non-admin', (
    tester,
  ) async {
    final client = MockClient((request) async {
      // No session provider mock, so session will be null
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => MockSessionNotifier(null),
            ), // No session
            userProvider.overrideWith(
              (ref) => MockUserStateNotifier(ref, null),
            ),
            remoteRepositoryProvider.overrideWith(
              (ref) => RemoteRepository('http://test', client: client),
            ),
          ],
        ),
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: UserManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Error loading users'), findsOneWidget);
    expect(
      find.text('Exception: No active session found. Please log in again.'),
      findsOneWidget,
    );
  });

  testWidgets('UserManagementScreen loads and displays users for admin', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path == '/auth/verify') {
        return http.Response(
          jsonEncode({
            'id': 'admin',
            'email': 'admin@example.com',
            'is_admin': true,
            'is_approved': true,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (request.url.path == '/admin/users') {
        return http.Response(
          jsonEncode({
            'users': [
              {
                'id': 'u1',
                'email': 'user1@example.com',
                'created_at': '2023-01-01',
                'is_approved': false,
              },
              {
                'id': 'u2',
                'email': 'user2@example.com',
                'created_at': '2023-01-02',
                'is_approved': true,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response('Not Found', 404);
    });

    final mockSession = MockSessionNotifier('s-123');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [
            sessionProvider.overrideWith((ref) => mockSession),
            userProvider.overrideWith(
              (ref) => MockUserStateNotifier(ref, null),
            ),
            remoteRepositoryProvider.overrideWith(
              (ref) => RemoteRepository('http://test', client: client),
            ),
          ],
        ),
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: UserManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('user1@example.com'), findsOneWidget);
    expect(find.text('user2@example.com'), findsOneWidget);
    expect(find.byType(NeumorphicSwitch), findsNWidgets(2));
  });

  testWidgets('UserManagementScreen toggles approval', (tester) async {
    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn('http://localhost:5600/');

    bool patchCalled = false;
    final client = MockClient((request) async {
      if (request.url.path == '/auth/verify') {
        return http.Response(
          jsonEncode({
            'id': 'admin',
            'email': 'admin@example.com',
            'is_admin': true,
            'is_approved': true,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (request.method == 'GET' && request.url.path == '/admin/users') {
        return http.Response(
          jsonEncode({
            'users': [
              {
                'id': 'u1',
                'email': 'user1@example.com',
                'created_at': '2023-01-01',
                'is_approved': false,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.method == 'PATCH' &&
          request.url.path.contains('/admin/users/u1/approve')) {
        patchCalled = true;
        return http.Response('{}', 200);
      }
      return http.Response('Not found', 404);
    });

    final mockSession = MockSessionNotifier('s-123');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [
            sessionProvider.overrideWith((ref) => mockSession),
            userProvider.overrideWith(
              (ref) => MockUserStateNotifier(ref, null),
            ),
            aiServiceProvider.overrideWith(
              (ref) => AiServiceNotifier(mockPrefs),
            ),
            remoteRepositoryProvider.overrideWith(
              (ref) => RemoteRepository('http://test', client: client),
            ),
          ],
        ),
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: UserManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Toggle switch
    await tester.tap(find.byType(NeumorphicSwitch).first);
    await tester.pumpAndSettle();

    expect(patchCalled, isTrue);
  });
}
