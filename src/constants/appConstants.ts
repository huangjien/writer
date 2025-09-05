// Application-wide constants to replace magic numbers and improve code readability

// Timing constants (in milliseconds)
export const TIMING = {
  // Speech and audio delays
  SPEECH_CONTINUE_DELAY: 50,
  CONTENT_LOAD_DELAY: 1000,
  SPEECH_RESTART_DELAY_ANDROID: 200,
  SPEECH_RESTART_DELAY_IOS: 100,
  BACKGROUND_MONITORING_DELAY: 500,
  SPEECH_MONITORING_INTERVAL: 1000,

  // UI and interaction delays
  PROGRESS_RESTART_DELAY: 100,
  TOAST_DELAY: 100,
  DEBOUNCE_DELAY: 300,
  ANIMATION_DURATION: 250,
  TOAST_DURATION: 3000,
  CHAPTER_SWITCH_DELAY: 1000,
  SESSION_TIMEOUT: 1000 * 60 * 60 * 8,
} as const;

// UI constants
export const UI = {
  // Font sizes
  DEFAULT_FONT_SIZE: 16,
  MIN_FONT_SIZE: 12,
  MAX_FONT_SIZE: 24,

  // Safe area and layout
  DEFAULT_SAFE_AREA_TOP: 0,
  DEFAULT_PADDING: 16,
  SMALL_PADDING: 8,
  LARGE_PADDING: 24,

  // Progress and percentage
  PROGRESS_MIN: 0,
  PROGRESS_MAX: 1,
  PERCENTAGE_MAX: 100,
} as const;

// Application settings
export const APP_SETTINGS = {
  // Default language
  DEFAULT_LANGUAGE: 'zh' as const,

  // Storage keys (moved from global.ts for better organization)
  STORAGE_KEYS: {
    ANALYSIS: 'analysis',
    CONTENT: 'content',
    SETTINGS: 'settings',
  } as const,

  // Speech settings
  SPEECH: {
    DEFAULT_RATE: 0.5,
    DEFAULT_PITCH: 1.0,
    MIN_RATE: 0.1,
    MAX_RATE: 2.0,
    MIN_PITCH: 0.5,
    MAX_PITCH: 2.0,
  } as const,
} as const;

// Color shade constants (for use with color palettes)
export const COLOR_SHADES = {
  LIGHTEST: 50,
  LIGHTER: 100,
  LIGHT: 200,
  MEDIUM_LIGHT: 300,
  MEDIUM: 400,
  DEFAULT: 500,
  MEDIUM_DARK: 600,
  DARK: 700,
  DARKER: 800,
  DARKEST: 900,
  // Special charcoal shades
  CHARCOAL_EXTRA_DARK: 850,
  CHARCOAL_DARKEST: 950,
} as const;

// Network and API constants
export const NETWORK = {
  TIMEOUT: 10000, // 10 seconds
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000,
} as const;

// API constants
export const API = {
  GITHUB: {
    API_VERSION: '2022-11-28',
    ACCEPT_HEADER: 'application/vnd.github.v3+json',
    ACCEPT_HEADER_RAW: 'application/vnd.github.v4+raw',
  },
} as const;

// File and content constants
export const CONTENT = {
  MAX_CONTENT_LENGTH: 10000,
  MIN_CONTENT_LENGTH: 10,
  CONTENT_LENGTH_THRESHOLD: 64,
  MAX_SPEECH_INPUT_LENGTH: 4000,
  SENTENCES_PER_CHUNK: 5,
  WORDS_PER_MINUTE_READING: 200,
} as const;

// Export all constants as a single object for convenience
export const CONSTANTS = {
  TIMING,
  UI: {
    ...UI,
    DEFAULT_FONT_SIZE: 16,
    FONT_WEIGHT: {
      MEDIUM: '500',
      SEMI_BOLD: '600',
      HEAVY: '900',
    },
  },
  APP_SETTINGS,
  COLOR_SHADES,
  NETWORK,
  API,
  CONTENT,
} as const;

export default CONSTANTS;
