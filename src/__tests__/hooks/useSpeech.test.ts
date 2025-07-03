import { renderHook, act, waitFor } from '@testing-library/react-native';
import { useSpeech } from '@/hooks/useSpeech';
import * as Speech from 'expo-speech';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

// Mock dependencies
jest.mock('expo-speech');
jest.mock('expo-keep-awake');

const mockSpeech = Speech as jest.Mocked<typeof Speech>;
const mockActivateKeepAwake = activateKeepAwakeAsync as jest.MockedFunction<
  typeof activateKeepAwakeAsync
>;
const mockDeactivateKeepAwake = deactivateKeepAwake as jest.MockedFunction<
  typeof deactivateKeepAwake
>;

describe('useSpeech', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock implementations
    mockSpeech.speak.mockImplementation((text, options) => {
      // Simulate immediate completion for testing
      setTimeout(() => {
        options?.onDone?.();
      }, 0);
    });
    mockSpeech.stop.mockImplementation(() => Promise.resolve());
    mockSpeech.pause.mockImplementation(() => Promise.resolve());
    mockSpeech.resume.mockImplementation(() => Promise.resolve());
    mockActivateKeepAwake.mockResolvedValue(undefined);
    mockDeactivateKeepAwake.mockImplementation(() => Promise.resolve());
  });

  describe('initial state', () => {
    it('should return initial state values', () => {
      const { result } = renderHook(() => useSpeech());

      expect(result.current.status).toBe(STATUS_STOPPED);
      expect(result.current.progress).toBe(0);
      expect(result.current.currentSentenceIndex).toBe(0);
      expect(typeof result.current.speak).toBe('function');
      expect(typeof result.current.stop).toBe('function');
      expect(typeof result.current.pause).toBe('function');
      expect(typeof result.current.resume).toBe('function');
    });
  });

  describe('keep awake functionality', () => {
    it('should activate keep awake when playing', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      expect(mockActivateKeepAwake).toHaveBeenCalled();
    });

    it('should deactivate keep awake when stopped', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      await act(async () => {
        result.current.stop();
      });

      expect(mockDeactivateKeepAwake).toHaveBeenCalled();
    });

    it('should deactivate keep awake when paused', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      await act(async () => {
        result.current.pause();
      });

      expect(mockDeactivateKeepAwake).toHaveBeenCalled();
    });
  });

  describe('splitIntoSentences helper', () => {
    it('should handle content with multiple sentences', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'First sentence. Second sentence! Third sentence?';

      await act(async () => {
        result.current.speak(content);
      });

      // Should call Speech.speak for each sentence
      expect(mockSpeech.speak).toHaveBeenCalledWith(
        'First sentence.',
        expect.any(Object)
      );
    });

    it('should handle content with Chinese punctuation', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = '第一句。第二句！第三句？';

      await act(async () => {
        result.current.speak(content);
      });

      expect(mockSpeech.speak).toHaveBeenCalledWith(
        '第一句。',
        expect.any(Object)
      );
    });

    it('should handle content without sentence endings', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'Single sentence without ending';

      await act(async () => {
        result.current.speak(content);
      });

      expect(mockSpeech.speak).toHaveBeenCalledWith(
        content,
        expect.any(Object)
      );
    });
  });

  describe('speak function', () => {
    it('should start speaking and update status', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
      expect(result.current.progress).toBe(0);
      expect(result.current.currentSentenceIndex).toBe(0);
      expect(mockSpeech.speak).toHaveBeenCalledWith(
        'Hello world',
        expect.objectContaining({
          onDone: expect.any(Function),
        })
      );
    });

    it('should pass speech options correctly', async () => {
      const { result } = renderHook(() => useSpeech());
      const options = {
        language: 'en-US',
        pitch: 1.2,
        rate: 0.8,
        onDone: jest.fn(),
      };

      await act(async () => {
        result.current.speak('Hello world', options);
      });

      expect(mockSpeech.speak).toHaveBeenCalledWith(
        'Hello world',
        expect.objectContaining({
          language: 'en-US',
          pitch: 1.2,
          rate: 0.8,
          onDone: expect.any(Function),
        })
      );
    });

    it('should reset state when starting new speech', async () => {
      const { result } = renderHook(() => useSpeech());

      // Start first speech
      await act(async () => {
        result.current.speak('First speech');
      });

      // Simulate some progress
      await act(async () => {
        result.current.pause();
      });

      // Start new speech
      await act(async () => {
        result.current.speak('Second speech');
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
      expect(result.current.progress).toBe(0);
      expect(result.current.currentSentenceIndex).toBe(0);
    });
  });

  describe('stop function', () => {
    it('should stop speech and reset state', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      await act(async () => {
        result.current.stop();
      });

      expect(result.current.status).toBe(STATUS_STOPPED);
      expect(result.current.progress).toBe(0);
      expect(result.current.currentSentenceIndex).toBe(0);
      expect(mockSpeech.stop).toHaveBeenCalled();
    });
  });

  describe('pause function', () => {
    it('should pause speech and update status', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      await act(async () => {
        result.current.pause();
      });

      expect(result.current.status).toBe(STATUS_PAUSED);
      expect(mockSpeech.pause).toHaveBeenCalled();
    });
  });

  describe('resume function', () => {
    it('should resume speech and update status', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('Hello world');
      });

      await act(async () => {
        result.current.pause();
      });

      await act(async () => {
        result.current.resume();
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
      expect(mockSpeech.resume).toHaveBeenCalled();
    });

    it('should continue speaking from current sentence when resumed', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'First sentence. Second sentence.';

      // Mock Speech.speak to simulate sentence completion
      let onDoneCallback: (() => void) | undefined;
      mockSpeech.speak.mockImplementation((text, options) => {
        onDoneCallback = options?.onDone;
      });

      await act(async () => {
        result.current.speak(content);
      });

      // Simulate first sentence completion
      await act(async () => {
        onDoneCallback?.();
      });

      // Pause during second sentence
      await act(async () => {
        result.current.pause();
      });

      // Resume should continue from current sentence
      await act(async () => {
        result.current.resume();
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
      expect(mockSpeech.resume).toHaveBeenCalled();
    });
  });

  describe('progress tracking', () => {
    it('should update progress as sentences complete', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'First. Second.';

      // Mock Speech.speak to capture onDone callback
      let onDoneCallback: (() => void) | undefined;
      mockSpeech.speak.mockImplementation((text, options) => {
        onDoneCallback = options?.onDone;
      });

      await act(async () => {
        result.current.speak(content);
      });

      expect(result.current.progress).toBe(0);

      // Simulate first sentence completion
      await act(async () => {
        onDoneCallback?.();
      });

      // Progress should be updated
      expect(result.current.progress).toBeGreaterThan(0);
      expect(result.current.currentSentenceIndex).toBe(1);
    });

    it('should complete with progress 1 when all sentences are done', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'Single sentence.';
      const onDone = jest.fn();

      // Mock Speech.speak to capture onDone callback
      let speechOnDoneCallback: (() => void) | undefined;
      mockSpeech.speak.mockImplementation((text, options) => {
        speechOnDoneCallback = options?.onDone;
      });

      await act(async () => {
        result.current.speak(content, { onDone });
      });

      // Simulate sentence completion
      await act(async () => {
        speechOnDoneCallback?.();
      });

      expect(result.current.progress).toBe(1);
      expect(result.current.status).toBe(STATUS_STOPPED);
      expect(onDone).toHaveBeenCalled();
    });
  });

  describe('sentence navigation', () => {
    it('should advance to next sentence after completion', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'First sentence. Second sentence.';

      // Mock Speech.speak to capture onDone callback
      let onDoneCallback: (() => void) | undefined;
      mockSpeech.speak.mockImplementation((text, options) => {
        onDoneCallback = options?.onDone;
      });

      await act(async () => {
        result.current.speak(content);
      });

      expect(result.current.currentSentenceIndex).toBe(0);

      // Simulate first sentence completion
      await act(async () => {
        onDoneCallback?.();
      });

      expect(result.current.currentSentenceIndex).toBe(1);
      // Should call speak again for the second sentence
      expect(mockSpeech.speak).toHaveBeenCalledTimes(2);
    });

    it('should not advance if paused during sentence completion', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'First sentence. Second sentence.';

      // Mock Speech.speak to capture onDone callback
      let onDoneCallback: (() => void) | undefined;
      mockSpeech.speak.mockImplementation((text, options) => {
        onDoneCallback = options?.onDone;
      });

      await act(async () => {
        result.current.speak(content);
      });

      // Pause immediately
      await act(async () => {
        result.current.pause();
      });

      // Simulate sentence completion while paused
      await act(async () => {
        onDoneCallback?.();
      });

      // Should not advance to next sentence
      expect(result.current.currentSentenceIndex).toBe(0);
      expect(mockSpeech.speak).toHaveBeenCalledTimes(1);
    });
  });

  describe('edge cases', () => {
    it('should handle empty content', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('');
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
      expect(mockSpeech.speak).toHaveBeenCalledWith('', expect.any(Object));
    });

    it('should handle content with only whitespace', async () => {
      const { result } = renderHook(() => useSpeech());

      await act(async () => {
        result.current.speak('   \n\t   ');
      });

      expect(result.current.status).toBe(STATUS_PLAYING);
    });

    it('should handle multiple consecutive punctuation marks', async () => {
      const { result } = renderHook(() => useSpeech());
      const content = 'What?!?! Really...';

      await act(async () => {
        result.current.speak(content);
      });

      expect(mockSpeech.speak).toHaveBeenCalled();
    });
  });
});
