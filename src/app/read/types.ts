// Type definitions for the Reading module

/**
 * Speech playback status
 */
export type SpeechStatus = 'playing' | 'stopped' | 'paused';

/**
 * Swipe gesture direction
 */
export type SwipeDirection = 'left' | 'right';

/**
 * Source that triggered speech stop
 */
export type StopSource =
  | 'unknown'
  | 'doubleTap'
  | 'playBarStop'
  | 'manualProgressChange'
  | 'cleanup'
  | 'navigation';

/**
 * Speech control state
 */
export interface SpeechState {
  status: SpeechStatus;
  progress: number;
  currentSentenceIndex: number;
  shouldAutoPlay: boolean;
}

/**
 * UI state for the reading page
 */
export interface UIState {
  modalVisible: boolean;
  showBar: boolean;
  selectedLanguage: string;
  voice: string;
}

/**
 * Navigation handlers interface
 */
export interface NavigationHandlers {
  toPreview: () => void;
  toNext: () => void;
  showEval: () => void;
}

/**
 * Speech control handlers interface
 */
export interface SpeechHandlers {
  handlePlay: () => void;
  handleStop: () => void;
  handleProgressChange: (value: number) => void;
}

/**
 * Content processing utilities interface
 */
export interface ContentUtils {
  getContentFromProgress: (currentProgress?: number) => string;
  contentArray: string[];
}

/**
 * Reading page hook return type
 */
export interface UseReadingPageReturn {
  // State
  speechState: SpeechState;
  uiState: UIState;
  safeAreaTop: number;
  scrollViewRef: React.RefObject<any>;

  // Content
  content: string;
  analysis: string;
  preview: string;
  next: string;
  current: string;
  progress: number;
  fontSize: number;

  // Handlers
  navigationHandlers: NavigationHandlers;
  speechHandlers: SpeechHandlers;

  // Utilities
  contentUtils: ContentUtils;

  // Gesture handlers
  gestureHandlers: {
    longPress: any;
    oneTap: any;
    doubleTap: any;
    composed: any;
    handleSwipe: any;
  };

  // Modal handlers
  handleModalClose: () => void;

  // Speech control functions
  speak: (startProgress?: number) => void;
  stop: (source: StopSource) => void;
  pause: () => void;
  resume: () => void;
  setSpeechProgress: (progress: number) => void;
  setShouldAutoPlay: (shouldAutoPlay: boolean) => void;
  cleanupSpeech: () => void;
}
