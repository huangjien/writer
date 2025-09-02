/**
 * Media session controls and TrackPlayer setup for speech functionality
 */

import TrackPlayer, {
  Event,
  State,
  Capability,
  AppKilledPlaybackBehavior,
} from 'react-native-track-player';
import { MediaSessionOptions } from './types';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

/**
 * Set up media session controls for earphone buttons and notification controls
 */
export const setupMediaSessionControls = async (): Promise<void> => {
  try {
    // Initialize TrackPlayer
    await TrackPlayer.setupPlayer({
      waitForBuffer: false,
      autoHandleInterruptions: true, // Let TrackPlayer handle audio interruptions
    });

    // Set up media session metadata and capabilities
    await TrackPlayer.updateOptions({
      capabilities: [
        Capability.Play,
        Capability.Pause,
        Capability.Stop,
        Capability.SkipToNext,
        Capability.SkipToPrevious,
      ],
      compactCapabilities: [
        Capability.Play,
        Capability.Pause,
        Capability.SkipToNext,
        Capability.SkipToPrevious,
      ],
      // Enable notification controls
      notificationCapabilities: [
        Capability.Play,
        Capability.Pause,
        Capability.Stop,
      ],
      // Configure for speech playback
      android: {
        appKilledPlaybackBehavior:
          AppKilledPlaybackBehavior.StopPlaybackAndRemoveNotification,
      },
    });

    console.log('Media session controls configured with interruption handling');
  } catch (error) {
    console.error('Failed to setup media session controls:', error);
  }
};

/**
 * Set up media session event listeners for remote control buttons
 */
export const setupMediaSessionListeners = (
  currentStatus: string,
  sentences: string[],
  currentSentenceIndex: number,
  onPlay: () => void,
  onPause: () => void,
  onStop: () => void,
  onNext: () => void,
  onPrevious: () => void
) => {
  const playListener = TrackPlayer.addEventListener(Event.RemotePlay, () => {
    console.log('Remote play button pressed');
    if (currentStatus === STATUS_PAUSED) {
      onPlay();
    } else if (currentStatus === STATUS_STOPPED && sentences.length > 0) {
      onPlay();
    }
  });

  const pauseListener = TrackPlayer.addEventListener(Event.RemotePause, () => {
    console.log('Remote pause button pressed');
    if (currentStatus === STATUS_PLAYING) {
      onPause();
    }
  });

  const stopListener = TrackPlayer.addEventListener(Event.RemoteStop, () => {
    console.log('Remote stop button pressed');
    onStop();
  });

  const nextListener = TrackPlayer.addEventListener(Event.RemoteNext, () => {
    console.log('Remote next button pressed');
    if (currentSentenceIndex < sentences.length - 1) {
      onNext();
    }
  });

  const previousListener = TrackPlayer.addEventListener(
    Event.RemotePrevious,
    () => {
      console.log('Remote previous button pressed');
      if (currentSentenceIndex > 0) {
        onPrevious();
      }
    }
  );

  // Return cleanup function
  return () => {
    playListener?.remove();
    pauseListener?.remove();
    stopListener?.remove();
    nextListener?.remove();
    previousListener?.remove();
  };
};
