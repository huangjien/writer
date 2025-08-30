import { useState, useEffect, useRef } from 'react';
import { AppState, AppStateStatus, Platform } from 'react-native';
import * as Speech from 'expo-speech';
import { Audio, InterruptionModeIOS, AVPlaybackStatus } from 'expo-av';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import TrackPlayer, {
  Event,
  State,
  Capability,
} from 'react-native-track-player';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

export function useSpeech() {
  const [status, setStatus] = useState(STATUS_STOPPED);
  const [progress, setProgress] = useState(0); // Progress as percentage (0-1)
  const [currentSentenceIndex, setCurrentSentenceIndex] = useState(0);

  // Refs to maintain state across renders
  const sentencesRef = useRef<string[]>([]);
  const totalContentLengthRef = useRef(0);
  const completedContentLengthRef = useRef(0);
  const isPausedRef = useRef(false);
  const wasPlayingBeforeBackgroundRef = useRef(false);
  const wasPlayingBeforeInterruptionRef = useRef(false);
  const audioInterruptionListenerRef = useRef<any>(null);
  const speechOptionsRef = useRef<{
    language?: string;
    pitch?: number;
    rate?: number;
    onDone?: () => void;
  }>({});

  const enableKeepAwake = async () => {
    await activateKeepAwakeAsync();
  };

  // Handle audio interruptions from other apps
  const handleAudioInterruption = (interruptionStatus: any) => {
    console.log('Audio interruption:', interruptionStatus);

    if (interruptionStatus.shouldPause || interruptionStatus.shouldStop) {
      // Another app is taking over audio focus
      if (status === STATUS_PLAYING) {
        console.log('Audio interrupted by another app, pausing playback');
        wasPlayingBeforeInterruptionRef.current = true;
        Speech.pause();
        setStatus(STATUS_PAUSED);
        isPausedRef.current = true;
      }
    } else if (interruptionStatus.shouldResume) {
      // Audio focus returned, resume if we were playing before
      if (wasPlayingBeforeInterruptionRef.current && status === STATUS_PAUSED) {
        console.log('Audio focus returned, resuming playback');
        wasPlayingBeforeInterruptionRef.current = false;
        Speech.resume();
        setStatus(STATUS_PLAYING);
        isPausedRef.current = false;

        // Continue with current sentence if needed
        if (currentSentenceIndex < sentencesRef.current.length) {
          speakCurrentSentence();
        }
      }
    }
  };

  // Set up media session controls for earphone buttons
  const setupMediaSessionControls = async () => {
    try {
      await TrackPlayer.setupPlayer({
        waitForBuffer: false,
      });

      // Set up media session metadata
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
      });

      console.log('Media session controls configured');
    } catch (error) {
      console.error('Failed to setup media session controls:', error);
    }
  };

  // Configure audio session for background playback
  const configureAudioSession = async () => {
    try {
      if (Platform.OS === 'android') {
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          staysActiveInBackground: true,
          playsInSilentModeIOS: true,
          shouldDuckAndroid: true,
          playThroughEarpieceAndroid: false,
        });
      } else if (Platform.OS === 'ios') {
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          staysActiveInBackground: true,
          playsInSilentModeIOS: true,
          interruptionModeIOS: InterruptionModeIOS.DuckOthers,
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

  // Enhanced background audio handling for screen lock scenarios
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
          if (status === STATUS_PLAYING && !isPausedRef.current) {
            speakCurrentSentence();
          }
        }, 200);
      } else {
        // For iOS, try to continue current sentence if interrupted
        if (
          currentSentenceIndex < sentencesRef.current.length &&
          !isPausedRef.current
        ) {
          setTimeout(() => {
            if (status === STATUS_PLAYING) {
              speakCurrentSentence();
            }
          }, 100);
        }
      }
    }
  };

  // Monitor for potential speech interruptions and resume
  const monitorSpeechContinuity = () => {
    if (status === STATUS_PLAYING && !isPausedRef.current) {
      // Check if we should be speaking but aren't
      if (currentSentenceIndex < sentencesRef.current.length) {
        const checkInterval = setInterval(async () => {
          if (status === STATUS_PLAYING && !isPausedRef.current) {
            try {
              // Check if speech is actually running
              const isSpeaking = await Speech.isSpeakingAsync();
              if (!isSpeaking) {
                console.log('Speech interrupted, restarting current sentence');
                speakCurrentSentence();
              }
            } catch (error) {
              console.log('Error checking speech status, restarting:', error);
              speakCurrentSentence();
            }
            clearInterval(checkInterval);
          } else {
            clearInterval(checkInterval);
          }
        }, 1000);
      }
    }
  };

  // Keep awake effect
  useEffect(() => {
    if (status === STATUS_PLAYING) {
      enableKeepAwake();
    } else {
      deactivateKeepAwake();
    }
  }, [status]);

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
            setTimeout(() => monitorSpeechContinuity(), 500);
          }
        }
      } else if (nextAppState === 'active') {
        // App is coming to foreground
        console.log('App coming to foreground, restoring audio state');

        // If we were playing before going to background, ensure we continue
        if (
          wasPlayingBeforeBackgroundRef.current &&
          status !== STATUS_PLAYING &&
          !isPausedRef.current
        ) {
          // Resume speech if it was interrupted
          setStatus(STATUS_PLAYING);
          if (currentSentenceIndex < sentencesRef.current.length) {
            speakCurrentSentence();
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
  }, [status, currentSentenceIndex]);

  // Initialize audio session for background playbook
  useEffect(() => {
    configureAudioSession();
    setupMediaSessionControls();

    // Set up media session event listener for earphone buttons
    const mediaSessionListener = TrackPlayer.addEventListener(
      Event.RemotePlay,
      () => {
        if (status === STATUS_PAUSED) {
          resume();
        } else if (
          status === STATUS_STOPPED &&
          sentencesRef.current.length > 0
        ) {
          speak(sentencesRef.current.join(' '));
        }
      }
    );
    const pauseListener = TrackPlayer.addEventListener(
      Event.RemotePause,
      () => {
        if (status === STATUS_PLAYING) {
          pause();
        }
      }
    );
    const stopListener = TrackPlayer.addEventListener(Event.RemoteStop, () => {
      stop();
    });
    const nextListener = TrackPlayer.addEventListener(Event.RemoteNext, () => {
      if (currentSentenceIndex < sentencesRef.current.length - 1) {
        setCurrentSentenceIndex((prev) => prev + 1);
        speakCurrentSentence();
      }
    });
    const previousListener = TrackPlayer.addEventListener(
      Event.RemotePrevious,
      () => {
        if (currentSentenceIndex > 0) {
          setCurrentSentenceIndex((prev) => prev - 1);
          speakCurrentSentence();
        }
      }
    );

    // Set up audio interruption handling using app state changes
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
          setStatus(STATUS_PAUSED);
          isPausedRef.current = true;
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
          setStatus(STATUS_PLAYING);
          isPausedRef.current = false;
        }
      }
    };

    const subscription = AppState.addEventListener(
      'change',
      handleAppStateChange
    );

    return () => {
      subscription?.remove();
      mediaSessionListener?.remove();
      pauseListener?.remove();
      stopListener?.remove();
      nextListener?.remove();
      previousListener?.remove();
      if (audioInterruptionListenerRef.current) {
        audioInterruptionListenerRef.current = null;
      }
    };
  }, [status]);

  // Continuous monitoring for speech interruptions (especially for Android)
  useEffect(() => {
    let monitoringInterval: number | null = null;

    if (status === STATUS_PLAYING && Platform.OS === 'android') {
      monitoringInterval = setInterval(async () => {
        if (status === STATUS_PLAYING && !isPausedRef.current) {
          try {
            const isSpeaking = await Speech.isSpeakingAsync();
            if (
              !isSpeaking &&
              currentSentenceIndex < sentencesRef.current.length
            ) {
              console.log(
                'Android: Speech stopped unexpectedly, recovering...'
              );
              // Restart current sentence
              speakCurrentSentence();
            }
          } catch (error) {
            console.log(
              'Android: Error monitoring speech, attempting recovery:',
              error
            );
            if (currentSentenceIndex < sentencesRef.current.length) {
              speakCurrentSentence();
            }
          }
        }
      }, 2000); // Check every 2 seconds
    }

    return () => {
      if (monitoringInterval) {
        clearInterval(monitoringInterval);
      }
    };
  }, [status, currentSentenceIndex]);

  // Helper function to split content into sentences
  const splitIntoSentences = (content: string): string[] => {
    // Split by sentence endings, keeping the punctuation
    const sentences = content
      .split(/([.!?。！？]+)/)
      .filter((s) => s.trim().length > 0);
    const result: string[] = [];

    for (let i = 0; i < sentences.length; i += 2) {
      const sentence = sentences[i];
      const punctuation = sentences[i + 1] || '';
      if (sentence.trim()) {
        result.push((sentence + punctuation).trim());
      }
    }

    return result.length > 0 ? result : [content];
  };

  // Function to speak the current sentence
  const speakCurrentSentence = () => {
    if (
      isPausedRef.current ||
      currentSentenceIndex >= sentencesRef.current.length
    ) {
      return;
    }

    const sentence = sentencesRef.current[currentSentenceIndex];
    const options = speechOptionsRef.current;

    Speech.speak(sentence, {
      language: options.language,
      pitch: options.pitch,
      rate: options.rate,
      onDone: () => {
        if (!isPausedRef.current) {
          // Update progress
          completedContentLengthRef.current += sentence.length;
          const newProgress =
            totalContentLengthRef.current > 0
              ? completedContentLengthRef.current /
                totalContentLengthRef.current
              : 0;
          setProgress(Math.min(newProgress, 1));

          // Move to next sentence
          const nextIndex = currentSentenceIndex + 1;
          setCurrentSentenceIndex(nextIndex);

          // Continue with next sentence or finish
          if (nextIndex < sentencesRef.current.length) {
            speakCurrentSentence();
          } else {
            setStatus(STATUS_STOPPED);
            setProgress(1);
            options.onDone?.();
          }
        }
      },
    });
  };

  const speak = (
    content: string,
    options?: {
      language?: string;
      pitch?: number;
      rate?: number;
      onDone?: () => void;
    }
  ) => {
    // Split content into sentences
    const sentences = splitIntoSentences(content);

    // Store options in ref for resume functionality
    speechOptionsRef.current = options || {};

    // Initialize refs and state
    sentencesRef.current = sentences;
    totalContentLengthRef.current = content.length;
    completedContentLengthRef.current = 0;
    isPausedRef.current = false;

    // Reset state
    setCurrentSentenceIndex(0);
    setProgress(0);
    setStatus(STATUS_PLAYING);

    // Start speaking the first sentence
    speakCurrentSentence();

    // Monitor speech continuity for background playback
    monitorSpeechContinuity();
  };

  const stop = () => {
    setStatus(STATUS_STOPPED);
    setProgress(0);
    setCurrentSentenceIndex(0);
    isPausedRef.current = false;
    completedContentLengthRef.current = 0;
    Speech.stop();
  };

  const pause = () => {
    setStatus(STATUS_PAUSED);
    isPausedRef.current = true;
    Speech.pause();
  };

  const resume = () => {
    setStatus(STATUS_PLAYING);
    isPausedRef.current = false;
    Speech.resume();

    // If we were in the middle of speaking sentences, continue from current position
    if (currentSentenceIndex < sentencesRef.current.length) {
      speakCurrentSentence();
    }
  };

  return {
    status,
    progress,
    currentSentenceIndex,
    speak,
    stop,
    pause,
    resume,
  };
}
