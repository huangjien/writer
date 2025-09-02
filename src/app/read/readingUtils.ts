import { useMemo, useCallback } from 'react';
import { ContentUtils } from './types';

/**
 * Utility function to get content from progress position
 * @param content - The full content string
 * @param currentProgress - Progress value between 0 and 1
 * @returns The content paragraph at the given progress
 */
export const getContentFromProgress = (
  content: string,
  currentProgress: number = 0
): string => {
  try {
    // Validate input parameters
    if (
      typeof currentProgress !== 'number' ||
      currentProgress < 0 ||
      currentProgress > 1
    ) {
      console.warn('Invalid progress value:', currentProgress);
      return '';
    }

    if (!content || typeof content !== 'string') {
      console.warn('Invalid content for speech:', content);
      return '';
    }

    // Split content into paragraphs
    const paragraphs = content
      .split(/\n\s*\n/)
      .filter((p) => p.trim().length > 0);

    if (paragraphs.length === 0) {
      console.warn('No paragraphs found in content');
      return '';
    }

    // Calculate which paragraph to start from based on progress
    // Use Math.round to avoid floating point precision issues
    const paragraphIndex = Math.min(
      Math.round(currentProgress * paragraphs.length),
      paragraphs.length - 1
    );

    // Return the current paragraph, or empty string if we've reached the end
    return paragraphIndex < paragraphs.length
      ? paragraphs[paragraphIndex].trim()
      : '';
  } catch (error) {
    console.error('Error getting content from progress:', error);
    return '';
  }
};

/**
 * Utility function to convert content to array format for speech control
 * @param content - The full content string
 * @returns Array of content paragraphs
 */
export const convertContentToArray = (content: string): string[] => {
  if (!content || typeof content !== 'string') return [];
  return content.split(/\n\s*\n/).filter((p) => p.trim().length > 0);
};

/**
 * Hook to provide content utilities
 * @param content - The content string
 * @param progress - Current reading progress
 * @returns Content utilities object
 */
export const useContentUtils = (
  content: string,
  progress: number
): ContentUtils => {
  // Convert content to array format for speech control
  const contentArray = useMemo(() => {
    return convertContentToArray(content);
  }, [content]);

  // Memoized callback for getting content from progress
  const getContentFromProgressCallback = useCallback(
    (currentProgress = progress) => {
      return getContentFromProgress(content, currentProgress);
    },
    [content, progress]
  );

  return {
    contentArray,
    getContentFromProgress: getContentFromProgressCallback,
  };
};

/**
 * Utility function to validate content
 * @param content - Content to validate
 * @returns Whether content is valid
 */
export const isValidContent = (content: any): content is string => {
  return content && typeof content === 'string' && content.trim().length > 0;
};

/**
 * Utility function to calculate paragraph index from progress
 * @param progress - Progress value between 0 and 1
 * @param totalParagraphs - Total number of paragraphs
 * @returns Paragraph index
 */
export const calculateParagraphIndex = (
  progress: number,
  totalParagraphs: number
): number => {
  if (totalParagraphs === 0) return 0;
  return Math.min(Math.round(progress * totalParagraphs), totalParagraphs - 1);
};
