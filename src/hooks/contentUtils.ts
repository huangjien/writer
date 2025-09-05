/**
 * Utility functions for content processing and validation
 */

/**
 * Validates if a progress value is within acceptable bounds
 */
export function validateProgress(progress: number): boolean {
  return (
    typeof progress === 'number' &&
    !isNaN(progress) &&
    progress >= 0 &&
    progress <= 1
  );
}

/**
 * Validates if content is a non-empty string
 */
export function validateContent(content: string): boolean {
  return content && typeof content === 'string';
}

/**
 * Gets content from a specific progress point
 * @param content - The full content string
 * @param progress - Progress value between 0 and 1
 * @returns The content substring from the progress point
 */
export function getContentFromProgress(
  content: string,
  progress: number
): string {
  try {
    // Input validation
    if (!validateContent(content)) {
      console.warn(
        'getContentFromProgress: content must be a non-empty string'
      );
      return '';
    }

    if (!validateProgress(progress)) {
      console.warn(
        'getContentFromProgress: progress must be a number between 0 and 1'
      );
      return content; // Return full content if progress is invalid
    }

    const contentLength: number = Math.round(content.length * progress);

    // Ensure content_length is within bounds
    if (contentLength < 0 || contentLength > content.length) {
      console.warn(
        'getContentFromProgress: calculated content_length is out of bounds'
      );
      return content;
    }

    return content.substring(contentLength);
  } catch (error) {
    console.error('Error in getContentFromProgress:', error);
    return content || '';
  }
}

/**
 * Calculates progress based on current position in content
 * @param content - The full content string
 * @param currentPosition - Current character position
 * @returns Progress value between 0 and 1
 */
export function calculateProgress(
  content: string,
  currentPosition: number
): number {
  try {
    if (!validateContent(content)) {
      console.warn('calculateProgress: content must be a non-empty string');
      return 0;
    }

    if (typeof currentPosition !== 'number' || isNaN(currentPosition)) {
      console.warn('calculateProgress: currentPosition must be a valid number');
      return 0;
    }

    if (currentPosition <= 0) return 0;
    if (currentPosition >= content.length) return 1;

    return currentPosition / content.length;
  } catch (error) {
    console.error('Error in calculateProgress:', error);
    return 0;
  }
}

/**
 * Validates and normalizes progress value
 * @param progress - Progress value to validate
 * @returns Normalized progress value between 0 and 1
 */
export function normalizeProgress(progress: number): number {
  try {
    if (typeof progress !== 'number' || isNaN(progress)) {
      console.warn('normalizeProgress: progress must be a valid number');
      return 0;
    }

    if (progress < 0) return 0;
    if (progress > 1) return 1;

    return progress;
  } catch (error) {
    console.error('Error in normalizeProgress:', error);
    return 0;
  }
}

/**
 * Validates chapter key format
 * @param chapterKey - Chapter key to validate
 * @returns True if valid, false otherwise
 */
export function validateChapterKey(
  chapterKey: string | number | undefined
): boolean {
  if (!chapterKey) return false;

  if (typeof chapterKey !== 'string' && typeof chapterKey !== 'number') {
    return false;
  }

  const keyString = chapterKey.toString().trim();
  return keyString.length > 0;
}

/**
 * Normalizes chapter key to string format
 * @param chapterKey - Chapter key to normalize
 * @returns Normalized chapter key or null if invalid
 */
export function normalizeChapterKey(
  chapterKey: string | number | undefined
): string | null {
  if (!validateChapterKey(chapterKey)) {
    return null;
  }

  return chapterKey!.toString().trim();
}

/**
 * Content processing utilities object
 */
export const ContentUtils = {
  validateProgress,
  validateContent,
  getContentFromProgress,
  calculateProgress,
  normalizeProgress,
  validateChapterKey,
  normalizeChapterKey,
} as const;

export default ContentUtils;
