import {
  navigateToChapter,
  handleProgressChange,
  handleContentChange,
  handleSpeechProgressUpdate,
} from '../utils/readingUtils';
import { router } from 'expo-router';
import * as Speech from 'expo-speech';
import { sleep, STATUS_PLAYING } from '../components/global';

// Mock dependencies
jest.mock('expo-router', () => ({
  router: {
    push: jest.fn(),
  },
}));

jest.mock('expo-speech', () => ({
  stop: jest.fn(),
  isSpeakingAsync: jest.fn(),
}));

jest.mock('../components/global', () => ({
  sleep: jest.fn(),
  STATUS_PLAYING: 'playing',
}));

const mockRouter = router as jest.Mocked<typeof router>;
const mockSpeech = Speech as jest.Mocked<typeof Speech>;
const mockSleep = sleep as jest.MockedFunction<typeof sleep>;

describe('readingUtils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('navigateToChapter', () => {
    it('should navigate to chapter when chapterName is provided', () => {
      const chapterName = 'chapter1';

      navigateToChapter(chapterName);

      expect(mockRouter.push).toHaveBeenCalledWith({
        pathname: '/read',
        params: { post: chapterName },
      });
    });

    it('should not navigate when chapterName is undefined', () => {
      navigateToChapter(undefined);

      expect(mockRouter.push).not.toHaveBeenCalled();
    });

    it('should not navigate when chapterName is empty string', () => {
      navigateToChapter('');

      expect(mockRouter.push).not.toHaveBeenCalled();
    });

    it('should not navigate when chapterName is null', () => {
      navigateToChapter(null as any);

      expect(mockRouter.push).not.toHaveBeenCalled();
    });
  });

  describe('handleProgressChange', () => {
    let mockSetProgress: jest.Mock;
    let mockSpeak: jest.Mock;

    beforeEach(() => {
      mockSetProgress = jest.fn();
      mockSpeak = jest.fn();
    });

    it('should stop speech, set progress, and speak when status is playing', () => {
      const newProgress = 0.5;
      const status = STATUS_PLAYING;

      handleProgressChange(newProgress, mockSetProgress, status, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSetProgress).toHaveBeenCalledWith(newProgress);
      expect(mockSpeak).toHaveBeenCalled();
    });

    it('should stop speech and set progress but not speak when status is not playing', () => {
      const newProgress = 0.3;
      const status = 'paused';

      handleProgressChange(newProgress, mockSetProgress, status, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSetProgress).toHaveBeenCalledWith(newProgress);
      expect(mockSpeak).not.toHaveBeenCalled();
    });

    it('should handle zero progress correctly', () => {
      const newProgress = 0;
      const status = STATUS_PLAYING;

      handleProgressChange(newProgress, mockSetProgress, status, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSetProgress).toHaveBeenCalledWith(0);
      expect(mockSpeak).toHaveBeenCalled();
    });

    it('should handle full progress correctly', () => {
      const newProgress = 1;
      const status = STATUS_PLAYING;

      handleProgressChange(newProgress, mockSetProgress, status, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSetProgress).toHaveBeenCalledWith(1);
      expect(mockSpeak).toHaveBeenCalled();
    });
  });

  describe('handleContentChange', () => {
    let mockSpeak: jest.Mock;
    let mockSleepPromise: Promise<void>;

    beforeEach(() => {
      mockSpeak = jest.fn();
      mockSleepPromise = Promise.resolve();
      mockSleep.mockReturnValue(mockSleepPromise);
    });

    it('should stop speech, sleep, and then speak when status is playing and content is long enough', async () => {
      const status = STATUS_PLAYING;
      const contentLength = 100;

      handleContentChange(status, contentLength, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSleep).toHaveBeenCalledWith(1000);

      // Wait for the sleep promise to resolve
      await mockSleepPromise;

      expect(mockSpeak).toHaveBeenCalledWith(0);
    });

    it('should not do anything when status is not playing and shouldAutoPlay is false', () => {
      const status = 'paused';
      const contentLength = 100;

      handleContentChange(status, contentLength, mockSpeak, false);

      expect(mockSpeech.stop).not.toHaveBeenCalled();
      expect(mockSleep).not.toHaveBeenCalled();
      expect(mockSpeak).not.toHaveBeenCalled();
    });

    it('should not do anything when content is too short', () => {
      const status = STATUS_PLAYING;
      const contentLength = 50; // Less than 64

      handleContentChange(status, contentLength, mockSpeak);

      expect(mockSpeech.stop).not.toHaveBeenCalled();
      expect(mockSleep).not.toHaveBeenCalled();
      expect(mockSpeak).not.toHaveBeenCalled();
    });

    it('should not do anything when content length is exactly 64', () => {
      const status = STATUS_PLAYING;
      const contentLength = 64;

      handleContentChange(status, contentLength, mockSpeak);

      expect(mockSpeech.stop).not.toHaveBeenCalled();
      expect(mockSleep).not.toHaveBeenCalled();
      expect(mockSpeak).not.toHaveBeenCalled();
    });

    it('should work when content length is just above threshold', () => {
      const status = STATUS_PLAYING;
      const contentLength = 65;

      handleContentChange(status, contentLength, mockSpeak);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSleep).toHaveBeenCalledWith(1000);
    });

    it('should trigger speech when shouldAutoPlay is true even if status is not playing', async () => {
      const status = 'stopped';
      const contentLength = 100;

      handleContentChange(status, contentLength, mockSpeak, true);

      expect(mockSpeech.stop).toHaveBeenCalled();
      expect(mockSleep).toHaveBeenCalledWith(1000);

      // Wait for the sleep promise to resolve
      await mockSleepPromise;

      expect(mockSpeak).toHaveBeenCalledWith(0);
    });
  });

  describe('handleSpeechProgressUpdate', () => {
    let mockSetProgress: jest.Mock;
    let mockToNext: jest.Mock;
    let mockIsSpeakingPromise: Promise<boolean>;

    beforeEach(() => {
      mockSetProgress = jest.fn();
      mockToNext = jest.fn();
      mockIsSpeakingPromise = Promise.resolve(false);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);
    });

    it('should set progress and call toNext when speech is complete', () => {
      const speechProgress = 1;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockToNext).toHaveBeenCalled();
    });

    it('should set progress and call toNext when speech progress exceeds 1', () => {
      const speechProgress = 1.2;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockToNext).toHaveBeenCalled();
    });

    it('should set progress and check speech status when progress is less than 1 and speech is still playing', async () => {
      const speechProgress = 0.5;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      // Mock speech as still speaking
      mockIsSpeakingPromise = Promise.resolve(true);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      // toNext should not be called when speech is still playing
      expect(mockToNext).not.toHaveBeenCalled();
    });

    it('should call toNext when speech has stopped unexpectedly and progress > 0.1', async () => {
      const speechProgress = 0.5;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      // Mock speech as not speaking
      mockIsSpeakingPromise = Promise.resolve(false);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      expect(mockToNext).toHaveBeenCalled();
    });

    it('should not call toNext when speech has stopped but progress <= 0.1', async () => {
      const speechProgress = 0.05;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      // Mock speech as not speaking
      mockIsSpeakingPromise = Promise.resolve(false);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      expect(mockToNext).not.toHaveBeenCalled();
    });

    it('should not call toNext when speech is still playing', async () => {
      const speechProgress = 0.5;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      // Mock speech as still speaking
      mockIsSpeakingPromise = Promise.resolve(true);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      expect(mockToNext).not.toHaveBeenCalled();
    });

    it('should not call toNext when status is not playing', async () => {
      const speechProgress = 0.5;
      const contentLength = 1000;
      const status = 'paused';

      // Mock speech as not speaking
      mockIsSpeakingPromise = Promise.resolve(false);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      expect(mockToNext).not.toHaveBeenCalled();
    });

    it('should handle zero progress correctly', async () => {
      const speechProgress = 0;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(0);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      // Should not call toNext for progress = 0 even if not speaking
      expect(mockToNext).not.toHaveBeenCalled();
    });

    it('should handle progress exactly at 0.1 threshold', async () => {
      const speechProgress = 0.1;
      const contentLength = 1000;
      const status = STATUS_PLAYING;

      // Mock speech as not speaking
      mockIsSpeakingPromise = Promise.resolve(false);
      mockSpeech.isSpeakingAsync.mockReturnValue(mockIsSpeakingPromise);

      handleSpeechProgressUpdate(
        speechProgress,
        mockSetProgress,
        contentLength,
        status,
        mockToNext
      );

      expect(mockSetProgress).toHaveBeenCalledWith(speechProgress);
      expect(mockSpeech.isSpeakingAsync).toHaveBeenCalled();

      // Wait for the promise to resolve
      await mockIsSpeakingPromise;

      // Should not call toNext for progress = 0.1 (not > 0.1)
      expect(mockToNext).not.toHaveBeenCalled();
    });
  });
});
