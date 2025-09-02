/**
 * Speech monitoring and recovery utilities
 */

import { Platform } from 'react-native';
import * as Speech from 'expo-speech';
import { CONSTANTS } from '@/constants/appConstants';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

interface SpeechMonitoringOptions {
  status: string;
  isPaused: boolean;
  currentSentenceIndex: number;
  sentences: string[];
  onSpeakCurrentSentence: () => void;
}

/**
 * Monitor for potential speech interruptions and resume
 */
export const monitorSpeechContinuity = ({
  status,
  isPaused,
  currentSentenceIndex,
  sentences,
  onSpeakCurrentSentence,
}: SpeechMonitoringOptions) => {
  if (status === STATUS_PLAYING && !isPaused) {
    // Check if we should be speaking but aren't
    if (currentSentenceIndex < sentences.length) {
      const checkInterval = setInterval(async () => {
        if (status === STATUS_PLAYING && !isPaused) {
          try {
            // Check if speech is actually running
            const isSpeaking = await Speech.isSpeakingAsync();
            if (!isSpeaking) {
              console.log('Speech interrupted, restarting current sentence');
              onSpeakCurrentSentence();
            }
          } catch (error) {
            console.log('Error checking speech status, restarting:', error);
            onSpeakCurrentSentence();
          }
          clearInterval(checkInterval);
        } else {
          clearInterval(checkInterval);
        }
      }, CONSTANTS.TIMING.SPEECH_MONITORING_INTERVAL);
    }
  }
};

/**
 * Enhanced background audio handling for screen lock scenarios
 */
export const handleScreenLock = ({
  status,
  isPaused,
  currentSentenceIndex,
  sentences,
  onSpeakCurrentSentence,
}: SpeechMonitoringOptions) => {
  // When screen locks, ensure audio continues by maintaining keep awake
  if (status === STATUS_PLAYING) {
    console.log('Screen locked, maintaining audio playback');

    // For Android, implement more aggressive recovery
    if (Platform.OS === 'android') {
      // Stop any current speech and restart to ensure continuity
      Speech.stop();
      setTimeout(() => {
        if (status === STATUS_PLAYING && !isPaused) {
          onSpeakCurrentSentence();
        }
      }, CONSTANTS.TIMING.SPEECH_RESTART_DELAY_ANDROID);
    } else {
      // For iOS, try to continue current sentence if interrupted
      if (currentSentenceIndex < sentences.length && !isPaused) {
        setTimeout(() => {
          if (status === STATUS_PLAYING) {
            onSpeakCurrentSentence();
          }
        }, CONSTANTS.TIMING.SPEECH_RESTART_DELAY_IOS);
      }
    }
  }
};

/**
 * Android-specific speech monitoring for background scenarios
 */
export const startAndroidSpeechMonitoring = (
  options: SpeechMonitoringOptions
) => {
  if (Platform.OS === 'android') {
    setTimeout(() => {
      monitorSpeechContinuity(options);
    }, CONSTANTS.TIMING.BACKGROUND_MONITORING_DELAY);
  }
};

/**
 * Check if speech should be recovered after interruption
 */
export const shouldRecoverSpeech = (
  wasPlayingBefore: boolean,
  currentStatus: string,
  isPaused: boolean
): boolean => {
  return wasPlayingBefore && currentStatus !== STATUS_PLAYING && !isPaused;
};

/**
 * Recover speech playback after interruption
 */
export const recoverSpeechPlayback = (
  currentSentenceIndex: number,
  sentences: string[],
  onResume: () => void,
  onSpeakCurrentSentence: () => void
) => {
  onResume();
  if (currentSentenceIndex < sentences.length) {
    onSpeakCurrentSentence();
  }
};

/**
 * Handle audio interruption scenarios
 */
export const handleAudioInterruption = (
  isInterrupted: boolean,
  status: string,
  onPause: () => void,
  onResume: () => void
) => {
  if (isInterrupted && status === STATUS_PLAYING) {
    console.log('Audio interrupted, pausing speech');
    Speech.pause();
    onPause();
    return true; // Return true to indicate we were playing before interruption
  } else if (!isInterrupted && status === STATUS_PAUSED) {
    console.log('Audio interruption ended, resuming speech');
    Speech.resume();
    onResume();
    return false; // Return false to reset the interruption state
  }
  return false;
};
