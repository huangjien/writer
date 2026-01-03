import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations_en.dart';

void main() {
  group('AppLocalizationsEn', () {
    late AppLocalizationsEn l10n;

    setUp(() {
      l10n = AppLocalizationsEn();
    });

    test('returns correct locale', () {
      expect(l10n.localeName, 'en');
    });

    test('returns non-empty strings for all getters', () {
      expect(l10n.helloWorld, isNotEmpty);
      expect(l10n.settings, isNotEmpty);
      expect(l10n.appTitle, isNotEmpty);
      expect(l10n.about, isNotEmpty);
      expect(l10n.aboutDescription, isNotEmpty);
      expect(l10n.aboutIntro, isNotEmpty);
      expect(l10n.aboutSecurity, isNotEmpty);
      expect(l10n.aboutCoach, isNotEmpty);
      expect(l10n.aboutFeatureCreate, isNotEmpty);
      expect(l10n.aboutFeatureTemplates, isNotEmpty);
      expect(l10n.aboutFeatureTracking, isNotEmpty);
      expect(l10n.aboutFeatureCoach, isNotEmpty);
      expect(l10n.aboutFeaturePrompts, isNotEmpty);
      expect(l10n.aboutUsage, isNotEmpty);
      expect(l10n.aboutUsageList, isNotEmpty);
      expect(l10n.version, isNotEmpty);
      expect(l10n.appLanguage, isNotEmpty);
      expect(l10n.english, isNotEmpty);
      expect(l10n.chinese, isNotEmpty);
      expect(l10n.supabaseIntegrationInitialized, isNotEmpty);
      expect(l10n.configureEnvironment, isNotEmpty);
      expect(l10n.guest, isNotEmpty);
      expect(l10n.notSignedIn, isNotEmpty);
      expect(l10n.signIn, isNotEmpty);
      expect(l10n.continueLabel, isNotEmpty);
    });

    test('signedInAs returns formatted string', () {
      expect(
        l10n.signedInAs('test@example.com'),
        'Signed in as test@example.com',
      );
    });

    test('specific values match expected English text', () {
      expect(l10n.appTitle, 'Writer');
      expect(l10n.settings, 'Settings');
      expect(l10n.helloWorld, 'Hello World!');
    });
  });
}
