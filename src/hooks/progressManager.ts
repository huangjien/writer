import { useCallback, useEffect, useRef } from 'react';
import { ReadingStorageService } from './readingStorage';
import { validateProgress, normalizeProgress } from './contentUtils';

export interface ProgressState {
  progress: number;
  isInitialLoad: boolean;
}

export interface ProgressManagerOptions {
  storageService: ReadingStorageService;
  onProgressChange?: (progress: number) => void;
  debounceMs?: number;
}

/**
 * Progress manager for handling reading progress persistence
 */
export class ProgressManager {
  private debounceTimer: ReturnType<typeof setTimeout> | null = null;
  private readonly debounceMs: number;

  constructor(
    private storageService: ReadingStorageService,
    private onProgressChange?: (progress: number) => void,
    debounceMs: number = 500
  ) {
    this.debounceMs = debounceMs;
  }

  /**
   * Load progress for a specific chapter
   */
  async loadProgress(chapterKey: string): Promise<number> {
    try {
      const settings = await this.storageService.loadSettings();
      if (!settings) return 0;

      // Check if this is the same chapter as the last one
      const isContinuingFromLastChapter = settings.current === chapterKey;

      if (isContinuingFromLastChapter && settings.progress !== undefined) {
        return normalizeProgress(settings.progress);
      }

      return 0; // New chapter, start from beginning
    } catch (error) {
      console.error('Error loading progress:', error);
      return 0;
    }
  }

  /**
   * Save progress with debouncing to avoid excessive storage writes
   */
  saveProgress(progress: number, immediate: boolean = false): void {
    if (!validateProgress(progress)) {
      console.warn('saveProgress: invalid progress value:', progress);
      return;
    }

    const normalizedProgress = normalizeProgress(progress);

    if (immediate) {
      this.performSave(normalizedProgress);
    } else {
      this.debouncedSave(normalizedProgress);
    }
  }

  /**
   * Debounced save to reduce storage operations
   */
  private debouncedSave(progress: number): void {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    this.debounceTimer = setTimeout(() => {
      this.performSave(progress);
    }, this.debounceMs);
  }

  /**
   * Perform the actual save operation
   */
  private async performSave(progress: number): Promise<void> {
    try {
      await this.storageService.updateSettings({ progress });
      this.onProgressChange?.(progress);
    } catch (error) {
      console.error('Error saving progress:', error);
    }
  }

  /**
   * Update current chapter and reset progress if needed
   */
  async updateCurrentChapter(chapterKey: string): Promise<number> {
    try {
      const settings = await this.storageService.loadSettings();
      const isSameChapter = settings?.current === chapterKey;

      if (!isSameChapter) {
        // New chapter, reset progress
        await this.storageService.updateSettings({
          current: chapterKey,
          progress: 0,
        });
        return 0;
      } else {
        // Same chapter, just update current
        await this.storageService.updateSettings({ current: chapterKey });
        return settings?.progress || 0;
      }
    } catch (error) {
      console.error('Error updating current chapter:', error);
      return 0;
    }
  }

  /**
   * Clean up resources
   */
  cleanup(): void {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
  }
}

/**
 * Hook for managing reading progress
 */
export function useProgressManager(options: ProgressManagerOptions) {
  const { storageService, onProgressChange, debounceMs = 500 } = options;
  const managerRef = useRef<ProgressManager | null>(null);

  // Initialize manager
  if (!managerRef.current) {
    managerRef.current = new ProgressManager(
      storageService,
      onProgressChange,
      debounceMs
    );
  }

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      managerRef.current?.cleanup();
    };
  }, []);

  const loadProgress = useCallback((chapterKey: string) => {
    return managerRef.current?.loadProgress(chapterKey) || Promise.resolve(0);
  }, []);

  const saveProgress = useCallback((progress: number, immediate?: boolean) => {
    managerRef.current?.saveProgress(progress, immediate);
  }, []);

  const updateCurrentChapter = useCallback((chapterKey: string) => {
    return (
      managerRef.current?.updateCurrentChapter(chapterKey) || Promise.resolve(0)
    );
  }, []);

  const setProgressWithValidation = useCallback(
    (newProgress: number) => {
      if (!validateProgress(newProgress)) {
        console.warn('setProgress: newProgress must be between 0 and 1');
        return;
      }

      const normalizedProgress = normalizeProgress(newProgress);
      saveProgress(normalizedProgress);
      onProgressChange?.(normalizedProgress);
    },
    [saveProgress, onProgressChange]
  );

  return {
    loadProgress,
    saveProgress,
    updateCurrentChapter,
    setProgress: setProgressWithValidation,
  };
}
