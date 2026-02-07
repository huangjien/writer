import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/features/settings/widgets/enhanced_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/ai_agent_settings.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/storage_service.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/services/sync_service.dart';
import 'package:writer/models/sync_state.dart';
import 'package:writer/state/sync_service_provider.dart';

class MockBiometricService extends Mock implements BiometricService {}

class MockSyncService extends Mock implements SyncService {}

class MockStorageService implements StorageService {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Toggling Reduce Motion switch updates provider state', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Mock biometric service to avoid UnimplementedError
    final mockBiometricService = MockBiometricService();
    when(
      () => mockBiometricService.isBiometricAvailable(),
    ).thenAnswer((_) async => false);
    when(
      () => mockBiometricService.isBiometricEnabled(),
    ).thenAnswer((_) async => false);

    // Mock storage service
    final mockStorageService = MockStorageService();

    // Mock sync service - required by AppLifecycleMonitor in app tree
    final mockSyncService = MockSyncService();
    when(() => mockSyncService.currentSyncState).thenReturn(
      const SyncState(
        status: SyncStatus.synced,
        pendingOperations: 0,
        errorMessage: null,
        lastSyncTime: null,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        motionSettingsProvider.overrideWith(
          (_) => MotionSettingsNotifier.lazy(),
        ),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        aiAgentSettingsProvider.overrideWith(
          (_) => AiAgentSettingsNotifier(prefs),
        ),
        adminModeProvider.overrideWith((_) => AdminModeNotifier(prefs)),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(mockStorageService),
        ),
        isSignedInProvider.overrideWithValue(false),
        syncServiceProvider.overrideWithValue(mockSyncService),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    )!;

    final textFinder = find.text(l10n.reduceMotion);
    final parentFinder = find.ancestor(
      of: textFinder,
      matching: find.byType(SettingsToggle),
    );

    await tester.pump();

    final toggleFinder = find.descendant(
      of: parentFinder,
      matching: find.byType(NeumorphicSwitch),
    );
    expect(toggleFinder, findsOneWidget);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isTrue);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isFalse);
  });
}
