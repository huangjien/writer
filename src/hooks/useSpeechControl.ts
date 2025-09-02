import { useState, useRef, useCallback } from 'react';
import * as Speech from 'expo-speech';
import { CONSTANTS } from '@/constants/appConstants';

type SpeechStatus = 'playing' | 'stopped' | 'paused';
type StopSource =
  | 'unknown'
  | 'doubleTap'
  | 'playBarStop'
  | 'manualProgressChange'
  | 'cleanup'
  | 'navigation';

interface SpeechState {
  status: SpeechStatus;
  progress: number;
  currentSentenceIndex: number;
  shouldAutoPlay: boolean;
}

interface SpeechControlOptions {
  content: string[];
  voice: string;
  onProgressUpdate?: (progress: number) => void;
  onSentenceIndexUpdate?: (index: number) => void;
  onStatusChange?: (status: SpeechStatus) => void;
}

export function useSpeechControl({
  content,
  voice,
  onProgressUpdate,
  onSentenceIndexUpdate,
  onStatusChange,
}: SpeechControlOptions) {
  // Input validation
  if (!Array.isArray(content)) {
    console.warn('useSpeechControl: content must be an array');
  }

  if (!voice || typeof voice !== 'string') {
    console.warn('useSpeechControl: voice must be a non-empty string');
  }
  const [speechState, setSpeechState] = useState<SpeechState>({
    status: 'stopped',
    progress: 0,
    currentSentenceIndex: 0,
    shouldAutoPlay: false,
  });

  const isSpeakingRef = useRef<boolean>(false);
  const stopSourceRef = useRef<StopSource>('unknown');

  const updateSpeechState = useCallback(
    (updates: Partial<SpeechState>) => {
      try {
        // Input validation
        if (!updates || typeof updates !== 'object') {
          console.warn('updateSpeechState: updates must be an object');
          return;
        }

        // Validate individual fields
        if (
          updates.progress !== undefined &&
          (typeof updates.progress !== 'number' || isNaN(updates.progress))
        ) {
          console.warn('updateSpeechState: progress must be a valid number');
          delete updates.progress;
        }

        if (
          updates.currentSentenceIndex !== undefined &&
          (typeof updates.currentSentenceIndex !== 'number' ||
            isNaN(updates.currentSentenceIndex))
        ) {
          console.warn(
            'updateSpeechState: currentSentenceIndex must be a valid number'
          );
          delete updates.currentSentenceIndex;
        }

        if (
          updates.status !== undefined &&
          !['playing', 'stopped', 'paused'].includes(updates.status)
        ) {
          console.warn(
            'updateSpeechState: status must be a valid SpeechStatus'
          );
          delete updates.status;
        }

        if (
          updates.shouldAutoPlay !== undefined &&
          typeof updates.shouldAutoPlay !== 'boolean'
        ) {
          console.warn('updateSpeechState: shouldAutoPlay must be a boolean');
          delete updates.shouldAutoPlay;
        }

        setSpeechState((prev) => {
          const newState = { ...prev, ...updates };

          // Notify parent components of changes
          if (updates.progress !== undefined && onProgressUpdate) {
            onProgressUpdate(updates.progress);
          }
          if (
            updates.currentSentenceIndex !== undefined &&
            onSentenceIndexUpdate
          ) {
            onSentenceIndexUpdate(updates.currentSentenceIndex);
          }
          if (updates.status !== undefined && onStatusChange) {
            onStatusChange(updates.status);
          }

          return newState;
        });
      } catch (error) {
        console.error('Error updating speech state:', error);
      }
    },
    [onProgressUpdate, onSentenceIndexUpdate, onStatusChange]
  );

  const speak = useCallback(
    (startProgress?: number) => {
      try {
        if (!content || content.length === 0) {
          console.warn('No content available for speech');
          return;
        }

        const progressToUse = startProgress ?? speechState.progress;
        const sentenceIndex = Math.floor(progressToUse * content.length);

        if (sentenceIndex >= content.length) {
          console.warn('Speech index out of bounds');
          updateSpeechState({ status: 'stopped' });
          return;
        }

        const textToSpeak = content[sentenceIndex];
        if (!textToSpeak || textToSpeak.trim() === '') {
          console.warn('Empty text at index:', sentenceIndex);
          return;
        }

        isSpeakingRef.current = true;
        updateSpeechState({
          status: 'playing',
          currentSentenceIndex: sentenceIndex,
          progress: progressToUse,
        });

        Speech.speak(textToSpeak, {
          language: voice,
          onDone: () => {
            if (!isSpeakingRef.current) return;

            const nextIndex = sentenceIndex + 1;
            if (nextIndex < content.length) {
              const nextProgress = nextIndex / content.length;
              setTimeout(() => {
                if (isSpeakingRef.current) {
                  speak(nextProgress);
                }
              }, CONSTANTS.TIMING.SPEECH_CONTINUE_DELAY);
            } else {
              // Reached end of content
              updateSpeechState({ status: 'stopped' });
              isSpeakingRef.current = false;
            }
          },
          onError: (error) => {
            console.error('Speech error:', error);
            updateSpeechState({ status: 'stopped' });
            isSpeakingRef.current = false;
          },
          onStopped: () => {
            if (stopSourceRef.current !== 'manualProgressChange') {
              updateSpeechState({ status: 'stopped' });
            }
            isSpeakingRef.current = false;
            stopSourceRef.current = 'unknown';
          },
        });
      } catch (error) {
        console.error('Error in speak function:', error);
        updateSpeechState({ status: 'stopped' });
        isSpeakingRef.current = false;
      }
    },
    [content, voice, speechState.progress, updateSpeechState]
  );

  const stop = useCallback(
    (source: StopSource = 'unknown') => {
      try {
        // Input validation
        if (source && typeof source !== 'string') {
          console.warn('stop: source must be a string');
          source = 'unknown';
        }

        stopSourceRef.current = source;
        Speech.stop();
        isSpeakingRef.current = false;
        updateSpeechState({ status: 'stopped' });
      } catch (error) {
        console.error('Error stopping speech:', error);
      }
    },
    [updateSpeechState]
  );

  const pause = useCallback(() => {
    try {
      Speech.stop();
      isSpeakingRef.current = false;
      updateSpeechState({ status: 'paused' });
    } catch (error) {
      console.error('Error pausing speech:', error);
    }
  }, [updateSpeechState]);

  const resume = useCallback(() => {
    try {
      speak(speechState.progress);
    } catch (error) {
      console.error('Error resuming speech:', error);
    }
  }, [speak, speechState.progress]);

  const setProgress = useCallback(
    (newProgress: number) => {
      try {
        // Input validation
        if (typeof newProgress !== 'number' || isNaN(newProgress)) {
          console.warn('setProgress: newProgress must be a valid number');
          return;
        }

        const clampedProgress = Math.max(0, Math.min(1, newProgress));

        if (speechState.status === 'playing') {
          stop('manualProgressChange');
          setTimeout(() => {
            updateSpeechState({ progress: clampedProgress });
            speak(clampedProgress);
          }, CONSTANTS.TIMING.PROGRESS_RESTART_DELAY);
        } else {
          updateSpeechState({ progress: clampedProgress });
        }
      } catch (error) {
        console.error('Error setting progress:', error);
      }
    },
    [speechState.status, stop, updateSpeechState, speak]
  );

  const setShouldAutoPlay = useCallback(
    (shouldAutoPlay: boolean) => {
      try {
        // Input validation
        if (typeof shouldAutoPlay !== 'boolean') {
          console.warn('setShouldAutoPlay: shouldAutoPlay must be a boolean');
          return;
        }

        updateSpeechState({ shouldAutoPlay });
      } catch (error) {
        console.error('Error setting shouldAutoPlay:', error);
      }
    },
    [updateSpeechState]
  );

  const cleanup = useCallback(() => {
    try {
      stop('cleanup');
    } catch (error) {
      console.error('Error during speech cleanup:', error);
    }
  }, [stop]);

  return {
    speechState,
    speak,
    stop,
    pause,
    resume,
    setProgress,
    setShouldAutoPlay,
    cleanup,
    isSpeaking: isSpeakingRef.current,
  };
}
