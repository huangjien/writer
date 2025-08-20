import { useState, useEffect, useRef } from 'react';
import { AppState, AppStateStatus } from 'react-native';
import * as Speech from 'expo-speech';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
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
  const speechOptionsRef = useRef<{
    language?: string;
    pitch?: number;
    rate?: number;
    onDone?: () => void;
  }>({});

  const enableKeepAwake = async () => {
    await activateKeepAwakeAsync();
  };

  // Enhanced background audio handling for screen lock scenarios
  const handleScreenLock = () => {
    // When screen locks, ensure audio continues by maintaining keep awake
    if (status === STATUS_PLAYING) {
      console.log('Screen locked, maintaining audio playback');
      enableKeepAwake();

      // Force continue current sentence if speech was interrupted
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
  };

  // Monitor for potential speech interruptions and resume
  const monitorSpeechContinuity = () => {
    if (status === STATUS_PLAYING && !isPausedRef.current) {
      // Check if we should be speaking but aren't
      if (currentSentenceIndex < sentencesRef.current.length) {
        const checkInterval = setInterval(() => {
          if (status === STATUS_PLAYING && !isPausedRef.current) {
            // Ensure speech continues
            speakCurrentSentence();
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
