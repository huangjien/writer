import { CONTENT_KEY } from '@/components/global';
import { ReadingStorageService } from './readingStorage';
import { normalizeChapterKey } from './contentUtils';

export interface NavigationInfo {
  preview: string | undefined;
  next: string | undefined;
  currentIndex: number;
  totalChapters: number;
}

export interface ChapterNavigationOptions {
  storageService: ReadingStorageService;
  onNavigationChange?: (info: NavigationInfo) => void;
}

/**
 * Navigation utilities for chapter management
 */
export class ChapterNavigationManager {
  constructor(
    private storageService: ReadingStorageService,
    private onNavigationChange?: (info: NavigationInfo) => void
  ) {}

  /**
   * Get navigation information for a specific chapter
   */
  async getNavigationInfo(
    currentChapter: string | number | undefined
  ): Promise<NavigationInfo> {
    const defaultInfo: NavigationInfo = {
      preview: undefined,
      next: undefined,
      currentIndex: -1,
      totalChapters: 0,
    };

    try {
      const normalizedChapter = normalizeChapterKey(currentChapter);
      if (!normalizedChapter) {
        return defaultInfo;
      }

      const navigationInfo =
        await this.storageService.getNavigationInfo(normalizedChapter);
      const contentList = await this.storageService.loadContentList();

      if (!contentList) {
        return {
          ...defaultInfo,
          preview: navigationInfo.preview,
          next: navigationInfo.next,
        };
      }

      const chapterName = normalizedChapter.replace(CONTENT_KEY, '');
      const currentIndex = contentList.findIndex(
        (item) => item.name === chapterName
      );

      const result: NavigationInfo = {
        preview: navigationInfo.preview,
        next: navigationInfo.next,
        currentIndex,
        totalChapters: contentList.length,
      };

      this.onNavigationChange?.(result);
      return result;
    } catch (error) {
      console.error('Error getting navigation info:', error);
      return defaultInfo;
    }
  }

  /**
   * Navigate to the previous chapter
   */
  async navigateToPrevious(
    currentChapter: string | number | undefined
  ): Promise<string | null> {
    try {
      const navigationInfo = await this.getNavigationInfo(currentChapter);
      return navigationInfo.preview || null;
    } catch (error) {
      console.error('Error navigating to previous chapter:', error);
      return null;
    }
  }

  /**
   * Navigate to the next chapter
   */
  async navigateToNext(
    currentChapter: string | number | undefined
  ): Promise<string | null> {
    try {
      const navigationInfo = await this.getNavigationInfo(currentChapter);
      return navigationInfo.next || null;
    } catch (error) {
      console.error('Error navigating to next chapter:', error);
      return null;
    }
  }

  /**
   * Get chapter at specific index
   */
  async getChapterAtIndex(index: number): Promise<string | null> {
    try {
      const contentList = await this.storageService.loadContentList();
      if (!contentList || index < 0 || index >= contentList.length) {
        return null;
      }

      return CONTENT_KEY + contentList[index].name;
    } catch (error) {
      console.error('Error getting chapter at index:', error);
      return null;
    }
  }

  /**
   * Get all available chapters
   */
  async getAllChapters(): Promise<string[]> {
    try {
      const contentList = await this.storageService.loadContentList();
      if (!contentList) {
        return [];
      }

      return contentList.map((item) => CONTENT_KEY + item.name);
    } catch (error) {
      console.error('Error getting all chapters:', error);
      return [];
    }
  }

  /**
   * Check if a chapter exists
   */
  async chapterExists(chapterKey: string): Promise<boolean> {
    try {
      const allChapters = await this.getAllChapters();
      return allChapters.includes(chapterKey);
    } catch (error) {
      console.error('Error checking if chapter exists:', error);
      return false;
    }
  }

  /**
   * Get reading progress across all chapters
   */
  async getOverallProgress(
    currentChapter: string | number | undefined,
    currentProgress: number
  ): Promise<{
    chaptersCompleted: number;
    totalChapters: number;
    overallProgress: number;
  }> {
    try {
      const navigationInfo = await this.getNavigationInfo(currentChapter);
      const chaptersCompleted = navigationInfo.currentIndex;
      const totalChapters = navigationInfo.totalChapters;

      if (totalChapters === 0) {
        return { chaptersCompleted: 0, totalChapters: 0, overallProgress: 0 };
      }

      // Calculate overall progress: completed chapters + current chapter progress
      const overallProgress =
        (chaptersCompleted + currentProgress) / totalChapters;

      return {
        chaptersCompleted,
        totalChapters,
        overallProgress: Math.min(1, Math.max(0, overallProgress)),
      };
    } catch (error) {
      console.error('Error calculating overall progress:', error);
      return { chaptersCompleted: 0, totalChapters: 0, overallProgress: 0 };
    }
  }
}

/**
 * Hook for chapter navigation management
 */
export function useChapterNavigation(options: ChapterNavigationOptions) {
  const { storageService, onNavigationChange } = options;
  const navigationManager = new ChapterNavigationManager(
    storageService,
    onNavigationChange
  );

  return {
    getNavigationInfo: (currentChapter: string | number | undefined) =>
      navigationManager.getNavigationInfo(currentChapter),
    navigateToPrevious: (currentChapter: string | number | undefined) =>
      navigationManager.navigateToPrevious(currentChapter),
    navigateToNext: (currentChapter: string | number | undefined) =>
      navigationManager.navigateToNext(currentChapter),
    getChapterAtIndex: (index: number) =>
      navigationManager.getChapterAtIndex(index),
    getAllChapters: () => navigationManager.getAllChapters(),
    chapterExists: (chapterKey: string) =>
      navigationManager.chapterExists(chapterKey),
    getOverallProgress: (
      currentChapter: string | number | undefined,
      currentProgress: number
    ) => navigationManager.getOverallProgress(currentChapter, currentProgress),
  };
}

/**
 * Utility functions for navigation
 */
export const NavigationUtils = {
  normalizeChapterKey,
  validateChapterKey: (key: string | number | undefined) =>
    normalizeChapterKey(key) !== null,
  extractChapterName: (chapterKey: string) =>
    chapterKey.replace(CONTENT_KEY, ''),
  formatChapterKey: (chapterName: string) => CONTENT_KEY + chapterName,
} as const;

export default useChapterNavigation;
