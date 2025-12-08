import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'isAdminProvider: Supabase disabled falls back to adminModeProvider',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          supabaseEnabledProvider.overrideWith((_) => false),
          adminModeProvider.overrideWith((ref) {
            final n = AdminModeNotifier(prefs);
            return n;
          }),
        ],
      );
      final n = container.read(adminModeProvider.notifier);
      await n.enable();
      final isAdmin = container.read(isAdminProvider);
      expect(isAdmin, isTrue);
    },
  );

  test('isAdminProvider: reads roles and role from session', () async {
    final session = MockSession();
    final user = MockUser();
    when(() => session.user).thenReturn(user);
    when(() => user.appMetadata).thenReturn({
      'roles': ['admin'],
    });

    final container = ProviderContainer(
      overrides: [
        supabaseEnabledProvider.overrideWith((_) => true),
        supabaseSessionProvider.overrideWith((_) => session),
      ],
    );
    final isAdmin = container.read(isAdminProvider);
    expect(isAdmin, isTrue);

    when(() => user.appMetadata).thenReturn({'role': 'admin'});
    final isAdmin2 = container.read(isAdminProvider);
    expect(isAdmin2, isTrue);
  });

  test(
    'promptsServiceProvider uses aiServiceProvider base URL when available',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AiServiceNotifier(prefs);
      await notifier.setAiServiceUrl('http://unit.test');
      final container = ProviderContainer(
        overrides: [aiServiceProvider.overrideWith((ref) => notifier)],
      );
      final svc = container.read(promptsServiceProvider);
      expect(svc.baseUrl, 'http://unit.test');
    },
  );
}
