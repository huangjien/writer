import { ContentItem } from './types';

/**
 * Sort content items by name for consistent ordering
 */
export const sortContentItems = (items: ContentItem[]): ContentItem[] => {
  return items.sort((a, b) => a.name.localeCompare(b.name));
};

/**
 * Filter content items to only include markdown files
 */
export const filterMarkdownFiles = (items: ContentItem[]): ContentItem[] => {
  return items.filter((item) => item.name.endsWith('.md'));
};

/**
 * Check if content item needs update based on SHA comparison
 */
export const needsContentUpdate = (
  existingData: any,
  newItem: ContentItem
): boolean => {
  return !existingData || existingData.sha !== newItem.sha;
};

/**
 * Extract file name without extension
 */
export const getFileNameWithoutExtension = (fileName: string): string => {
  return fileName.replace('.md', '');
};

/**
 * Format file size for display
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 bytes';

  const k = 1024;
  const sizes = ['bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

/**
 * Validate content item structure
 */
export const isValidContentItem = (item: any): item is ContentItem => {
  return (
    item &&
    typeof item.name === 'string' &&
    typeof item.path === 'string' &&
    typeof item.sha === 'string' &&
    typeof item.size === 'number' &&
    typeof item.url === 'string' &&
    typeof item.html_url === 'string' &&
    typeof item.git_url === 'string' &&
    typeof item.download_url === 'string' &&
    (item.type === 'file' || item.type === 'dir')
  );
};

/**
 * Create content item with analysis status
 */
export const createContentItemWithAnalysis = (
  item: ContentItem,
  analysisItems: ContentItem[]
): ContentItem => {
  return {
    ...item,
    analysed: analysisItems.some(
      (analysisItem) => analysisItem.name === item.name
    ),
  };
};

/**
 * Group content items by analysis status
 */
export const groupContentByAnalysisStatus = (
  items: ContentItem[]
): {
  analysed: ContentItem[];
  unanalysed: ContentItem[];
} => {
  return items.reduce(
    (acc, item) => {
      if (item.analysed) {
        acc.analysed.push(item);
      } else {
        acc.unanalysed.push(item);
      }
      return acc;
    },
    { analysed: [] as ContentItem[], unanalysed: [] as ContentItem[] }
  );
};

/**
 * Calculate total size of content items
 */
export const calculateTotalSize = (items: ContentItem[]): number => {
  return items.reduce((total, item) => total + item.size, 0);
};

/**
 * Find content item by name
 */
export const findContentItemByName = (
  items: ContentItem[],
  name: string
): ContentItem | undefined => {
  return items.find((item) => item.name === name);
};

/**
 * Get unique file extensions from content items
 */
export const getUniqueExtensions = (items: ContentItem[]): string[] => {
  const extensions = items
    .map((item) => {
      const lastDot = item.name.lastIndexOf('.');
      return lastDot > 0 ? item.name.substring(lastDot) : '';
    })
    .filter((ext) => ext.length > 0);

  return Array.from(new Set(extensions)).sort();
};
