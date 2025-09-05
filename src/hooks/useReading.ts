import { useState, useEffect } from 'react';
import { useIsFocused } from '@react-navigation/native';
import { CONTENT_KEY } from '@/components/global';
import { ReadingStorageService } from './readingStorage';
import { useReadingState } from './readingState';
import { useProgressManager } from './progressManager';
import { useChapterNavigation } from './navigationUtils';
import { getContentFromProgress, validateProgress } from './contentUtils';
import { useAsyncStorage } from './useAsyncStorage';

export function useReading() {
  // Initialize storage operations
  const [, storageOps] = useAsyncStorage();

  // Initialize storage service
  const [storageService] = useState(
    () =>
      new ReadingStorageService({
        getItem: storageOps.getItem,
        setItem: storageOps.setItem,
      })
  );

  // Initialize state management
  const readingState = useReadingState();

  // Initialize progress management
  const progressManager = useProgressManager({
    storageService,
    onProgressChange: (progress) => {
      console.log(`Progress saved: ${Math.round(progress * 100)}%`);
    },
  });

  // Initialize navigation
  const navigation = useChapterNavigation({
    storageService,
    onNavigationChange: (info) => {
      readingState.setPreview(info.preview);
      readingState.setNext(info.next);
    },
  });

  let isFocused = true;
  try {
    isFocused = useIsFocused();
  } catch (error) {
    console.log('useIsFocused not available, defaulting to true');
  }

  // Load settings on mount
  useEffect(() => {
    const loadInitialSettings = async () => {
      try {
        const settings = await storageService.loadSettings();
        if (settings?.fontSize) {
          readingState.setFontSize(settings.fontSize);
        }
      } catch (error) {
        console.error('Error loading settings:', error);
      }
    };

    loadInitialSettings();
  }, [storageService, readingState]);

  // Save progress when it changes
  useEffect(() => {
    if (!readingState.isInitialLoad && readingState.current && isFocused) {
      progressManager.saveProgress(readingState.progress);
    }
  }, [
    readingState.progress,
    readingState.current,
    readingState.isInitialLoad,
    isFocused,
    progressManager,
  ]);

  const loadReadingByName = async (name: string) => {
    try {
      const contentKey = name.startsWith(CONTENT_KEY)
        ? name
        : CONTENT_KEY + name;
      readingState.setCurrent(contentKey);

      // Load settings and progress
      const settings = await storageService.loadSettings();
      const savedProgress = await progressManager.loadProgress(contentKey);

      if (settings?.fontSize) {
        readingState.setFontSize(settings.fontSize);
      }

      // Load content
      const contentData = await storageService.loadContent(contentKey);
      if (contentData) {
        readingState.setContent(contentData);
        readingState.setProgress(savedProgress);
      } else {
        readingState.setContent('Content not found');
        readingState.setProgress(0);
      }

      // Load analysis
      const analysisData = await storageService.loadAnalysis(contentKey);
      readingState.setAnalysis(
        analysisData || 'No analysis for this chapter yet'
      );

      // Load navigation info
      await navigation.getNavigationInfo(contentKey);

      readingState.setIsInitialLoad(false);
    } catch (error) {
      console.error('Error in loadReadingByName:', error);
      readingState.setContent('Error loading content');
      readingState.setAnalysis('Error loading analysis');
      readingState.setIsInitialLoad(false);
    }
  };

  const setProgressWithValidation = (newProgress: number) => {
    if (isNaN(newProgress) || newProgress < 0 || newProgress > 1) {
      console.warn(
        'setProgressWithValidation: progress must be a valid number between 0 and 1'
      );
      return;
    }
    readingState.setProgress(newProgress);
    progressManager.saveProgress(newProgress);
  };

  return {
    // State values
    content: readingState.content,
    analysis: readingState.analysis,
    preview: readingState.preview,
    next: readingState.next,
    current: readingState.current,
    progress: readingState.progress,
    fontSize: readingState.fontSize,
    isInitialLoad: readingState.isInitialLoad,

    // State setters
    setContent: readingState.setContent,
    setAnalysis: readingState.setAnalysis,
    setPreview: readingState.setPreview,
    setNext: readingState.setNext,
    setCurrent: readingState.setCurrent,
    setProgress: setProgressWithValidation,
    setFontSize: readingState.setFontSize,
    setIsInitialLoad: readingState.setIsInitialLoad,

    // Functions
    loadReadingByName,
    getContentFromProgress: (content: string, progress: number) =>
      getContentFromProgress(content, progress),
  };
}
