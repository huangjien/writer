import { router } from 'expo-router';
import * as Speech from 'expo-speech';
import { sleep } from '@/components/global';
import { CONSTANTS } from '@/constants/appConstants';

export const navigateToChapter = (chapterName: string | undefined) => {
  try {
    // Input validation
    if (
      !chapterName ||
      typeof chapterName !== 'string' ||
      chapterName.trim() === ''
    ) {
      console.warn('navigateToChapter: chapterName must be a non-empty string');
      return;
    }

    router.push({
      pathname: '/read',
      params: { post: chapterName },
    });
  } catch (error) {
    console.error('Error navigating to chapter:', error);
  }
};

export const handleProgressChange = (
  newProgress: number,
  setProgress: (progress: number) => void,
  status: string,
  speak: () => void
) => {
  try {
    // Input validation
    if (typeof newProgress !== 'number' || isNaN(newProgress)) {
      console.warn('handleProgressChange: newProgress must be a valid number');
      return;
    }

    if (typeof setProgress !== 'function') {
      console.warn('handleProgressChange: setProgress must be a function');
      return;
    }

    if (typeof status !== 'string') {
      console.warn('handleProgressChange: status must be a string');
      return;
    }

    if (typeof speak !== 'function') {
      console.warn('handleProgressChange: speak must be a function');
      return;
    }

    Speech.stop();
    setProgress(newProgress);
    if (status === 'playing') {
      speak();
    }
  } catch (error) {
    console.error('Error handling progress change:', error);
  }
};

export const handleContentChange = (
  status: string,
  contentLength: number,
  speak: (startProgress?: number) => void,
  shouldAutoPlay: boolean = false
) => {
  try {
    // Input validation
    if (typeof status !== 'string') {
      console.warn('handleContentChange: status must be a string');
      return;
    }

    if (
      typeof contentLength !== 'number' ||
      isNaN(contentLength) ||
      contentLength < 0
    ) {
      console.warn(
        'handleContentChange: contentLength must be a valid non-negative number'
      );
      return;
    }

    if (typeof speak !== 'function') {
      console.warn('handleContentChange: speak must be a function');
      return;
    }

    // This is used for switch to another chapter, if was reading before, then read new chapter
    // Fixed: Always start from beginning (progress 0) when switching chapters
    if (
      (status === 'playing' || shouldAutoPlay) &&
      contentLength > CONSTANTS.CONTENT.CONTENT_LENGTH_THRESHOLD
    ) {
      Speech.stop();
      sleep(CONSTANTS.TIMING.CHAPTER_SWITCH_DELAY).then(() => {
        // Start from the beginning of the new chapter
        speak(0);
      });
    }
  } catch (error) {
    console.error('Error handling content change:', error);
  }
};

export const handleSpeechProgressUpdate = (
  speechProgress: number,
  setProgress: (progress: number) => void,
  contentLength: number,
  status: string,
  toNext: () => void
) => {
  try {
    // Input validation
    if (typeof speechProgress !== 'number' || isNaN(speechProgress)) {
      console.warn(
        'handleSpeechProgressUpdate: speechProgress must be a valid number'
      );
      return;
    }

    if (typeof setProgress !== 'function') {
      console.warn(
        'handleSpeechProgressUpdate: setProgress must be a function'
      );
      return;
    }

    if (
      typeof contentLength !== 'number' ||
      isNaN(contentLength) ||
      contentLength < 0
    ) {
      console.warn(
        'handleSpeechProgressUpdate: contentLength must be a valid non-negative number'
      );
      return;
    }

    if (typeof status !== 'string') {
      console.warn('handleSpeechProgressUpdate: status must be a string');
      return;
    }

    if (typeof toNext !== 'function') {
      console.warn('handleSpeechProgressUpdate: toNext must be a function');
      return;
    }

    // Update reading progress based on speech progress
    setProgress(speechProgress);

    if (speechProgress >= 1) {
      // Speech is complete, go to next chapter
      toNext();
      return;
    }

    // Check if speech has stopped unexpectedly
    Speech.isSpeakingAsync()
      .then((res) => {
        if (!res && status === 'playing' && speechProgress > 0.1) {
          toNext();
        }
      })
      .catch((error) => {
        console.error('Error checking speech status:', error);
      });
  } catch (error) {
    console.error('Error handling speech progress update:', error);
  }
};
