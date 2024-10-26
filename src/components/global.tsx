import AsyncStorage from '@react-native-async-storage/async-storage';

// components/global.tsx
export const SETTINGS_KEY = '@Settings';
export const CONTENT_KEY = '@Content:';
export const ANALYSIS_KEY = '@Analysis:';
export const STATUS_PLAYING = 'playing';
export const STATUS_PAUSED = 'paused';
export const STATUS_STOPPED = 'stopped';

export const getStoredSettings = AsyncStorage.getItem(SETTINGS_KEY).then(
  (data) => {
    if (data) {
      const parsedData = JSON.parse(data);
      return parsedData;
    }
    return undefined;
  }
);
