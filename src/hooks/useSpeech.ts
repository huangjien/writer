import { useState, useRef, useEffect } from 'react';
import * as Speech from 'expo-speech';
import { CONSTANTS } from '@/constants/appConstants';
import {
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';

// Import extracted modules
import { SpeechOptions, SpeechHookReturn } from './speech/types';
import {
  configureAudioSession,
  enableKeepAwake,
  disableKeepAwake,
} from './speech/audioSession';
import {
  setupMediaSessionControls,
  setupMediaSessionListeners,
} from './speech/mediaSession';
import { useAppStateHandler } from './speech/useAppStateHandler';
import {
  splitIntoSentences,
  calculateProgress,
  getCurrentSentence,
} from './speech/sentenceProcessing';

export function useSpeech(): SpeechHookReturn {
  const [status, setStatus] = useState(STATUS_STOPPED);
  const [progress, setProgress] = useState(0);
  const [currentSentenceIndex, setCurrentSentenceIndex] = useState(0);

  // Refs to maintain state across renders
  const sentencesRef = useRef<string[]>([]);
  const totalContentLengthRef = useRef(0);
  const completedContentLengthRef = useRef(0);
  const isPausedRef = useRef(false);
  const speechOptionsRef = useRef<SpeechOptions>({});
  const originalTextRef = useRef('');

  // Speak the current sentence
  const speakCurrentSentence = () => {
    const currentSentence = getCurrentSentence(
      sentencesRef.current,
      currentSentenceIndex
    );

    if (!currentSentence) {
      return;
    }

    console.log(
      `Speaking sentence ${currentSentenceIndex + 1}/${sentencesRef.current.length}: ${currentSentence}`
    );

    Speech.speak(currentSentence, {
      language: speechOptionsRef.current.language || 'en',
      pitch: speechOptionsRef.current.pitch || 1.0,
      rate: speechOptionsRef.current.rate || 1.0,
      onDone: () => {
        if (!isPausedRef.current && status === STATUS_PLAYING) {
          // Update progress
          const completedText = sentencesRef.current
            .slice(0, currentSentenceIndex + 1)
            .join(' ');
          completedContentLengthRef.current = completedText.length;
          const newProgress =
            totalContentLengthRef.current > 0
              ? completedContentLengthRef.current /
                totalContentLengthRef.current
              : 0;
          setProgress(Math.min(1, newProgress));

          // Move to next sentence
          const nextIndex = currentSentenceIndex + 1;
          setCurrentSentenceIndex(nextIndex);

          // Continue with next sentence or finish
          if (nextIndex < sentencesRef.current.length) {
            speakCurrentSentence();
          } else {
            setStatus(STATUS_STOPPED);
            setProgress(1);
            disableKeepAwake();
            speechOptionsRef.current.onDone?.();
          }
        }
      },
    });
  };

  // App state handler for background/foreground behavior
  const { monitorSpeechContinuity } = useAppStateHandler({
    status,
    currentSentenceIndex,
    sentences: sentencesRef.current,
    isPaused: isPausedRef.current,
    onSpeakCurrentSentence: speakCurrentSentence,
    onPause: () => {
      setStatus(STATUS_PAUSED);
      isPausedRef.current = true;
    },
    onResume: () => {
      setStatus(STATUS_PLAYING);
      isPausedRef.current = false;
    },
  });

  // Initialize audio session and media controls on mount
  useEffect(() => {
    configureAudioSession();
    setupMediaSessionControls();
    setupMediaSessionListeners(
      status,
      sentencesRef.current,
      currentSentenceIndex,
      () => {
        if (status === STATUS_PAUSED) {
          resume();
        }
      },
      () => {
        if (status === STATUS_PLAYING) {
          pause();
        }
      },
      stop,
      () => {
        if (currentSentenceIndex < sentencesRef.current.length - 1) {
          setCurrentSentenceIndex(currentSentenceIndex + 1);
          if (status === STATUS_PLAYING) {
            Speech.stop();
            speakCurrentSentence();
          }
        }
      },
      () => {
        if (currentSentenceIndex > 0) {
          setCurrentSentenceIndex(currentSentenceIndex - 1);
          if (status === STATUS_PLAYING) {
            Speech.stop();
            speakCurrentSentence();
          }
        }
      }
    );
  }, []);

  const speak = (content: string, options?: SpeechOptions) => {
    // Validate input
    if (
      !content ||
      typeof content !== 'string' ||
      content.trim().length === 0
    ) {
      console.warn('Invalid content provided to speak function');
      return;
    }

    if (content.length > CONSTANTS.CONTENT.MAX_SPEECH_INPUT_LENGTH) {
      console.warn('Content too long for speech synthesis');
      return;
    }

    // Split content into sentences
    const sentences = splitIntoSentences(content);

    if (sentences.length === 0) {
      console.warn('No valid sentences found in content');
      return;
    }

    // Store options and content in refs
    speechOptionsRef.current = options || {};
    sentencesRef.current = sentences;
    totalContentLengthRef.current = content.length;
    completedContentLengthRef.current = 0;
    isPausedRef.current = false;
    originalTextRef.current = content;

    // Reset state
    setCurrentSentenceIndex(0);
    setProgress(0);
    setStatus(STATUS_PLAYING);

    // Enable keep awake for background playback
    enableKeepAwake();

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
    disableKeepAwake();
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
