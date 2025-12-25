import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/auth/user_management_screen.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/user_state.dart';

import 'package:writer/state/ai_service_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSessionNotifier extends SessionNotifier {
  MockSessionNotifier(String? initial) : super(null) {
    state = initial;
  }
}

class MockUserStateNotifier extends UserStateNotifier {
  MockUserStateNotifier(super.ref, super.initial);

  @override
  void init() {}
}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  testWidgets('UserManagementScreen shows access denied for non-admin', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWith(
            (ref) => MockUserStateNotifier(
              ref,
              const AsyncValue.data(null), // Not logged in or not admin
            ),
          ),
        ],
        child: const MaterialApp(home: UserManagementScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Access Denied'), findsOneWidget);
  });

  testWidgets('UserManagementScreen loads and displays users for admin', (
    tester,
  ) async {
    final client = MockClient((request) async {
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
      return http.Response('Not found', 500);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith((ref) => MockSessionNotifier('s-123')),
          userProvider.overrideWith(
            (ref) => MockUserStateNotifier(
              ref,
              AsyncValue.data(User(id: 'admin', isAdmin: true)),
            ),
          ),
        ],
        child: MaterialApp(home: UserManagementScreen(client: client)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('user1@example.com'), findsOneWidget);
    expect(find.text('user2@example.com'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
  });

  testWidgets('UserManagementScreen toggles approval', (tester) async {
    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn('http://localhost:5600/');

    bool patchCalled = false;
    final client = MockClient((request) async {
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
        return http.Response('OK', 200);
      }
      return http.Response('Not found', 404);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith((ref) => MockSessionNotifier('s-123')),
          userProvider.overrideWith(
            (ref) => MockUserStateNotifier(
              ref,
              AsyncValue.data(User(id: 'admin', isAdmin: true)),
            ),
          ),
          aiServiceProvider.overrideWith((ref) => AiServiceNotifier(mockPrefs)),
        ],
        child: MaterialApp(home: UserManagementScreen(client: client)),
      ),
    );

    await tester.pumpAndSettle();

    // Toggle switch
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(patchCalled, isTrue);
  });
}
