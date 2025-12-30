import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/settings_screen.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/admin_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/theme_controller.dart';
import 'package:writer/services/biometric_service.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/services/storage_service.dart';

class MockBiometricService extends Mock implements BiometricService {}

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

    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        motionSettingsProvider.overrideWith(
          (_) => MotionSettingsNotifier.lazy(),
        ),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
        adminModeProvider.overrideWith((_) => AdminModeNotifier(prefs)),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(mockStorageService),
        ),
        isSignedInProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure the tile is visible
    final textFinder = find.text('Reduce motion');
    expect(
      textFinder,
      findsOneWidget,
      reason: 'Should find text "Reduce motion"',
    );

    final tileFinder = find.ancestor(
      of: textFinder,
      matching: find.byType(SwitchListTile),
    );
    expect(
      tileFinder,
      findsOneWidget,
      reason: 'Should find SwitchListTile ancestor',
    );

    // Initial state should be false
    expect(container.read(motionSettingsProvider).reduceMotion, isFalse);

    // Tap to enable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isTrue);

    // Tap again to disable
    await tester.tap(tileFinder);
    await tester.pumpAndSettle();
    expect(container.read(motionSettingsProvider).reduceMotion, isFalse);
  });
}
