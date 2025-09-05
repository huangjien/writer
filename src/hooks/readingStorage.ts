import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  SETTINGS_KEY,
  showErrorToast,
  showInfoToast,
} from '@/components/global';

export interface ReadingSettings {
  fontSize?: number;
  current?: string;
  progress?: number;
  [key: string]: any;
}

export interface ContentData {
  content: string;
}

export interface AnalysisData {
  content: string;
}

export interface ChapterInfo {
  name: string;
  [key: string]: any;
}

export interface StorageOperations {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
}

/**
 * Storage service for reading-related data operations
 */
export class ReadingStorageService {
  constructor(private storage: StorageOperations) {}

  /**
   * Load and parse settings from storage
   */
  async loadSettings(): Promise<ReadingSettings | null> {
    try {
      const res = await this.storage.getItem(SETTINGS_KEY);
      if (!res) return null;

      return JSON.parse(res);
    } catch (error) {
      console.error('Error loading settings:', error);
      return null;
    }
  }

  /**
   * Save settings to storage
   */
  async saveSettings(settings: ReadingSettings): Promise<void> {
    try {
      await this.storage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    } catch (error) {
      console.error('Error saving settings:', error);
      throw error;
    }
  }

  /**
   * Update specific setting fields
   */
  async updateSettings(updates: Partial<ReadingSettings>): Promise<void> {
    try {
      const currentSettings = (await this.loadSettings()) || {};
      const updatedSettings = { ...currentSettings, ...updates };
      await this.saveSettings(updatedSettings);
    } catch (error) {
      console.error('Error updating settings:', error);
      throw error;
    }
  }

  /**
   * Load content for a specific chapter
   */
  async loadContent(chapterKey: string): Promise<string | null> {
    try {
      if (!chapterKey || typeof chapterKey !== 'string') {
        console.warn('loadContent: chapterKey must be a non-empty string');
        return null;
      }

      const data = await this.storage.getItem(chapterKey.trim());
      if (!data) {
        showErrorToast(`No content for this chapter yet: ${chapterKey}!`);
        return null;
      }

      const parsedData: ContentData = JSON.parse(data);
      return parsedData.content || '';
    } catch (error) {
      console.error('Error loading content:', error);
      showErrorToast(`Error loading content for chapter: ${chapterKey}`);
      return null;
    }
  }

  /**
   * Load analysis for a specific chapter
   */
  async loadAnalysis(chapterKey: string): Promise<string | null> {
    try {
      if (!chapterKey || typeof chapterKey !== 'string') {
        console.warn('loadAnalysis: chapterKey must be a non-empty string');
        return null;
      }

      const analysisKey = chapterKey.replace(CONTENT_KEY, ANALYSIS_KEY);
      const data = await this.storage.getItem(analysisKey);

      if (!data) {
        return null;
      }

      const parsedData: AnalysisData = JSON.parse(data);
      return parsedData.content;
    } catch (error) {
      console.error('Error loading analysis:', error);
      return null;
    }
  }

  /**
   * Load the content list to determine chapter navigation
   */
  async loadContentList(): Promise<ChapterInfo[] | null> {
    try {
      const data = await this.storage.getItem(CONTENT_KEY);
      if (!data) return null;

      return JSON.parse(data);
    } catch (error) {
      console.error('Error loading content list:', error);
      return null;
    }
  }

  /**
   * Get navigation info (previous and next chapters) for a given chapter
   */
  async getNavigationInfo(currentChapter: string): Promise<{
    preview: string | undefined;
    next: string | undefined;
  }> {
    try {
      const contentList = await this.loadContentList();
      if (!contentList) {
        return { preview: undefined, next: undefined };
      }

      const chapterName = currentChapter.replace(CONTENT_KEY, '');
      const index = contentList.findIndex((item) => item.name === chapterName);

      if (index === -1) {
        return { preview: undefined, next: undefined };
      }

      const prevChapter = index === 0 ? undefined : contentList[index - 1].name;
      const nextChapter =
        index === contentList.length - 1
          ? undefined
          : contentList[index + 1].name;

      return {
        preview: prevChapter ? CONTENT_KEY + prevChapter : undefined,
        next: nextChapter ? CONTENT_KEY + nextChapter : undefined,
      };
    } catch (error) {
      console.error('Error getting navigation info:', error);
      return { preview: undefined, next: undefined };
    }
  }

  /**
   * Initialize settings with default values if they don't exist
   */
  async initializeSettings(): Promise<ReadingSettings> {
    try {
      const settings = await this.loadSettings();
      if (!settings) {
        showErrorToast('No settings found, please set up settings first');
        console.error('No settings found, please set up settings first');
        return { fontSize: 16 };
      }

      // Ensure default values
      const initializedSettings = {
        fontSize: 16,
        ...settings,
      };

      return initializedSettings;
    } catch (error) {
      console.error('Error initializing settings:', error);
      return { fontSize: 16 };
    }
  }
}

/**
 * Factory function to create a ReadingStorageService instance
 */
export function createReadingStorageService(
  storage: StorageOperations
): ReadingStorageService {
  return new ReadingStorageService(storage);
}

/**
 * Hook factory for creating storage operations with async storage
 */
export function useReadingStorage(storage: StorageOperations) {
  const storageService = createReadingStorageService(storage);

  return {
    loadSettings: () => storageService.loadSettings(),
    saveSettings: (settings: ReadingSettings) =>
      storageService.saveSettings(settings),
    updateSettings: (updates: Partial<ReadingSettings>) =>
      storageService.updateSettings(updates),
    loadContent: (chapterKey: string) => storageService.loadContent(chapterKey),
    loadAnalysis: (chapterKey: string) =>
      storageService.loadAnalysis(chapterKey),
    getNavigationInfo: (currentChapter: string) =>
      storageService.getNavigationInfo(currentChapter),
    initializeSettings: () => storageService.initializeSettings(),
  };
}
