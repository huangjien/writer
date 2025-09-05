import { useState, useCallback } from 'react';
import { validateChapterKey, normalizeChapterKey } from './contentUtils';

export interface ReadingState {
  content: string;
  analysis: string | undefined;
  preview: string | undefined;
  next: string | undefined;
  current: string | number | undefined;
  progress: number;
  fontSize: number;
  isInitialLoad: boolean;
}

export interface ReadingStateActions {
  setContent: (content: string) => void;
  setAnalysis: (analysis: string | undefined) => void;
  setPreview: (preview: string | undefined) => void;
  setNext: (next: string | undefined) => void;
  setCurrent: (current: string | number | undefined) => void;
  setProgress: (progress: number) => void;
  setFontSize: (fontSize: number) => void;
  setIsInitialLoad: (isInitialLoad: boolean) => void;
  resetState: () => void;
}

export interface ReadingStateManager
  extends ReadingState,
    ReadingStateActions {}

const DEFAULT_STATE: ReadingState = {
  content: 'Please select a file to read',
  analysis: 'No analysis for this chapter yet',
  preview: undefined,
  next: undefined,
  current: undefined,
  progress: 0,
  fontSize: 16,
  isInitialLoad: true,
};

/**
 * Validates font size value
 */
function validateFontSize(fontSize: number): boolean {
  return (
    typeof fontSize === 'number' &&
    !isNaN(fontSize) &&
    fontSize >= 8 &&
    fontSize <= 72
  );
}

/**
 * Validates content string
 */
function validateContent(content: string): boolean {
  return typeof content === 'string';
}

/**
 * Hook for managing reading state with validation
 */
export function useReadingState(
  initialState?: Partial<ReadingState>
): ReadingStateManager {
  const [state, setState] = useState<ReadingState>({
    ...DEFAULT_STATE,
    ...initialState,
  });

  const setContent = useCallback((content: string) => {
    if (!validateContent(content)) {
      console.warn('setContent: content must be a string');
      return;
    }
    setState((prev) => ({ ...prev, content }));
  }, []);

  const setAnalysis = useCallback((analysis: string | undefined) => {
    if (analysis !== undefined && typeof analysis !== 'string') {
      console.warn('setAnalysis: analysis must be a string or undefined');
      return;
    }
    setState((prev) => ({ ...prev, analysis }));
  }, []);

  const setPreview = useCallback((preview: string | undefined) => {
    if (preview !== undefined && typeof preview !== 'string') {
      console.warn('setPreview: preview must be a string or undefined');
      return;
    }
    setState((prev) => ({ ...prev, preview }));
  }, []);

  const setNext = useCallback((next: string | undefined) => {
    if (next !== undefined && typeof next !== 'string') {
      console.warn('setNext: next must be a string or undefined');
      return;
    }
    setState((prev) => ({ ...prev, next }));
  }, []);

  const setCurrent = useCallback((current: string | number | undefined) => {
    if (current !== undefined && !validateChapterKey(current)) {
      console.warn('setCurrent: current must be a valid chapter key');
      return;
    }
    setState((prev) => ({ ...prev, current }));
  }, []);

  const setProgress = useCallback((progress: number) => {
    if (
      typeof progress !== 'number' ||
      isNaN(progress) ||
      progress < 0 ||
      progress > 1
    ) {
      console.warn('setProgress: progress must be a number between 0 and 1');
      return;
    }
    setState((prev) => ({ ...prev, progress }));
  }, []);

  const setFontSize = useCallback((fontSize: number) => {
    if (!validateFontSize(fontSize)) {
      console.warn('setFontSize: fontSize must be a number between 8 and 72');
      return;
    }
    setState((prev) => ({ ...prev, fontSize }));
  }, []);

  const setIsInitialLoad = useCallback((isInitialLoad: boolean) => {
    if (typeof isInitialLoad !== 'boolean') {
      console.warn('setIsInitialLoad: isInitialLoad must be a boolean');
      return;
    }
    setState((prev) => ({ ...prev, isInitialLoad }));
  }, []);

  const resetState = useCallback(() => {
    setState(DEFAULT_STATE);
  }, []);

  return {
    ...state,
    setContent,
    setAnalysis,
    setPreview,
    setNext,
    setCurrent,
    setProgress,
    setFontSize,
    setIsInitialLoad,
    resetState,
  };
}

/**
 * Utility functions for state validation
 */
export const ReadingStateUtils = {
  validateFontSize,
  validateContent,
  validateChapterKey,
  normalizeChapterKey,
  DEFAULT_STATE,
} as const;

export default useReadingState;
