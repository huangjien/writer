/**
 * Custom hook for handling app state changes and background behavior during speech
 */

import { useEffect, useRef } from 'react';
import { AppState, AppStateStatus, Platform } from 'react-native';
import * as Speech from 'expo-speech';
import { CONSTANTS } from '@/constants/appConstants';
import {
  enableKeepAwake,
  setupAudioInterruptionListener,
} from './audioSession';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

interface UseAppStateHandlerProps {
  status: string;
  currentSentenceIndex: number;
  sentences: string[];
  isPaused: boolean;
  onSpeakCurrentSentence: () => void;
  onPause: () => void;
  onResume: () => void;
}

export const useAppStateHandler = ({
  status,
  currentSentenceIndex,
  sentences,
  isPaused,
  onSpeakCurrentSentence,
  onPause,
  onResume,
}: UseAppStateHandlerProps) => {
  const wasPlayingBeforeBackgroundRef = useRef(false);
  const wasPlayingBeforeInterruptionRef = useRef(false);
  const audioInterruptionListenerRef = useRef<any>(null);

  /**
   * Enhanced background audio handling for screen lock scenarios
   */
  const handleScreenLock = () => {
    // When screen locks, ensure audio continues by maintaining keep awake
    if (status === STATUS_PLAYING) {
      console.log('Screen locked, maintaining audio playback');
      enableKeepAwake();

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
   * Monitor for potential speech interruptions and resume
   */
  const monitorSpeechContinuity = () => {
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

  // Handle app state changes for background/foreground
  useEffect(() => {
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      if (nextAppState === 'background' || nextAppState === 'inactive') {
        // App is going to background - save current playing state
        wasPlayingBeforeBackgroundRef.current = status === STATUS_PLAYING;
        console.log(
          'App going to background, audio state saved:',
          wasPlayingBeforeBackgroundRef.current
        );

        // Keep the device awake to maintain audio playback
        if (status === STATUS_PLAYING) {
          enableKeepAwake();
          handleScreenLock();
          // Start monitoring speech continuity for Android
          if (Platform.OS === 'android') {
            setTimeout(
              () => monitorSpeechContinuity(),
              CONSTANTS.TIMING.BACKGROUND_MONITORING_DELAY
            );
          }
        }
      } else if (nextAppState === 'active') {
        // App is coming to foreground
        console.log('App coming to foreground, restoring audio state');

        // If we were playing before going to background, ensure we continue
        if (
          wasPlayingBeforeBackgroundRef.current &&
          status !== STATUS_PLAYING &&
          !isPaused
        ) {
          // Resume speech if it was interrupted
          onResume();
          if (currentSentenceIndex < sentences.length) {
            onSpeakCurrentSentence();
          }
        }
      }
    };

    const subscription = AppState.addEventListener(
      'change',
      handleAppStateChange
    );

    return () => {
      subscription?.remove();
    };
  }, [
    status,
    currentSentenceIndex,
    sentences,
    isPaused,
    onSpeakCurrentSentence,
    onResume,
  ]);

  // Handle app state changes for background/foreground and audio interruptions
  useEffect(() => {
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      console.log('App state changed to:', nextAppState);

      if (nextAppState === 'background' || nextAppState === 'inactive') {
        // App going to background, check if we should pause due to audio interruption
        if (status === STATUS_PLAYING) {
          console.log(
            'App backgrounded while playing, checking for audio interruption'
          );
          // In a real scenario, we'd check if another app is using audio
          // For now, we'll pause when app goes to background
          wasPlayingBeforeInterruptionRef.current = true;
          Speech.pause();
          onPause();
        }
      } else if (nextAppState === 'active') {
        // App coming back to foreground
        if (
          wasPlayingBeforeInterruptionRef.current &&
          status === STATUS_PAUSED
        ) {
          console.log('App foregrounded, resuming playback');
          wasPlayingBeforeInterruptionRef.current = false;
          Speech.resume();
          onResume();
        }
      }
    };

    const subscription = AppState.addEventListener(
      'change',
      handleAppStateChange
    );

    setupAudioInterruptionListener();

    return () => {
      subscription?.remove();
      if (audioInterruptionListenerRef.current) {
        audioInterruptionListenerRef.current = null;
      }
    };
  }, [status, onPause, onResume]);

  return {
    wasPlayingBeforeBackgroundRef,
    wasPlayingBeforeInterruptionRef,
    monitorSpeechContinuity,
  };
};
