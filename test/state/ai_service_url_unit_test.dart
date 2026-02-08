import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/ai_service_settings.dart';

void main() {
  group('AiServiceNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    group('URL persistence', () {
      test('should save and load URL from SharedPreferences', () async {
        final notifier = AiServiceNotifier(prefs);
        const testUrl = 'https://api.example.com/v1';

        await notifier.setAiServiceUrl(testUrl);
        expect(notifier.state, testUrl);
        expect(prefs.getString('ai_service_url'), testUrl);
      });

      test('should load default URL when none is saved', () {
        final notifier = AiServiceNotifier(prefs);

        expect(notifier.state, isNotEmpty);
        expect(notifier.state, contains('http'));
      });

      test('should update URL when new valid URL is set', () async {
        final notifier = AiServiceNotifier(prefs);
        const initialUrl = 'https://initial.example.com';
        const newUrl = 'https://new.example.com/v1';

        await notifier.setAiServiceUrl(initialUrl);
        expect(notifier.state, initialUrl);

        await notifier.setAiServiceUrl(newUrl);
        expect(notifier.state, newUrl);
        expect(prefs.getString('ai_service_url'), newUrl);
      });

      test('should persist URL changes to disk', () async {
        final notifier = AiServiceNotifier(prefs);
        const testUrl = 'https://persistent.example.com';

        await notifier.setAiServiceUrl(testUrl);

        final newNotifier = AiServiceNotifier(prefs);
        expect(
          newNotifier.state,
          testUrl,
          reason: 'Should load persisted URL from SharedPreferences',
        );
      });
    });

    group('State management', () {
      test('should notify listeners when URL changes', () async {
        final notifier = AiServiceNotifier(prefs);
        const newUrl = 'https://api.example.com';

        final states = <String>[];
        final subscription = notifier.stream.listen(states.add);

        await notifier.setAiServiceUrl(newUrl);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(
          states,
          isNotEmpty,
          reason: 'Should emit new state when URL changes',
        );
        expect(
          states.contains(newUrl),
          isTrue,
          reason: 'Should contain the new URL',
        );

        await subscription.cancel();
      });

      test('should update state synchronously after setAiServiceUrl', () async {
        final notifier = AiServiceNotifier(prefs);
        const newUrl = 'https://example.com/api';

        await notifier.setAiServiceUrl(newUrl);
        expect(notifier.state, newUrl);
      });
    });

    group('Reset functionality', () {
      test('should reset to default URL', () async {
        final notifier = AiServiceNotifier(prefs);
        const customUrl = 'https://custom.example.com';

        await notifier.setAiServiceUrl(customUrl);
        expect(notifier.state, customUrl);

        await notifier.resetToDefault();

        expect(
          notifier.state,
          isNot(customUrl),
          reason: 'Should reset to default URL',
        );
        expect(
          notifier.state,
          'http://localhost:5600/',
          reason: 'Should be default URL',
        );
      });
    });

    group('URL format handling', () {
      test('should handle URLs with query parameters', () async {
        final notifier = AiServiceNotifier(prefs);
        const urlWithQuery =
            'https://api.example.com/v1?key=value&param2=value2';

        await notifier.setAiServiceUrl(urlWithQuery);
        expect(notifier.state, urlWithQuery);
      });

      test('should handle URLs with ports', () async {
        final notifier = AiServiceNotifier(prefs);
        const urlWithPort = 'https://example.com:8443/api';

        await notifier.setAiServiceUrl(urlWithPort);
        expect(notifier.state, urlWithPort);
      });

      test('should handle URLs with trailing slashes', () async {
        final notifier = AiServiceNotifier(prefs);
        const urlWithSlash = 'https://example.com/api/';
        const urlWithoutSlash = 'https://example.com/api';

        await notifier.setAiServiceUrl(urlWithSlash);
        expect(notifier.state, urlWithSlash);

        await notifier.setAiServiceUrl(urlWithoutSlash);
        expect(notifier.state, urlWithoutSlash);
      });

      test('should handle localhost URLs', () async {
        final notifier = AiServiceNotifier(prefs);
        const localhostUrl = 'http://localhost:8080/api';

        await notifier.setAiServiceUrl(localhostUrl);
        expect(notifier.state, localhostUrl);
      });

      test('should handle IP address URLs', () async {
        final notifier = AiServiceNotifier(prefs);
        const ipUrl = 'http://192.168.1.1:3000/api';

        await notifier.setAiServiceUrl(ipUrl);
        expect(notifier.state, ipUrl);
      });
    });

    group('Edge cases', () {
      test('should handle empty string as URL', () async {
        final notifier = AiServiceNotifier(prefs);
        const emptyUrl = '';

        await notifier.setAiServiceUrl(emptyUrl);
        expect(notifier.state, emptyUrl);
      });

      test('should handle URL with special characters', () async {
        final notifier = AiServiceNotifier(prefs);
        const urlWithSpecialChars =
            'https://example.com/api?key=value&name=test%20name';

        await notifier.setAiServiceUrl(urlWithSpecialChars);
        expect(notifier.state, urlWithSpecialChars);
      });

      test('should handle URL with fragments', () async {
        final notifier = AiServiceNotifier(prefs);
        const urlWithFragment = 'https://example.com/page#section';

        await notifier.setAiServiceUrl(urlWithFragment);
        expect(notifier.state, urlWithFragment);
      });
    });
  });
}
