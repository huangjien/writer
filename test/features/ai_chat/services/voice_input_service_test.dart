import 'package:flutter_test/flutter_test.dart';
import 'package:writer/features/ai_chat/services/voice_input_service.dart';

void main() {
  group('VoiceInputService Tests', () {
    late VoiceInputService service;

    setUp(() {
      service = VoiceInputService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initial state is correct', () {
      expect(service.isInitialized, false);
      expect(service.isListening, false);
      expect(service.lastWords, '');
      expect(service.localeId, 'en_US');
      expect(service.confidence, 0.0);
    });

    test('isInitialized returns false before initialization', () {
      expect(service.isInitialized, false);
    });

    test('isListening returns false initially', () {
      expect(service.isListening, false);
    });

    test('lastWords returns empty string initially', () {
      expect(service.lastWords, '');
    });

    test('localeId defaults to en_US', () {
      expect(service.localeId, 'en_US');
    });

    test('confidence defaults to 0.0', () {
      expect(service.confidence, 0.0);
    });

    test('dispose can be called multiple times', () {
      service.dispose();
      service.dispose();
      expect(true, true);
    });

    test('service can be created and disposed', () {
      final testService = VoiceInputService();
      expect(testService.isInitialized, false);
      testService.dispose();
    });

    test('multiple services can coexist', () {
      final service1 = VoiceInputService();
      final service2 = VoiceInputService();

      expect(service1.isInitialized, false);
      expect(service2.isInitialized, false);

      service1.dispose();
      service2.dispose();
    });
  });

  group('VoiceInputService Edge Cases', () {
    test('handles rapid dispose cycles', () {
      final service = VoiceInputService();
      for (var i = 0; i < 10; i++) {
        service.dispose();
      }
    });

    test('handles null operations gracefully', () {
      final service = VoiceInputService();
      expect(service.isListening, false);
      service.dispose();
    });
  });
}
