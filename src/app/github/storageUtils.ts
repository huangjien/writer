import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  SETTINGS_KEY,
  handleError,
  showErrorToast,
  fileNameComparator,
} from '@/components/global';
import {
  GitHubSettings,
  ContentItem,
  StorageValidationResult,
  StorageOperationParams,
} from './types';

/**
 * Check if an element with a specific name exists in an array
 */
export function elementWithNameExists(
  array: any[],
  nameToFind: string
): boolean {
  if (!array || !Array.isArray(array)) {
    return false;
  }
  return array.some((element) => element.name === nameToFind);
}

/**
 * Load settings from storage
 */
export const loadSettingsFromStorage = async (
  getItem: (key: string) => Promise<string | null>,
  setSettings: (settings: GitHubSettings) => void,
  setIsLoadingContent: (loading: boolean) => void
): Promise<GitHubSettings | null> => {
  try {
    const res = await getItem(SETTINGS_KEY);
    if (!res) {
      console.log('no data returned for settings');
      setIsLoadingContent(false);
      return null;
    }

    const data = JSON.parse(res);
    setSettings(data);
    return data;
  } catch (err) {
    console.error('Error loading settings from storage:', err);
    handleError(err);
    setIsLoadingContent(false);
    return null;
  }
};

/**
 * Load existing content from storage
 */
export const loadExistingContentFromStorage = async (
  getItem: (key: string) => Promise<string | null>,
  setContent: (content: ContentItem[]) => void
): Promise<void> => {
  try {
    const existingContent = await getItem(CONTENT_KEY);
    if (existingContent) {
      try {
        const parsedContent = JSON.parse(existingContent);
        if (Array.isArray(parsedContent) && parsedContent.length > 0) {
          setContent(parsedContent);
        }
      } catch (parseError) {
        console.error('Error parsing existing content:', parseError);
      }
    }
  } catch (error) {
    console.error('Error loading existing content:', error);
  }
};

/**
 * Load existing analysis from storage
 */
export const loadExistingAnalysisFromStorage = async (
  getItem: (key: string) => Promise<string | null>,
  setAnalysis: (analysis: ContentItem[]) => void
): Promise<void> => {
  try {
    const existingAnalysis = await getItem(ANALYSIS_KEY);
    if (existingAnalysis) {
      try {
        const parsedAnalysis = JSON.parse(existingAnalysis);
        if (Array.isArray(parsedAnalysis)) {
          setAnalysis(parsedAnalysis);
        }
      } catch (parseError) {
        console.error('Error parsing existing analysis:', parseError);
      }
    }
  } catch (error) {
    console.error('Error loading existing analysis:', error);
  }
};

/**
 * Validate items for storage
 */
export const validateItemsForStorage = (
  items: any
): StorageValidationResult => {
  if (!items || items.length <= 0) {
    console.log('no items to save');
    return { isValid: false, error: null };
  }

  if (!Array.isArray(items)) {
    let errorMessage = 'Unexpected data format received from GitHub API.';

    if (items && typeof items === 'object' && items.message) {
      if (items.status === '401') {
        errorMessage =
          'Authentication failed. Please check your GitHub token in settings.';
      } else {
        errorMessage = `GitHub API error: ${items.message}`;
      }
    }

    return { isValid: false, error: errorMessage };
  }

  return { isValid: true, error: null };
};

/**
 * Update item metadata
 */
export const updateItemMetadata = (
  item: ContentItem,
  contentSize: number,
  mark: string,
  analysis: ContentItem[]
): void => {
  if (mark === CONTENT_KEY && item.name.endsWith('.md')) {
    item.size = contentSize;
    item.analysed = elementWithNameExists(analysis, item.name);
  }
};

/**
 * Finalize storage update
 */
export const finalizeStorageUpdate = (
  items: ContentItem[],
  mark: string,
  index: number,
  setItem: (key: string, value: string) => Promise<void>,
  setContent: (content: ContentItem[]) => void
): void => {
  if (index >= items.length - 1) {
    const filteredItems = items.filter((item) => item.name.endsWith('.md'));
    setItem(mark, JSON.stringify(filteredItems));
    setContent(filteredItems);
  }
};

/**
 * Clean up orphan items from storage
 */
export const cleanupOrphanItems = async (
  currentItems: ContentItem[],
  keyPrefix: string,
  storage: Record<string, any>,
  removeItem: (key: string) => Promise<void>
): Promise<void> => {
  try {
    // Get all storage keys
    const allKeys = Object.keys(storage);
    const prefixKeys = allKeys.filter((key) => key.startsWith(keyPrefix));
    const currentFileKeys = currentItems.map((item) => keyPrefix + item.name);
    const orphanKeys = prefixKeys.filter(
      (key) =>
        key !== keyPrefix && // Keep the main list key
        !currentFileKeys.includes(key)
    );

    // Remove orphan items
    if (orphanKeys.length > 0) {
      await Promise.all(orphanKeys.map((key) => removeItem(key)));
      console.log(
        `Cleaned up ${orphanKeys.length} orphan items for ${keyPrefix}`
      );
    }
  } catch (error) {
    console.error('Error cleaning orphan items:', error);
  }
};

/**
 * Save items to storage with validation and processing
 */
export const saveToStorage = async (
  mark: string,
  items: any,
  storageOps: StorageOperationParams,
  setContent: (content: ContentItem[]) => void,
  analysis: ContentItem[],
  storage: Record<string, any>,
  fetchContentFromGitHub: (item: ContentItem) => Promise<any>
): Promise<void> => {
  const { getItem, setItem, removeItem } = storageOps;

  // Load existing content to show immediately
  if (mark === CONTENT_KEY) {
    try {
      const res = await getItem(mark);
      if (res) {
        try {
          setContent(JSON.parse(res));
        } catch (parseError) {
          console.error(
            'Error parsing content for immediate display:',
            parseError
          );
        }
      }
    } catch (error) {
      console.error('Error loading content for immediate display:', error);
    }
  }

  // Validate items
  const validation = validateItemsForStorage(items);
  if (!validation.isValid) {
    if (validation.error) {
      showErrorToast(validation.error);
    }
    return;
  }

  // Sort items and process each one
  items.sort(fileNameComparator);

  for (let index = 0; index < items.length; index++) {
    const item = items[index];
    await processStorageItem(
      item,
      index,
      mark,
      items,
      storageOps,
      analysis,
      fetchContentFromGitHub,
      setContent
    );
  }

  // Save the items list
  await setItem(mark, JSON.stringify(items));
};

/**
 * Process individual storage item
 */
export const processStorageItem = async (
  item: ContentItem,
  index: number,
  mark: string,
  items: ContentItem[],
  storageOps: StorageOperationParams,
  analysis: ContentItem[],
  fetchContentFromGitHub: (item: ContentItem) => Promise<any>,
  setContent: (content: ContentItem[]) => void
): Promise<void> => {
  const { getItem, setItem } = storageOps;

  try {
    const existingData = await getItem(mark + item.name);
    let data = null;

    if (existingData) {
      try {
        data = JSON.parse(existingData);
      } catch (parseError) {
        console.error(
          'Error parsing existing data for item:',
          item.name,
          parseError
        );
        data = null;
      }
    }

    if (!data || data.sha !== item.sha) {
      // Need to update - fetch new content
      const content = await fetchContentFromGitHub(item);
      updateItemMetadata(item, content.size, mark, analysis);
      await setItem(mark + item.name, JSON.stringify(content));
    } else {
      // Content is up to date - just update metadata
      updateItemMetadata(item, data.size, mark, analysis);
    }

    finalizeStorageUpdate(items, mark, index, setItem, setContent);
  } catch (err) {
    handleError(err);
  }
};
