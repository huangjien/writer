import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/state/ai_service_settings.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AiServiceSettings', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
    });

    test(
      'AiServiceNotifier initializes with default URL when no saved value',
      () {
        when(() => mockPrefs.getString('ai_service_url')).thenReturn(null);

        final notifier = AiServiceNotifier(mockPrefs);

        expect(notifier.state, 'http://localhost:5600/');
        verify(() => mockPrefs.getString('ai_service_url')).called(1);
      },
    );

    test('AiServiceNotifier initializes with saved URL when available', () {
      const savedUrl = 'http://example.com:8080/';
      when(() => mockPrefs.getString('ai_service_url')).thenReturn(savedUrl);

      final notifier = AiServiceNotifier(mockPrefs);

      expect(notifier.state, savedUrl);
      verify(() => mockPrefs.getString('ai_service_url')).called(1);
    });

    test('setAiServiceUrl updates state and saves to preferences', () async {
      const newUrl = 'http://new-service:9000/';
      when(() => mockPrefs.getString('ai_service_url')).thenReturn(null);
      when(
        () => mockPrefs.setString('ai_service_url', newUrl),
      ).thenAnswer((_) async => true);

      final notifier = AiServiceNotifier(mockPrefs);
      await notifier.setAiServiceUrl(newUrl);

      expect(notifier.state, newUrl);
      verify(() => mockPrefs.setString('ai_service_url', newUrl)).called(1);
    });

    test('resetToDefault resets to default URL', () async {
      const currentUrl = 'http://example.com:8080/';
      when(() => mockPrefs.getString('ai_service_url')).thenReturn(currentUrl);
      when(
        () => mockPrefs.setString('ai_service_url', 'http://localhost:5600/'),
      ).thenAnswer((_) async => true);

      final notifier = AiServiceNotifier(mockPrefs);
      await notifier.resetToDefault();

      expect(notifier.state, 'http://localhost:5600/');
      verify(
        () => mockPrefs.setString('ai_service_url', 'http://localhost:5600/'),
      ).called(1);
    });
  });
}
