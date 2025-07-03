import { router } from 'expo-router';
import * as Speech from 'expo-speech';
import { sleep } from '@/components/global';

export const navigateToChapter = (chapterName: string | undefined) => {
  if (chapterName) {
    router.push({
      pathname: '/read',
      params: { post: chapterName },
    });
  }
};

export const handleProgressChange = (
  newProgress: number,
  setProgress: (progress: number) => void,
  status: string,
  speak: () => void
) => {
  Speech.stop();
  setProgress(newProgress);
  if (status === 'playing') {
    speak();
  }
};

export const handleContentChange = (
  status: string,
  contentLength: number,
  speak: () => void
) => {
  // This is used for switch to another chapter, if was reading before, then read new chapter
  if (status === 'playing' && contentLength > 64) {
    Speech.stop();
    sleep(1000).then(() => {
      speak();
    });
  }
};

export const handleSpeechProgressUpdate = (
  speechProgress: number,
  setProgress: (progress: number) => void,
  contentLength: number,
  status: string,
  toNext: () => void
) => {
  // Update reading progress based on speech progress
  setProgress(speechProgress);

  if (speechProgress >= 1) {
    // Speech is complete, go to next chapter
    toNext();
    return;
  }

  // Check if speech has stopped unexpectedly
  Speech.isSpeakingAsync().then((res) => {
    if (!res && status === 'playing' && speechProgress > 0.1) {
      toNext();
    }
  });
};
