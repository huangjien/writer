/**
 * Sentence processing utilities for text splitting and progress tracking
 */

import { SentenceProcessingResult, ProgressUpdate } from './types';

/**
 * Split text into sentences for speech processing
 * Handles various sentence endings and edge cases
 */
export const splitIntoSentences = (text: string): string[] => {
  if (!text || typeof text !== 'string') {
    return [];
  }

  // Clean up the text first
  const cleanText = text
    .trim()
    .replace(/\s+/g, ' ') // Replace multiple spaces with single space
    .replace(/\n+/g, ' '); // Replace newlines with spaces

  if (!cleanText) {
    return [];
  }

  // Split by sentence endings, keeping the delimiter
  const sentences = cleanText
    .split(/([.!?]+\s*)/)
    .reduce((acc: string[], part: string, index: number) => {
      if (index % 2 === 0) {
        // This is the sentence content
        if (part.trim()) {
          acc.push(part.trim());
        }
      } else {
        // This is the delimiter, append to the last sentence
        if (acc.length > 0) {
          acc[acc.length - 1] += part;
        }
      }
      return acc;
    }, [])
    .filter((sentence) => sentence.trim().length > 0)
    .map((sentence) => sentence.trim());

  // If no sentences were found (no sentence endings), return the whole text as one sentence
  if (sentences.length === 0 && cleanText.length > 0) {
    return [cleanText];
  }

  return sentences;
};

/**
 * Calculate progress information for speech playback
 */
export const calculateProgress = (
  currentSentenceIndex: number,
  sentences: string[],
  originalText: string
): ProgressUpdate => {
  const totalSentences = sentences.length;
  const completedSentences = Math.max(0, currentSentenceIndex);
  const sentenceProgress =
    totalSentences > 0 ? completedSentences / totalSentences : 0;

  // Calculate character-based progress
  let characterProgress = 0;
  if (originalText && sentences.length > 0) {
    const completedText = sentences.slice(0, currentSentenceIndex).join(' ');
    characterProgress =
      originalText.length > 0 ? completedText.length / originalText.length : 0;
  }

  return {
    sentenceProgress: Math.min(1, Math.max(0, sentenceProgress)),
    characterProgress: Math.min(1, Math.max(0, characterProgress)),
    currentSentence: currentSentenceIndex,
    totalSentences,
    isComplete: currentSentenceIndex >= totalSentences,
  };
};

/**
 * Process text for speech and return structured result
 */
export const processTextForSpeech = (
  text: string
): SentenceProcessingResult => {
  const sentences = splitIntoSentences(text);
  const totalCharacters = text.length;
  const totalSentences = sentences.length;
  const averageSentenceLength =
    totalSentences > 0 ? totalCharacters / totalSentences : 0;

  return {
    sentences,
    totalSentences,
    totalCharacters,
    averageSentenceLength,
    isValid: sentences.length > 0,
  };
};

/**
 * Get the current sentence being spoken
 */
export const getCurrentSentence = (
  sentences: string[],
  currentIndex: number
): string => {
  if (currentIndex >= 0 && currentIndex < sentences.length) {
    return sentences[currentIndex];
  }
  return '';
};

/**
 * Get the next sentence to be spoken
 */
export const getNextSentence = (
  sentences: string[],
  currentIndex: number
): string => {
  const nextIndex = currentIndex + 1;
  if (nextIndex >= 0 && nextIndex < sentences.length) {
    return sentences[nextIndex];
  }
  return '';
};

/**
 * Get the previous sentence
 */
export const getPreviousSentence = (
  sentences: string[],
  currentIndex: number
): string => {
  const prevIndex = currentIndex - 1;
  if (prevIndex >= 0 && prevIndex < sentences.length) {
    return sentences[prevIndex];
  }
  return '';
};

/**
 * Check if there are more sentences to speak
 */
export const hasMoreSentences = (
  sentences: string[],
  currentIndex: number
): boolean => {
  return currentIndex < sentences.length - 1;
};

/**
 * Check if there are previous sentences
 */
export const hasPreviousSentences = (currentIndex: number): boolean => {
  return currentIndex > 0;
};

/**
 * Get estimated speaking time for text (rough calculation)
 * Assumes average speaking rate of ~150 words per minute
 */
export const getEstimatedSpeakingTime = (text: string): number => {
  if (!text) return 0;

  const wordCount = text.trim().split(/\s+/).length;
  const wordsPerMinute = 150; // Average speaking rate
  const minutes = wordCount / wordsPerMinute;

  return Math.ceil(minutes * 60); // Return seconds
};

/**
 * Validate if text is suitable for speech
 */
export const validateTextForSpeech = (
  text: string
): {
  isValid: boolean;
  errors: string[];
} => {
  const errors: string[] = [];

  if (!text || typeof text !== 'string') {
    errors.push('Text must be a non-empty string');
  } else {
    const trimmedText = text.trim();
    if (trimmedText.length === 0) {
      errors.push('Text cannot be empty or only whitespace');
    }
    if (trimmedText.length > 4000) {
      // Max speech input length from constants
      errors.push('Text is too long for speech synthesis');
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};
