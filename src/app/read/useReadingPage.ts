import { useState, useEffect, useCallback, useMemo } from 'react';
import { useLocalSearchParams } from 'expo-router';
import { useReading } from '@/hooks/useReading';
import { useSpeechControl } from '@/hooks/useSpeechControl';
import { useGestureHandlers } from '@/hooks/useGestureHandlers';
import { useContentUtils } from './readingUtils';
import { useNavigationHandlers, useSwipeHandler } from './navigationHandlers';
import { useSpeechHandlers, useSpeechProgressUpdate } from './speechHandlers';
import { UseReadingPageReturn, UIState } from './types';
import { CONSTANTS } from '@/constants/appConstants';

/**
 * Main hook that combines all reading page functionality
 * @returns Complete reading page state and handlers
 */
export const useReadingPage = (): UseReadingPageReturn => {
  // Get route parameters
  const { id, preview, next } = useLocalSearchParams<{
    id: string;
    preview: string;
    next: string;
  }>();

  // UI state management
  const [modalVisible, setModalVisible] = useState<boolean>(false);
  const [uiState, setUIState] = useState<UIState>({
    modalVisible: false,
    showBar: true,
    selectedLanguage: 'zh',
    voice: 'zh-CN',
  });

  // Core reading functionality
  const {
    content,
    progress,
    setProgress,
    analysis,
    preview: readingPreview,
    next: readingNext,
    current,
    fontSize,
  } = useReading();

  // Content utilities
  const { getContentFromProgress } = useContentUtils(content, progress);

  // Speech progress update callback (declare before using)
  const onProgressUpdate = useSpeechProgressUpdate(
    setProgress,
    content,
    'stopped', // Default status
    () => {} // Default toNext function
  );

  // Speech control functionality
  const contentArray = content
    ? content.split('\n').filter((p) => p.trim())
    : [];
  const {
    speechState,
    speak,
    stop,
    pause,
    resume,
    setProgress: setSpeechProgress,
    setShouldAutoPlay,
    cleanup,
    isSpeaking,
  } = useSpeechControl({
    content: contentArray,
    voice: uiState.voice,
    onProgressUpdate,
    onSentenceIndexUpdate: (index: number) => {
      // Handle sentence index updates
    },
    onStatusChange: (status: string) => {
      // Handle status changes
    },
  });

  // Navigation handlers
  const navigationHandlers = useNavigationHandlers(
    preview,
    next,
    speechState,
    stop,
    setModalVisible
  );

  // Speech handlers
  const speechHandlers = useSpeechHandlers(
    speechState,
    speak,
    stop,
    setProgress,
    content,
    navigationHandlers.toNext,
    progress
  );

  // Swipe handler
  const handleSwipe = useSwipeHandler(
    navigationHandlers.toPreview,
    navigationHandlers.toNext
  );

  // Gesture handlers
  const gestureHandlers = useGestureHandlers({
    showBar: uiState.showBar,
    setShowBar: (show: boolean) => {
      // Update showBar state - this would need to be implemented based on the actual state management
      console.log('Setting showBar:', show);
    },
    speechStatus: speechState.status,
    onShowEval: navigationHandlers.showEval,
    onSpeak: speak,
    onStop: stop,
    onSwipe: handleSwipe,
  });

  // Memoized values
  const memoizedValues = useMemo(
    () => ({
      contentArray: content ? content.split('\n').filter((p) => p.trim()) : [],
      currentContent: getContentFromProgress(progress),
      isContentReady: Boolean(content && content.length > 0),
      hasPreview: Boolean(preview),
      hasNext: Boolean(next),
    }),
    [content, getContentFromProgress, progress, preview, next]
  );

  // Handle content changes and auto-play
  useEffect(() => {
    if (
      content &&
      speechState.shouldAutoPlay &&
      speechState.status === 'stopped'
    ) {
      const timer = setTimeout(() => {
        speak(progress);
      }, CONSTANTS.TIMING.CONTENT_LOAD_DELAY);
      return () => clearTimeout(timer);
    }
  }, [
    content,
    speechState.shouldAutoPlay,
    speechState.status,
    speak,
    progress,
  ]);

  // Update UI state based on modal visibility
  useEffect(() => {
    setUIState((prev) => ({
      ...prev,
      modalVisible,
    }));
  }, [modalVisible]);

  // Modal handlers
  const handleModalClose = useCallback(() => {
    setModalVisible(false);
    setUIState((prev) => ({ ...prev, modalVisible: false }));
  }, []);

  const handleModalOpen = useCallback(() => {
    setModalVisible(true);
    setUIState((prev) => ({ ...prev, modalVisible: true }));
  }, []);

  // Combined handlers
  const combinedHandlers = useMemo(
    () => ({
      ...navigationHandlers,
      ...speechHandlers,
      handleModalClose,
      handleModalOpen,
      onProgressUpdate,
    }),
    [
      navigationHandlers,
      speechHandlers,
      handleModalClose,
      handleModalOpen,
      onProgressUpdate,
    ]
  );

  return {
    // Core data
    content,
    analysis,
    preview: preview || readingPreview || '',
    next: next || readingNext || '',
    current: Array.isArray(current)
      ? current[0] || id || ''
      : current || id || '',
    progress,
    fontSize,

    // State
    speechState,
    uiState,
    safeAreaTop: 0,
    scrollViewRef: { current: null },

    // Handlers
    navigationHandlers,
    speechHandlers,

    // Content utilities
    contentUtils: {
      getContentFromProgress,
      contentArray: memoizedValues.contentArray,
    },

    // Gesture handlers
    gestureHandlers,

    // Modal handlers
    handleModalClose,

    // Speech control
    speak,
    stop,
    pause,
    resume,
    setSpeechProgress,
    setShouldAutoPlay,
    cleanupSpeech: cleanup,
  };
};
