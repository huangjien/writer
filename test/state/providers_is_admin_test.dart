import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('isAdminProvider reads adminModeProvider', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        adminModeProvider.overrideWith((ref) {
          return AdminModeNotifier(prefs);
        }),
      ],
    );
    addTearDown(container.dispose);

    final n = container.read(adminModeProvider.notifier);
    await n.enable();
    expect(container.read(isAdminProvider), isTrue);

    await n.disable();
    expect(container.read(isAdminProvider), isFalse);
  });

  test(
    'promptsServiceProvider uses aiServiceProvider base URL when available',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = AiServiceNotifier(prefs);
      await notifier.setAiServiceUrl('http://unit.test');
      final storageService = LocalStorageService(prefs);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          aiServiceProvider.overrideWith((ref) => notifier),
          sessionProvider.overrideWith(
            (ref) => SessionNotifier(storageService),
          ),
        ],
      );
      final svc = container.read(promptsServiceProvider);
      expect(svc.baseUrl, 'http://unit.test');
    },
  );
}
