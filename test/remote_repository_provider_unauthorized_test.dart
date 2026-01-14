import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/repositories/remote_repository.dart';
import 'package:writer/services/auth_redirect_service.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

class _FakeAuthRedirectService extends AuthRedirectService {
  _FakeAuthRedirectService() : super(GlobalKey<NavigatorState>());

  int redirects = 0;

  @override
  Future<void> redirectToLogin(Ref ref, {String? currentPath}) async {
    redirects++;
  }
}

void main() {
  test(
    'remoteRepositoryProvider clears session and redirects on 401',
    () async {
      SharedPreferences.setMockInitialValues({'backend_session_id': 'sid_1'});
      final prefs = await SharedPreferences.getInstance();

      int calls = 0;
      final client = MockClient((request) async {
        calls++;
        final keys = request.headers.keys.map((k) => k.toLowerCase()).toSet();
        if (calls == 1) {
          expect(keys.contains('x-session-id'), true);
          return http.Response('unauthorized', 401);
        }
        expect(keys.contains('x-session-id'), false);
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final fakeRedirect = _FakeAuthRedirectService();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          httpClientProvider.overrideWithValue(client),
          authRedirectServiceProvider.overrideWithValue(fakeRedirect),
        ],
      );

      final remote = container.read(remoteRepositoryProvider);
      final res = await remote.get('anything');
      expect((res as Map<String, dynamic>)['ok'], true);

      expect(fakeRedirect.redirects, 1);
      expect(container.read(sessionProvider), isNull);

      container.dispose();
    },
  );
}
