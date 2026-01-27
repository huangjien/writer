import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/features/settings/widgets/app_settings_section.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/repositories/local_storage_repository.dart';
import 'package:writer/shared/widgets/app_dialog.dart';
import 'package:writer/state/ai_service_settings.dart';
import 'package:writer/state/app_settings.dart';
import 'package:writer/state/biometric_session_state.dart';
import 'package:writer/state/motion_settings.dart';
import 'package:writer/state/providers.dart';
import 'package:writer/state/session_state.dart';
import 'package:writer/state/storage_service_provider.dart';
import 'package:writer/state/theme_controller.dart';

class _FakeBiometricService extends BiometricService {
  @override
  Future<bool> isBiometricAvailable() async => false;

  @override
  Future<bool> isBiometricEnabled() async => false;
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required SharedPreferences prefs,
  required Size size,
  required TextScaler textScaler,
}) async {
  final storageService = LocalStorageService(prefs);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageRepositoryProvider.overrideWithValue(
          LocalStorageRepository(storageService),
        ),
        biometricServiceProvider.overrideWithValue(_FakeBiometricService()),
        sessionProvider.overrideWith((ref) => SessionNotifier(storageService)),
        appSettingsProvider.overrideWith((_) => AppSettingsNotifier(prefs)),
        themeControllerProvider.overrideWith((_) => ThemeController(prefs)),
        motionSettingsProvider.overrideWith(
          (_) => MotionSettingsNotifier(prefs),
        ),
        aiServiceProvider.overrideWith((_) => AiServiceNotifier(prefs)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(size: size, textScaler: textScaler),
          child: const Scaffold(
            body: SingleChildScrollView(child: AppSettingsSection()),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('AI Service URL dialog is responsive and interactive', (
    tester,
  ) async {
    final oldPhysicalSize = tester.view.physicalSize;
    final oldDevicePixelRatio = tester.view.devicePixelRatio;
    addTearDown(() {
      tester.view.physicalSize = oldPhysicalSize;
      tester.view.devicePixelRatio = oldDevicePixelRatio;
    });

    final sizes = <Size>[
      const Size(320, 568),
      const Size(390, 844),
      const Size(1024, 768),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await _pumpHost(
        tester,
        prefs: prefs,
        size: size,
        textScaler: const TextScaler.linear(1.4),
      );

      final editButton = find.byIcon(Icons.edit);
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppDialog), findsOneWidget);
      final urlField = find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(TextField),
      );

      await tester.enterText(urlField.first, 'invalid-url');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text('URL must start with http:// or https://.'),
        findsOneWidget,
      );

      await tester.enterText(urlField.first, 'http://valid.com');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.text('URL must start with http:// or https://.'),
        findsNothing,
      );
      await tester.tap(urlField.first);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppDialog), findsNothing);
      expect(find.text('http://valid.com'), findsOneWidget);
    }
  });
}
