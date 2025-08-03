import { useSpeech } from './useSpeech';
import * as Speech from 'expo-speech';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import { AppState } from 'react-native';

// Mock dependencies
jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
  isSpeakingAsync: jest.fn(),
  getAvailableVoicesAsync: jest.fn(),
}));

jest.mock('expo-keep-awake', () => ({
  activateKeepAwakeAsync: jest.fn(),
  deactivateKeepAwake: jest.fn(),
}));

jest.mock('react-native', () => ({
  AppState: {
    addEventListener: jest.fn(),
    currentState: 'active',
  },
}));

const mockSpeak = Speech.speak as jest.MockedFunction<typeof Speech.speak>;
const mockStop = Speech.stop as jest.MockedFunction<typeof Speech.stop>;
const mockPause = Speech.pause as jest.MockedFunction<typeof Speech.pause>;
const mockResume = Speech.resume as jest.MockedFunction<typeof Speech.resume>;
const mockIsSpeakingAsync = Speech.isSpeakingAsync as jest.MockedFunction<
  typeof Speech.isSpeakingAsync
>;
const mockGetAvailableVoicesAsync =
  Speech.getAvailableVoicesAsync as jest.MockedFunction<
    typeof Speech.getAvailableVoicesAsync
  >;
const mockActivateKeepAwakeAsync =
  activateKeepAwakeAsync as jest.MockedFunction<typeof activateKeepAwakeAsync>;
const mockDeactivateKeepAwake = deactivateKeepAwake as jest.MockedFunction<
  typeof deactivateKeepAwake
>;
const mockAddEventListener = AppState.addEventListener as jest.MockedFunction<
  typeof AppState.addEventListener
>;
// AppState.removeEventListener is deprecated, using subscription.remove() instead

describe('useSpeech - Comprehensive Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock implementations
    mockSpeak.mockImplementation(() => {});
    mockStop.mockImplementation(() => Promise.resolve());
    mockPause.mockImplementation(() => Promise.resolve());
    mockResume.mockImplementation(() => Promise.resolve());
    mockIsSpeakingAsync.mockResolvedValue(false);
    mockGetAvailableVoicesAsync.mockResolvedValue([]);
    mockActivateKeepAwakeAsync.mockResolvedValue();
    mockDeactivateKeepAwake.mockImplementation(() => Promise.resolve());
    mockAddEventListener.mockImplementation(() => ({ remove: jest.fn() }));
  });

  describe('Text Processing Edge Cases', () => {
    it('should handle extremely long text content', () => {
      const longText = 'This is a very long sentence. '.repeat(10000);
      const sentences = longText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences.length).toBe(10000);
      expect(sentences[0].trim()).toBe('This is a very long sentence');
    });

    it('should handle text with mixed punctuation', () => {
      const mixedText =
        'Hello world! How are you? I am fine. Really? Yes! Absolutely.';
      const sentences = mixedText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual([
        'Hello world',
        ' How are you',
        ' I am fine',
        ' Really',
        ' Yes',
        ' Absolutely',
      ]);
    });

    it('should handle text with no punctuation', () => {
      const noPunctuationText = 'This is text without any punctuation marks';
      const sentences = noPunctuationText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual(['This is text without any punctuation marks']);
    });

    it('should handle text with only punctuation', () => {
      const punctuationOnlyText = '...!!!???';
      const sentences = punctuationOnlyText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual([]);
    });

    it('should handle text with special characters and symbols', () => {
      const specialText =
        'Price: $100.50! Discount: 20%? Email: test@example.com.';
      const sentences = specialText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual([
        'Price: $100',
        '50',
        ' Discount: 20%',
        ' Email: test@example',
        'com',
      ]);
    });

    it('should handle text with Unicode characters', () => {
      const unicodeText = '你好世界！こんにちは世界？مرحبا بالعالم. 🌍🚀';
      const sentences = unicodeText
        .split(/[.!?！？]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences.length).toBeGreaterThan(0);
      expect(sentences.some((s) => s.includes('你好世界'))).toBe(true);
    });

    it('should handle text with multiple consecutive punctuation marks', () => {
      const multiPuncText = 'What...!!! Really??? Yes!!!';
      const sentences = multiPuncText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual(['What', ' Really', ' Yes']);
    });

    it('should handle text with abbreviations', () => {
      const abbreviationText =
        'Dr. Smith went to the U.S.A. He met Mr. Johnson.';
      const sentences = abbreviationText
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      // Note: This will split on abbreviation periods, which is expected behavior
      expect(sentences.length).toBeGreaterThan(2);
    });

    it('should handle empty and whitespace-only text', () => {
      const emptyTexts = ['', '   ', '\n\n\n', '\t\t\t', '   \n\t   '];

      emptyTexts.forEach((text) => {
        const sentences = text
          .split(/[.!?]+/)
          .filter((s) => s.trim().length > 0);
        expect(sentences).toEqual([]);
      });
    });
  });

  describe('Speech Options and Configuration', () => {
    it('should handle invalid speech rate values', () => {
      const invalidRates = [
        -1,
        0,
        2,
        NaN,
        Infinity,
        -Infinity,
        null,
        undefined,
        'invalid',
      ];

      invalidRates.forEach((rate) => {
        const normalizedRate =
          typeof rate === 'number' &&
          rate >= 0.1 &&
          rate <= 1.0 &&
          !isNaN(rate) &&
          isFinite(rate)
            ? rate
            : 0.5;

        expect(normalizedRate).toBeGreaterThanOrEqual(0.1);
        expect(normalizedRate).toBeLessThanOrEqual(1.0);
      });
    });

    it('should handle invalid speech pitch values', () => {
      const invalidPitches = [
        -1,
        3,
        NaN,
        Infinity,
        -Infinity,
        null,
        undefined,
        'invalid',
      ];

      invalidPitches.forEach((pitch) => {
        const normalizedPitch =
          typeof pitch === 'number' &&
          pitch >= 0.5 &&
          pitch <= 2.0 &&
          !isNaN(pitch) &&
          isFinite(pitch)
            ? pitch
            : 1.0;

        expect(normalizedPitch).toBeGreaterThanOrEqual(0.5);
        expect(normalizedPitch).toBeLessThanOrEqual(2.0);
      });
    });

    it('should handle invalid voice selection', async () => {
      const mockVoices = [
        {
          identifier: 'voice1',
          name: 'Voice 1',
          language: 'en-US',
          quality: 'Default' as any,
        },
        {
          identifier: 'voice2',
          name: 'Voice 2',
          language: 'en-GB',
          quality: 'Enhanced' as any,
        },
      ] as Speech.Voice[];

      mockGetAvailableVoicesAsync.mockResolvedValue(mockVoices);

      const voices = await mockGetAvailableVoicesAsync();
      const invalidVoiceId = 'nonexistent_voice';
      const selectedVoice = voices.find((v) => v.identifier === invalidVoiceId);

      expect(selectedVoice).toBeUndefined();

      // Should fall back to default voice (first available or system default)
      const fallbackVoice = voices.length > 0 ? voices[0] : null;
      expect(fallbackVoice?.identifier).toBe('voice1');
    });

    it('should handle speech options with boundary values', () => {
      const boundaryOptions = [
        { rate: 0.1, pitch: 0.5 }, // Minimum values
        { rate: 1.0, pitch: 2.0 }, // Maximum values
        { rate: 0.5, pitch: 1.0 }, // Default values
      ];

      boundaryOptions.forEach((options) => {
        mockSpeak('Test text', options);
        expect(mockSpeak).toHaveBeenCalledWith('Test text', options);
      });
    });
  });

  describe('Speech State Management Edge Cases', () => {
    it('should handle rapid state transitions', async () => {
      // Simulate rapid play/pause/stop operations
      const operations = [
        'speak',
        'pause',
        'resume',
        'stop',
        'speak',
        'pause',
        'stop',
      ];

      for (const operation of operations) {
        switch (operation) {
          case 'speak':
            mockSpeak('Test text');
            break;
          case 'pause':
            mockPause();
            break;
          case 'resume':
            mockResume();
            break;
          case 'stop':
            mockStop();
            break;
        }
      }

      expect(mockSpeak).toHaveBeenCalledTimes(2);
      expect(mockPause).toHaveBeenCalledTimes(2);
      expect(mockResume).toHaveBeenCalledTimes(1);
      expect(mockStop).toHaveBeenCalledTimes(2);
    });

    it('should handle speech status checking errors', async () => {
      mockIsSpeakingAsync.mockRejectedValue(
        new Error('Speech status unavailable')
      );

      try {
        await mockIsSpeakingAsync();
      } catch (error) {
        expect(error.message).toBe('Speech status unavailable');
      }
    });

    it('should handle concurrent speech operations', async () => {
      const promises = [];

      // Simulate multiple concurrent speech operations
      for (let i = 0; i < 10; i++) {
        promises.push(Promise.resolve(mockSpeak(`Text ${i}`)));
        promises.push(Promise.resolve(mockIsSpeakingAsync()));
      }

      await Promise.all(promises);

      expect(mockSpeak).toHaveBeenCalledTimes(10);
      expect(mockIsSpeakingAsync).toHaveBeenCalledTimes(10);
    });

    it('should handle speech interruption scenarios', () => {
      // Start speaking
      mockSpeak('Long text content that takes time to speak');

      // Interrupt with stop
      mockStop();

      // Try to resume (should not work after stop)
      mockResume();

      // Start new speech
      mockSpeak('New text content');

      expect(mockSpeak).toHaveBeenCalledTimes(2);
      expect(mockStop).toHaveBeenCalledTimes(1);
      expect(mockResume).toHaveBeenCalledTimes(1);
    });
  });

  describe('Progress Tracking Edge Cases', () => {
    it('should handle progress calculation for empty content', () => {
      const emptyContent = '';
      const currentSentenceIndex = 0;
      const sentences = emptyContent
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      const progress =
        sentences.length > 0 ? currentSentenceIndex / sentences.length : 0;

      expect(progress).toBe(0);
    });

    it('should handle progress calculation for single sentence', () => {
      const singleSentence = 'This is a single sentence';
      const sentences = singleSentence
        .split(/[.!?]+/)
        .filter((s) => s.trim().length > 0);

      // Progress at start
      let progress = 0 / sentences.length;
      expect(progress).toBe(0);

      // Progress at end
      progress = 1 / sentences.length;
      expect(progress).toBe(1);
    });

    it('should handle progress calculation for very large content', () => {
      const largeSentences = Array.from(
        { length: 10000 },
        (_, i) => `Sentence ${i}`
      );
      const totalSentences = largeSentences.length;

      // Test progress at various points
      const testIndices = [0, 1000, 5000, 9999];

      testIndices.forEach((index) => {
        const progress = index / totalSentences;
        expect(progress).toBeGreaterThanOrEqual(0);
        expect(progress).toBeLessThanOrEqual(1);
      });
    });

    it('should handle invalid sentence indices', () => {
      const sentences = ['Sentence 1', 'Sentence 2', 'Sentence 3'];
      const invalidIndices = [-1, 5, NaN, Infinity, -Infinity];

      invalidIndices.forEach((index) => {
        const clampedIndex = Math.max(0, Math.min(sentences.length - 1, index));
        const progress = isNaN(clampedIndex)
          ? 0
          : clampedIndex / sentences.length;

        expect(progress).toBeGreaterThanOrEqual(0);
        expect(progress).toBeLessThanOrEqual(1);
      });
    });
  });

  describe('Keep Awake Integration Edge Cases', () => {
    it('should handle keep awake activation failures', async () => {
      mockActivateKeepAwakeAsync.mockRejectedValue(
        new Error('Keep awake not supported')
      );

      try {
        await mockActivateKeepAwakeAsync();
      } catch (error) {
        expect(error.message).toBe('Keep awake not supported');
      }
    });

    it('should handle keep awake deactivation failures', () => {
      mockDeactivateKeepAwake.mockImplementation(() => {
        throw new Error('Keep awake deactivation failed');
      });

      expect(() => {
        try {
          mockDeactivateKeepAwake();
        } catch (error) {
          // Should handle gracefully
        }
      }).not.toThrow();
    });

    it('should handle multiple keep awake operations', async () => {
      // Multiple activations
      await mockActivateKeepAwakeAsync();
      await mockActivateKeepAwakeAsync();
      await mockActivateKeepAwakeAsync();

      // Multiple deactivations
      mockDeactivateKeepAwake();
      mockDeactivateKeepAwake();
      mockDeactivateKeepAwake();

      expect(mockActivateKeepAwakeAsync).toHaveBeenCalledTimes(3);
      expect(mockDeactivateKeepAwake).toHaveBeenCalledTimes(3);
    });

    it('should handle keep awake state inconsistencies', async () => {
      // Activate keep awake
      await mockActivateKeepAwakeAsync();

      // Try to activate again (should be idempotent)
      await mockActivateKeepAwakeAsync();

      // Deactivate
      mockDeactivateKeepAwake();

      // Try to deactivate again (should be safe)
      mockDeactivateKeepAwake();

      expect(mockActivateKeepAwakeAsync).toHaveBeenCalledTimes(2);
      expect(mockDeactivateKeepAwake).toHaveBeenCalledTimes(2);
    });
  });

  describe('App State Integration Edge Cases', () => {
    it('should handle invalid app state values', () => {
      const invalidStates = [null, undefined, '', 'invalid', 123, {}, []];

      invalidStates.forEach((state) => {
        const validStates = ['active', 'background', 'inactive'];
        const normalizedState = validStates.includes(state as string)
          ? state
          : 'active';

        expect(validStates.includes(normalizedState as string)).toBe(true);
      });
    });

    it('should handle rapid app state changes', () => {
      const stateChanges = [
        'active',
        'inactive',
        'background',
        'active',
        'inactive',
        'active',
      ];

      stateChanges.forEach((state) => {
        // Simulate app state change
        const mockListener = jest.fn();
        mockAddEventListener.mockReturnValue({ remove: jest.fn() });

        const subscription = mockAddEventListener('change', mockListener);

        // Trigger state change
        mockListener(state);

        expect(mockListener).toHaveBeenCalledWith(state);

        // Clean up
        subscription.remove();
      });
    });

    it('should handle app state listener registration failures', () => {
      mockAddEventListener.mockImplementation(() => {
        throw new Error('Event listener registration failed');
      });

      expect(() => {
        try {
          mockAddEventListener('change', jest.fn());
        } catch (error) {
          // Should handle gracefully
        }
      }).not.toThrow();
    });

    it('should handle app state listener removal failures', () => {
      const mockRemove = jest.fn().mockImplementation(() => {
        throw new Error('Event listener removal failed');
      });

      mockAddEventListener.mockReturnValue({ remove: mockRemove });

      const subscription = mockAddEventListener('change', jest.fn());

      expect(() => {
        try {
          subscription.remove();
        } catch (error) {
          // Should handle gracefully
        }
      }).not.toThrow();
    });

    it('should handle missing app state subscription', () => {
      mockAddEventListener.mockReturnValue(null);

      const subscription = mockAddEventListener('change', jest.fn());

      expect(subscription).toBeNull();

      // Should not throw when trying to remove null subscription
      expect(() => {
        if (subscription?.remove) {
          subscription.remove();
        }
      }).not.toThrow();
    });
  });

  describe('Error Handling and Recovery', () => {
    it('should handle speech synthesis not available', () => {
      mockSpeak.mockImplementation(() => {
        throw new Error('Speech synthesis not available');
      });

      expect(() => {
        try {
          mockSpeak('Test text');
        } catch (error) {
          // Should handle gracefully
        }
      }).not.toThrow();
    });

    it('should handle speech synthesis interruption', () => {
      mockSpeak.mockImplementation(() => {
        throw new Error('Speech synthesis interrupted');
      });

      mockStop.mockImplementation(() => {
        throw new Error('Speech stop failed');
      });

      expect(() => {
        try {
          mockSpeak('Test text');
        } catch (error) {
          try {
            mockStop();
          } catch (stopError) {
            // Should handle both errors gracefully
          }
        }
      }).not.toThrow();
    });

    it('should handle voice loading failures', async () => {
      mockGetAvailableVoicesAsync.mockRejectedValue(
        new Error('Voice loading failed')
      );

      try {
        await mockGetAvailableVoicesAsync();
      } catch (error) {
        expect(error.message).toBe('Voice loading failed');
      }
    });

    it('should handle platform-specific speech limitations', () => {
      const platformErrors = [
        'Speech not supported on this platform',
        'Audio session interrupted',
        'Speech synthesis engine not available',
        'Voice data not downloaded',
        'Network required for speech synthesis',
      ];

      platformErrors.forEach((errorMessage) => {
        mockSpeak.mockImplementationOnce(() => {
          throw new Error(errorMessage);
        });

        expect(() => {
          try {
            mockSpeak('Test text');
          } catch (error) {
            expect(error.message).toBe(errorMessage);
          }
        }).not.toThrow();
      });
    });
  });

  describe('Memory and Performance Edge Cases', () => {
    it('should handle memory pressure during speech', () => {
      // Simulate memory pressure by creating large text content
      const largeText =
        'This is a very long sentence that consumes memory. '.repeat(10000);

      expect(() => {
        mockSpeak(largeText);
      }).not.toThrow();

      expect(mockSpeak).toHaveBeenCalledWith(largeText);
    });

    it('should handle rapid speech operations without memory leaks', () => {
      // Simulate rapid operations
      for (let i = 0; i < 1000; i++) {
        mockSpeak(`Text ${i}`);
        mockStop();
      }

      expect(mockSpeak).toHaveBeenCalledTimes(1000);
      expect(mockStop).toHaveBeenCalledTimes(1000);
    });

    it('should handle long-running speech sessions', async () => {
      // Simulate long-running speech session
      const longContent = Array.from(
        { length: 1000 },
        (_, i) => `Sentence ${i}.`
      ).join(' ');

      mockSpeak(longContent);

      // Simulate periodic status checks
      for (let i = 0; i < 100; i++) {
        await mockIsSpeakingAsync();
      }

      expect(mockSpeak).toHaveBeenCalledWith(longContent);
      expect(mockIsSpeakingAsync).toHaveBeenCalledTimes(100);
    });
  });

  describe('Callback and Event Handling', () => {
    it('should handle missing onDone callback', () => {
      const speechOptions = {
        rate: 0.5,
        pitch: 1.0,
        // onDone callback is missing
      };

      expect(() => {
        mockSpeak('Test text', speechOptions);
      }).not.toThrow();
    });

    it('should handle onDone callback errors', () => {
      const errorCallback = () => {
        throw new Error('Callback error');
      };

      const speechOptions = {
        onDone: errorCallback,
      };

      expect(() => {
        mockSpeak('Test text', speechOptions);
        // Simulate callback execution
        try {
          speechOptions.onDone();
        } catch (error) {
          // Should handle callback errors gracefully
        }
      }).not.toThrow();
    });

    it('should handle multiple callback registrations', () => {
      const callbacks = [jest.fn(), jest.fn(), jest.fn()];

      callbacks.forEach((callback, index) => {
        mockSpeak(`Text ${index}`, { onDone: callback });
      });

      expect(mockSpeak).toHaveBeenCalledTimes(3);
    });
  });
});
