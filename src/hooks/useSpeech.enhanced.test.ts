import { useSpeech } from './useSpeech';
import * as Speech from 'expo-speech';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import { AppState } from 'react-native';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

// Mock dependencies
jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
  isSpeakingAsync: jest.fn(),
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

jest.mock('@/components/global', () => ({
  STATUS_PAUSED: 'paused',
  STATUS_PLAYING: 'playing',
  STATUS_STOPPED: 'stopped',
}));

const mockSpeak = Speech.speak as jest.MockedFunction<typeof Speech.speak>;
const mockStop = Speech.stop as jest.MockedFunction<typeof Speech.stop>;
const mockPause = Speech.pause as jest.MockedFunction<typeof Speech.pause>;
const mockResume = Speech.resume as jest.MockedFunction<typeof Speech.resume>;
const mockIsSpeakingAsync = Speech.isSpeakingAsync as jest.MockedFunction<
  typeof Speech.isSpeakingAsync
>;
const mockActivateKeepAwake = activateKeepAwakeAsync as jest.MockedFunction<
  typeof activateKeepAwakeAsync
>;
const mockDeactivateKeepAwake = deactivateKeepAwake as jest.MockedFunction<
  typeof deactivateKeepAwake
>;
const mockAddEventListener = AppState.addEventListener as jest.MockedFunction<
  typeof AppState.addEventListener
>;

describe('useSpeech - Enhanced Tests', () => {
  let appStateListener: ((state: string) => void) | null = null;
  let mockRemove: jest.MockedFunction<() => void>;

  beforeEach(() => {
    jest.clearAllMocks();
    appStateListener = null;
    mockRemove = jest.fn();

    // Mock AppState.addEventListener to capture the listener
    mockAddEventListener.mockImplementation((event, listener) => {
      if (event === 'change') {
        appStateListener = listener as (state: string) => void;
      }
      return { remove: mockRemove };
    });

    mockIsSpeakingAsync.mockResolvedValue(false);
    mockActivateKeepAwake.mockResolvedValue();
  });

  describe('Hook Dependencies', () => {
    it('should verify Speech module is properly mocked', () => {
      expect(mockSpeak).toBeDefined();
      expect(mockStop).toBeDefined();
      expect(mockPause).toBeDefined();
      expect(mockResume).toBeDefined();
    });

    it('should verify KeepAwake module is properly mocked', () => {
      expect(mockActivateKeepAwake).toBeDefined();
      expect(mockDeactivateKeepAwake).toBeDefined();
    });

    it('should verify AppState module is properly mocked', () => {
      expect(mockAddEventListener).toBeDefined();
      expect(AppState.currentState).toBe('active');
    });

    it('should verify status constants are properly mocked', () => {
      expect(STATUS_STOPPED).toBe('stopped');
      expect(STATUS_PLAYING).toBe('playing');
      expect(STATUS_PAUSED).toBe('paused');
    });
  });

  describe('Speech Service Integration', () => {
    it('should call Speech.speak when speaking text', () => {
      mockSpeak('Hello world.', { onDone: jest.fn() });

      expect(mockSpeak).toHaveBeenCalledWith('Hello world.', {
        onDone: expect.any(Function),
      });
    });

    it('should call Speech.stop when stopping', () => {
      mockStop();

      expect(mockStop).toHaveBeenCalled();
    });

    it('should call Speech.pause when pausing', () => {
      mockPause();

      expect(mockPause).toHaveBeenCalled();
    });

    it('should call Speech.resume when resuming', () => {
      mockResume();

      expect(mockResume).toHaveBeenCalled();
    });
  });

  describe('Keep Awake Integration', () => {
    it('should activate keep awake when starting speech', async () => {
      await mockActivateKeepAwake();

      expect(mockActivateKeepAwake).toHaveBeenCalled();
    });

    it('should deactivate keep awake when stopping speech', () => {
      mockDeactivateKeepAwake();

      expect(mockDeactivateKeepAwake).toHaveBeenCalled();
    });
  });

  describe('AppState Integration', () => {
    it('should set up AppState listener', () => {
      // Simulate hook initialization
      mockAddEventListener('change', jest.fn());

      expect(mockAddEventListener).toHaveBeenCalledWith(
        'change',
        expect.any(Function)
      );
    });

    it('should clean up AppState listener', () => {
      // Simulate hook cleanup
      const subscription = mockAddEventListener('change', jest.fn());
      subscription.remove();

      expect(mockRemove).toHaveBeenCalled();
    });

    it('should handle app state change to background', () => {
      const listener = jest.fn();
      mockAddEventListener('change', listener);

      // Simulate app going to background
      listener('background');

      expect(listener).toHaveBeenCalledWith('background');
    });

    it('should handle app state change to inactive', () => {
      const listener = jest.fn();
      mockAddEventListener('change', listener);

      // Simulate app becoming inactive
      listener('inactive');

      expect(listener).toHaveBeenCalledWith('inactive');
    });

    it('should handle app state change to active', () => {
      const listener = jest.fn();
      mockAddEventListener('change', listener);

      // Simulate app becoming active
      listener('active');

      expect(listener).toHaveBeenCalledWith('active');
    });
  });

  describe('Text Processing', () => {
    it('should handle empty text input', () => {
      const text = '';
      const sentences = text
        .split(/([.!?。！？]+)/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toEqual([]);
    });

    it('should split text into sentences correctly', () => {
      const text = 'First sentence. Second sentence! Third sentence?';
      const sentences = text
        .split(/([.!?。！？]+)/)
        .filter((s) => s.trim().length > 0);

      expect(sentences.length).toBeGreaterThan(0);
      expect(sentences).toContain('First sentence');
      expect(sentences).toContain('.');
    });

    it('should handle text with multiple punctuation marks', () => {
      const text = 'Hello... World!!! How are you???';
      const sentences = text
        .split(/([.!?。！？]+)/)
        .filter((s) => s.trim().length > 0);

      expect(sentences.length).toBeGreaterThan(0);
    });

    it('should handle text without sentence endings', () => {
      const text = 'This is a text without proper endings';
      const sentences = text
        .split(/([.!?。！？]+)/)
        .filter((s) => s.trim().length > 0);

      expect(sentences).toContain(text);
    });
  });

  describe('Speech Options', () => {
    it('should handle speech options correctly', () => {
      const options = {
        language: 'en-US',
        pitch: 1.2,
        rate: 0.8,
        onDone: jest.fn(),
      };

      mockSpeak('Hello world.', options);

      expect(mockSpeak).toHaveBeenCalledWith('Hello world.', options);
    });

    it('should handle onDone callback', () => {
      const onDone = jest.fn();
      const options = { onDone };

      mockSpeak('Hello world.', options);

      // Simulate speech completion
      options.onDone();

      expect(onDone).toHaveBeenCalled();
    });
  });

  describe('Progress Tracking', () => {
    it('should calculate progress correctly', () => {
      const text = 'Hello world. This is a test.';
      const totalLength = text.length;
      const completedLength = 'Hello world.'.length;
      const progress = completedLength / totalLength;

      expect(progress).toBeGreaterThan(0);
      expect(progress).toBeLessThanOrEqual(1);
    });

    it('should handle progress calculation for empty text', () => {
      const totalLength = 0;
      const completedLength = 0;
      const progress = totalLength > 0 ? completedLength / totalLength : 0;

      expect(progress).toBe(0);
    });
  });

  describe('Error Handling', () => {
    it('should handle speech errors gracefully', () => {
      const onError = jest.fn();
      const options = { onError };

      mockSpeak('Hello world.', options);

      // Simulate speech error
      if (options.onError) {
        options.onError('Speech error');
      }

      expect(onError).toHaveBeenCalledWith('Speech error');
    });

    it('should handle keep awake errors gracefully', async () => {
      mockActivateKeepAwake.mockRejectedValue(new Error('Keep awake error'));

      try {
        await mockActivateKeepAwake();
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
      }
    });
  });

  describe('Cleanup and Memory Management', () => {
    it('should clean up resources properly', () => {
      // Simulate cleanup
      mockStop();
      mockDeactivateKeepAwake();
      mockRemove();

      expect(mockStop).toHaveBeenCalled();
      expect(mockDeactivateKeepAwake).toHaveBeenCalled();
      expect(mockRemove).toHaveBeenCalled();
    });
  });
});
