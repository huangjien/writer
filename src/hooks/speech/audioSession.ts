/**
 * Audio session configuration utilities for speech functionality
 */

import { Platform } from 'react-native';
import { Audio, InterruptionModeIOS } from 'expo-av';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import { AudioSessionConfig } from './types';

/**
 * Enable keep awake to prevent device from sleeping during speech
 */
export const enableKeepAwake = async (): Promise<void> => {
  await activateKeepAwakeAsync();
};

/**
 * Disable keep awake when speech is not active
 */
export const disableKeepAwake = (): void => {
  deactivateKeepAwake();
};

/**
 * Configure audio session for background playback with proper interruption handling
 */
export const configureAudioSession = async (): Promise<void> => {
  try {
    if (Platform.OS === 'android') {
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: false,
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        shouldDuckAndroid: true, // Allow ducking for proper interruption handling
        playThroughEarpieceAndroid: false,
      });
    } else if (Platform.OS === 'ios') {
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: false,
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        interruptionModeIOS: InterruptionModeIOS.MixWithOthers, // Allow mixing but handle interruptions properly
        shouldDuckAndroid: false,
        playThroughEarpieceAndroid: false,
      });
    }

    // Configure audio session to handle interruptions properly
    await Audio.setIsEnabledAsync(true);

    console.log(
      'Audio session configured for background playback with interruption handling'
    );
  } catch (error) {
    console.error('Failed to configure audio session:', error);
  }
};

/**
 * Set up audio interruption listener for handling interruptions from other apps
 */
export const setupAudioInterruptionListener = async (): Promise<void> => {
  try {
    // Listen for audio interruptions (when other apps start playing audio)
    await Audio.setAudioModeAsync({
      allowsRecordingIOS: false,
      staysActiveInBackground: true,
      playsInSilentModeIOS: true,
      interruptionModeIOS:
        Platform.OS === 'ios' ? InterruptionModeIOS.MixWithOthers : undefined,
      shouldDuckAndroid: Platform.OS === 'android',
    });

    console.log('Audio interruption handling configured');
  } catch (error) {
    console.error('Failed to set up audio interruption listener:', error);
  }
};

/**
 * Handle audio interruptions from other apps
 */
export const handleAudioInterruption = (
  interruptionStatus: any,
  currentStatus: string,
  onPause: () => void,
  onResume: () => void
): void => {
  console.log('Audio interruption:', interruptionStatus);

  if (interruptionStatus.shouldPause || interruptionStatus.shouldStop) {
    // Another app is taking over audio focus
    if (currentStatus === 'playing') {
      console.log('Audio interrupted by another app, pausing playback');
      onPause();
    }
  } else if (interruptionStatus.shouldResume) {
    // Audio focus returned, resume if we were playing before
    if (currentStatus === 'paused') {
      console.log('Audio focus returned, resuming playback');
      onResume();
    }
  }
};
