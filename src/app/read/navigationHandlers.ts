import { useCallback } from 'react';
import { NavigationHandlers, SpeechState, StopSource } from './types';
import { navigateToChapter } from '@/utils/readingUtils';

/**
 * Hook to provide navigation handlers for the reading page
 * @param preview - Preview chapter identifier
 * @param next - Next chapter identifier
 * @param speechState - Current speech state
 * @param stop - Function to stop speech
 * @param setModalVisible - Function to control modal visibility
 * @returns Navigation handlers object
 */
export const useNavigationHandlers = (
  preview: string,
  next: string,
  speechState: SpeechState,
  stop: (source: StopSource) => void,
  setModalVisible: (visible: boolean) => void
): NavigationHandlers => {
  const showEval = useCallback(() => {
    try {
      setModalVisible(true);
    } catch (error) {
      console.error('Error showing analysis modal:', error);
    }
  }, [setModalVisible]);

  const toPreview = useCallback(() => {
    try {
      if (!preview) {
        console.warn('No preview chapter available');
        return;
      }

      // Stop any ongoing speech before navigation
      if (speechState.status === 'playing') {
        stop('navigation');
      }

      navigateToChapter(preview);
    } catch (error) {
      console.error('Error navigating to preview chapter:', error);
    }
  }, [preview, speechState.status, stop]);

  const toNext = useCallback(() => {
    try {
      if (!next) {
        console.warn('No next chapter available');
        return;
      }

      // Stop any ongoing speech before navigation
      if (speechState.status === 'playing') {
        stop('navigation');
      }

      navigateToChapter(next);
    } catch (error) {
      console.error('Error navigating to next chapter:', error);
    }
  }, [next, speechState.status, stop]);

  return {
    showEval,
    toPreview,
    toNext,
  };
};

/**
 * Utility function to handle swipe gestures
 * @param direction - Swipe direction ('left' or 'right')
 * @param toPreview - Function to navigate to preview
 * @param toNext - Function to navigate to next
 */
export const handleSwipeGesture = (
  direction: 'left' | 'right',
  toPreview: () => void,
  toNext: () => void
): void => {
  try {
    direction === 'left' ? toPreview() : toNext();
  } catch (error) {
    console.error('Error handling swipe gesture:', error);
  }
};

/**
 * Hook to provide swipe handler
 * @param toPreview - Function to navigate to preview
 * @param toNext - Function to navigate to next
 * @returns Memoized swipe handler
 */
export const useSwipeHandler = (toPreview: () => void, toNext: () => void) => {
  return useCallback(
    (direction: 'left' | 'right') => {
      handleSwipeGesture(direction, toPreview, toNext);
    },
    [toPreview, toNext]
  );
};
