import { useMemo, useCallback } from 'react';
import { Gesture } from 'react-native-gesture-handler';

type SpeechStatus = 'playing' | 'stopped' | 'paused';
type SwipeDirection = 'left' | 'right';

interface GestureHandlersOptions {
  showBar: boolean;
  setShowBar: (show: boolean) => void;
  speechStatus: SpeechStatus;
  onShowEval: () => void;
  onSpeak: () => void;
  onStop: (source: string) => void;
  onSwipe: (direction: SwipeDirection) => void;
}

interface GestureHandlers {
  longPress: any;
  oneTap: any;
  doubleTap: any;
  composed: any;
  handleSwipe: (direction: SwipeDirection) => void;
}

/**
 * Custom hook for managing gesture handlers in the reading interface
 * Provides memoized gesture handlers for long press, single tap, double tap, and swipe actions
 */
export function useGestureHandlers({
  showBar,
  setShowBar,
  speechStatus,
  onShowEval,
  onSpeak,
  onStop,
  onSwipe,
}: GestureHandlersOptions): GestureHandlers {
  // Memoized long press gesture for showing evaluation modal
  const longPress = useMemo(
    () =>
      Gesture.LongPress()
        .onEnd(() => {
          try {
            onShowEval();
          } catch (error) {
            console.error('Error handling long press gesture:', error);
          }
        })
        .runOnJS(true),
    [onShowEval]
  );

  // Memoized single tap gesture for toggling the play bar
  const oneTap = useMemo(
    () =>
      Gesture.Tap()
        .numberOfTaps(1)
        .onEnd(() => {
          try {
            setShowBar(!showBar);
          } catch (error) {
            console.error('Error handling single tap gesture:', error);
          }
        })
        .runOnJS(true),
    [showBar, setShowBar]
  );

  // Memoized double tap gesture for play/stop speech
  const doubleTap = useMemo(
    () =>
      Gesture.Tap()
        .numberOfTaps(2)
        .onEnd(() => {
          try {
            if (speechStatus === 'stopped') {
              onSpeak();
            } else if (speechStatus === 'playing') {
              onStop('doubleTap');
            }
          } catch (error) {
            console.error('Error handling double tap gesture:', error);
          }
        })
        .runOnJS(true),
    [speechStatus, onSpeak, onStop]
  );

  // Memoized composed gesture combining all gestures
  const composed = useMemo(
    () => Gesture.Simultaneous(longPress, doubleTap, oneTap),
    [longPress, doubleTap, oneTap]
  );

  // Memoized swipe handler
  const handleSwipe = useCallback(
    (direction: SwipeDirection) => {
      try {
        onSwipe(direction);
      } catch (error) {
        console.error('Error handling swipe gesture:', error);
      }
    },
    [onSwipe]
  );

  return {
    longPress,
    oneTap,
    doubleTap,
    composed,
    handleSwipe,
  };
}
