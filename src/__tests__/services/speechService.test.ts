import { speechService, SpeechService } from '@/services/speechService';
import * as Speech from 'expo-speech';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { CONTENT_KEY, showErrorToast } from '@/components/global';

// Mock dependencies
jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
  isSpeakingAsync: jest.fn(),
  maxSpeechInputLength: 4000,
}));
jest.mock('@react-native-async-storage/async-storage');
jest.mock('@/components/global', () => ({
  CONTENT_KEY: 'content_',
  showErrorToast: jest.fn(),
}));

const mockSpeech = Speech as jest.Mocked<typeof Speech>;
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;
const mockShowErrorToast = showErrorToast as jest.MockedFunction<
  typeof showErrorToast
>;

describe('SpeechService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockSpeech.isSpeakingAsync.mockResolvedValue(false);
  });

  describe('Singleton Pattern', () => {
    it('should return the same instance when called multiple times', () => {
      const instance1 = SpeechService.getInstance();
      const instance2 = SpeechService.getInstance();
      expect(instance1).toBe(instance2);
    });

    it('should return the same instance as the exported speechService', () => {
      const instance = SpeechService.getInstance();
      expect(instance).toBe(speechService);
    });
  });

  describe('getNext', () => {
    it('should return the next chapter when available', async () => {
      const mockContent = JSON.stringify([
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ]);
      mockAsyncStorage.getItem.mockResolvedValue(mockContent);

      const result = await speechService.getNext('content_chapter2');
      expect(result).toBe('content_chapter3');
      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith(CONTENT_KEY);
    });

    it('should return undefined when at the last chapter', async () => {
      const mockContent = JSON.stringify([
        { name: 'chapter1' },
        { name: 'chapter2' },
      ]);
      mockAsyncStorage.getItem.mockResolvedValue(mockContent);

      const result = await speechService.getNext('content_chapter2');
      expect(result).toBeUndefined();
    });

    it('should return undefined when chapter is not found', async () => {
      const mockContent = JSON.stringify([
        { name: 'chapter1' },
        { name: 'chapter2' },
      ]);
      mockAsyncStorage.getItem.mockResolvedValue(mockContent);

      const result = await speechService.getNext('content_nonexistent');
      expect(result).toBeUndefined();
    });

    it('should return undefined when AsyncStorage returns null', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(null);

      const result = await speechService.getNext('content_chapter1');
      expect(result).toBeUndefined();
    });

    it('should handle JSON parse errors gracefully', async () => {
      mockAsyncStorage.getItem.mockResolvedValue('invalid json');
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      const result = await speechService.getNext('content_chapter1');
      expect(result).toBeUndefined();
      expect(consoleSpy).toHaveBeenCalledWith(
        'Error in getNext function:',
        expect.any(Error)
      );

      consoleSpy.mockRestore();
    });

    it('should handle AsyncStorage errors gracefully', async () => {
      mockAsyncStorage.getItem.mockRejectedValue(new Error('Storage error'));
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      const result = await speechService.getNext('content_chapter1');
      expect(result).toBeUndefined();
      expect(consoleSpy).toHaveBeenCalledWith(
        'AsyncStorage getItem error:',
        expect.any(Error)
      );

      consoleSpy.mockRestore();
    });
  });

  describe('speak', () => {
    const mockChapterData = JSON.stringify({
      content: 'This is test content for speech synthesis.',
    });

    it('should speak content successfully with default options', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(mockChapterData);

      await speechService.speak('chapter1', 0);

      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith('content_chapter1');
      expect(mockSpeech.speak).toHaveBeenCalledWith(
        'This is test content for speech synthesis.',
        expect.objectContaining({
          language: 'zh',
          voice: 'zh',
          onDone: expect.any(Function),
        })
      );
    });

    it('should speak content with custom options', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(mockChapterData);
      const customOnDone = jest.fn();

      await speechService.speak('chapter1', 0, {
        language: 'en',
        voice: 'en-US',
        onDone: customOnDone,
      });

      expect(mockSpeech.speak).toHaveBeenCalledWith(
        'This is test content for speech synthesis.',
        expect.objectContaining({
          language: 'en',
          voice: 'en-US',
          onDone: customOnDone,
        })
      );
    });

    it('should handle content from progress correctly', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(mockChapterData);

      await speechService.speak('chapter1', 0.5);

      const expectedContent =
        'This is test content for speech synthesis.'.substring(
          Math.round('This is test content for speech synthesis.'.length * 0.5)
        );
      expect(mockSpeech.speak).toHaveBeenCalledWith(
        expectedContent,
        expect.any(Object)
      );
    });

    it('should show error when no content is found', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(null);

      await speechService.speak('chapter1', 0);

      expect(mockShowErrorToast).toHaveBeenCalledWith(
        'No content for this chapter yet: chapter1!'
      );
      expect(mockSpeech.speak).not.toHaveBeenCalled();
    });

    it('should show error when content is too long', async () => {
      const longContent = 'a'.repeat(5000);
      const mockLongChapterData = JSON.stringify({ content: longContent });
      mockAsyncStorage.getItem.mockResolvedValue(mockLongChapterData);

      await speechService.speak('chapter1', 0);

      expect(mockShowErrorToast).toHaveBeenCalledWith(
        'Content is too long to be handled by TTS engine'
      );
      expect(mockSpeech.speak).not.toHaveBeenCalled();
    });

    it('should handle AsyncStorage errors gracefully', async () => {
      mockAsyncStorage.getItem.mockRejectedValue(new Error('Storage error'));
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      await speechService.speak('chapter1', 0);

      expect(consoleSpy).toHaveBeenCalledWith(
        'AsyncStorage getItem error:',
        expect.any(Error)
      );
      expect(mockSpeech.speak).not.toHaveBeenCalled();

      consoleSpy.mockRestore();
    });

    it('should handle content key with and without prefix', async () => {
      mockAsyncStorage.getItem.mockResolvedValue(mockChapterData);

      // Test with prefix
      await speechService.speak('content_chapter1', 0);
      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith('content_chapter1');

      // Test without prefix
      await speechService.speak('chapter2', 0);
      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith('content_chapter2');
    });
  });

  describe('Speech Control Methods', () => {
    it('should call Speech.stop when stop is called', () => {
      speechService.stop();
      expect(mockSpeech.stop).toHaveBeenCalled();
    });

    it('should call Speech.pause when pause is called', () => {
      speechService.pause();
      expect(mockSpeech.pause).toHaveBeenCalled();
    });

    it('should call Speech.resume when resume is called', () => {
      speechService.resume();
      expect(mockSpeech.resume).toHaveBeenCalled();
    });

    it('should return Speech.isSpeakingAsync result when isSpeaking is called', async () => {
      mockSpeech.isSpeakingAsync.mockResolvedValue(true);

      const result = await speechService.isSpeaking();
      expect(result).toBe(true);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();
    });
  });

  describe('Default onDone Behavior', () => {
    it('should automatically move to next chapter when onDone is triggered', async () => {
      const mockChapterData = JSON.stringify({ content: 'Test content' });
      const mockContentList = JSON.stringify([
        { name: 'chapter1' },
        { name: 'chapter2' },
      ]);

      mockAsyncStorage.getItem
        .mockResolvedValueOnce(mockChapterData) // First call for speak
        .mockResolvedValueOnce(mockContentList) // Second call for getNext
        .mockResolvedValueOnce(mockChapterData); // Third call for next chapter speak

      await speechService.speak('chapter1', 0);

      // Get the onDone callback and trigger it
      const speakCall = mockSpeech.speak.mock.calls[0];
      const options = speakCall[1];
      const onDone = options.onDone;

      // Call onDone and wait for the promise chain to complete
      await onDone();

      // Wait a bit more for the asynchronous operations to complete
      await new Promise((resolve) => setTimeout(resolve, 0));

      // Verify that speak was called again for the next chapter
      expect(mockSpeech.speak).toHaveBeenCalledTimes(2);
      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith('content_chapter2');
    });

    it('should handle errors in default onDone callback', async () => {
      const mockChapterData = JSON.stringify({ content: 'Test content' });
      mockAsyncStorage.getItem.mockResolvedValueOnce(mockChapterData);

      await speechService.speak('chapter1', 0);

      // Get the onDone callback and trigger it
      const speakCall = mockSpeech.speak.mock.calls[0];
      const options = speakCall[1];
      const onDone = options.onDone;

      // Mock getNext to throw an error
      mockAsyncStorage.getItem.mockRejectedValueOnce(
        new Error('Storage error')
      );
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

      await onDone();

      expect(consoleSpy).toHaveBeenCalledWith(
        'AsyncStorage getItem error:',
        expect.any(Error)
      );

      consoleSpy.mockRestore();
    });
  });
});
