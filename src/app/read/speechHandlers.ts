import { useCallback } from 'react';
import { SpeechHandlers, SpeechState, StopSource } from './types';
import { handleSpeechProgressUpdate } from '@/utils/readingUtils';

/**
 * Hook to provide speech control handlers
 * @param speechState - Current speech state
 * @param speak - Function to start speech
 * @param stop - Function to stop speech
 * @param setProgress - Function to set reading progress
 * @param content - Content being read
 * @param toNext - Function to navigate to next chapter
 * @returns Speech handlers object
 */
export const useSpeechHandlers = (
  speechState: SpeechState,
  speak: (startProgress?: number) => void,
  stop: (source: StopSource) => void,
  setProgress: (progress: number) => void,
  content: string,
  toNext: () => void,
  progress: number
): SpeechHandlers => {
  // Memoized play handler
  const handlePlay = useCallback(() => {
    speak();
  }, [speak]);

  // Memoized stop handler
  const handleStop = useCallback(() => {
    stop('playBarStop');
  }, [stop]);

  // Memoized progress change handler
  const handleProgressChange = useCallback(
    (value: number) => {
      // Prevent accidental resets to 0 unless it's a genuine user action
      if (value === 0 && progress > 0.01) {
        return; // Ignore slider resets
      }

      // Only stop speech if user manually changes progress
      if (speechState.status === 'playing') {
        stop('manualProgressChange');
      }
      setProgress(value);
      if (speechState.status === 'playing') {
        speak(value);
      }
    },
    [progress, speechState.status, stop, setProgress, speak]
  );

  return {
    handlePlay,
    handleStop,
    handleProgressChange,
  };
};

/**
 * Hook to provide speech progress update callback
 * @param setProgress - Function to set reading progress
 * @param content - Content being read
 * @param speechStatus - Current speech status
 * @param toNext - Function to navigate to next chapter
 * @returns Memoized progress update callback
 */
export const useSpeechProgressUpdate = (
  setProgress: (progress: number) => void,
  content: string,
  speechStatus: string,
  toNext: () => void
) => {
  return useCallback(
    (progress: number) => {
      handleSpeechProgressUpdate(
        progress,
        setProgress,
        content.length,
        speechStatus,
        toNext
      );
    },
    [setProgress, content.length, speechStatus, toNext]
  );
};

/**
 * Utility function to handle speech state changes
 * @param status - New speech status
 * @param onStatusChange - Optional callback for status changes
 */
export const handleSpeechStatusChange = (
  status: string,
  onStatusChange?: (status: string) => void
): void => {
  try {
    if (onStatusChange) {
      onStatusChange(status);
    }
  } catch (error) {
    console.error('Error handling speech status change:', error);
  }
};

/**
 * Utility function to handle sentence index updates
 * @param index - New sentence index
 * @param onSentenceIndexUpdate - Optional callback for sentence index updates
 */
export const handleSentenceIndexUpdate = (
  index: number,
  onSentenceIndexUpdate?: (index: number) => void
): void => {
  try {
    if (onSentenceIndexUpdate) {
      onSentenceIndexUpdate(index);
    }
  } catch (error) {
    console.error('Error handling sentence index update:', error);
  }
};
